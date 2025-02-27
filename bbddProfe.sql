DROP DATABASE IF EXISTS Preguntas_RespuestasBD;
CREATE DATABASE Preguntas_RespuestasBD;
USE Preguntas_RespuestasBD;

DROP TABLE IF EXISTS preguntas;
CREATE TABLE IF NOT EXISTS preguntas (
                                         id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
                                         cadena_pregunta VARCHAR(255) UNIQUE NOT NULL
    );

DROP TABLE IF EXISTS respuestas;
CREATE TABLE IF NOT EXISTS respuestas (
                                          id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
                                          cadena_respuesta VARCHAR(255) UNIQUE NOT NULL
    );

DROP TABLE IF EXISTS preguntas_respuestas;
CREATE TABLE IF NOT EXISTS preguntas_respuestas (
                                                    id_pregunta INT UNSIGNED NOT NULL,
                                                    id_respuesta INT UNSIGNED NOT NULL,
                                                    PRIMARY KEY (id_pregunta, id_respuesta),
    FOREIGN KEY (id_pregunta) REFERENCES preguntas(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_respuesta) REFERENCES respuestas(id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX FK_PREGUNTA (id_pregunta),
    INDEX FK_RESPUESTA (id_respuesta)
    );

SET @using_insert_procedure = FALSE;
SET @using_delete_procedure = FALSE;

DELIMITER $$

DROP TRIGGER IF EXISTS block_preguntas_insert$$
CREATE TRIGGER block_preguntas_insert
    BEFORE INSERT ON preguntas
    FOR EACH ROW
BEGIN
    IF NOT @using_insert_procedure THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede insertar una pregunta sin respuesta, utiliza el procedimiento';
END IF;
END $$

DROP TRIGGER IF EXISTS block_respuestas_insert$$
CREATE TRIGGER block_respuestas_insert
    BEFORE INSERT ON respuestas
    FOR EACH ROW
BEGIN
    IF NOT @using_insert_procedure THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede insertar una respuesta sin pregunta, utiliza el procedimiento';
END IF;
END $$

DROP TRIGGER IF EXISTS block_respuestas_delete$$
CREATE TRIGGER block_respuestas_delete
    BEFORE DELETE ON respuestas
    FOR EACH ROW
BEGIN
    IF NOT @using_delete_procedure THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar una respuesta sin pregunta, utiliza el procedimiento';
END IF;
END $$

DROP TRIGGER IF EXISTS block_pregunta_delete$$
CREATE TRIGGER block_pregunta_delete
    BEFORE DELETE ON preguntas
    FOR EACH ROW
BEGIN
    IF NOT @using_delete_procedure THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar una pregunta sin su respuesta, utiliza el procedimiento';
END IF;
END $$

CREATE FUNCTION get_pregunta_id(pregunta VARCHAR(255)) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE id_pregunta INT DEFAULT 0;
SELECT COALESCE(id, 0) INTO id_pregunta FROM preguntas WHERE cadena_pregunta = pregunta;
RETURN id_pregunta;
END $$

CREATE FUNCTION get_respuesta_id(respuesta VARCHAR(255)) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE id_respuesta INT DEFAULT 0;
SELECT COALESCE(id, 0) INTO id_respuesta FROM respuestas WHERE cadena_respuesta = respuesta;
RETURN id_respuesta;
END $$

DROP PROCEDURE IF EXISTS insert_pregunta_respuesta$$
CREATE PROCEDURE insert_pregunta_respuesta(IN pregunta VARCHAR(255), IN respuesta VARCHAR(255))
BEGIN
    DECLARE last_pregunta_id INT;
    DECLARE last_respuesta_id INT;
    DECLARE CONTINUE HANDLER FOR 1062 SELECT 'LA RELACIÓN YA EXISTÍA';

IF (pregunta IS NOT NULL AND respuesta IS NOT NULL) THEN
        SET @using_insert_procedure = TRUE;

        IF (get_pregunta_id(pregunta) = 0) THEN
            INSERT INTO preguntas (cadena_pregunta) VALUES (pregunta);
            SET last_pregunta_id = LAST_INSERT_ID();
ELSE
            SET last_pregunta_id = get_pregunta_id(pregunta);
END IF;

        IF (get_respuesta_id(respuesta) = 0) THEN
            INSERT INTO respuestas (cadena_respuesta) VALUES (respuesta);
            SET last_respuesta_id = LAST_INSERT_ID();
ELSE
            SET last_respuesta_id = get_respuesta_id(respuesta);
END IF;

INSERT INTO preguntas_respuestas (id_pregunta, id_respuesta)
VALUES (last_pregunta_id, last_respuesta_id);

SET @using_insert_procedure = FALSE;
ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede insertar una respuesta sin pregunta, se necesita valor en los dos argumentos';
END IF;
END $$

DROP PROCEDURE IF EXISTS delete_pregunta_respuesta$$
CREATE PROCEDURE delete_pregunta_respuesta(IN pregunta VARCHAR(255), IN respuesta VARCHAR(255))
BEGIN
    DECLARE id_pregunta_p, id_respuesta_p INTEGER UNSIGNED;

    IF (pregunta IS NOT NULL AND respuesta IS NOT NULL) THEN
        SET @using_delete_procedure = TRUE;
        SET id_pregunta_p = get_pregunta_id(pregunta);
        SET id_respuesta_p = get_respuesta_id(respuesta);

        IF (id_pregunta_p != 0 AND id_respuesta_p != 0) THEN
DELETE FROM preguntas_respuestas
WHERE id_pregunta = id_pregunta_p AND id_respuesta = id_respuesta_p;

IF ((SELECT COUNT(*) FROM preguntas_respuestas WHERE id_pregunta = id_pregunta_p) = 0) THEN
DELETE FROM preguntas WHERE id = id_pregunta_p;
END IF;

            IF ((SELECT COUNT(*) FROM preguntas_respuestas WHERE id_respuesta = id_respuesta_p) = 0) THEN
DELETE FROM respuestas WHERE id = id_respuesta_p;
END IF;
ELSE
            SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'No se puede eliminar la relación, la pregunta y/o la respuesta no existen en la base de datos';
END IF;

        SET @using_delete_procedure = FALSE;
ELSE
        SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'No se puede eliminar la relación entre una pregunta y su respuesta por separado, se necesita valor en los dos argumentos';
END IF;
END $$

DELIMITER ;

DELIMITER $$
DROP FUNCTION IF EXISTS  get_respuesta_from_pregunta$$
CREATE FUNCTION get_respuesta_from_pregunta(pregunta VARCHAR(255))
    RETURNS INT UNSIGNED /**un id de respuesta a esa pregunta, si no está alamcenada
                        en la base de datos retorna como id 0"*/
    NOT DETERMINISTIC
    READS SQL DATA
BEGIN
    DECLARE pregunta_id INT UNSIGNED DEFAULT 0;
    DECLARE respuesta_id INT UNSIGNED DEFAULT 0;
    DECLARE random_row INT UNSIGNED DEFAULT 0;
    DECLARE i INT UNSIGNED DEFAULT 1;
    DECLARE numero_respuestas INT UNSIGNED;

    /*Declaramos Cursor*/
    DECLARE lista_respuestas CURSOR FOR
        SELECT id_respuesta FROM preguntas_respuestas
        WHERE id_pregunta = pregunta_id;

    IF pregunta IS NULL   THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La pregunta no puede estar vacía, se necesita un argumento en la llamada';
    ELSE  /*proceso*/
        SET pregunta_id = get_pregunta_id(pregunta);
        /*Obtenemos el id de la pregunta que nos pasan por parámetro*/

        IF (pregunta_id = 0)THEN	/*Comprobamos si la pregunta existe en la base de datos*/
            RETURN 0;
        ELSE
            SELECT COUNT(*) INTO numero_respuestas
            FROM preguntas_respuestas
            WHERE id_pregunta = pregunta_id;

            /*Obtenemos un número aleatorio del rango [1-x]*/
            /*Siendo x el número de las filas de la tabla preguntas_respuestas que tengan como id_pregunta el de la pregunta recibida en el parámetro*/
            /*para obtener numero aleatorio R comprendido  i<=R< x   usamos
            FLOOR( i +RAND()*(x-i)) */
            SELECT FLOOR(1+RAND()* ((numero_respuestas+1)-1))
            INTO random_row;

            OPEN  lista_respuestas;	/*ejecutamos la consulta asociada al cursor*/

            /*Recorremos las filas que nos devuelve la consulta del Cursor*/
            WHILE ( i <= random_row )	/* random_row NO recogimos el identificador  nuestra fila aleatoria */
                DO
                    FETCH  lista_respuestas INTO respuesta_id;	/*Guardamos en una variable el id_respuesta de esta vuelta del bucle y movemos el puntero del Cursor*/
                    SET i = i+1;
                END WHILE;
            CLOSE  lista_respuestas;	/*Cerramos nuestro Cursor*/
        END IF; /*fin proceso contenido en else*/
        RETURN respuesta_id;
        /*Devolvemos el último id_respuesta obtenido, se corresponde con el
        número de orden aleatorio*/
    END IF;

END $$

DELIMITER ;

CALL INSERT_PREGUNTA_RESPUESTA("VOY A APROBAR?","SI");
CALL INSERT_PREGUNTA_RESPUESTA ("ESTOY ESTUDIANDO MUCHO?", "SI");
CALL INSERT_PREGUNTA_RESPUESTA ("VOY A APROBAR?","DEPENDE DE CUANTO ESTUDIES");
CALL INSERT_PREGUNTA_RESPUESTA ("CUALES SON LAS FASES DE LA LUNA?", "NUEVA, CRECIENTE, LLENA, MENGUANTE");
CALL INSERT_PREGUNTA_RESPUESTA("VOY A APROBAR?","SI");
CALL INSERT_PREGUNTA_RESPUESTA ("SOY GUAPO?", "SI");
CALL INSERT_PREGUNTA_RESPUESTA ("SOY GUAPO?","SI, MUCHO");
CALL INSERT_PREGUNTA_RESPUESTA ("CUÁNTOS DÍAS TIENE EL AÑO?", "365");