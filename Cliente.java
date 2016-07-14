package JavaClient;

import java.io.*;
import java.net.*;
import java.util.Scanner;


public class Cliente {

	public static void main(String[] args) throws IOException {
    
        int userInput;
        Login log = new Login();
        Register reg = new Register();
        Condutor driver = new Condutor();
        Passageiro cliente = new Passageiro();
        
        if (args.length != 2) {
            System.err.println(
                "Usage: java EchoClient <host name> <port number>");
            System.exit(1);
        }

        String hostName = args[0];
        int portNumber = Integer.parseInt(args[1]);

        try (
            Socket echoSocket = new Socket(hostName, portNumber);
            PrintWriter out =
                new PrintWriter(echoSocket.getOutputStream(), true);
            BufferedReader in =
                new BufferedReader(
                    new InputStreamReader(echoSocket.getInputStream()));
            BufferedReader stdIn =
                new BufferedReader(
                    new InputStreamReader(System.in))
        ) {
            Scanner input = new Scanner(System.in);
            System.out.println("Escolha a sua opção\n");
            System.out.println("1. Login\n");
            System.out.println("2. Registar\n");
           userInput = input.nextInt();
            
            switch(userInput) {
                case 1 :    log.login(out, in, stdIn);
                            break;

                case 2 :    userInput = reg.register(out, in, stdIn);
                            break;
            }
            switch(userInput){
                case 1:     driver.condutor(out, in, stdIn);
                            break;

                case 2:     cliente.pass(out, in, stdIn);
                            break;
            }
            input.close();

        } catch (UnknownHostException e) {
            System.err.println("Erro no host " + hostName);
            System.exit(1);
        } catch (IOException e) {
            System.err.println("Sem ligação " +
                hostName);
            System.exit(1);
        } 
    }

}
