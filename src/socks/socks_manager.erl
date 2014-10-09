%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 08. окт 2014 15:53
%%%-------------------------------------------------------------------
-module(socks_manager).
-behaviour(gen_server).

-include("../logs.hrl").

-record(state, {
  tab
}).

%% API
-export([start_link/1, stop/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([add_socks/3, broadcast/3, remove_socks/1]).


%% ===================================================================
%% client functions
%% ===================================================================

start_link({ets_tab, Name}) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [{ets_tab, Name}], []).

stop() ->
  gen_server:cast(?MODULE, stop).

add_socks(Pid, Action, Model)->
  gen_server:call(?MODULE, {add_socks, Pid, Action, Model}).

broadcast(Message, Action, Model)->
  gen_server:cast(?MODULE, {broadcast, Message, Action, Model}).

remove_socks(Pid) ->
  gen_server:cast(?MODULE, {remove_socks, Pid}).

bang('$end_of_table', _Action, _Message, _Model, _Tab) -> ok;
bang(Firts, Action, Message, Model, Tab) ->
  case ets:lookup(Tab, Firts) of
    [{Pid, _, Model}] ->
      Pid ! {json, jsx:encode(Message)};
    _ ->
      ok
  end,
  bang(ets:next(Tab, Firts), Action, Message, Model, Tab).
%% ===================================================================
%% callback functions
%% ===================================================================
init([{ets_tab, Name}]) ->
  {ok, #state{tab = Name}}.

handle_call({add_socks, Pid, Action, Model}, _From, State) ->
  {reply, ets:insert(State#state.tab, {Pid, Action, Model}), State};

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast({remove_socks, Pid}, State) ->
  ets:delete(State#state.tab, Pid),
  {noreply, State};

handle_cast({broadcast, Message, Action, Model}, State) ->
  bang(ets:first(State#state.tab), Action, Message, Model, State#state.tab),
  {noreply, State};

handle_cast(_request, State) ->
  {noreply, State}.

handle_info(Info, State) ->
  {noreply, Info, State}.

terminate(_Reason, _State) ->
  io:format("terminating ~p ~p ~n",[{local, ?MODULE}, _Reason]),
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
