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