package edu.badpals.server;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class Conexion {

    private Connection conexion = null;

    public Conexion() {
        connectDatabase();
    }

    private void connectDatabase() {

        // REALIZADO CON LA BBDD DE LA PROFE

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/preguntas_respuestasbd";
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
            CallableStatement stms = conexion.prepareCall("{CALL insert_pregunta_respuesta(?, ?)}");
            stms.setString(1, pregunta);
            stms.setString(2, respuesta);
            stms.executeQuery();
        } catch (SQLException e) {
            System.out.println("Error al insertar pregunta y respuesta:");
            e.printStackTrace();
        }
    }

    public String getRespuestaRandom(String pregunta) {
        connectDatabase();
        String respuesta = "notFound";
        try {
            // Llamada a la función get_respuesta_from_pregunta para obtener la ID de la respuesta
            CallableStatement stms = conexion.prepareCall("{? = CALL get_respuesta_from_pregunta(?)}");
            stms.registerOutParameter(1, Types.INTEGER);  // Suponiendo que la ID sea un número entero
            stms.setString(2, pregunta);
            stms.execute();

            // Obtener la ID de la respuesta
            int idRespuesta = stms.getInt(1);

            if (idRespuesta != 0) {
                // Realizar la query para obtener la respuesta usando la ID obtenida
                String query = "SELECT cadena_respuesta FROM respuestas WHERE id = ?";
                PreparedStatement stms2 = conexion.prepareStatement(query);
                stms2.setInt(1, idRespuesta);
                ResultSet rs = stms2.executeQuery();

                if (rs.next()) {
                    respuesta = rs.getString("cadena_respuesta");
                }
            }

        } catch (SQLException e) {
            System.out.println("Error al obtener respuesta random:");
            e.printStackTrace();
        }
        return respuesta;
    }

    public void closeConnection() {
        try {
            conexion.close();
        } catch (SQLException e) {
            System.out.println("Error al cerrar la conexión:");
            e.printStackTrace();
        }
    }
}