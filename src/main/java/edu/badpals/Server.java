package edu.badpals;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Scanner;

public class Server {

    public static void main(String[] arg) throws IOException {

        // Crear servidor
        int numeroPuerto = 6000;
        ServerSocket servidor = null;
        try{
            servidor = new ServerSocket(numeroPuerto);
        } catch(IOException io){
            io.printStackTrace();
        }

        // Aceptar cliente
        Socket clienteConectado = null;
        System.out.println("Esperando al cliente.....");
        try{
            clienteConectado = servidor.accept();
        }catch(IOException io){
            io.printStackTrace();
        }

        // Mandar mensaje a cliente
        OutputStream salida = null;
        try{
            salida = clienteConectado.getOutputStream();
        }catch (IOException e1){
            e1.printStackTrace();
        }
        DataOutputStream flujoSalida = new DataOutputStream(salida);

        Scanner scanner = new Scanner(System.in);

        // Mandar pregunta
        System.out.println("Escribe la pregunta para el CLIENTE: ");
        flujoSalida.writeUTF(scanner.nextLine());

        // Mandar respuesta
        System.out.println("Escribe la respuesta para el CLIENTE: ");
        flujoSalida.writeUTF(scanner.nextLine());

        // Entrada mensaje del cliente
        InputStream entrada = null;
        try{
            entrada = clienteConectado.getInputStream();
        }catch(IOException e){
            e.printStackTrace();
        }
        DataInputStream flujoEntrada = new DataInputStream(entrada);

        System.out.println("Recibiendo mensaje del CLIENTE: \n\t" +
                flujoEntrada.readUTF());

        // Cerrar streams y sockets
        try {
            entrada.close();
            flujoEntrada.close();
            salida.close();
            flujoSalida.close();
            clienteConectado.close();
            servidor.close();

        } catch (IOException i){
            i.printStackTrace();
        }
    }
}