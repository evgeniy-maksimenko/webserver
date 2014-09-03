%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 18. июл 2014 14:55
%%%-------------------------------------------------------------------
-module(app).
-author("Evgenij.Maksimenko").
-include("../logs.hrl").

-define(SERVER, "https://promin-stage.it.loc/").
-define(URL, "https://itsmtest.it.loc").
-define(DT_INFO, ?URL ++ "/tech/rest/dt_info/").

%% API
-export([
  getCookie/2,
  getting_user/1,
  personality/1,
  getUserContacts/2
]).

getCookie(Name, Req) ->
  {Cookie, _} = cowboy_req:cookie(Name, Req),
  Cookie.

%%----------------------------------
%% Получение ldap login пользователя
%%----------------------------------
getting_user(Req) ->
  AccToken = app:getCookie(<<"access_token">>, Req),

  Response = httpc:request(get,
    {?SERVER++"ProminShell/user/get?format=json",
      [
        {"Authorization", "Bearer " ++ binary_to_list(AccToken)},
        {"Accept", "application/json"},
        {"Content-Type", "application/x-www-form-urlencoded"}
      ]
    }, [], []),
  Body = c_http_request:response_body(Response),

  BodyList = re:split(Body, "[\"]", [{return, list}]), %TODO переписать
  [_, _, _, Ldap|_] = BodyList,

  Ldap.

%%---------------------------------------------------
%% Получение данных зарегистрированного пользователя
%%---------------------------------------------------
personality(Req) ->
  Data = jsx:decode(getUserContacts(Req, undefined)),
  Data.

%%--------------------------------------------------
%% Получение детальной информации о владельце сессии
%%--------------------------------------------------
getUserContacts(Req, _Login) ->

  Ldap =
    case _Login of
      undefined -> getting_user(Req);
      _ -> binary_to_list(_Login)
    end,


  AccessToken = app:getCookie(<<"access_token">>, Req),
  URL = ?DT_INFO ++ Ldap ++ ".json?access_token=" ++ binary_to_list(AccessToken),
  Response = c_http_request:get(URL),
  Body = c_http_request:response_body(Response),
  Result = list_to_binary(Body),
  Result.
