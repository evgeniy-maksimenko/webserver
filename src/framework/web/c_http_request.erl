%%%-------------------------------------------------------------------
%%% @author jeka
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. июл 2014 22:52
%%%-------------------------------------------------------------------
-module(c_http_request).
-author("jeka").

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
  {ok, _} = cowboy_req:reply(303, [
    {<<"location">>, Url}
  ], Req).

post(URL, ContentType, Body) -> request(post, {URL, [], ContentType, Body}).
get(URL)                     -> request(get,  {URL, []}).

request(Method, Body) ->
  httpc:request(Method, Body, [], []).

response_body({ok, { _, _, Body}}) -> Body.
