DROP TABLE etudiant;

CREATE TABLE etudiant (
    idetudiant  VARCHAR(255) CONSTRAINT CPidEtudiant PRIMARY KEY,
    rue         VARCHAR(100),
    numero      INTEGER,
    localite    VARCHAR2(80),
    cp          INTEGER
);