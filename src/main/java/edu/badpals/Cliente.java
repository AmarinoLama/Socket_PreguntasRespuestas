package edu.badpals;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;

public class Cliente {

    private static boolean verificacion = false;

    public static void main(String[] args) throws Exception {

        // Conexión al servidor
        String Host = "localhost";
        int Puerto = 6000;

        // Crear cliente
        System.out.println("PROGRAMA CLIENTE INICIADO....");
        Socket cliente=null;
        try{
            cliente = new Socket(Host, Puerto);
        }catch (IOException i){
            i.printStackTrace();
        }

        // Flujos de entrada y salida
        DataOutputStream flujoSalida = new DataOutputStream(cliente.getOutputStream());
        DataInputStream flujoEntrada = new DataInputStream(cliente.getInputStream());

        // Recibir primer mensaje del servidor
        String mensaje1 = flujoEntrada.readUTF();

        // Recibir segundo mensaje del servidor
        String mensaje2 = flujoEntrada.readUTF();

        // Añadir pregunta y respuesta a la base de datos
        addPreguntaRespuesta(mensaje1, mensaje2);

        // Mandar mensaje al servidor
        flujoSalida.writeUTF("Se ha añadido la pregunta y respuesta a la base de datos: " + verificacion);

        // Cerrar streams y sockets
        flujoEntrada.close();
        flujoSalida.close();
        cliente.close();

    }

    private static void addPreguntaRespuesta(String pregunta, String respuesta) {
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