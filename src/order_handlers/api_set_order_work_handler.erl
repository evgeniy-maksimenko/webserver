%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 22. июл 2014 14:07
%%%-------------------------------------------------------------------
-module(api_set_order_work_handler).
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
      {NewOid, NewWg} =
        case cowboy_req:qs_vals(Req) of
          {[ {<<"oid">> , Oid} , {<<"workgroup">> , Workgroup}| _], _} -> {Oid, Workgroup};
          _ -> mossing_echo_params
        end,
      Res = orders_module:setOrderWork(Req, binary_to_list(NewOid), binary_to_list(NewWg)),
      {200,Res}
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