package JavaClient;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Scanner;

public class Condutor {

	void condutor(PrintWriter out, BufferedReader in, BufferedReader stdIn) throws IOException{
		String receber;
		int userInput;
		Scanner input = new Scanner(System.in);
		try{
			out.println("condutor");
	        System.out.println("Indique o modelo do veículo");
	        receber = stdIn.readLine();
	        out.println(receber);
	        System.out.println("Indique a matricula");
	        receber = stdIn.readLine();
	        out.println(receber);
	        System.out.println("Indique a sua posição");
	        System.out.println("Latitude");
	        userInput = input.nextInt();
	        out.println(userInput);
	        System.out.println("Longitude");
	        userInput = input.nextInt();
	        out.println(userInput);
	        System.out.println(in.readLine());
	        System.out.println("Deve digitar \"cheguei\" quando estiver no local de partida");
	        receber = stdIn.readLine();
	        out.println(receber);
	        System.out.println("Marque 1 assim que chegar ao destino");
	        userInput = input.nextInt();
	        if(userInput == 1){
	            out.println("destino");
	        }
	        input.close();
	        
		} catch (IOException e) {
            System.err.println("Erro");
            System.exit(1);
        } 
	}
}
