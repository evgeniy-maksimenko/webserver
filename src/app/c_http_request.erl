%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 16. июл 2014 22:52
%%%-------------------------------------------------------------------
-module(c_http_request).
-include("../logs.hrl").
%% API
-export([
  redirect/2,
  post/3,
  get/1,
  response_body/1
]).

%% Редирект на необходимую страницу
%% Url
%% Req - request

redirect(Url, Req) ->
  {ok, Req1} = cowboy_req:reply(303, [
    {<<"location">>, list_to_binary(Url)}
  ], Req),
  Req1.

post(URL, ContentType, Body) -> request(post, {URL, [], ContentType, Body}).
get(URL)                     -> request(get,  {URL, []}).

request(Method, Body) ->
  httpc:request(Method, Body, [], []).

response_body({ok, { {_, _, Status}, _, Body}}) ->
  Result =
    try
      Res =
        case Status of
          "OK" -> Body;
          "Unauthorized" -> ?LOG_ERROR("TAG ~p", ["Unauthorized"])
        end,
      Res
    catch
      _ : Reason -> ?LOG_ERROR("TAG ~p", [Reason])
    end,
  Result.

