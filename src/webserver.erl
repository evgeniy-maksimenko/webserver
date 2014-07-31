%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 16. июл 2014 21:07
%%%-------------------------------------------------------------------
-module(webserver).

%% API
-export([
  start/0,
  stop/0
]).

start() ->
  F = fun({App, _, _}) -> App end,
  RunningApps = lists:map(F, application:which_applications()),
  LoadedApps = lists:map(F, application:loaded_applications()),
  case lists:member(?MODULE, LoadedApps) of
    true ->
      true;
    false ->
      ok = application:load(?MODULE)
  end,
  {ok, Apps} = application:get_key(?MODULE, applications),
  [ok = application:start(A) || A <- Apps ++ [?MODULE], not lists:member(A, RunningApps)],
  ok.

stop() ->
  application:stop(?MODULE).



