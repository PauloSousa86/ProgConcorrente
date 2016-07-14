package JavaClient;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Scanner;

public class Passageiro {
	void pass(PrintWriter out, BufferedReader in, BufferedReader stdIn) throws IOException{
		int userInput;
		Scanner input = new Scanner(System.in);
		try{
			out.println("passageiro");
	        System.out.println("Indique a origem");
	        System.out.println("Latitude");
	        userInput = input.nextInt();
	        out.println(userInput);
	        System.out.println("Longitude");
	        userInput = input.nextInt();
	        out.println(userInput);
	        System.out.println("Indique o seu destino");
	        System.out.println("Latitude");
	        userInput = input.nextInt();
	        out.println(userInput);
	        System.out.println("Longitude");
	        userInput = input.nextInt();
	        out.println(userInput);
	        System.out.println(in.readLine());
	        System.out.println("Pode cancelar a sua viagem antes de entrar no veículo ou informar que entrou.");
	        System.out.println("1. Cancelar");
	        System.out.println(in.readLine());
	        System.out.println("2. Entrou no veículo");
	        userInput = input.nextInt();
	        if(userInput == 1){
	            out.println("cancelar");
	        }
	        else{
	            out.println("entrei");
	        }
	        System.out.println(in.readLine());
	        input.close();
	        
		} catch (IOException e) {
            System.err.println("Erro");
            System.exit(1);
        } 
	}
}
