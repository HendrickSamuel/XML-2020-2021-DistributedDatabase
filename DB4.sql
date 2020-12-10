DROP TABLE etudiant;

CREATE TABLE etudiant (
    idetudiant  VARCHAR(255) CONSTRAINT CPidEtudiant PRIMARY KEY,
    nom         VARCHAR2(80),
    prenom      VARCHAR2(80),
    section     VARCHAR(7)
);