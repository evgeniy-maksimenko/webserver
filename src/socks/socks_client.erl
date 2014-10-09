%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 08. окт 2014 19:21
%%%-------------------------------------------------------------------
-module(socks_client).

-export([socks_to_ets/3, send_msg/3, ets_delete/1]).

%% ===================================================================
%% socks functions
%% ===================================================================
socks_to_ets(Pid, Action, Model) ->
  webserver_socks:socks_to_ets(Pid, Action, Model).

send_msg(Message, Action, Model) ->
  webserver_socks:send_msg(Message, Action, Model).

ets_delete(Pid) ->
  webserver_socks:ets_delete(Pid).


