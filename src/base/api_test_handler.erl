%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 22. июл 2014 20:18
%%%-------------------------------------------------------------------
-module(api_test_handler).
-behaviour(cowboy_http_handler).
-author("Evgenij.Maksimenko").

%% API
-export([
  init/3,
  handle/2,
  terminate/3
]).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

%% Заметка, возможно проблема с кодировкой
%% Решение unicode:characters_to_binary([Body])

handle(Req, State) ->

  auth_handler:getAuthPage(Req),


  Body = jsx:encode([
    [
      {<<"id">>,<<"1">>},
      {<<"date">>,<<"05-06-2014 16:11:26">>}
    ],
    [
      {<<"id">>,<<"2">>},
      {<<"date">>,<<"05-06-2014 16:78:26">>}
    ]
  ]),
  {ok, Req5} = cowboy_req:reply(200, [{<<"content-type">>, <<"application/json">>}], Body, Req),
  {ok, Req5, State}.

terminate(_Reason, _Req, _State) ->
  ok.





