%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 31. июл 2014 12:17
%%%-------------------------------------------------------------------
-module(c_mail).
-author("Evgenij.Maksimenko").

-define(RELAY,"smtp.gmail.com").
-define(USERNAME,"siemenspromaster@gmail.com").
-define(PASSWORD,"kondor_88").

%% API
-export([
  signed_body/4,
  send/3
]).

signed_body(Subject, From, To, Body) ->
  mimemail:encode({<<"text">>, <<"html">>,
    [{<<"Subject">>, Subject},
      {<<"From">>, From},
      {<<"To">>, To}],
    [],
    Body},
    []).

send(SignedMailBody, From, To) ->
  gen_smtp_client:send({
    From,
    [To],SignedMailBody}, [
    {relay, ?RELAY},
    {username, ?USERNAME},
    {password, ?PASSWORD}
  ]).