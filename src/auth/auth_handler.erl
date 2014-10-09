%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 17. июл 2014 13:49
%%%-------------------------------------------------------------------
-module(auth_handler).
-behaviour(cowboy_http_handler).
-author("Evgenij.Maksimenko").
-include("../logs.hrl").
-include("../../include/config.hrl").

%% API
-export([
  init/3,
  handle/2,
  terminate/3,
  getResponse/1,
  getAuthPage/1,
  getToken/1
]).

-define(REDIRECT_HOME, "/").

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

%% Заметка, возможно проблема с кодировкой
%% Решение unicode:characters_to_binary([Body])

handle(Req, _State) ->
  {Echo, Req2} = cowboy_req:qs_val(<<"code">>, Req),
  AccessToken = getResponse(Echo),
  Req4 = cowboy_req:set_resp_cookie(<<"access_token">>, AccessToken, [{path, <<"/">>}, {max_age, 3600}], Req2),
  c_http_request:redirect(?REDIRECT_HOME, Req4).

terminate(_Reason, _Req, _State) ->
  ok.

%% ===================================================================
%% ШАГ 1
%% Редирект (HTTP 302) на страницу аутентификации
%% ===================================================================
getAuthPage(Req) ->
  {Path, Req2} = cowboy_req:path(Req),
  PageName     = re:split(Path, "/", [{return, list}]),

  E = #pagesExceptions{},
  PageException   = lists:nth(2, PageName),

  case lists:member(PageException, E#pagesExceptions.list) of
    true ->
      Req2;
    false ->
      AccessToken = app_logic:getCookie(<<"access_token">>, Req2),
      case AccessToken of
        undefined ->
          c_http_request:redirect(?POINT_AUTH ++ "?client_id=" ++ ?CLIENT_ID ++ "&scope=read&response_type=code&state=enter&redirect_uri=" ++ ?REDIRECT_URI, Req2);
        AccessToken ->
          Req2
      end
  end.

%% ===================================================================
%% ШАГ 2
%% Ответ сайта аутентификации браузеру
%% ===================================================================
getResponse(Echo) when is_binary(Echo)->
  Auth = base64:encode_to_string(?CLIENT_ID ++ ":" ++ ?SECRET),
  Response = httpc:request(post,
    {?POINT_RECEIPT_TOKEN,
      [{"Authorization", "Basic " ++ Auth}],
      "application/x-www-form-urlencoded",
        "grant_type=authorization_code&code=" ++ binary_to_list(Echo) ++ "&nonce=UNIQUE_RANDOM_STRING&redirect_uri=" ++ ?REDIRECT_URI
    }, [], []),
  Body = c_http_request:response_body(Response),
  getToken(Body).

%% ===================================================================
%% ШАГ 3
%% Ответ сервера аутентификации
%% ===================================================================
getToken(Body) ->
  case jsx:is_json(list_to_binary(Body)) of
    true ->
      Decode = jsx:decode(list_to_binary(Body)),
      case proplists:is_defined(<<"access_token">>, Decode) of
        true ->
          proplists:get_value(<<"access_token">>, Decode);
        false -> lager:log(error, [], ["access_token not find"])
      end;
    false -> lager:log(error, [], [false])
  end.











