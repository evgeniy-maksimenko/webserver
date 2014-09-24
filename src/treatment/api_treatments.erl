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
  find/3,
  reading_the_req_body/1,
  httpPost/4,
  save/3,
  inWork/2
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

find(AllBindings, false, _Req) ->
  Find = emongo:find(model, "treatment", [{<<"status">>, proplists:get_value(<<"status">>, AllBindings)}]),
  Data = deletekey(Find),
  Data;
find(Id, true, Req) ->
  Find = emongo:find(model, "treatment", [{"sh_cli_id", Id}]),
  Data = deletekey(Find),

  OpenedBy = proplists:get_value(<<"opened_by">>, lists:merge(Data)),
  Login = proplists:get_value(<<"login">>, app:personality(Req)),

  Result =
    case OpenedBy =:= Login of
      true ->
        Data;
      false ->
        <<"Forbidden">>
    end,
  Result.

inWork(Id, Req) ->
  DataIn = emongo:find(model, "treatment", [{"sh_cli_id", Id}]),
  Data = deletekey(DataIn),
  List = lists:merge(
    lists:delete({<<"working">>, <<"0">>}, lists:merge(Data)),
    [
      {<<"opened_at">>, erlydtl_dateformat:format(erlang:localtime(), "Y-m-d H:i:s")},
      {<<"opened_by">>, proplists:get_value(<<"login">>, app:personality(Req))},
      {<<"working">>, 1}
    ]
  ),
  emongo:update(model, "treatment", [{<<"sh_cli_id">>, Id}], List),
  <<"{\"status\":\"ok\"}">>.

save(PostAttrs, AllBindings, Req) ->
  List = [<<"opened_at">>, <<"opened_by">>, <<"working">>],
  case proplists:get_value(<<"status">>, PostAttrs) of
    <<"1lvl">> ->
      List1LVL = [{K, V} || {K, V} <- PostAttrs, not lists:member(K, List)],
      emongo:update(model, "treatment", [{<<"sh_cli_id">>, proplists:get_value(<<"id">>, AllBindings)}], lists:merge(
        List1LVL,
        [
          {<<"working">>, 0}
        ]
      ));
    <<"2lvl">> ->
      List2LVL = [{K, V} || {K, V} <- PostAttrs, not lists:member(K, List)],
      emongo:update(model, "treatment", [{<<"sh_cli_id">>, proplists:get_value(<<"id">>, AllBindings)}], lists:merge(
        List2LVL,
        [
          {<<"working">>, 0}
        ]
      ));
    <<"OK">> ->
      emongo:update(model, "treatment", [{<<"sh_cli_id">>, proplists:get_value(<<"id">>, AllBindings)}], lists:merge(
        PostAttrs,
        [
          {<<"modified_at">>, erlydtl_dateformat:format(erlang:localtime(), "Y-m-d H:i:s")},
          {<<"author_login">>, proplists:get_value(<<"login">>, app:personality(Req))}
        ]
      ))
  end,
  <<"{\"status\":\"ok\"}">>.

deletekey(List) -> delete_key(List, []).
delete_key([], Acc) -> Acc;
delete_key([H | T], Acc) -> delete_key(T, [proplists:delete(<<"_id">>, H) | Acc]).

reading_the_req_body(Req) ->
  {AllBindings, Req1} = cowboy_req:qs_vals(Req),
  Case = httpPost(proplists:get_value(<<"condition">>, AllBindings), proplists:is_defined(<<"id">>, AllBindings), AllBindings, Req1),
  Case.

httpPost(<<"open">>, IsDefined, AllBindings, Req) ->
  find(proplists:get_value(<<"id">>, AllBindings), IsDefined, Req);
httpPost(<<"all">>, IsDefined, AllBindings, Req) ->
  find(AllBindings, IsDefined, Req);
httpPost(<<"made">>, _IsDefined, AllBindings, Req) ->
  {ok, PostAttrs, Req1} = cowboy_req:body_qs(Req),
  save(PostAttrs, AllBindings, Req1);
httpPost(<<"in_work">>, _IsDefined, AllBindings, Req) ->
  inWork(proplists:get_value(<<"id">>, AllBindings), Req).





