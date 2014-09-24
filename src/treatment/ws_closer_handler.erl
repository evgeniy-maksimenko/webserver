%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 12. сен 2014 09:12
%%%-------------------------------------------------------------------
-module(ws_closer_handler).
-behaviour(cowboy_websocket_handler).
-include("../logs.hrl").

%% API
-export([
  init/3,
  websocket_init/3,
  websocket_handle/3,
  websocket_info/3,
  websocket_terminate/3
]).

init({tcp, http}, _Req, _Opts) ->
  {upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
  ets:insert(treatments_closer,{self(),self()}),
  {ok, Req, undefined_state}.

websocket_handle({text, Msg}, Req, State) ->
  TreatmentList = ets:tab2list(treatments_closer),
  lists:foreach(fun(ListIn)->
    {Pid, _} = ListIn,
    Pid ! {json, Msg} end, TreatmentList),
  {ok, Req, State};
websocket_handle(_Data, Req, State) ->
  {ok, Req, State}.

websocket_info({timeout, _Ref, Msg}, Req, State) ->
  {reply, {text, Msg}, Req, State};
websocket_info({json, Msg}, Req, State) ->
  {reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
  {ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
  ets:delete(treatments_closer, self()),
  ok.
