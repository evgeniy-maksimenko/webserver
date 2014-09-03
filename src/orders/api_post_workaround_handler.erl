%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 03. сен 2014 08:45
%%%-------------------------------------------------------------------
-module(api_post_workaround_handler).
-behaviour(cowboy_http_handler).
-include("../logs.hrl").

%% API
-export([
  init/3,
  handle/2,
  terminate/3,
  http_post/3,
  make_out/2
]).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

handle(Req, State) ->
  {Method, Req2} = cowboy_req:method(Req),
  HasBody = cowboy_req:has_body(Req2),
  {ok, Req3} = http_post(Method, HasBody, Req2),
  {ok, Req3, State}.

http_post(<<"POST">>, true, Req) ->
  {ok, PostAttrs, Req2} = cowboy_req:body_qs(Req),
  make_out(PostAttrs,Req2);

http_post(<<"POST">>, false, Req) ->
  cowboy_req:reply(400, [], <<"Missing body.">>, Req);

http_post(_, _, Req) ->
  cowboy_req:reply(405, Req).

make_out(undefined, Req) ->
  cowboy_req:reply(400, [], <<"Missing echo parameter.">>, Req);

make_out(PostAttrs, Req) ->
  orders_module:postWorkaroundOrder(Req, PostAttrs),
  cowboy_req:reply(200, [
    {<<"content-type">>, <<"application/json">>}
  ], jsx:encode([{<<"status">>,<<"ok">>}]), Req).

terminate(_Reason, _Req, _State) ->
  ok.