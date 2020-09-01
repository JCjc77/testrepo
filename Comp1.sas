/*****Código para comparar el número de registros de la información publicada en el *****/
/*****BIT contra la información proporcionada en el formato fuente***********************/

/***Ajustar el nombre de la tabla a comparar, la fuentes y el servicio***/

%LET TBBIT=TD_ACC_TVRES_ITE_VA;
%LET SOURCE1=R1151H01_;
%LET SERV=ACC_TVRES;

/*****Se crea una vista de la tabla del BIT para realizar el conteo de registros****/

PROC SQL;
CREATE VIEW WORK.&SERV AS 
  SELECT *, CATS(FOLIO,ANIO,MES) AS CLAVE
  FROM DEE.&TBBIT;
QUIT;


/*****Se hace el conteo de registros presentados en el BIT****/

PROC SQL;
 CREATE TABLE WORK.CONTEO_&SERV AS
 SELECT FOLIO, CONCESIONARIO, ANIO, MES, CLAVE, COUNT(CLAVE) AS CONTEO_BIT
 FROM WORK.&SERV
 GROUP BY FOLIO, ANIO, MES;
QUIT;



PROC SORT DATA=WORK.CONTEO_&SERV NODUPKEY OUT=WORK.CONTEO_&SERV;
BY CLAVE;
RUN;

/*****Se realiza un conteo de la información de las fuentes*****/

PROC SQL;
CREATE VIEW WORK.VIEW_&SOURCE1  AS   
  SELECT *, CATS(FOLIO,C070,C071) AS CLAVE
  FROM DEE.&SOURCE1;
QUIT;


/*****Se hace el conteo de registros presentados las fuentes****/

PROC SQL;
 CREATE TABLE WORK.CONTEO_&SOURCE1 AS
 SELECT FOLIO, CONCESIONARIO, C070, C071, CLAVE, COUNT(CLAVE) AS CONTEO_&SOURCE1
 FROM WORK.VIEW_&SOURCE1
 GROUP BY FOLIO, C070, C071;
QUIT;


PROC SORT DATA=WORK.CONTEO_&SOURCE1 NODUPKEY OUT=WORK.CONTEO_&SOURCE1;
BY CLAVE;
RUN;


/*****Se hace el comparativo de los registros del BIT y la primera fuente de información*****/

PROC SQL;
CREATE TABLE DEE.COMP_&SERV AS  /*CAMBIAR A DEE POR WORK PARA  HACER PRUEBAS*/
  SELECT T1.FOLIO, T1.CONCESIONARIO, T1.ANIO, T1.MES, T1.CONTEO_BIT,
         T2.FOLIO AS FOLIO_&SOURCE1, T2.C070, T2.C071, T2.CONTEO_&SOURCE1
  from WORK.CONTEO_&SERV T1 FULL JOIN WORK.CONTEO_&SOURCE1 T2 on (T1.CLAVE=T2.CLAVE);
QUIT;

