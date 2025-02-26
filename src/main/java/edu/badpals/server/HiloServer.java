package edu.badpals.server;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Scanner;

public class HiloServer extends Thread {

    private int numeroPuerto = 0;
    private ServerSocket servidor = null;
    private boolean verificacion = false;

    public HiloServer(int numeroPuerto) {
        this.numeroPuerto = numeroPuerto;
    }

    public void run() {
        try {
            // Crear servidor
            servidor = new ServerSocket(numeroPuerto);

            // Aceptar cliente
            Socket clienteConectado = null;
            System.out.println("Esperando al cliente.....");
            clienteConectado = servidor.accept();

            // Inicializar flujos
            DataOutputStream flujoSalida = new DataOutputStream(clienteConectado.getOutputStream());
            DataInputStream flujoEntrada = new DataInputStream(clienteConectado.getInputStream());
            Scanner sc = new Scanner(System.in);

            // Mandar pregunta
            flujoSalida.writeUTF("Escribe la pregunta para subir a la BBDD: ");

            // Recibir pregunta
            String pregunta = flujoEntrada.readUTF();

            // Mandar respuesta
            flujoSalida.writeUTF("Escribe la respuesta de la pregunta anterior para subir a la BBDD: ");

            // Recibir pregunta
            String respuesta = flujoEntrada.readUTF();

            // Añadir pregunta y respuesta a la base de datos
            addPreguntaRespuesta(pregunta, respuesta);

            // Mandar mensaje al servidor
            flujoSalida.writeUTF("Se ha añadido la pregunta y respuesta a la base de datos: " + verificacion);

            // Cerrar streams y sockets
            System.out.println("El programa ha finalizado");
            flujoEntrada.close();
            flujoSalida.close();
            clienteConectado.close();
            servidor.close();

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

    private void getRespuesta(String pregunta) {

    }
}