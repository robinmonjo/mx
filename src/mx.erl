-module(mx).

%% API exports
-export([main/1]).

%%====================================================================
%% API functions
%%====================================================================

%% escript Entry point
main(_Args) ->
  required_application_do(start),
  
  %% config
  Nb = 1,
  Database = <<"mobi_checkin_development">>,
  Collection = <<"guests">>,

  case mc_worker_api:connect([{database, Database}]) of
    {ok, Connection} -> 
      Nb_docs = mc_worker_api:count(Connection, Collection, {}),
      io:format("Starting export on ~p/~p with ~p workers (~p documents)~n", [Database, Collection, Nb, Nb_docs]),
      
      spawn_workers(Nb, Connection, Collection),
      loop(Nb, Connection);
    {error, Reason} -> io:format("unable to connect to ~p: ~p~n", [Database, Reason])
  end.

%%====================================================================
%% Internal functions
%%====================================================================
spawn_workers(0, _, _) ->
  ok;
spawn_workers(Nb, Connection, Collection) ->
  spawn(mx_worker, work, [self(), Connection, Collection, 0, 1]),
  spawn_workers(Nb - 1, Connection, Collection).
  
loop(0, Connection) ->
  mc_worker_api:disconnect(Connection),
  required_application_do(stop),
  erlang:halt(0);
loop(Nb, Connection) ->
  receive
    {worker_done, Pid} ->
      io:format("~p finished~n", [Pid]),
      loop(Nb - 1, Connection);
    _ ->
      io:format("Received an unknown message~n"),
      loop(Nb, Connection)
  end.
  
required_application_do(Action) ->
  apply(application, Action, [bson]),
  apply(application, Action, [crypto]),
  apply(application, Action, [mongodb]).