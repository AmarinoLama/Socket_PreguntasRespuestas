package edu.badpals.server;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.List;
import java.util.Random;
import java.util.Scanner;

public class HiloServer extends Thread {

    private Socket socket;
    private Conexion bd;
    private Random random;
    private DataInputStream fentrada;
    private DataOutputStream fsalida;

    private boolean verificacion = false;

    public HiloServer(Socket s) throws IOException {
        //el hilo recibe el socket conectado al cliente
        socket = s;

        // el hilo se encarga de crear flujos de entrada y salida para el socket
        fsalida = new DataOutputStream(socket.getOutputStream());
        fentrada = new DataInputStream(socket.getInputStream());

        // creamos las instancias para manejar la bd y para tener el random
        bd = new Conexion();
        random = new Random();
    }

    public void run() {
        try {
            // Inicializamos datos
            String cadena = "";
            System.out.println("COMUNICO CON: " + socket.toString());

            // Bucle de comunicación
            cadena = fentrada.readUTF();
            System.out.println("Pregunta recibida: " + cadena);
            while (!cadena.equals("SALIR")) {
                // le paso la respuesta random a la pregunta y espero por otra pregunta
                String respuesta = bd.getRespuestaRandom(cadena);
                if (respuesta.equals("notFound")) {
                    respuesta = "No tengo la respuesta a la pregunta";
                }

                //pasamos al cliente la respuesta del servidor
                fsalida.writeUTF(respuesta);

                // leemos la siguiente pregunta
                cadena = fentrada.readUTF();
            }

            // Cerrar streams y sockets
            System.out.println("El programa ha finalizado");
            fsalida.close();
            fentrada.close();
            socket.close();

        } catch (IOException i) {
            i.printStackTrace();
        }
    }

    private void addPreguntaRespuesta(String pregunta, String respuesta) {
        try {
            Conexion conexion = new Conexion();
            conexion.addPreguntaRespuesta(pregunta, respuesta);
            conexion.closeConnection();
            verificacion = true;
        } catch (Exception e) {
            System.out.println("Error al añadir pregunta y respuesta:");
            e.printStackTrace();
            verificacion = false;
        }
    }
}