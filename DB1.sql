set serveroutput on;

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

/* -- Package --*/

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
    
    PROCEDURE INSERTETUDIANT(newStudent TypeEtudiant);
    PROCEDURE UPDATEETUDIANT(newStudent TypeEtudiant, oldStudent TypeEtudiant);
    PROCEDURE DELETEETUDIANT(oldStudent TypeEtudiant);

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
    (newStudent TypeEtudiant) as
    
    BEGIN
   
        if(newStudent.cp < 5000) then
            insert into etudiant@mylink2 (idetudiant, nom, prenom, section) values (newStudent.idetudiant, newStudent.nom, newStudent.prenom, newStudent.section);
            insert into etudiant@mylink3 (idetudiant, rue, numero, localite, cp) values (newStudent.idetudiant, newStudent.rue, newStudent.numero, newStudent.localite, newStudent.cp);
        else
            insert into etudiant@mylink4 (idetudiant, nom, prenom, section) values (newStudent.idetudiant, newStudent.nom, newStudent.prenom, newStudent.section);
            insert into etudiant@mylink5 (idetudiant, rue, numero, localite, cp) values (newStudent.idetudiant, newStudent.rue, newStudent.numero, newStudent.localite, newStudent.cp);
        end if;
        COMMIT;
        
        exception
    when others then raise;
    END INSERTETUDIANT;
    
PROCEDURE DELETEETUDIANT(oldStudent TypeEtudiant) AS
BEGIN
    DELETE FROM etudiant@mylink2 WHERE idetudiant = oldStudent.idetudiant;
    DELETE FROM etudiant@mylink3 WHERE idetudiant = oldStudent.idetudiant;
    DELETE FROM etudiant@mylink4 WHERE idetudiant = oldStudent.idetudiant;
    DELETE FROM etudiant@mylink5 WHERE idetudiant = oldStudent.idetudiant;
    COMMIT;
end DELETEETUDIANT;
    
PROCEDURE UPDATEETUDIANT
(newStudent TypeEtudiant,oldStudent TypeEtudiant) as

BEGIN

    if(oldStudent.cp < 5000 AND newStudent.cp >= 5000 OR oldStudent.cp >= 5000 AND newStudent.cp < 5000) then
        ETUDIANTPACKAGE.DELETEETUDIANT(oldStudent);
        ETUDIANTPACKAGE.INSERTETUDIANT(newStudent);
    else
        if(oldStudent.cp < 5000) then
            update etudiant@mylink2 set nom = newStudent.nom, prenom = newStudent.prenom, section = newStudent.section where idetudiant = oldStudent.idetudiant;
            update etudiant@mylink3 set rue = newStudent.rue, numero = newStudent.numero, localite = newStudent.localite, cp = newStudent.cp where idetudiant = oldStudent.idetudiant;        
        else
            update etudiant@mylink4 set nom = newStudent.nom, prenom = newStudent.prenom, section = newStudent.section where idetudiant = oldStudent.idetudiant;
            update etudiant@mylink5 set rue = newStudent.rue, numero = newStudent.numero, localite = newStudent.localite, cp = newStudent.cp where idetudiant = oldStudent.idetudiant;
        end if;
    end if;

end UPDATEETUDIANT;

END ETUDIANTPACKAGE;



/* -- Population de la base de donnée--*/

set serveroutput on;

declare
    newStudentToInsert ETUDIANTPACKAGE.TypeEtudiant;
    begin
        newStudentToInsert.idetudiant := '#etud-01'; newStudentToInsert.nom := 'Beck'; newStudentToInsert.prenom := 'Thomas'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Du lapin'; newStudentToInsert.numero := 9; newStudentToInsert.localite := 'Seraing'; newStudentToInsert.cp := 4000;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-02'; newStudentToInsert.nom := 'Collette'; newStudentToInsert.prenom := 'Loic'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'De la revision'; newStudentToInsert.numero := 44; newStudentToInsert.localite := 'Chennee'; newStudentToInsert.cp := 4032;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-03'; newStudentToInsert.nom := 'Delaval'; newStudentToInsert.prenom := 'Kevin'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Francois Michoel'; newStudentToInsert.numero := 222; newStudentToInsert.localite := 'Sart-lez-Spa'; newStudentToInsert.cp := 4845;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-04'; newStudentToInsert.nom := 'Brandt'; newStudentToInsert.prenom := 'Fabian'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Haies de la brassine'; newStudentToInsert.numero := 24; newStudentToInsert.localite := 'Neupre'; newStudentToInsert.cp := 4120;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-05'; newStudentToInsert.nom := 'Khamana bantu'; newStudentToInsert.prenom := 'Benedict'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Route dhonneux'; newStudentToInsert.numero := 41; newStudentToInsert.localite := 'Heusy'; newStudentToInsert.cp := 4802;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-06'; newStudentToInsert.nom := 'John'; newStudentToInsert.prenom := 'Doe'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Du soleil'; newStudentToInsert.numero := 320; newStudentToInsert.localite := 'Liege'; newStudentToInsert.cp := 4000;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-07'; newStudentToInsert.nom := 'John'; newStudentToInsert.prenom := 'Doe'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Du soleil'; newStudentToInsert.numero := 320; newStudentToInsert.localite := 'Liege'; newStudentToInsert.cp := 4000;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-08'; newStudentToInsert.nom := 'John'; newStudentToInsert.prenom := 'Doe'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Du soleil'; newStudentToInsert.numero := 320; newStudentToInsert.localite := 'Liege'; newStudentToInsert.cp := 4000;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-09'; newStudentToInsert.nom := 'John'; newStudentToInsert.prenom := 'Doe'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Du soleil'; newStudentToInsert.numero := 320; newStudentToInsert.localite := 'Liege'; newStudentToInsert.cp := 4000;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-10'; newStudentToInsert.nom := 'John'; newStudentToInsert.prenom := 'Doe'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Du soleil'; newStudentToInsert.numero := 320; newStudentToInsert.localite := 'Liege'; newStudentToInsert.cp := 4000;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);     

        newStudentToInsert.idetudiant := '#etud-11'; newStudentToInsert.nom := 'John'; newStudentToInsert.prenom := 'One'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Du soleil'; newStudentToInsert.numero := 320; newStudentToInsert.localite := 'Liege'; newStudentToInsert.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-12'; newStudentToInsert.nom := 'John'; newStudentToInsert.prenom := 'Two'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Du soleil'; newStudentToInsert.numero := 320; newStudentToInsert.localite := 'Liege'; newStudentToInsert.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-13'; newStudentToInsert.nom := 'John'; newStudentToInsert.prenom := 'Three'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Du soleil'; newStudentToInsert.numero := 320; newStudentToInsert.localite := 'Liege'; newStudentToInsert.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-14'; newStudentToInsert.nom := 'John'; newStudentToInsert.prenom := 'Four'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Du soleil'; newStudentToInsert.numero := 320; newStudentToInsert.localite := 'Liege'; newStudentToInsert.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-15'; newStudentToInsert.nom := 'John'; newStudentToInsert.prenom := 'Five'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Du soleil'; newStudentToInsert.numero := 320; newStudentToInsert.localite := 'Liege'; newStudentToInsert.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-16'; newStudentToInsert.nom := 'John'; newStudentToInsert.prenom := 'Six'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Du soleil'; newStudentToInsert.numero := 320; newStudentToInsert.localite := 'Liege'; newStudentToInsert.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-17'; newStudentToInsert.nom := 'John'; newStudentToInsert.prenom := 'Seven'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Du soleil'; newStudentToInsert.numero := 320; newStudentToInsert.localite := 'Liege'; newStudentToInsert.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-18'; newStudentToInsert.nom := 'John'; newStudentToInsert.prenom := 'Eight'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Du soleil'; newStudentToInsert.numero := 320; newStudentToInsert.localite := 'Liege'; newStudentToInsert.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-19'; newStudentToInsert.nom := 'John'; newStudentToInsert.prenom := 'Nine'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Du soleil'; newStudentToInsert.numero := 320; newStudentToInsert.localite := 'Liege'; newStudentToInsert.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

        newStudentToInsert.idetudiant := '#etud-20'; newStudentToInsert.nom := 'John'; newStudentToInsert.prenom := 'Ten'; newStudentToInsert.section := '2302';
        newStudentToInsert.rue := 'Du soleil'; newStudentToInsert.numero := 320; newStudentToInsert.localite := 'Liege'; newStudentToInsert.cp := 6000;             
        ETUDIANTPACKAGE.insertetudiant(newStudentToInsert);

exception
when others then
    dbms_output.put_line('erreur insert etudiant');
end;

