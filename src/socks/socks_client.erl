%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 08. окт 2014 19:21
%%%-------------------------------------------------------------------
-module(socks_client).

-export([add_socks/3, broadcast/3, remove_socks/1]).

%% ===================================================================
%% socks functions
%% ===================================================================
add_socks(Pid, Action, Model) ->
  socks_manager:add_socks(Pid, Action, Model).

broadcast(Message, Action, Model) ->
  socks_manager:broadcast(Message, Action, Model).

remove_socks(Pid) ->
  socks_manager:remove_socks(Pid).


