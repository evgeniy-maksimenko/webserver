%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 08. окт 2014 09:47
%%%-------------------------------------------------------------------
-module(test_handler).
-behaviour(cowboy_http_handler).
-include("logs.hrl").
-include("../include/config.hrl").

%% API
%% API
-compile(export_all).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

handle(Req, State) ->



  {ok, Req2} = cowboy_req:reply(200, [], [], Req),
  {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
  ok.



