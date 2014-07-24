%%%-------------------------------------------------------------------
%%% @author Admin
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. июл 2014 14:07
%%%-------------------------------------------------------------------
-module(api_set_order_work_handler).
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
  {[ {<<"oid">> , Oid} , {<<"workgroup">> , Workgroup}| _], _} = cowboy_req:qs_vals(Req),
  Result = orders_module:setOrderWork(Req, binary_to_list(Oid), binary_to_list(Workgroup)),
    {ok, Req2} = cowboy_req:reply(200, [
      {<<"content-type">>, <<"application/json">>}
  ], jsx:encode([{<<"status">>,Result}]), Req),
  {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
  ok.