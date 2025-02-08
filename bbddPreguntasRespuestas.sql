DROP DATABASE IF EXISTS PreguntasRespuestas;
CREATE DATABASE IF NOT EXISTS PreguntasRespuestas;
USE PreguntasRespuestas;

-- Tabla de preguntas
DROP TABLE IF EXISTS preguntas;
CREATE TABLE IF NOT EXISTS preguntas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pregunta VARCHAR(500) NOT NULL UNIQUE
);

-- Tabla de respuestas
DROP TABLE IF EXISTS respuestas;
CREATE TABLE IF NOT EXISTS respuestas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    respuesta VARCHAR(500) NOT NULL UNIQUE
);

-- Tabla intermedia para la relación muchos a muchos
DROP TABLE IF EXISTS pregunta_respuesta;
CREATE TABLE IF NOT EXISTS pregunta_respuesta (
    pregunta_id INT,
    respuesta_id INT,
    PRIMARY KEY (pregunta_id, respuesta_id),
    FOREIGN KEY (pregunta_id) REFERENCES preguntas(id) ON DELETE CASCADE,
    FOREIGN KEY (respuesta_id) REFERENCES respuestas(id) ON DELETE CASCADE
);

-- Procedimiento para comprobar si una pregunta existe y una respuesta y luego meterlas en la relación n:m
DELIMITER $
CREATE PROCEDURE InsertarPreguntaRespuesta(IN pregunta_nueva VARCHAR(500), IN respuesta_nueva VARCHAR(500))
BEGIN
    DECLARE v_pregunta_id INT;
    DECLARE v_respuesta_id INT;
    
    -- Verificar si la pregunta ya existe
    SELECT id INTO v_pregunta_id FROM preguntas WHERE pregunta = pregunta_nueva;
    
    -- Si no existe, insertarla
    IF v_pregunta_id IS NULL THEN
        INSERT INTO preguntas (pregunta) VALUES (pregunta_nueva);
        SET v_pregunta_id = LAST_INSERT_ID();
    END IF;
    
    -- Verificar si la respuesta ya existe
    SELECT id INTO v_respuesta_id FROM respuestas WHERE respuesta = respuesta_nueva;
    
    -- Si no existe, insertarla
    IF v_respuesta_id IS NULL THEN
        INSERT INTO respuestas (respuesta) VALUES (respuesta_nueva);
        SET v_respuesta_id = LAST_INSERT_ID();
    END IF;
    
    -- Insertar en la tabla intermedia si no existe la relación
    IF NOT EXISTS (
        SELECT 1 FROM pregunta_respuesta WHERE pregunta_id = v_pregunta_id AND respuesta_id = v_respuesta_id
    ) THEN
        INSERT INTO pregunta_respuesta (pregunta_id, respuesta_id) VALUES (v_pregunta_id, v_respuesta_id);
    END IF;
END $