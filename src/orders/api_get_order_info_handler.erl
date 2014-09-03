%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 22. июл 2014 14:07
%%%-------------------------------------------------------------------
-module(api_get_order_info_handler).
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
      AccessToken = app:getCookie(<<"access_token">>,Req),
      Validate = case cowboy_req:qs_val(<<"wo-oid">>, Req) of
        {Echo, _} -> Echo
       end,
      Res = orders_module:getOrderInfo(Req, binary_to_list(Validate)),
      NewResult= jsx:decode(Res) ++ [{<<"access_token">>, AccessToken}],
      {200, NewResult}
    catch
      _ : Reason -> ?LOG_ERROR("TAG ~p", [Reason]),
      {400, <<"Missing echo parameters.">>}
    end,

  {ok, Req3} = cowboy_req:reply(Code, [
   {<<"content-type">>, <<"application/json">>}

  ], jsx:encode(Result), Req),
  {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
  ok.