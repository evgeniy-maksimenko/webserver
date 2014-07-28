%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 25. июл 2014 09:57
%%%-------------------------------------------------------------------
-module(api_close_order_handler).
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
  {Code, Result} =
    try
      {IdValid, SoulutionValid} =
        case cowboy_req:qs_vals(Req) of
          {[ {<<"id">> , Id} , {<<"solution">> , Solution}| _], _} -> {Id, Solution};
          _ -> throw
        end,
      Res = orders_module:closeOrder(Req, binary_to_list(IdValid), binary_to_list(SoulutionValid)),
      {200, Res}
    catch
      _ : Reason -> ?LOG_ERROR("TAG ~p", [Reason]),
        {400, <<"Missing echo parameters.">>}
    end,

  {ok, Req2} = cowboy_req:reply(Code, [
    {<<"content-type">>, <<"application/json">>}
  ], jsx:encode([{<<"status">>,Result}]), Req),

  {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
  ok.