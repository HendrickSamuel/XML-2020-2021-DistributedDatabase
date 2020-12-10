--set serveroutput on

create database link mylink2
connect to DB2 Identified by DB2
using '(DESCRIPTION=
        (ADDRESS_LIST=
        (ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521)))
        (CONNECT_DATA= (SERVER=DEDICATED)
        (SERVICE_NAME=xe)))';
        
create database link mylink3
connect to DB3 Identified by DB3
using '(DESCRIPTION=
        (ADDRESS_LIST=
        (ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521)))
        (CONNECT_DATA= (SERVER=DEDICATED)
        (SERVICE_NAME=xe)))';

create database link mylink4
connect to DB4 Identified by DB4
using '(DESCRIPTION=
        (ADDRESS_LIST=
        (ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521)))
        (CONNECT_DATA= (SERVER=DEDICATED)
        (SERVICE_NAME=xe)))';

create database link mylink5
connect to DB5 Identified by DB5
using '(DESCRIPTION=
        (ADDRESS_LIST=
        (ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521)))
        (CONNECT_DATA= (SERVER=DEDICATED)
        (SERVICE_NAME=xe)))';

------------------PACKAGE-------------

create or replace PACKAGE ETUDIANTPACKAGE AS 

    Type TypeEtudiant is record (
        idetudiant VARCHAR(255),
        nom VARCHAR2(80),
        prenom VARCHAR2(80),
        section VARCHAR2(7),
        rue VARCHAR(100),
        numero INTEGER,
        localite VARCHAR2(80),
        cp INTEGER
        );
    Type TypeTabEtudiant is Table of TypeEtudiant index by binary_integer;
    Function SelectEtudiant return TypeTabEtudiant;
    
    PROCEDURE INSERTETUDIANT(newEtudiants in TypeEtudiant);

END ETUDIANTPACKAGE;


create or replace PACKAGE BODY ETUDIANTPACKAGE AS

    Function SelectEtudiant return TypeTabEtudiant 
    AS
    tabretour TypeTabEtudiant;
    BEGIN
        select distinct idetudiant,nom, prenom, section, rue, numero, localite, cp bulk collect into tabretour 
        from etudiant@mylink2 link2 JOIN etudiant@mylink3 link3 USING(idetudiant)
        union
        select distinct idetudiant,nom, prenom, section, rue, numero, localite, cp
        from etudiant@mylink4 link4 JOIN etudiant@mylink5 link5 USING(idetudiant);

    return tabretour;

    exception
    when others then raise;
    END SelectEtudiant;
    
    PROCEDURE INSERTETUDIANT 
    (newEtudiants in TypeEtudiant) as
    
    BEGIN
        if(newEtudiants.cp < 5000) then
            insert into etudiant@mylink2 (idetudiant, nom, prenom, section) values (newEtudiants.idetudiant, newEtudiants.nom, newEtudiants.prenom, newEtudiants.section);
            insert into etudiant@mylink3 (idetudiant, rue, numero, localite, cp) values (newEtudiants.idetudiant, newEtudiants.rue, newEtudiants.numero, newEtudiants.localite, newEtudiants.cp);
        else
            insert into etudiant@mylink4 (idetudiant, nom, prenom, section) values (newEtudiants.idetudiant, newEtudiants.nom, newEtudiants.prenom, newEtudiants.section);
            insert into etudiant@mylink5 (idetudiant, rue, numero, localite, cp) values (newEtudiants.idetudiant, newEtudiants.rue, newEtudiants.numero, newEtudiants.localite, newEtudiants.cp);
        end if;
        COMMIT;
        
        exception
    when others then raise;
    END INSERTETUDIANT;

END ETUDIANTPACKAGE;



-------------------------TEST------------------
set serveroutput on;



declare
    newetudiant ETUDIANTPACKAGE.TypeEtudiant;
    begin
        newetudiant.idetudiant := '#etud-01'; newetudiant.nom := 'Beck'; newetudiant.prenom := 'Thomas'; newetudiant.section := '2302';
        newetudiant.rue := 'Du lapin'; newetudiant.numero := 9; newetudiant.localite := 'Seraing'; newetudiant.cp := 4000;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-02'; newetudiant.nom := 'Collette'; newetudiant.prenom := 'Loic'; newetudiant.section := '2302';
        newetudiant.rue := 'De la revision'; newetudiant.numero := 44; newetudiant.localite := 'Chennee'; newetudiant.cp := 4032;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-03'; newetudiant.nom := 'Delaval'; newetudiant.prenom := 'Kevin'; newetudiant.section := '2302';
        newetudiant.rue := 'Francois Michoel'; newetudiant.numero := 222; newetudiant.localite := 'Sart-lez-Spa'; newetudiant.cp := 4845;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-04'; newetudiant.nom := 'Brandt'; newetudiant.prenom := 'Fabian'; newetudiant.section := '2302';
        newetudiant.rue := 'Haies de la brassine'; newetudiant.numero := 24; newetudiant.localite := 'Neupre'; newetudiant.cp := 4120;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-05'; newetudiant.nom := 'Khamana bantu'; newetudiant.prenom := 'Benedict'; newetudiant.section := '2302';
        newetudiant.rue := 'Route dhonneux'; newetudiant.numero := 41; newetudiant.localite := 'Heusy'; newetudiant.cp := 4802;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-06'; newetudiant.nom := 'John'; newetudiant.prenom := 'Doe'; newetudiant.section := '2302';
        newetudiant.rue := 'Du soleil'; newetudiant.numero := 320; newetudiant.localite := 'Liege'; newetudiant.cp := 4000;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-07'; newetudiant.nom := 'John'; newetudiant.prenom := 'Doe'; newetudiant.section := '2302';
        newetudiant.rue := 'Du soleil'; newetudiant.numero := 320; newetudiant.localite := 'Liege'; newetudiant.cp := 4000;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-08'; newetudiant.nom := 'John'; newetudiant.prenom := 'Doe'; newetudiant.section := '2302';
        newetudiant.rue := 'Du soleil'; newetudiant.numero := 320; newetudiant.localite := 'Liege'; newetudiant.cp := 4000;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-09'; newetudiant.nom := 'John'; newetudiant.prenom := 'Doe'; newetudiant.section := '2302';
        newetudiant.rue := 'Du soleil'; newetudiant.numero := 320; newetudiant.localite := 'Liege'; newetudiant.cp := 4000;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-10'; newetudiant.nom := 'John'; newetudiant.prenom := 'Doe'; newetudiant.section := '2302';
        newetudiant.rue := 'Du soleil'; newetudiant.numero := 320; newetudiant.localite := 'Liege'; newetudiant.cp := 4000;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);     

        newetudiant.idetudiant := '#etud-11'; newetudiant.nom := 'John'; newetudiant.prenom := 'One'; newetudiant.section := '2302';
        newetudiant.rue := 'Du soleil'; newetudiant.numero := 320; newetudiant.localite := 'Liege'; newetudiant.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-12'; newetudiant.nom := 'John'; newetudiant.prenom := 'Two'; newetudiant.section := '2302';
        newetudiant.rue := 'Du soleil'; newetudiant.numero := 320; newetudiant.localite := 'Liege'; newetudiant.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-13'; newetudiant.nom := 'John'; newetudiant.prenom := 'Three'; newetudiant.section := '2302';
        newetudiant.rue := 'Du soleil'; newetudiant.numero := 320; newetudiant.localite := 'Liege'; newetudiant.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-14'; newetudiant.nom := 'John'; newetudiant.prenom := 'Four'; newetudiant.section := '2302';
        newetudiant.rue := 'Du soleil'; newetudiant.numero := 320; newetudiant.localite := 'Liege'; newetudiant.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-15'; newetudiant.nom := 'John'; newetudiant.prenom := 'Five'; newetudiant.section := '2302';
        newetudiant.rue := 'Du soleil'; newetudiant.numero := 320; newetudiant.localite := 'Liege'; newetudiant.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-16'; newetudiant.nom := 'John'; newetudiant.prenom := 'Six'; newetudiant.section := '2302';
        newetudiant.rue := 'Du soleil'; newetudiant.numero := 320; newetudiant.localite := 'Liege'; newetudiant.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-17'; newetudiant.nom := 'John'; newetudiant.prenom := 'Seven'; newetudiant.section := '2302';
        newetudiant.rue := 'Du soleil'; newetudiant.numero := 320; newetudiant.localite := 'Liege'; newetudiant.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-18'; newetudiant.nom := 'John'; newetudiant.prenom := 'Eight'; newetudiant.section := '2302';
        newetudiant.rue := 'Du soleil'; newetudiant.numero := 320; newetudiant.localite := 'Liege'; newetudiant.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-19'; newetudiant.nom := 'John'; newetudiant.prenom := 'Nine'; newetudiant.section := '2302';
        newetudiant.rue := 'Du soleil'; newetudiant.numero := 320; newetudiant.localite := 'Liege'; newetudiant.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

        newetudiant.idetudiant := '#etud-20'; newetudiant.nom := 'John'; newetudiant.prenom := 'Ten'; newetudiant.section := '2302';
        newetudiant.rue := 'Du soleil'; newetudiant.numero := 320; newetudiant.localite := 'Liege'; newetudiant.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newetudiant);

exception
when others then
    dbms_output.put_line('erreur insert etudiant');
end;

/*
declare
    v_return packageetudiant.typetabetudiant;
    begin
        v_return := packageetudiant.selectetudiant();
        for i in v_return.first..v_return.last
        loop
            DBMS_OUTPUT.PUT_LINE('Nom : ' || v_return(i).nom || ' ' || 'Prenom : ' || v_return(i).prenom || ' ');
        end loop;
    exception
        when others then
            DBMS_OUTPUT.PUT_LINE('Erreur ');
    end;
  */      
  

/*
DECLARE
  NEWETUDIANTS etudiant%rowtype;
  OLDETUDIANT etudiant%rowtype;
BEGIN
 
  select etudiant.idetudiant@mylink2, nom, prenom, section, rue, numero, localite, cp into OLDETUDIANT from etudiant@mylink2, etudiant@mylink3 
  where etudiant.idetudiant@mylink2 = etudiant.idetudiant@mylink3
  and etudiant.idetudiant@mylink2 = 23;
  
  select etudiant.idetudiant@mylink2, nom, prenom, section, rue, numero, localite, cp into NEWETUDIANTS from etudiant@mylink2, etudiant@mylink3 
  where etudiant.idetudiant@mylink2 = etudiant.idetudiant@mylink3
  and etudiant.idetudiant@mylink2 = 23;
  NEWETUDIANTS.nom := 'Samuel';

  UPDATEETUDIANT(
    NEWETUDIANTS => NEWETUDIANTS,
    OLDETUDIANT => OLDETUDIANT
  );
--rollback; 
END;


DECLARE
    v_Return DB1.etudiantpackage.TypeTabEtudiant;
BEGIN 
    v_Return := etudiantpackage.selectetudiant();
    
    FOR i IN v_Return.FIRST..v_Return.LAST
    LOOP
        DBMS_OUTPUT.PUT_LINE('[Nom: ' || v_Return(i).nom || ']' );
    END LOOP;
    
    EXCEPTION 
        WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('Erreur : '||SQLERRM);
END;
*/


/*
select * from etudiant@mylink2;
select * from etudiant@mylink3;
select * from etudiant@mylink4;
select * from etudiant@mylink5;
*/