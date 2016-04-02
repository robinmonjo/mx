-module(mx_worker).

-export([work/2]).

work(Spawner, Args) ->
  io:format("~p starting with args: ~p~n", [self(), Args]),
  Spawner ! {worker_done, self()}.
  
  
  

