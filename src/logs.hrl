%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 28. июл 2014 11:01
%%%-------------------------------------------------------------------
-author("Admin").

-define(LOG_ERROR(Format, Data),
  lager:log(error, [], "~p:~p(): " ++ Format ++ "~n~n", [?MODULE, ?LINE] ++ Data)).
-define(LOG_WARNING(Format, Data),
  lager:log(warning, [], "~p:~p(): " ++ Format ++ "~n~n", [?MODULE, ?LINE] ++ Data)).
-define(LOG_INFO(Format, Data),
  lager:log(info, [], "~p.erl:~p: " ++ Format ++ "~n~n", [?MODULE, ?LINE] ++ Data)).
