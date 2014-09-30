%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 10. сен 2014 11:27
%%%-------------------------------------------------------------------
-module(api_treatments).
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

httpPost(<<"open">>, IsDefined, AllBindings, Req) ->
  tms:find(proplists:get_value(<<"id">>, AllBindings), IsDefined, Req);
httpPost(<<"all">>, IsDefined, AllBindings, Req) ->
  tms:find(AllBindings, IsDefined, Req);
httpPost(<<"made">>, _IsDefined, AllBindings, Req) ->
  {ok, PostAttrs, Req1} = cowboy_req:body_qs(Req),
  tms:save(PostAttrs, AllBindings, Req1);
httpPost(<<"in_work">>, _IsDefined, AllBindings, Req) ->
  tms:inWork(proplists:get_value(<<"id">>, AllBindings), Req).



