%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 30. сен 2014 15:51
%%%-------------------------------------------------------------------
-module(tms).
-include("../logs.hrl").
-include("../../include/config.hrl").

%% API
-export([
  find/3,
  find_admin/3,
  save/3,
  inWork/2,
  send_mail/2,
  update_level/3,
  tc/1,
  static/0,
  mongo_find/1,
  rating_static/1,
  delete/2
]).

-record(mongo_db,{
  table = model,
  collection = "treatment"
}).

save(PostAttrs, AllBindings, Req) ->

  List = [<<"opened_at">>, <<"opened_by">>, <<"working">>],

  case proplists:get_value(<<"status">>, PostAttrs) of
    <<"1lvl">> ->
      update_level(PostAttrs, List, AllBindings);
    <<"2lvl">> ->
      update_level(PostAttrs, List, AllBindings);
    <<"OK">> ->
%%        {ok, Req2} = send_mail(AllBindings, Req),
      emongo:update(model, "treatment", [{<<"id">>, proplists:get_value(<<"id">>, AllBindings)}], lists:merge(
        PostAttrs,
        [
          {<<"modified_at">>, erlydtl_dateformat:format(erlang:localtime(), "Y-m-d H:i:s")},
          {<<"author_login">>, app_logic:getting_user(Req)},
          {<<"rating">>, 0},
          {<<"rating_at">>, <<"">>}
        ]
      ))
  end,
  <<"{\"status\":\"ok\"}">>.

find(AllBindings, false, _Req) ->

  Find = emongo:find(model, "treatment", [{<<"status">>, proplists:get_value(<<"status">>, AllBindings)}]),
  Data = tm_module:remove_id_mongo(Find),
  Data;

find(Id, true, Req) ->

  Find = emongo:find(model, "treatment", [{"id", Id}]),
  Data = tm_module:remove_id_mongo(Find),

  OpenedBy = proplists:get_value(<<"opened_by">>, lists:merge(Data)),
  Login = list_to_binary(app_logic:getting_user(Req)),

  Result =
    case OpenedBy =:= Login of
      true ->
        Data;
      false ->
        <<"Forbidden">>
    end,
  Result.

find_admin(Id, true, _Req) ->
  Find = emongo:find(model, "treatment", [{"id", Id}]),
  Data = tm_module:remove_id_mongo(Find),
  Data.

rating_static(AllBindings) ->
  Find = emongo:find(model, "treatment", [{"rating", proplists:get_value(<<"rating">>, AllBindings)}]),
  Data = tm_module:remove_id_mongo(Find),
  Data.

delete(AllBindings, _Req) ->
  emongo:delete(model, "treatment", [{"id", proplists:get_value(<<"id">>, AllBindings)}]),
  <<"{\"status\":\"ok\"}">>.


inWork(Id, Req) ->
  DataIn = emongo:find(model, "treatment", [{<<"id">>,Id}]),
  Data = tm_module:remove_id_mongo(DataIn),

  List = lists:merge(
    lists:delete({<<"working">>, <<"0">>}, lists:merge(Data)),
    [
      {<<"opened_at">>, erlydtl_dateformat:format(erlang:localtime(), "Y-m-d H:i:s")},
      {<<"opened_by">>, app_logic:getting_user(Req)},
      {<<"working">>, 1}
    ]
  ),

    emongo:update(model, "treatment", [{<<"id">>, Id}], List),
  <<"{\"status\":\"ok\"}">>.

send_mail(AllBindings, Req) ->

  {Host, Req1} = cowboy_req:host(Req),
  ADDRESS = binary_to_list(Host) ++ "/tm_view/response/" ++ binary_to_list(proplists:get_value(<<"id">>, AllBindings)),

  BODY = <<?MAIL_BODY/utf8>>,
  List = <<"'>ссылке</a>.</p>"/utf8>>,

  ANSWER = binary_to_list(BODY) ++ ADDRESS ++ binary_to_list(List),
  BILL = list_to_binary(ANSWER),


  DataIn = emongo:find(model, "treatment", [{"id", proplists:get_value(<<"id">>, AllBindings)}]),
  Data = tm_module:remove_id_mongo(DataIn),

  Email = binary_to_list(proplists:get_value(<<"email">>, lists:merge(Data))),

  mailer:send(Email, <<"Обращение в Помощь Онлайн."/utf8>>, BILL),
  {ok, Req1}.

update_level(PostAttrs, List, AllBindings) ->
  ListLVL = [{K, V} || {K, V} <- PostAttrs, not lists:member(K, List)],
  emongo:update(model, "treatment", [{<<"id">>, proplists:get_value(<<"id">>, AllBindings)}], lists:merge(
    ListLVL,
    [
      {<<"working">>, 0}
    ]
  )).

static() ->
  Count = length(mongo_find([])),
  Made  = length(mongo_find([{<<"status">>, <<"OK">>}])),
  RtgGd = length(mongo_find([{<<"rating">>, <<"1">>}])),
  RtgBd = length(mongo_find([{<<"rating">>, <<"2">>}])),
  RtgEs = length(mongo_find([{<<"rating">>, <<"3">>}])),
  [{<<"count">>, Count}, {<<"made">>, Made}, {<<"rating_gd">>, RtgGd},{<<"rating_bd">>, RtgBd},{<<"rating_es">>, RtgEs}].

tc([]) ->
  [].

mongo_find(Condition) ->
  M = #mongo_db{},
  tm_module:remove_id_mongo(emongo:find(M#mongo_db.table, M#mongo_db.collection, Condition)).