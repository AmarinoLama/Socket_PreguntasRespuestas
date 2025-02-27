package edu.badpals.server;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class ServidorPreguntas {

    public static void main(String[] args) throws IOException {

        // Se crea el serversocket en el puerto 6000
        ServerSocket servidor = new ServerSocket(6000);
        System.out.println("Servidor iniciado.....");

        // Se crea un hilo para cada cliente que se conecte hasta que se fuerze el cierre del servidor
        while (true) {
            Socket cliente = new Socket();
            cliente = servidor.accept();
            HiloServer hilo = new HiloServer(cliente);
            hilo.start();
        }
    }
}