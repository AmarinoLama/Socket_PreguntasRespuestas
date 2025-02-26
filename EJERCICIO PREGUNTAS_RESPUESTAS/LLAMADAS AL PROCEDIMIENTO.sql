CALL INSERT_PREGUNTA_RESPUESTA("VOY A APROBAR?","SI");
CALL INSERT_PREGUNTA_RESPUESTA ("ESTOY ESTUDIANDO MUCHO?", "SI");
CALL INSERT_PREGUNTA_RESPUESTA ("VOY A APROBAR?","DEPENDE DE CUANTO ESTUDIES");
CALL INSERT_PREGUNTA_RESPUESTA ("CUALES SON LAS FASES DE LA LUNA?", "NUEVA, CRECIENTE, LLENA, MENGUANTE");
CALL INSERT_PREGUNTA_RESPUESTA("VOY A APROBAR?","SI");
CALL INSERT_PREGUNTA_RESPUESTA ("SOY GUAPO?", "SI");
CALL INSERT_PREGUNTA_RESPUESTA ("SOY GUAPO?","SI, MUCHO");
CALL INSERT_PREGUNTA_RESPUESTA ("CUÁNTOS DÍAS TIENE EL AÑO?", "365");
CALL INSERT_PREGUNTA_RESPUESTA ("HOLA, QUÉ TAL?",NULL);


SELECT * FROM PREGUNTAS;
SELECT * FROM RESPUESTAS;
SELECT * FROM PREGUNTAS_RESPUESTAS;

/*para probar no es posible un insert en solitario de pregunta y de respuesta*/

insert into preguntas
(cadena_pregunta)
values ("HOY ES LUNES?");

INSERT INTO RESPUESTAS
(cadena_respuesta)
values("PUEDE QUE SI, PUEDE QUE NO");

/*OK*/

/**para probar que no se puede eliminar una pegunta en solitario*/ 
DELETE FROM PREGUNTAS
    WHERE ID=get_pregunta_id("CUALES SON LAS FASES DE LA LUNA?");
   
  /*OK*/
  /**para probar que no se puede eliminar una respuesta en solitario, */ 
  
  DELETE FROM RESPUESTAS
  WHERE id=get_respuesta_id("365");
      /*El disparador debe borrar la pregunta  "CUÁNTOS DÍAS TIENE EL AÑO?"*/
      
      /*OK*/
      
 /*para probar borrado de una relación inexistente"    */ 
   CALL  delete_pregunta_respuesta ("CUALES SON LAS FASES DE LA LUNA?","SI");
 /*para probar al eliminar relación elimina en preguntas y en respuestas*/  
 CALL  delete_pregunta_respuesta ("CUALES SON LAS FASES DE LA LUNA?","NUEVA, CRECIENTE, LLENA, MENGUANTE" );
 /** para probar borrar pregunta /respuesta no almacenadas */
 CALL delete_pregunta_respuesta ("hola", "adios");
 /*ok*/
 /*para probar se elimina la relación, no la pregunta, nila respuesta*/
 
 CALL delete_pregunta_respuesta("SOY GUAPO?", "SI");
 
 