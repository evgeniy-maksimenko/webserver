%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 30. сен 2014 15:51
%%%-------------------------------------------------------------------
-module(tms).
-include("../logs.hrl").
-include("../../include/config.hrl").

%% API
-export([
  deletekey/1,
  find/3,
  save/3,
  inWork/2,
  send_mail/2,
  update_level/3
]).

save(PostAttrs, AllBindings, Req) ->

  List = [<<"opened_at">>, <<"opened_by">>, <<"working">>],

  case proplists:get_value(<<"status">>, PostAttrs) of
    <<"1lvl">> ->
      update_level(PostAttrs, List, AllBindings);
    <<"2lvl">> ->
      update_level(PostAttrs, List, AllBindings);
    <<"OK">> ->
      {ok, Req2} = send_mail(AllBindings, Req),
      emongo:update(model, "treatment", [{<<"sh_cli_id">>, proplists:get_value(<<"id">>, AllBindings)}], lists:merge(
        PostAttrs,
        [
          {<<"modified_at">>, erlydtl_dateformat:format(erlang:localtime(), "Y-m-d H:i:s")},
          {<<"author_login">>, proplists:get_value(<<"login">>, app:personality(Req2))},
          {<<"rating">>, 0},
          {<<"rating_at">>, <<"">>}
        ]
      ))
  end,
  <<"{\"status\":\"ok\"}">>.

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
  ?LOG_INFO("~p~n",[DataIn]),
  Data = deletekey(DataIn),

  List = lists:merge(
    lists:delete({<<"working">>, <<"0">>}, lists:merge(Data)),
    [
      {<<"opened_at">>, erlydtl_dateformat:format(erlang:localtime(), "Y-m-d H:i:s")},
      {<<"opened_by">>, proplists:get_value(<<"login">>, app:personality(Req))},
      {<<"working">>, 1}
    ]
  ),
  %%emongo:update(model, "treatment", [{<<"sh_cli_id">>, Id}], List),
  <<"{\"status\":\"ok\"}">>.

deletekey(List) -> delete_key(List, []).
delete_key([], Acc) -> Acc;
delete_key([H | T], Acc) -> delete_key(T, [proplists:delete(<<"_id">>, H) | Acc]).

send_mail(AllBindings, Req) ->
  {Host, Req1} = cowboy_req:host(Req),
  {Port, Req2} = cowboy_req:port(Req1),
  ADDRESS = binary_to_list(Host) ++":"++integer_to_list(Port)++"/tm_view/response/"++ binary_to_list(proplists:get_value(<<"id">>, AllBindings)),
  ANSWER = ?MAIL_BODY ++ ADDRESS ++ "'>ссылке</a>.</p>",
  %%mailer:send("siemenspromaster@gmail.com",<<"Обращение в Помощь Онлайн.">>,list_to_binary(ANSWER)),
  {ok, Req2}.

update_level(PostAttrs, List, AllBindings) ->
  ListLVL = [{K, V} || {K, V} <- PostAttrs, not lists:member(K, List)],
  emongo:update(model, "treatment", [{<<"sh_cli_id">>, proplists:get_value(<<"id">>, AllBindings)}], lists:merge(
    ListLVL,
    [
      {<<"working">>, 0}
    ]
  )).
