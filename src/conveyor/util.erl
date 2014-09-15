-module(util).

-compile(export_all).

time()->
    integer_to_list(timer:now_diff(now(), {0,0,0})).

unixtime()->
    {A,B,_C} = now(),
    A*1000000 + B.
    %timer:now_diff(now(), {0,0,0}) * 1000000.

md5(Bin) ->
    binary_to_hex(erlang:md5(Bin)).	

sha1(Bin) ->
        bin_to_hexstr(crypto:hash(sha, Bin)).
                    
binary_to_hex(Bin) ->
    lists:foldl(fun (E, Acc) ->
                [hex(E bsr 4) | [hex(E band 16#F) | Acc]] end,
                [],
                lists:reverse(binary_to_list(Bin))).

hex(V) ->
    if
    V < 10 ->
            $0 + V;
    true ->
        $a + (V - 10)
    end.
%% convert list or binary to float or integer
string_to_number(N) when is_binary(N)->
    binary_to_list(string_to_number(N));
string_to_number(N)->
    case string:to_float(N) of
        {error,no_float} -> list_to_integer(N);
        {F,_Rest} -> F
    end.
%% get user ip
get_ip(Req)->
    case  lists:keyfind("X-Real-Ip", 1, Req:get(headers)) of
        {_, Ip} ->
                        Ip;
        _       ->
    		{Ip1, Ip2, Ip3, Ip4} =  Req:get(peer_addr),
                        integer_to_list(Ip1) ++ "." ++ integer_to_list(Ip2) ++ "." ++ integer_to_list(Ip3) ++ "." ++ integer_to_list(Ip4)
    end.
%%  compose_body
compose_body(Args) ->
lists:concat(
    lists:foldl(
        fun (Rec, []) -> [Rec]; (Rec, Ac) -> [Rec, "&" | Ac] end,
        [],
        [K ++ "=" ++ http_uri:encode( to_list(V) ) || {K, V} <- Args]
    )
).

to_list(Value) when is_list(Value)->
    Value;
to_list(Value) when is_binary(Value)->
    binary_to_list(Value);
to_list(Value) when is_integer(Value)->
    integer_to_list(Value);
to_list(Value) when is_float(Value)->
    float_to_list(Value);
to_list(Value) when is_atom(Value)->
   Value.

to_binary(T) when is_binary(T)->
    T;        
to_binary(T) when is_list(T)->
    list_to_binary(T);        
to_binary(T) when is_integer(T)->
    to_binary(integer_to_list(T));        
to_binary(T) when is_float(T)->
    to_binary(float_to_list(T));        
to_binary(T) when is_atom(T)->
    T. %to_binary(atom_to_list(T)).

to_binary_a(T) when is_binary(T)->
    T;        
to_binary_a(T) when is_list(T)->
    list_to_binary(T);        
to_binary_a(T) when is_integer(T)->
    to_binary_a(integer_to_list(T));        
to_binary_a(T) when is_float(T)->
    to_binary_a(float_to_list(T));        
to_binary_a(T) when is_atom(T)->
    to_binary_a(atom_to_list(T)).

to_float(Value) when is_list(Value)->
    list_to_float(Value);
to_float(Value) when is_binary(Value)->
    to_float(binary_to_list(Value));
to_float(Value) when is_integer(Value)->
    Value + 0.0 ;
to_float(Value) when is_float(Value)->
    Value.

to_integer(Text) when is_binary(Text)->
    list_to_integer( binary_to_list( Text ) );        
to_integer(Text) when is_list(Text)->
    list_to_integer( Text );        
to_integer(Text) when is_integer(Text)->
    Text.
    
get_value(Key, List)->
        get_value(Key, List, undefined).
get_value(Key, List, Default)->
        case lists:keyfind(Key, 1, List) of
            {_, Val} -> Val;
            _        -> Default
        end.

peer_addr(Headers, {PeerIp, _PeerPort})->
    RealIp = proplists:get_value(<<"x-real-ip">>, Headers),
    ForwardedForRaw = proplists:get_value(<<"x-forwarded-for">>, Headers),

    ForwardedFor =
    case ForwardedForRaw of
        undefined ->
            undefined;
        ForwardedForRaw ->
            case re:run(ForwardedForRaw, "^(?<first_ip>[^\\,]+)",
                    [{capture, [first_ip], binary}]) of
                {match, [FirstIp]} -> FirstIp;
                _Any -> undefined
            end
    end,
    Res =
    if
        is_binary(RealIp) -> inet_parse:address(binary_to_list(RealIp));
        is_binary(ForwardedFor) -> inet_parse:address(binary_to_list(ForwardedFor));
        true -> {ok, PeerIp}
    end,
    case Res of
        {ok, PeerAddr} ->
                PeerAddr;
        _   ->
                PeerIp
    end.

int(C) when $0 =< C, C =< $9 ->
    C - $0;
int(C) when $A =< C, C =< $F ->
    C - $A + 10;
int(C) when $a =< C, C =< $f ->
    C - $a + 10.

to_hex(N) when N < 256 ->
    [hex(N div 16), hex(N rem 16)].

list_to_hexstr([]) ->
    [];
list_to_hexstr([H|T]) ->
    to_hex(H) ++ list_to_hexstr(T).

bin_to_hexstr(Bin)when is_binary(Bin) ->
     list_to_binary( list_to_hexstr( binary_to_list(Bin)) );
bin_to_hexstr(S) ->
     list_to_binary( list_to_hexstr( S ) ).

hexstr_to_bin(S) when is_binary(S)->
    hexstr_to_bin(binary_to_list(S));
hexstr_to_bin(S)->
    list_to_binary(hexstr_to_list(S)).

hexstr_to_list([X,Y|T]) ->
    [int(X)*16 + int(Y) | hexstr_to_list(T)];
hexstr_to_list([]) ->
    [].

hexstring(<<X:128/big-unsigned-integer>>) ->
    lists:flatten(io_lib:format("~32.16.0b", [X]));
hexstring(<<X:160/big-unsigned-integer>>) ->
    lists:flatten(io_lib:format("~40.16.0b", [X]));
hexstring(<<X:256/big-unsigned-integer>>) ->
    lists:flatten(io_lib:format("~64.16.0b", [X]));
hexstring(<<X:512/big-unsigned-integer>>) ->
    lists:flatten(io_lib:format("~128.16.0b", [X])).

list2BinList([],ResList) -> ResList;
list2BinList([H|T],ResList) ->
  list2BinList(T,[to_binary(H)|ResList]).


get_prop_value(Key, PropList) ->
  case proplists:get_value(Key, PropList) of
    undefined ->
      KeyBin = util:to_binary_a(Key),
      throw(<<KeyBin/binary, " undefined">>);
    <<" ">> -> <<>>;
    Value ->
      Value
  end.

get_prop_value(Key, PropList, Default) ->
  case proplists:get_value(Key, PropList) of
    undefined ->
      Default;
    <<" ">> ->
      Default;
    <<"">> ->
      Default;
    "" ->
      Default;
    " " ->
      Default;
    Value ->
      Value
  end.

bin_to_int(Bin) ->
  if
    is_binary(Bin) -> binary_to_integer(Bin);
    true -> Bin
  end.

int_to_bin(Int) ->
  if
    is_integer(Int) -> integer_to_binary(Int);
    true -> Int
  end.