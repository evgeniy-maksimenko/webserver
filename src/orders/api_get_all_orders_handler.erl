%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 22. июл 2014 14:07
%%%-------------------------------------------------------------------
-module(api_get_all_orders_handler).
-behaviour(cowboy_http_handler).
-include("../logs.hrl").

%% API
-export([
  init/3,
  handle/2,
  terminate/3
]).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

handle(Req, State) ->
  {GetList, _}  = cowboy_req:qs_vals(Req),
  {Code, Result} =
    try
      Res = orders_module:getAllOrders(Req, GetList),
      {200, Res}
    catch
      _ : Reason -> ?LOG_ERROR("TAG ~p", [Reason]),
      {400, <<"Missing echo parameters.">>}
    end,

  {ok, Req2} = cowboy_req:reply(Code, [
    {<<"content-type">>, <<"application/json">>}
  ], Result, Req),

  {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
  ok.