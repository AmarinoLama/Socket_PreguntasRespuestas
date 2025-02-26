DROP DATABASE IF EXISTS Preguntas_RespuestasBD;
CREATE DATABASE Preguntas_RespuestasBD;
USE Preguntas_RespuestasBD;
/*** para almacenar la batería de preguntas*/
DROP TABLE IF EXISTS preguntas;
CREATE TABLE  IF NOT EXISTS preguntas(
	id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    cadena_pregunta VARCHAR(255) UNIQUE NOT NULL
    );

/*para almacenar la batería de respuestas*/
DROP TABLE IF EXISTS respuestas;
CREATE TABLE IF NOT EXISTS respuestas(
	id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    cadena_respuesta VARCHAR(255) UNIQUE NOT NULL
);
/*para almacenar las relaciones  pregunta_respuesta*/
DROP TABLE IF EXISTS preguntas_respuestas;
CREATE TABLE  IF NOT EXISTS preguntas_respuestas(
	id_pregunta INT UNSIGNED  NOT NULL,
    id_respuesta INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_pregunta, id_respuesta),
    FOREIGN KEY (id_pregunta) REFERENCES preguntas(id) 
                                  ON DELETE CASCADE
                                  ON UPDATE CASCADE ,
    INDEX FK_PREGUNTA (id_pregunta),                            
    FOREIGN KEY (id_respuesta) REFERENCES respuestas(id) 
                                 ON DELETE CASCADE
                                 ON UPDATE CASCADE,
   INDEX FK_RESPUESTA (id_respuesta)                              
);



/*Triggers, Functions y Procedures*/
SET @using_insert_procedure = FALSE;
SET @using_delete_procedure= FALSE;


DELIMITER $$
/* ESTE DISPARADOR IMPIDE LA INSERCCIÓN "EN SOLITARIO" DE UNA PREGUNTA, SÓLO SE PODRÁ
   REALIZAR DESDE EL PROCEDIMIENTO DE INSERCIÓN**/
 DROP TRIGGER IF EXISTS block_preguntas_insert$$ 
 CREATE TRIGGER  block_preguntas_insert BEFORE INSERT ON preguntas
	FOR EACH ROW
		BEGIN
			IF NOT @using_insert_procedure THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede insertar una pregunta sin respuesta, utiliza el procedimiento';
			END IF;
		END $$


   
/* ESTE DISPARADOR IMPIDE LA INSERCCIÓN "EN SOLITARIO" DE UNA RESPUESTA SÓLO SE PODRÁ
   REALIZAR DESDE EL PROCEDIMIENTO DE INSERCIÓN**/    
 DROP TRIGGER IF EXISTS  block_respuestas_insert $$ 
CREATE TRIGGER block_respuestas_insert BEFORE INSERT ON respuestas
	FOR EACH ROW
		BEGIN
			IF NOT @using_insert_procedure THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede insertar una respuesta sin pregunta, utiliza el procedimiento';
			END IF;
		END $$
 
       
  /* ESTE DISPARADOR IMPIDE EL BORRADO "EN SOLITARIO" DE UNA RESPUESTA SÓLO SE PODRÁ
   REALIZAR DESDE EL PROCEDIMIENTO DE ELIMINACIÓN**/    
 DROP TRIGGER IF EXISTS  block_respuestas_delete $$ 
CREATE TRIGGER block_respuestas_delete BEFORE DELETE ON respuestas
	FOR EACH ROW
		BEGIN
			IF NOT @using_delete_procedure THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar una respuesta sin pregunta, utiliza el procedimiento';
			END IF;
		END $$ 
   

/* ESTE DISPARADOR IMPIDE EL BORRADO "EN SOLITARIO" DE UNA PREGUNTA SÓLO SE PODRÁ
   REALIZAR DESDE EL PROCEDIMIENTO DE ELIMINACIÓN**/    
DROP TRIGGER IF EXISTS  block_pregunta_delete $$ 
CREATE TRIGGER block_pregunta_delete BEFORE DELETE ON preguntas
	FOR EACH ROW
		BEGIN
			IF NOT @using_delete_procedure THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar  una pregunta sin su respuesta, utiliza el procedimiento';
			END IF;
		END $$ 
   
  
CREATE FUNCTION get_pregunta_id(pregunta VARCHAR(255)) RETURNS INT 
   DETERMINISTIC
	BEGIN
		DECLARE id_pregunta INT DEFAULT 0;
        SELECT COALESCE(id,0)  INTO id_pregunta FROM preguntas WHERE cadena_pregunta = pregunta;
        RETURN id_pregunta;
    END $$
    
CREATE FUNCTION get_respuesta_id(respuesta VARCHAR(255)) RETURNS INT
  DETERMINISTIC
	BEGIN
		DECLARE id_respuesta INT DEFAULT 0;
        SELECT COALESCE(id, 0) INTO id_respuesta FROM respuestas WHERE cadena_respuesta = respuesta;
        RETURN id_respuesta;
    END $$
 
 
 
 
  /** EL REGISTRO  O ALMACENAMIENTO DE INFORMACIÓN EN LA BASE DE DATOS,
      SOLO SE HACE DESDE ESTE PROCEDIMIENTO**/
 DROP PROCEDURE IF EXISTS  insert_pregunta_respuesta$$    
CREATE PROCEDURE insert_pregunta_respuesta(IN pregunta VARCHAR(255), IN respuesta VARCHAR(255))
	BEGIN
		DECLARE last_pregunta_id INT;
        DECLARE last_respuesta_id INT;
        /** declaración de manejador de error para  si al insertar  una relación pregunta_respuesta,  ya existe**/
        DECLARE CONTINUE HANDLER FOR 1062
           SELECT " LA RELACIÓN YA EXISTÍA";
      /**proceso*/  
      IF (pregunta IS NOT NULL AND respuesta IS NOT NULL)
         THEN
            SET @using_insert_procedure = TRUE;    
       
            IF(get_pregunta_id(pregunta) = 0) 
            THEN
			      INSERT INTO preguntas (cadena_pregunta) VALUES (pregunta);
			      SET last_pregunta_id = LAST_INSERT_ID();
		     ELSE
			    SET last_pregunta_id = get_pregunta_id(pregunta);              
		    END IF;
        
            IF(get_respuesta_id(respuesta) = 0) THEN
			    INSERT INTO respuestas (cadena_respuesta) VALUES (respuesta);
			    SET last_respuesta_id = LAST_INSERT_ID();
		    ELSE
			   SET last_respuesta_id = get_respuesta_id(respuesta);
		    END IF;
        /** registramos ahora la relación**/
            INSERT INTO preguntas_respuestas (id_pregunta, id_respuesta) VALUES (last_pregunta_id, last_respuesta_id);
            /*si ya existiese, no se interrumpe el proceso, manejador de error*/
            SET @using_insert_procedure = FALSE;
          ELSE
              SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede insertar una respuesta sin pregunta,se necesita valor en los dos argumentos';
         END IF;   
    END $$
	
/** EL BORRADO DE UNA RELACIÓN PREGUNTA_RESPUESTA DE LA BASE DE DATOS,
      SOLO SE HACE DESDE ESTE PROCEDIMIENTO
	  SI LA PREGUNTA Y/O LA RESPUESTA SE QUEDAN SIN NINGUNA RELACIÓN MÁS SON ELIMINADAS DE LA BASE DE DATOS
	  PARA CUMPLIR PARTICIPACIÓN OBLIGATORIA (1,n)**/	
	  
DROP PROCEDURE IF EXISTS delete_pregunta_respuesta$$
CREATE PROCEDURE delete_pregunta_respuesta (IN pregunta VARCHAR(255), IN respuesta VARCHAR(255))
	BEGIN
	     DECLARE id_pregunta_p, id_respuesta_p INTEGER UNSIGNED;
		 
		 /*proceso*/
		    /** control argumentos recibidos*/
		  IF (pregunta IS NOT NULL AND respuesta IS NOT NULL)
		      THEN
			       SET @using_delete_procedure = TRUE;
		           SET id_pregunta_p=get_pregunta_id(pregunta);
				   SET id_respuesta_p=get_respuesta_id(respuesta);
				    /* control existen ambos en la base de datos*/
				   IF  (id_pregunta_p!=0 and id_respuesta_p!=0)
				             THEN /*proceso de elimnación de la realción*/
							   DELETE FROM preguntas_respuestas
							      WHERE id_pregunta=id_pregunta_p AND id_respuesta=id_respuesta_p;
								  IF (SELECT COUNT(*)
								        FROM preguntas_respuestas
										WHERE id_pregunta=id_pregunta_p
								     ) =0
									THEN DELETE FROM preguntas
                                           WHERE id=id_pregunta_p;									
                                  END IF;	
								  IF (SELECT COUNT(*)
								        FROM preguntas_respuestas
										WHERE id_respuesta=id_respuesta_p
								     ) =0
									THEN DELETE FROM respuestas
                                           WHERE id=id_respuesta_p;									
                                  END IF;
								  
							 ELSE SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'No se puede eliminar la relación, la pregunta y/o la respuesta no existen en la base de datos';
   							    
				   END IF;
				   SET @using_delete_procedure= FALSE;
			   ELSE SIGNAL SQLSTATE '45001' 
			        SET MESSAGE_TEXT = 'No se puede eliminar la relación entre una pregunta y su respuesta por separado, se necesita valor en los dos argumentos';	
	       END IF;
	
	END$$
        
DELIMITER ;

