alter session set "_ORACLE_SCRIPT"=true;

GRANT CREATE DATABASE LINK TO SGBD2_ROLE;

CREATE USER DB1 IDENTIFIED BY DB1
 DEFAULT TABLESPACE USERS
 TEMPORARY TABLESPACE TEMP
 PROFILE DEFAULT ACCOUNT UNLOCK;
ALTER USER DB1 QUOTA UNLIMITED ON USERS;
GRANT SGBD2_ROLE TO DB1;

CREATE USER DB2 IDENTIFIED BY DB2
 DEFAULT TABLESPACE USERS
 TEMPORARY TABLESPACE TEMP
 PROFILE DEFAULT ACCOUNT UNLOCK;
ALTER USER DB2 QUOTA UNLIMITED ON USERS;
GRANT SGBD2_ROLE TO DB2;

CREATE USER DB3 IDENTIFIED BY DB3
 DEFAULT TABLESPACE USERS
 TEMPORARY TABLESPACE TEMP
 PROFILE DEFAULT ACCOUNT UNLOCK;
ALTER USER DB3 QUOTA UNLIMITED ON USERS;
GRANT SGBD2_ROLE TO DB3;

CREATE USER DB4 IDENTIFIED BY DB4
 DEFAULT TABLESPACE USERS
 TEMPORARY TABLESPACE TEMP
 PROFILE DEFAULT ACCOUNT UNLOCK;
ALTER USER DB4 QUOTA UNLIMITED ON USERS;
GRANT SGBD2_ROLE TO DB4;

CREATE USER DB5 IDENTIFIED BY DB5
 DEFAULT TABLESPACE USERS
 TEMPORARY TABLESPACE TEMP
 PROFILE DEFAULT ACCOUNT UNLOCK;
ALTER USER DB5 QUOTA UNLIMITED ON USERS;
GRANT SGBD2_ROLE TO DB5;