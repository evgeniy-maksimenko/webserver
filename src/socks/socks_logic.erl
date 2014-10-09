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
-export([to_ets/4, send_msg/4, ets_delete/2]).

to_ets(Pid, Action, Model, Tab) ->
  ets:insert(Tab, {Pid, Action, Model}).

send_msg(Message, Action, Model, Tab) ->
  bang(ets:first(Tab), Action, Message, Model, Tab).

bang('$end_of_table', _Action, _Message, _Model, _Tab) -> ok;
bang(Firts, Action, Message, Model, Tab) ->
  case ets:lookup(Tab, Firts) of
    [{Pid, _, Model}] ->
      Pid ! {json, jsx:encode(Message)};
    _ ->
      ok
  end,
  bang(ets:next(Tab, Firts), Action, Message, Model, Tab).

ets_delete(Tab, Pid) ->
  ets:delete(Tab, Pid).