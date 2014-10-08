%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 08. окт 2014 19:21
%%%-------------------------------------------------------------------
-module(socks_client).

-export([socks_to_ets/4, send_msg/4]).

%% ===================================================================
%% socks functions
%% ===================================================================
socks_to_ets(Pid, Action, Model, Module) ->
  webserver_socks:socks_to_ets(Pid, Action, Model, Module).

send_msg(Message, Action, Model, Module) ->
  webserver_socks:send_msg(Message, Action, Model, Module).
