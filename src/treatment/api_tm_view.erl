%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 26. сен 2014 17:52
%%%-------------------------------------------------------------------
-module(api_tm_view).
-behaviour(cowboy_http_handler).
-include("../logs.hrl").


%% API
-export([
  init/3,
  handle/2,
  terminate/3,
  reading_the_req_body/1,
  httpPost/4
]).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

terminate(_Reason, _Req, _State) ->
  ok.

handle(Req, State) ->
  {Code, Data} =
    try
      FindAll = reading_the_req_body(Req),
      case is_list(FindAll) orelse jsx:is_json(FindAll) of
        true ->
          {200, FindAll};
        false ->
          {403, <<"Forbidden">>}
      end
    catch
      _ : Reason -> ?LOG_ERROR("TAG ~p", [Reason]),
        {400, <<"Missing echo parameters.">>}
    end,
  {ok, Req2} = cowboy_req:reply(Code, [
    {<<"content-type">>, <<"application/json">>}
  ], jsx:encode(Data), Req),
  {ok, Req2, State}.


reading_the_req_body(Req) ->
  {AllBindings, Req1} = cowboy_req:qs_vals(Req),
  Case = httpPost(proplists:get_value(<<"condition">>, AllBindings), proplists:is_defined(<<"id">>, AllBindings), AllBindings, Req1),
  Case.

httpPost(<<"all">>, IsDefined, AllBindings, Req) ->
  tm:find(AllBindings, IsDefined, Req);
httpPost(<<"view">>, _IsDefined, AllBindings, Req) ->
  tm:view(proplists:get_value(<<"id">>, AllBindings), Req);
httpPost(<<"rating">>, _IsDefined, AllBindings, Req) ->
  {ok, PostAttrs, Req1} = cowboy_req:body_qs(Req),
  tm:rating(proplists:get_value(<<"id">>, AllBindings), PostAttrs, Req1).

