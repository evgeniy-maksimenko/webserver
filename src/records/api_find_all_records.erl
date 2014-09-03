%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 22. июл 2014 14:07
%%%-------------------------------------------------------------------
-module(api_find_all_records).
-behaviour(cowboy_http_handler).
-include("../logs.hrl").

%% API
-export([
  init/3,
  handle/2,
  terminate/3,
  deletekey/1
]).

-export([reading_the_req_body/1]).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

handle(Req, State) ->
  {Code, ModelRecords} =
    try
      FindAll =
        case AllBindings = reading_the_req_body(Req) of
          false -> emongo:find(model, "records");
          _ ->
            emongo:find(model, "records", [{"created_at", [{'>=', proplists:get_value(<<"date_from">>, AllBindings)}, {'=<', proplists:get_value(<<"date_to">>, AllBindings)}]}])
        end,
      {200, FindAll}
    catch
      _ : Reason -> ?LOG_ERROR("TAG ~p", [Reason]),
        {400, <<"Missing echo parameters.">>}
    end,

  {ok, Req2} = cowboy_req:reply(Code, [
    {<<"content-type">>, <<"application/json">>}
  ], jsx:encode(deletekey(ModelRecords)), Req),

  {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
  ok.

deletekey(List) -> delete_key(List, []).
delete_key([], Acc) -> Acc;
delete_key([H | T], Acc) -> delete_key(T, [proplists:delete(<<"_id">>, H) | Acc]).

reading_the_req_body(Req) ->
  {AllBindings, Req1} = cowboy_req:qs_vals(Req),
  Case =
    case proplists:is_defined(<<"date_from">>, AllBindings) andalso proplists:is_defined(<<"date_to">>, AllBindings) of
      true -> AllBindings;
      false -> false
    end,
  Req1,
  Case.
