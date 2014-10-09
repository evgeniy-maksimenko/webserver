%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 08. окт 2014 15:53
%%%-------------------------------------------------------------------
-module(webserver_socks).
-behaviour(gen_server).

-include("../logs.hrl").

-record(state, {
  tab
}).

%% API
-export([start_link/1, stop/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([socks_to_ets/3, send_msg/3, ets_delete/1]).


%% ===================================================================
%% client functions
%% ===================================================================

start_link({ets_tab, Name}) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [{ets_tab, Name}], []).

stop() ->
  gen_server:cast(?MODULE, stop).

socks_to_ets(Pid, Action, Model)->
  gen_server:call(?MODULE, {to_ets, Pid, Action, Model}).

send_msg(Message, Action, Model)->
  gen_server:cast(?MODULE, {send_msg, Message, Action, Model}).

ets_delete(Pid) ->
  gen_server:cast(?MODULE, {ets_delete, Pid}).

%% ===================================================================
%% callback functions
%% ===================================================================
init([{ets_tab, Name}]) ->
  {ok, #state{tab = Name}}.

handle_call({to_ets, Pid, Action, Model}, _From, State) ->
  {reply, socks_logic:to_ets(Pid, Action, Model, State#state.tab), State};

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast({ets_delete, Pid}, State) ->
  socks_logic:ets_delete(State#state.tab, Pid),
  {noreply, State};

handle_cast({send_msg, Message, Action, Model}, State) ->
  socks_logic:send_msg(Message, Action, Model, State#state.tab),
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
