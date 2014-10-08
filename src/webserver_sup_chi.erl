%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 08. окт 2014 15:47
%%%-------------------------------------------------------------------
-module(webserver_sup_chi).
-behaviour(supervisor).

-record(state, {
  tab = socks
}).

%% API
-export([init/1]).
-export([start_link/0]).

init([])->
  S = #state{},
  ets:new(S#state.tab, [named_table, public, set]),

  Flags = {one_for_one, 5, 10},
  WebserverSocks = {webserver_socks, {webserver_socks, start_link, [{ets_tab, S#state.tab}]}, permanent, 10500, worker, [webserver_socks]},
  {ok, { Flags, [WebserverSocks]}}.

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).


