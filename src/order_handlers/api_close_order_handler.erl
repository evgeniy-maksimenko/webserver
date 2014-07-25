%%%-------------------------------------------------------------------
%%% @author Admin
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. июл 2014 09:57
%%%-------------------------------------------------------------------
-module(api_close_order_handler).
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
  {[ {<<"id">> , Id} , {<<"solution">> , Solution}| _], _} = cowboy_req:qs_vals(Req),
  Result = orders_module:closeOrder(Req, binary_to_list(Id), binary_to_list(Solution)),
  {ok, Req2} = cowboy_req:reply(200, [
    {<<"content-type">>, <<"application/json">>}
  ], jsx:encode([{<<"status">>,Result}]), Req),
  {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
  ok.