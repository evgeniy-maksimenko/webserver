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
  deletekey/1,
  find/2,
  reading_the_req_body/1,
  httpPost/4,
  save/3
]).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

terminate(_Reason, _Req, _State) ->
  ok.

handle(Req, State) ->
  {Code, Data} =
    try
      FindAll = reading_the_req_body(Req),
      {200, FindAll}
    catch
      _ : Reason -> ?LOG_ERROR("TAG ~p", [Reason]),
        {400, <<"Missing echo parameters.">>}
    end,
  {ok, Req2} = cowboy_req:reply(Code, [
    {<<"content-type">>, <<"application/json">>}
  ], jsx:encode(Data), Req),
  {ok, Req2, State}.

find(AllBindings, false) ->
  Find = emongo:find(model, "treatment", [{<<"status">>, proplists:get_value(<<"status">>, AllBindings)}]),
  Data = deletekey(Find),
  Data;
find(Id, true) ->
  Find = emongo:find(model, "treatment", [{"sh_cli_id", Id}]),
  Data = deletekey(Find),
  Data.

save(PostAttrs, AllBindings, Req) ->
  emongo:update(model, "treatment", [{<<"sh_cli_id">>, proplists:get_value(<<"id">>, AllBindings)}], lists:merge(
    PostAttrs,
    [
      {<<"modified_at">>, erlydtl_dateformat:format(erlang:localtime(), "Y-m-d H:i:s")},
      {<<"author_login">>, proplists:get_value(<<"login">>, app:personality(Req))}
    ]
  )),
  <<"{\"status\":\"ok\"}">>.

deletekey(List) -> delete_key(List, []).
delete_key([], Acc) -> Acc;
delete_key([H | T], Acc) -> delete_key(T, [proplists:delete(<<"_id">>, H) | Acc]).

reading_the_req_body(Req) ->
  {AllBindings, Req1} = cowboy_req:qs_vals(Req),
  Case = httpPost(proplists:get_value(<<"condition">>, AllBindings), proplists:is_defined(<<"id">>, AllBindings), AllBindings, Req1),
  Case.

httpPost(<<"open">>, IsDefined, AllBindings, _Req) ->
  find(proplists:get_value(<<"id">>, AllBindings), IsDefined);
httpPost(<<"all">>, IsDefined, AllBindings, _Req) ->
  find(AllBindings, IsDefined);
httpPost(<<"made">>, _IsDefined, AllBindings, Req) ->
  {ok, PostAttrs, Req1} = cowboy_req:body_qs(Req),
  save(PostAttrs, AllBindings, Req1).





