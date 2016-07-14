package JavaClient;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Scanner;

public class Register {
	int userInput;
	
	@SuppressWarnings("finally")
	int register(PrintWriter out, BufferedReader in, BufferedReader stdIn) throws IOException{
		String receber;
//		int userInput;
		Scanner input = new Scanner(System.in);
		
		try{
			out.println("registo");
	        System.out.println("Username:");
	        receber = stdIn.readLine();
	        out.println(receber);
	        System.out.println("Password:");
	        receber = stdIn.readLine();
	        out.println(receber);
	
	        System.out.println("Escolha a opção pretendida");
	        System.out.println("1. Condutor");
	        System.out.println("2. Passageiro");
	        userInput = input.nextInt();
		
	        
		} catch (IOException e) {
            System.err.println("Erro");
            System.exit(1);
        
		}finally{
			return userInput;
		}
	}
}


