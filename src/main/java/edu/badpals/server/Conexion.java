package edu.badpals.server;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class Conexion {

    private Connection conexion = null;

    private void connectDatabase() {

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/preguntasrespuestas";
            conexion = DriverManager.getConnection(url, "root", "root");
        } catch (SQLException e) {
            System.out.println("Error al conectar a la base de datos:");
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
    }

    public void addPreguntaRespuesta(String pregunta, String respuesta) {
        connectDatabase();
        try {
            // usar los "?"
            CallableStatement stms = conexion.prepareCall("{CALL InsertarPreguntaRespuesta(?, ?)}");
            stms.setString(1, pregunta);
            stms.setString(2, respuesta);
            stms.executeQuery();
        } catch (SQLException e) {
            System.out.println("Error al insertar pregunta y respuesta:");
            e.printStackTrace();
        }
    }

    /*public String getRespuesta(String pregunta) {
        try {
            ResultSet rs = instance.createStatement().executeQuery("SELECT pregunta_id, respuesta_id FROM preguntas_respuestas AS pr INNER JOIN preguntas AS p ON pr.pregunta_id = p.id");
            while (rs.next()) {
                preguntasRespuestas.add(rs.getString("pregunta") + ": " + rs.getString("respuesta"));
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener preguntas y respuestas:");
            e.printStackTrace();
        }
    }*/

    public void closeConnection() {
        try {
            conexion.close();
        } catch (SQLException e) {
            System.out.println("Error al cerrar la conexión:");
            e.printStackTrace();
        }
    }
}