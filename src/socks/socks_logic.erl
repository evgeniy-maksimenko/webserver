%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 08. окт 2014 16:45
%%%-------------------------------------------------------------------
-module(socks_logic).
-include("../logs.hrl").

%% API
-export([to_ets/5, send_msg/5]).

to_ets(Pid, Action, Model, Module, Tab) ->
  ets:insert(Tab, {Pid, Action, Model, Module}).

send_msg(Message, Action, Model, Module, Tab) ->
  bang(ets:first(Tab), Action, Message, Model, Module, Tab).

bang('$end_of_table', _Action, _Message, _Model, _Module, _Tab) -> ok;
bang(Firts, Action, Message, Model, Module, Tab) ->
  case ets:lookup(Tab, Firts) of
    [{Pid, Action, Model, Module}] ->
      ?LOG_INFO("~p~n", [Pid, Message]);
    _ ->
      ok
  end,
  bang(ets:next(Tab, Firts), Action, Message, Model, Module, Tab).

