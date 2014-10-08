-module(webserver_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
  Flags = {one_for_one, 5, 10},
  WebserverSupChi = {webserver_sup_chi, {webserver_sup_chi, start_link, []}, permanent, 10500, supervisor, [webserver_sup_chi]},
  {ok, {Flags, [WebserverSupChi]}}.

