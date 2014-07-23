%%%-------------------------------------------------------------------
%%% @author Admin
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. июл 2014 14:07
%%%-------------------------------------------------------------------
-module(api_get_all_orders_handler).
-behaviour(cowboy_http_handler).

%% API
-export([
  init/3,
  handle/2,
  terminate/3
]).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

handle(Req, State) ->
  {[ {<<"status">> , Status} , {<<"destinate">> , Destinate}| _], _} = cowboy_req:qs_vals(Req),
  Result = orders_module:getAllOrders(Req, binary_to_list(Status), binary_to_list(Destinate)),
    {ok, Req2} = cowboy_req:reply(200, [
    {<<"content-type">>, <<"application/json">>}
  ], Result, Req),
  {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
  ok.