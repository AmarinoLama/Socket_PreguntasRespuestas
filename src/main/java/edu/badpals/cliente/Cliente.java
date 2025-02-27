package edu.badpals.cliente;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;
import java.util.Scanner;

public class Cliente {

    public static void main(String[] args) throws Exception {

        try {
            // Crear cliente
            System.out.println("PROGRAMA CLIENTE INICIADO....");
            Socket cliente = new Socket("localhost", 6000);

            // Flujos de entrada y salida
            DataOutputStream flujoSalida = new DataOutputStream(cliente.getOutputStream());
            DataInputStream flujoEntrada = new DataInputStream(cliente.getInputStream());
            Scanner sc = new Scanner(System.in);

            String pregunta = "";
            String respuesta = "";

            while (true) {
                System.out.println("PREGUNTAME ALGO (Para finalizar escribe SALIR):");

                // leo la pregunta y se la mando al servidor
                pregunta = sc.nextLine();
                flujoSalida.writeUTF(pregunta);

                if (pregunta.equals("SALIR")) {
                    break;
                }

                // leo la respuesta del servidor
                respuesta = flujoEntrada.readUTF();
                System.out.println(respuesta);
            }

            // Cerrar streams y sockets
            System.out.println("Cerrando streams y sockets");
            flujoEntrada.close();
            flujoSalida.close();
            cliente.close();

        } catch (IOException i) {
            i.printStackTrace();
        }
    }
}