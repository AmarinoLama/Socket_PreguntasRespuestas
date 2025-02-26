package edu.badpals.server;

public class MainServer {

    public static void main(String[] args) {
        HiloServer hiloServer = new HiloServer(6000);
        hiloServer.start();

        // crear los hilos que sean necesarios y darle cada uno un cliente
    }
}
