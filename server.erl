-module(server).
-export([server/1]).


server(Port) ->	
	{ok, LSock} = gen_tcp:listen(Port, [binary, {packet, line}, {reuseaddr, true}]),
	register(autenticador, spawn(fun()-> regUtente([]) end)),
	register(tipos, spawn(fun()-> regUtente([]) end)),
	register(drivers, spawn(fun()-> condutores([]) end)),
	register(clients, spawn(fun()-> condutores([]) end)),
	acceptor(LSock). 


acceptor(LSock) -> 
	{ok, Sock} = gen_tcp:accept(LSock),
	spawn(fun() -> acceptor(LSock) end),
	io:format("Ligação estabelecida~n"),
	gestor(Sock).
%	reg(Sock).


gestor(Sock) ->
	receive
		{tcp, _, Msg} ->
			case Msg of
				<<"login\n">> ->

					login(Sock);

				<<"registo\n">> ->
					reg(Sock);
				_ -> 
					gen_tcp:send(Sock, "Erro\n"),
					gestor(Sock)

			end				
	end.


reg(Sock) -> 

	receive
		{tcp, _, Usr} ->
			io:format("User: ~p ~n",[Usr])
	end,
	receive
		{tcp, _, Pass} ->
			io:format(" a pass ~p~n",[Pass])
	end,


	autenticador ! {register, {Usr, Pass}}, 
	receive
		{tcp, _, Msg} ->
			tipos ! {register, {Usr, Msg}},
			case Msg of
				<<"condutor\n">> ->
					io:format("cCondutor~n"),
					receive
						{tcp, _, Modelo} ->
						io:format("Modelo: ~p ~n",[Modelo])

					end,

					receive
						{tcp, _, Matricula} ->
							io:format(" Matricula ~p~n",[Matricula])
					end,


					viagem(Sock);

				<<"passageiro\n">> ->
					io:format("passageiro~n"),
					viagem2(Sock)
			end
	end.
viagem2(Sock) ->
	receive
	 	{tcp, _, Pos} ->
			{OrLat, _} = string:to_integer(re:replace(Pos, "(^\\s+)|(\\s+$)", "", [global,{return,list}]))
	
	end,
	receive
		{tcp, _, Pos2} ->
			{OrLong, _} = string:to_integer(re:replace(Pos2, "(^\\s+)|(\\s+$)", "", [global,{return,list}]))
		
	end,
	receive
	 	{tcp, _, Pos3} ->
			{DeLat, _} = string:to_integer(re:replace(Pos3, "(^\\s+)|(\\s+$)", "", [global,{return,list}]))
		
	end,
	receive
		{tcp, _, Pos4} ->
			{DeLong, _} = string:to_integer(re:replace(Pos3, "(^\\s+)|(\\s+$)", "", [global,{return,list}]))
			
	end,



		Tmp = OrLat - DeLat,
		Tmp2 = OrLong - DeLong,
		if
		 	Tmp >= 0 ->
		 		DistLat = Tmp;
		 	Tmp < 0 ->
		 		DistLat = Tmp * -1
		 end,
		 if
		 	Tmp2 >= 0 ->
		 		DistLong = Tmp2;
		 	Tmp2 < 0 ->
		 		DistLong = Tmp2 * -1
		 end, 
		 Manhat = DistLat + DistLong,
		 Preco = Manhat * 2,



	clients ! {self(),{OrLat,OrLong}},
	drivers ! {getConds, self()},
	receive
		[Data] -> io:format("Conds : ~p~n",[Data])
		
	end,


	search_Drivers(Sock, Data, 0,OrLat,OrLong,DeLat,DeLong, 999999, Preco).



viagem(Sock) ->

	receive
	 	{tcp, _, Pos5} ->
	 	Z = re:replace(Pos5, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
		{PosLat, _} = string:to_integer(Z)
	end,
	receive
		{tcp, _, Pos6} ->
			T = re:replace(Pos6, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
			{PosLong, _} = string:to_integer(T)
	end,

	drivers ! {self(),{PosLat,PosLong}},
	loop_Condutores(Sock, 0, 0, 0).

search_Drivers(Sock,MapCondutores, Pid, SLat, SLong,DeLat,DeLong, Dist, Preco) ->
		if
		 	(MapCondutores == []) and (Pid == 0)	->
		 		drivers ! {getConds, self()},
				receive
					[] -> search_Drivers(Sock, [], Pid, SLat, SLong,DeLat,DeLong, Dist, Preco);
					[Data] -> 
						search_Drivers(Sock, Data, Pid, SLat, SLong,DeLat,DeLong, Dist, Preco)	
				end;

			(MapCondutores == []) ->
				Tempo = Dist * 0.30,
				Pid ! {lock, self(), {SLat,SLong}, {DeLat,DeLong}, Preco},
				io:format ("TEMPO : ~p~n", [Tempo]),
%				Tempo =
				emparelhado(Sock, Pid, Tempo, Preco);
%		end,
			true ->

		Cond = hd(MapCondutores),

		{A, B} = Cond,
		{Lat,Long} = B,
		Tmp = SLat - Lat,
		Tmp2 = SLong - Long,

		if
		 	Tmp >= 0 ->
		 		DistLat = Tmp;
		 	Tmp < 0 ->
		 		DistLat = Tmp * -1
		 end,
		 if
		 	Tmp2 >= 0 ->
		 		DistLong = Tmp2;
		 	Tmp2 < 0 ->
		 		DistLong = Tmp2 * -1
		 end, 

		 Manhat = DistLat + DistLong,

		 if
		 	Manhat < Dist ->

		 		search_Drivers(Sock, MapCondutores -- [Cond], A, SLat, SLong,DeLat, DeLong, Manhat, Preco);
		 	Manhat >= Dist ->
		 		search_Drivers(Sock, MapCondutores -- [Cond], Pid, SLat, SLong,DeLat, DeLong, Dist, Preco)
		 end
	end.

emparelhado(Sock, Pid, Tempo, Preco) ->
	clients ! {remove, self()},
	receive
		{going} -> 
			Tx = "O seu veículo está a caminho deverá chegar dentro de ",
			Tx2 = " segundos, a viagem terá um custo de ",
			Tx3 = lists:flatten(io_lib:format("~p", [Tempo])),
			Tx4 = lists:flatten(io_lib:format("~p", [Preco])),
			Tx5 = " euros\n",
			Text = [Tx]++[Tx3]++[Tx2]++[Tx4]++[Tx5],
			gen_tcp:send(Sock, [Text]),
			emparelhado(Sock, Pid,Tempo, Preco);

		{tcp,_,<<"cancelar\n">>} ->

			Pid ! {cancel},
			emparelhado(Sock, Pid, Tempo,Preco);

		{cancelado, PrecoA} ->
			Tx = "A sua viagem foi cancelada, deve pagar ",
			Tx2 = " euros\n",
			Tx3 = lists:flatten(io_lib:format("~p", [PrecoA])),
			Text = [Tx]++[Tx3]++[Tx2],
			gen_tcp:send(Sock, [Text]);

		{onSite} ->
			gen_tcp:send(Sock, "O veículo já se encontra no local de partida\n"),
			emparelhado(Sock, Pid, Tempo, Preco);
		{tcp,_,<<"entrei\n">>} ->

			viagemEmCurso(Sock, Pid) 
	end.
viagemEmCurso(Sock, Pid) ->

	receive
		{destino} ->
			
			gen_tcp:send(Sock, "Chegou ao seu destino\n"),
			gen_tcp:close(Sock)
	end.

loop_Condutores(Sock, PrecoT, PrecoA,EPid) ->
	receive
			
			{lock, Pid, PosI, PosF, Preco} ->
				drivers ! {remove, self()},
				Tx = "Dirija-se ao ponto ",
				Tx2 = "\n",
				Tx3 = lists:flatten(io_lib:format("~p", [PosI])),
				Tx4 = " para uma viagem com destino a ",
				Tx5 = lists:flatten(io_lib:format("~p", [PosF])),
				Text = [Tx]++[Tx3]++[Tx4]++[Tx5]++[Tx2],
				gen_tcp:send(Sock, Text),
				Self_Pid = self(),
				Pid ! {going},
				spawn(fun()-> clock(0, Self_Pid) end),
				loop_Condutores(Sock, Preco, PrecoA, Pid);
			{updateTime} ->

				loop_Condutores(Sock, PrecoT, PrecoT / 2, EPid);
			{cancel} ->
				gen_tcp:send(Sock,"A viagem foi cancelada\n"),
				EPid ! {cancelado, PrecoA};
			{tcp,_,<<"cheguei\n">>} ->
				gen_tcp:send(Sock, "ok\n"),
			
				EPid ! {onSite},

				loop_Condutores(Sock, PrecoT, PrecoA, EPid);
			{tcp,_,<<"destino\n">>} ->
				gen_tcp:send(Sock, "ok\n"),
				EPid ! {destino},
				gen_tcp:close(Sock)
	end.

clock(Tempo,Pid) ->
	if
		Tempo == 60 ->
			Pid ! {updateTime}; 
		Tempo /= 60 ->
			timer:sleep(1000),
			clock(Tempo+1, Pid)
 	end.

condutores(Drivers) ->
	receive
		Data = {Pid,{Lat,Long}} -> 
			condutores([Data | Drivers]);

		Data = {remove, Pid} ->
			case Tuplo = [V || {K, V} <- Drivers,K == Pid] of
    						[Valor] ->
      								[Valor];
    						[] ->
      							none
  			end,

  			condutores(Drivers -- [Tuplo]);


		{getConds, From} -> 
			From ! [Drivers],
			regUtente(Drivers)

	end.
	
login(Sock) ->

	receive
		{tcp, _, Usr} ->
			io:format("User: ~p ~n",[Usr])
	end,

	receive
		{tcp, _, Pass} ->
			io:format(" a pass ~p~n",[Pass])
	end,

	autenticador ! {getCondutor, Usr, self()},

	receive
		 [Data] -> SPass = Data
	end,

		 	if
	 		SPass == [Pass] ->
	 			gen_tcp:send(Sock, "OK\n"),
				tipos ! {getCondutor, Usr, self()},
				receive
					 [Type] -> Tipo = Type
				end,
				if
					Tipo == [<<"condutor\n">>] ->
						viagem(Sock);
					Tipo == [<<"passageiro\n">>] ->
						viagem2(Sock)
				end;
	 		SPass /= [Pass]->

				gen_tcp:send(Sock, "ERRO\n"),

				gen_tcp:close(Sock)
%				login(Sock)
			end.

regUtente(MapCondutores) ->
	receive
			
				{register, Data} ->
					regUtente([Data | MapCondutores]);

				{getConds, From} -> 
					From ! [MapCondutores],
					regUtente(MapCondutores);

				{getCondutor,Usr,From} ->
  						case Pass = [V || {K, V} <- MapCondutores,K == Usr] of
    						[Valor] ->
      								[Valor];
    						[] ->
      							none
  						end,

					From ! [Pass],
					regUtente([Pass | MapCondutores])

	end.
