DROP DATABASE IF EXISTS PreguntasRespuestas;
CREATE DATABASE IF NOT EXISTS PreguntasRespuestas;
USE PreguntasRespuestas;

-- Tabla de preguntas
DROP TABLE IF EXISTS preguntas;
CREATE TABLE IF NOT EXISTS preguntas (
                                         id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                                         pregunta VARCHAR(500) NOT NULL UNIQUE
);

-- Tabla de respuestas
DROP TABLE IF EXISTS respuestas;
CREATE TABLE IF NOT EXISTS respuestas (
                                          id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                                          respuesta VARCHAR(500) NOT NULL UNIQUE
);

-- Tabla intermedia para la relación muchos a muchos
DROP TABLE IF EXISTS pregunta_respuesta;
CREATE TABLE IF NOT EXISTS pregunta_respuesta (
                                                  pregunta_id INT UNSIGNED NOT NULL,
                                                  respuesta_id INT UNSIGNED NOT NULL,
                                                  PRIMARY KEY (pregunta_id, respuesta_id),
                                                  FOREIGN KEY (pregunta_id) REFERENCES preguntas(id) ON DELETE CASCADE,
                                                  FOREIGN KEY (respuesta_id) REFERENCES respuestas(id) ON DELETE CASCADE
);

-- Procedimiento para comprobar si una pregunta existe y una respuesta y luego meterlas en la relación n:m
DELIMITER $
CREATE PROCEDURE InsertarPreguntaRespuesta(IN pregunta_nueva VARCHAR(500), IN respuesta_nueva VARCHAR(500))
BEGIN
    DECLARE v_pregunta_id INT UNSIGNED;
    DECLARE v_respuesta_id INT UNSIGNED;

    SELECT id INTO v_pregunta_id FROM preguntas WHERE pregunta = pregunta_nueva;

    IF v_pregunta_id IS NULL THEN
        INSERT INTO preguntas (pregunta) VALUES (pregunta_nueva);
        SET v_pregunta_id = LAST_INSERT_ID();
    END IF;

    SELECT id INTO v_respuesta_id FROM respuestas WHERE respuesta = respuesta_nueva;

    IF v_respuesta_id IS NULL THEN
        INSERT INTO respuestas (respuesta) VALUES (respuesta_nueva);
        SET v_respuesta_id = LAST_INSERT_ID();
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pregunta_respuesta WHERE pregunta_id = v_pregunta_id AND respuesta_id = v_respuesta_id
    ) THEN
        INSERT INTO pregunta_respuesta (pregunta_id, respuesta_id) VALUES (v_pregunta_id, v_respuesta_id);
    END IF;
END $

CREATE FUNCTION get_pregunta_id(pregunta VARCHAR(255)) RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id_pregunta INT DEFAULT 0;
    SELECT COALESCE(id,0)  INTO id_pregunta FROM preguntas WHERE cadena_pregunta = pregunta;
    RETURN id_pregunta;
END $

CREATE FUNCTION get_respuesta_id(respuesta VARCHAR(255)) RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id_respuesta INT DEFAULT 0;
    SELECT COALESCE(id, 0) INTO id_respuesta FROM respuestas WHERE cadena_respuesta = respuesta;
    RETURN id_respuesta;
END $

CALL InsertarPreguntaRespuesta("VOY A APROBAR?","SI");
CALL InsertarPreguntaRespuesta ("ESTOY ESTUDIANDO MUCHO?", "SI");
CALL InsertarPreguntaRespuesta ("VOY A APROBAR?","DEPENDE DE CUANTO ESTUDIES");
CALL InsertarPreguntaRespuesta ("CUALES SON LAS FASES DE LA LUNA?", "NUEVA, CRECIENTE, LLENA, MENGUANTE");
CALL InsertarPreguntaRespuesta("VOY A APROBAR?","SI");
CALL InsertarPreguntaRespuesta ("SOY GUAPO?", "SI");
CALL InsertarPreguntaRespuesta ("SOY GUAPO?","SI, MUCHO");
CALL InsertarPreguntaRespuesta ("CUÁNTOS DÍAS TIENE EL AÑO?", "365");

SELECT * FROM pregunta_respuesta;

/*
faltan 3 trigers uno para cuando se cree una pregunta con una respuesta
	> verificar que existe la pregunta o no
    > verificar que existe la respuesta o no
    > verificar que al borrar algo no queden preguntas ni respuestas sueltas
*/