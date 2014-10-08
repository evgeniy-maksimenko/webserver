%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 08. окт 2014 09:47
%%%-------------------------------------------------------------------
-module(test_handler).
-behaviour(cowboy_http_handler).
-include("logs.hrl").
-include("../include/config.hrl").

%% API
%% API
-compile(export_all).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

handle(Req, State) ->
  ets:insert(treatments,{self(),self()}),
  TreatmentList = ets:tab2list(treatments),
%%   lists:foreach(fun(ListIn)-> {Pid, _} = ListIn, io:format("pid: ~p ~n", [Pid]) end, TreatmentList),

  ?LOG_INFO("tab2list = ~p~n",[timer:tc(fun tc_tab2list/0)]),
  ?LOG_INFO("foreach = ~p~n",[timer:tc(fun tc_foreach/1, [TreatmentList])]),
  ?LOG_INFO("match = ~p~n",[timer:tc(fun tc_match/0)]),

  ListMatch = tc_match(),
  ?LOG_INFO("recursion_match = ~p~n",[timer:tc(fun tc_recursion/1, [ListMatch])]),
  First = tc_first(),
  ?LOG_INFO("next = ~p~n",[timer:tc(fun tc_recursion_next/1, [First])]),

  {ok, Req2} = cowboy_req:reply(200, [], [], Req),
  {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
  ok.

tc_tab2list()->
  ets:tab2list(treatments).

tc_foreach(TreatmentList) ->
  lists:foreach(fun(ListIn)-> {Pid, _} = ListIn, Pid end, TreatmentList).

tc_match()->
  ets:match(treatments, {'_','$2'}).

tc_recursion(List)-> tc_recursion(List, []).
tc_recursion([], Acc) ->
  Acc;
tc_recursion([H | T], Acc) ->
  [Pid] = H,
  tc_recursion(T, [Pid | Acc]).

tc_first() ->
  ets:first(treatments).

tc_next(First) ->
  ets:next(treatments, First).

tc_recursion_next('$end_of_table') -> ok;
tc_recursion_next(Firts) ->
  tc_recursion_next(ets:next(treatments, Firts)).



