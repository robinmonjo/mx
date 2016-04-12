-module(mx_worker).

-export([work/5]).

work(Spawner, Connection, Collection, Skip, Limit) ->
  Cursor = mc_worker_api:find(Connection, Collection, {}, #{skip => Skip}),
  Data = export_fields(Cursor, Limit),
  %% TODO here I've got a list of csv rows, in reverse orders
  io:format("~p - data: ~p~n", [self(), Data]),
  Spawner ! {worker_done, self()}.

export_fields(Cursor, Limit) ->
  export_fields(Cursor, Limit, []).
  
export_fields(Cursor, 0, Acc) ->
  mc_cursor:close(Cursor),
  Acc;
export_fields(Cursor, Limit, Acc) ->
  { Data } = mc_cursor:next(Cursor),
  F = fun(_Key, Value, FieldsAcc) ->
      [Value | FieldsAcc]
    end,
  Fields = maps:fold(F, [], Data),
  NewAcc = [Fields | Acc],
  export_fields(Cursor, Limit - 1, NewAcc).
  
  
  
  
  
  

