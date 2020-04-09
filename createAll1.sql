DROP TABLE IF EXISTS Film CASCADE;
DROP TABLE IF EXISTS Spectateur CASCADE;
DROP TABLE IF EXISTS Abonne CASCADE;
DROP TABLE IF EXISTS Reservation CASCADE;
DROP TABLE IF EXISTS Seance CASCADE;
DROP TABLE IF EXISTS Salle CASCADE;
DROP TABLE IF EXISTS Cinema CASCADE;
DROP TABLE IF EXISTS Transaction CASCADE;
DROP TABLE IF EXISTS Programmateur CASCADE;
DROP TABLE IF EXISTS Distributeur CASCADE;
DROP TABLE IF EXISTS Contrat_De_Diffusion CASCADE;
DROP TABLE IF EXISTS Archivage CASCADE;
DROP TABLE IF EXISTS Date CASCADE;
DROP TABLE IF EXISTS Billet CASCADE;

/**********************************************************************************************************************/

create table Distributeur
(
    id_distri SERIAL PRIMARY KEY,
    nom       VARCHAR(50) NOT NULL

);

/**********************************************************************************************************************/

create table Programmateur
(
    id_prog SERIAL PRIMARY KEY,
    nom     VARCHAR(50) NOT NULL
);

/**********************************************************************************************************************/

CREATE TABLE Cinema
(
    id_cine      SERIAL PRIMARY KEY,
    adresse      VARCHAR(255) NOT NULL,
    nb_salle_max INTEGER      NOT NULL, --check pour connaitre le nombre de salles maximales
    id_prog      INTEGER      NOT NULL REFERENCES Programmateur (id_prog)
);
/**********************************************************************************************************************/

CREATE TABLE Film
(
    id_film     INTEGER PRIMARY KEY,
    titre       VARCHAR(255) NOT NULL,
    genre       VARCHAR(255) NOT NULL,
    nationalite VARCHAR(50)  NOT NULL,
    langue      VARCHAR(50)  NOT NULL,
    synopsis    text         NOT NULL,
    prix_film   FLOAT        NOT NULL,
    id_distri   INTEGER      not null REFERENCES Distributeur (id_distri)
);

/**********************************************************************************************************************/

create table Salle
(
    id_salle      SERIAL PRIMARY KEY,
    nb_places_max INTEGER NOT NULL, --check pour connaitre le nombre de place maximales
    id_cine       INTEGER NOT NULL REFERENCES Cinema (id_cine)
);

/**********************************************************************************************************************/

create table Seance
(
    id_seance       SERIAL PRIMARY KEY,
    date_seance     TIMESTAMP NOT NULL,
    tarif_abo       INTEGER   NOT NULL,
    tarif_spec      INTEGER   NOT NULL,
    nb_places_dispo INTEGER   NOT NULL,
    id_salle        INTEGER   NOT NULL REFERENCES Salle (id_salle),
    id_film         INTEGER   NOT NULL REFERENCES Film (id_film)

);

/**********************************************************************************************************************/

create table Spectateur
(
    id_spec SERIAL PRIMARY KEY,
    age     INTEGER NOT NULL

);

/**********************************************************************************************************************/

create table Abonne
(
    id_abo SERIAL PRIMARY KEY,
    nom    VARCHAR(50)  NOT NULL,
    prenom VARCHAR(50)  NOT NULL,
    sexe   VARCHAR(50)  NOT NULL,
    email  VARCHAR(255) NOT NULL
) INHERITS (Spectateur);

/**********************************************************************************************************************/

create TABLE Contrat_De_Diffusion
(
    contrat VARCHAR(255) PRIMARY KEY,
    montant INTEGER NOT NULL,
    licence text    not null,
    id_prog INTEGER NOT NULL REFERENCES Programmateur (id_prog),
    id_dist INTEGER NOT NULL REFERENCES Distributeur (id_distri)

);
/**********************************************************************************************************************/

create TABLE Date
(
    date_actuelle TIMESTAMP PRIMARY KEY
);

/**********************************************************************************************************************/


CREATE TABLE Archivage
(
    recette  float check ( recette > 0 ), --prix de toute les transaction(cout total * cpit de production)
    benefice float check ( benefice > 0),
    date     timestamp not null

);


/**********************************************************************************************************************/

create table Transaction
(
    id_trans      SERIAL PRIMARY KEY,
    date_payement timestamp NOT NULL,
    payement      float check ( payement >= 0 ),
    id_resa       INTEGER   NOT NULL

);

/**********************************************************************************************************************/

create table Reservation
(
    id_resa    SERIAL PRIMARY KEY,
    date_resa  timestamp NOT NULL,
    prix       FLOAT     NOT NULL check ( prix >= 0 ), --si abonnée alors prix de la reservation = prix * 30%
    id_spec    INTEGER   NOT NULL REFERENCES Spectateur (id_spec),
    id_trans   INTEGER   NOT NULL REFERENCES Transaction (id_trans),
    id_seances INTEGER   NOT NULL REFERENCES Seance (id_seance)
);

/**********************************************************************************************************************/

create table Billet
(
    id_billet     SERIAL PRIMARY KEY,
    numero_billet INTEGER NOT NULL,
    prix_billet   FLOAT   NOT NULL check ( prix_billet > 0 ) -- si l'user est un abonne alors le prix du billet aura une reduction sinon prix total 100%
);


/**********************************************************************************************************************/

ALTER TABLE Transaction
    ADD CONSTRAINT Transaction_Reservation_Fk
        FOREIGN KEY (id_resa)
            REFERENCES Reservation (id_resa);

ALTER TABLE Reservation
    ADD CONSTRAINT Reservation_Transaction_Fk
        FOREIGN KEY (id_trans)
            REFERENCES Transaction (id_trans);