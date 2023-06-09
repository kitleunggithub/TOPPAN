-- Create TABLEAUUSER
CREATE USER "TABLEAUUSER" IDENTIFIED BY "Welcome1"  
DEFAULT TABLESPACE "USERS"
TEMPORARY TABLESPACE "TEMP";

-- ROLE
GRANT CONNECT, RESOURCE TO TABLEAUUSER;
GRANT UNLIMITED TABLESPACE TO TABLEAUUSER;
GRANT SELECT ANY TABLE TO "TABLEAUUSER" ;

-- Create TABLEAUETL
CREATE USER "TABLEAUETL" IDENTIFIED BY "Welcome1"  
DEFAULT TABLESPACE "USERS"
TEMPORARY TABLESPACE "TEMP";

-- ROLE
GRANT CONNECT, RESOURCE TO TABLEAUETL;
GRANT UNLIMITED TABLESPACE TO TABLEAUETL;

-- SYSTEM PRIVILEGES
GRANT DROP ANY TRIGGER TO "TABLEAUETL" ;
GRANT ALTER ANY INDEX TO "TABLEAUETL" ;
GRANT DROP ANY SEQUENCE TO "TABLEAUETL" ;
GRANT CREATE ANY PROCEDURE TO "TABLEAUETL" ;
GRANT CREATE ANY INDEX TO "TABLEAUETL" ;
GRANT CREATE ANY SEQUENCE TO "TABLEAUETL" ;
GRANT CREATE VIEW TO "TABLEAUETL" ;
GRANT ALTER ANY TABLE TO "TABLEAUETL" ;
GRANT CREATE TABLE TO "TABLEAUETL" ;
GRANT DROP ANY TABLE TO "TABLEAUETL" ;
GRANT DROP ANY TYPE TO "TABLEAUETL" ;
GRANT CREATE ANY SYNONYM TO "TABLEAUETL" ;
GRANT EXECUTE ANY PROCEDURE TO "TABLEAUETL" ;
GRANT EXECUTE ANY TYPE TO "TABLEAUETL" ;
GRANT DROP ANY INDEX TO "TABLEAUETL" ;
GRANT UPDATE ANY TABLE TO "TABLEAUETL" ;
GRANT DROP ANY VIEW TO "TABLEAUETL" ;
GRANT ALTER ANY TRIGGER TO "TABLEAUETL" ;
GRANT CREATE ANY VIEW TO "TABLEAUETL" ;
GRANT DROP PUBLIC SYNONYM TO "TABLEAUETL" ;
GRANT ALTER ANY TYPE TO "TABLEAUETL" ;
GRANT DROP ANY PROCEDURE TO "TABLEAUETL" ;
GRANT CREATE ANY TRIGGER TO "TABLEAUETL" ;
GRANT CREATE ANY TABLE TO "TABLEAUETL" ;
GRANT CREATE ANY TYPE TO "TABLEAUETL" ;
GRANT CREATE PUBLIC SYNONYM TO "TABLEAUETL" ;


--GRANT SELECT, INSERT, UPDATE, DELETE ON schema. books TO books_admin;