package edu.badpals.cliente;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;
import java.util.Scanner;

public class Cliente {

    // manda una pregunta al servidor y recibe una respuesta

    // Conexión al servidor
    private static String host = "localhost";
    private static int puerto = 6000;

    public Cliente(int puerto) {
        Cliente.puerto = puerto;
    }

    public static void main(String[] args) throws Exception {

        try {
            // Crear cliente
            System.out.println("PROGRAMA CLIENTE INICIADO....");
            Socket cliente = null;

            cliente = new Socket(host, puerto);

            // Flujos de entrada y salida
            DataOutputStream flujoSalida = new DataOutputStream(cliente.getOutputStream());
            DataInputStream flujoEntrada = new DataInputStream(cliente.getInputStream());
            Scanner sc = new Scanner(System.in);

            // Recibir primer mensaje del servidor
            System.out.println(flujoEntrada.readUTF());

            // Mandar la pregunta
            flujoSalida.writeUTF(sc.nextLine());

            // Recibir segundo mensaje del servidor
            System.out.println(flujoEntrada.readUTF());

            // Mandar la respuesta
            flujoSalida.writeUTF(sc.nextLine());

            // Cerrar streams y sockets
            System.out.println(flujoEntrada.readUTF());
            flujoEntrada.close();
            flujoSalida.close();
            cliente.close();

        } catch (IOException i) {
            i.printStackTrace();
        }
    }
}