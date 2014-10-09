%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 22. июл 2014 14:31
%%%-------------------------------------------------------------------
-module(orders_module).
-include("../logs.hrl").
-include("../../include/config.hrl").
%% API
-export([
  getAllOrders/2,
  getOrderInfo/2,
  getOrderFile/4,
  setOrderWork/3,
  closeOrder/2,
  postWorkaroundOrder/2
]).



%%-------------------------------
%% Cервис "Взятие в работу"
%%-------------------------------
setOrderWork(Req, Oid, Workgroup) ->
  AccessToken = app_logic:getCookie(<<"access_token">>, Req),
  % URL = ?ORDER_WORK++"?wo-oid="++Oid++"&workgroup="++Workgroup++"&access_token="++binary_to_list(AccessToken),
  % Response = c_http_request:get(URL),
  % lager:log(info, [], Response),
  emongo:insert(model, "history",
    [
      {<<"created_at">>, erlydtl_dateformat:format(erlang:localtime(), "Y-m-d")},
      {<<"author_login">>, proplists:get_value(<<"login">>, app_logic:personality(Req))},
      {<<"author_fullName">>, proplists:get_value(<<"fullName">>, app_logic:personality(Req))},
      {<<"status">>,<<"inwork">>},

      {<<"wo-oid">>, Oid},
      {<<"workgroup">>, Workgroup}
    ]
  ),
  true.

%%-------------------------------
%% Cервис "Временное решение"
%%-------------------------------
postWorkaroundOrder(Req, PostAttrs) ->
  AccessToken = app_logic:getCookie(<<"access_token">>, Req),
  httpc:request(post,
    {?ORDER_WORKAROUND,
      [],
      "application/x-www-form-urlencoded",
        "workgroup=" ++ binary_to_list(proplists:get_value(<<"workgroup">>, PostAttrs)) ++ "&workaround=" ++ binary_to_list(proplists:get_value(<<"workaround">>, PostAttrs)) ++ "&wo-oid=" ++ binary_to_list(proplists:get_value(<<"wo-oid">>, PostAttrs)) ++ "&access_token=" ++ binary_to_list(AccessToken)
    }, [], []),

  emongo:insert(model, "history", lists:merge(
    PostAttrs,
    [
      {<<"created_at">>, erlydtl_dateformat:format(erlang:localtime(), "Y-m-d")},
      {<<"author_login">>, proplists:get_value(<<"login">>, app_logic:personality(Req))},
      {<<"author_fullName">>, proplists:get_value(<<"fullName">>, app_logic:personality(Req))},
     {<<"status">>,"workaround"}
    ]
  )),
  true.

%%-------------------------------
%% Cервис "Закрытие ордера"
%%-------------------------------
closeOrder(Req, PostAttrs) ->

  RequestorList = proplists:get_value(<<"requestor">>, PostAttrs),
  Requestor = jsx:decode(app_logic:getUserContacts(Req, RequestorList)),

  emongo:insert(model, "records", lists:merge(
    PostAttrs,
    [
      {<<"created_at">>, erlydtl_dateformat:format(erlang:localtime(), "Y-m-d")},
      {<<"author_login">>, proplists:get_value(<<"login">>, app_logic:personality(Req))},
      {<<"author_fullName">>, proplists:get_value(<<"fullName">>, app_logic:personality(Req))},
      {<<"requestor_login">>, proplists:get_value(<<"login">>, Requestor)},
      {<<"requestor_fullName">>, proplists:get_value(<<"fullName">>, Requestor)}
    ]
  )),

  emongo:insert(model, "history", lists:merge(
    PostAttrs,
    [
      {<<"created_at">>, erlydtl_dateformat:format(erlang:localtime(), "Y-m-d")},
      {<<"author_login">>, proplists:get_value(<<"login">>, app_logic:personality(Req))},
      {<<"author_fullName">>, proplists:get_value(<<"fullName">>, app_logic:personality(Req))},
      {<<"status">>,<<"closed">>}
    ]
  )),


%%   emongo:insert(model, "records", PostAttrs),
%%   Answer = <<"<br/>Мы ответили на Ваш вопрос <a href=\"http://localhost:8008/order/answer?id=1&status=1\">Да</a>&nbsp;<a href=\"http://localhost:8008/order/answer?id=1&status=0\">Нет</a>">>,
%%
%%   SignedBody = c_mail:signed_body(<<"test">>,<<"test">>,<<"test">>, list_to_binary(Solution++binary_to_list(Answer))),
%%   c_mail:send(SignedBody, "siemenspromaster@gmail.com","siemenspromaster@gmail.com"),

  AccessToken = app_logic:getCookie(<<"access_token">>, Req),
%%   Response = httpc:request(post,
%%     {?ORDER_CLOSE,
%%       [],
%%       "application/x-www-form-urlencoded",
%%       "wo-oid="++RecordId++"&wo-solution="++Solution++"&wo-workgroup=281518223917264&wo-close-code=3095134405&wo-back-cause=0&wo-subject=-1&access_token="++binary_to_list(AccessToken)
%%     }, [], []),
  true.

%%-------------------------------
%% Cервис "Скачать файл"
%%-------------------------------
getOrderFile(Req, Oid, FileName, ScOid) ->
  AccessToken = app_logic:getCookie(<<"access_token">>, Req),
  URL = ?ORDER_FILE ++ binary_to_list(Oid) ++ "?fileName=" ++ FileName ++ "&sc_oid=" ++ binary_to_list(ScOid) ++ "&access_token=" ++ binary_to_list(AccessToken),
  Response = c_http_request:get(URL),

  emongo:insert(model, "history",
    [
      {<<"created_at">>, erlydtl_dateformat:format(erlang:localtime(), "Y-m-d")},
      {<<"author_login">>, proplists:get_value(<<"login">>, app_logic:personality(Req))},
      {<<"author_fullName">>, proplists:get_value(<<"fullName">>, app_logic:personality(Req))},
      {<<"status">>,<<"download">>},

      {<<"wo-oid">>, Oid},
      {<<"filename">>, FileName},
      {<<"sc-oid">>, ScOid}
    ]
  ),
  Response.

%%-------------------------------
%% Cервис "Получение списка ордеров"
%%-------------------------------
getAllOrders(Req, List) ->
  AccessToken = app_logic:getCookie(<<"access_token">>, Req),

  Response =
    case proplists:is_defined(<<"fromDate">>, List) of
      false ->
        c_http_request:get(
          ?ALL_ORDERS ++
            "?status=" ++ binary_to_list(proplists:get_value(<<"status">>, List)) ++
            "&destinate=" ++ binary_to_list(proplists:get_value(<<"destinate">>, List)) ++
            "&access_token=" ++ binary_to_list(AccessToken));
      true ->
        c_http_request:get(
          ?ALL_ORDERS ++
            "?status=" ++ binary_to_list(proplists:get_value(<<"status">>, List)) ++
            "&destinate=" ++ binary_to_list(proplists:get_value(<<"destinate">>, List)) ++
            "&fromDate=" ++ binary_to_list(proplists:get_value(<<"fromDate">>, List)) ++
            "&toDate=" ++ binary_to_list(proplists:get_value(<<"toDate">>, List)) ++
            "&access_token=" ++ binary_to_list(AccessToken))
    end,

  Body = c_http_request:response_body(Response),
  Result = list_to_binary(Body),
  AaData = proplists:get_value(<<"aaData">>, jsx:decode(Result)),
  jsx:encode(AaData).

%%-------------------------------
%% Cервис "Получение детальное информации об ордере"
%%-------------------------------
getOrderInfo(Req, OrderId) ->
  AccessToken = app_logic:getCookie(<<"access_token">>, Req),
  Response = c_http_request:get(?ORDER_INFO ++ "?wo-oid=" ++ OrderId ++ "&access_token=" ++ binary_to_list(AccessToken)),
  Body = c_http_request:response_body(Response),
  Result = list_to_binary(Body),
  Result.

