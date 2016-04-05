-module(mx).

%% API exports
-export([main/1]).

%%====================================================================
%% API functions
%%====================================================================

%% escript Entry point
main(_Args) ->
  Nb = 10,
  spawn_workers(Nb),
  loop(Nb).

%%====================================================================
%% Internal functions
%%====================================================================
spawn_workers(0) ->
  ok;
spawn_workers(Nb) ->
  spawn(mx_worker, work, [self(), "some args"]),
  spawn_workers(Nb - 1).
  
loop(0) ->
  erlang:halt(0);
loop(Nb) ->
  receive
    {worker_done, Pid} ->
      io:format("~p finished~n", [Pid]),
      loop(Nb - 1);
    _ ->
      io:format("Received an unknown message~n"),
      loop(Nb)
  end.