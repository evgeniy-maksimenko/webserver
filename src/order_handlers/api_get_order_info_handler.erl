%%%-------------------------------------------------------------------
%%% @author Admin
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. июл 2014 14:07
%%%-------------------------------------------------------------------
-module(api_get_order_info_handler).
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
  AccessToken = c_application:getCookie(<<"access_token">>,Req),

  {Echo, Req2} = cowboy_req:qs_val(<<"wo-oid">>, Req),
  Result = orders_module:getOrderInfo(Req, binary_to_list(Echo)),
  NewResult= jsx:decode(Result) ++ [{<<"access_token">>,AccessToken}],
    {ok, Req3} = cowboy_req:reply(200, [
    {<<"content-type">>, <<"application/json">>}
  ], jsx:encode(NewResult), Req2),
  {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
  ok.