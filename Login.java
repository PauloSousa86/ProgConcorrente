package JavaClient;

import java.io.*;


public class Login {
	void login(PrintWriter out, BufferedReader in, BufferedReader stdIn) throws IOException{
		String receber;
		try{
			out.println("login");
			System.out.println("Username:");
			receber = stdIn.readLine();
			out.println(receber);
			System.out.println("Password:");
			receber = stdIn.readLine();
			out.println(receber);
			receber = in.readLine();
			if(receber.equals("ERRO")){
				System.out.println("Username ou password errados.");
				System.exit(1);
			}

		} catch (IOException e) {
            System.err.println("Erro ");
            System.exit(1);
        } 
	}
}
