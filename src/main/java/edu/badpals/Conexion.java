package edu.badpals;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class Conexion {

    private Connection instance = null;

    private void connectDatabase() {

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/preguntasrespuestas";
            instance = DriverManager.getConnection(url, "root", "root");
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
            instance.createStatement().executeUpdate("CALL InsertarPreguntaRespuesta('" + pregunta + "', '" + respuesta + "')");
        } catch (SQLException e) {
            System.out.println("Error al insertar pregunta y respuesta:");
            e.printStackTrace();
        }
    }

    public List<String> getPreguntasRespuestas() {
        connectDatabase();
        List<String> preguntasRespuestas = new ArrayList<>();
        try {
            ResultSet rs = instance.createStatement().executeQuery("SELECT * FROM preguntas_respuestas");
            while (rs.next()) {
                preguntasRespuestas.add(rs.getString("pregunta") + ": " + rs.getString("respuesta"));
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener preguntas y respuestas:");
            e.printStackTrace();
        }
        return preguntasRespuestas;
    }

    public void closeConnection() {
        try {
            instance.close();
        } catch (SQLException e) {
            System.out.println("Error al cerrar la conexión:");
            e.printStackTrace();
        }
    }
}