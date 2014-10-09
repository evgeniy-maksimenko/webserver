%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 01. сен 2014 16:23
%%%-------------------------------------------------------------------
-module(api_get_user_contacts_handler).
-behaviour(cowboy_http_handler).
-include("../logs.hrl").

%% API
-export([
  init/3,
  handle/2,
  terminate/3,
  readingTheReqBody/1
]).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

handle(Req, State) ->
  {Code, Result} =
    try
      Res =
        case AllBindings = readingTheReqBody(Req) of
          false -> app_logic:getUserContacts(Req, undefined);
          _ -> app_logic:getUserContacts(Req, proplists:get_value(<<"login">>, AllBindings))
        end,
      {200, Res}
    catch
      _ : Reason -> ?LOG_ERROR("TAG ~p", [Reason]),
        {400, <<"Missing echo parameters.">>}
    end,

  {ok, Req2} = cowboy_req:reply(Code, [
    {<<"content-type">>, <<"application/json">>}
  ], Result, Req),

  {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
  ok.

readingTheReqBody(Req) ->
  {AllBindings, Req1} = cowboy_req:qs_vals(Req),
  Result =
    case proplists:is_defined(<<"login">>, AllBindings) andalso proplists:get_value(<<"login">>, AllBindings) =/= <<>> of
      true -> AllBindings;
      false -> false
    end,
  Req1,
  Result.

