DROP TABLE IF EXISTS Film CASCADE;
DROP TABLE IF EXISTS Spectateur CASCADE;
DROP TABLE IF EXISTS Abonne CASCADE;
DROP TABLE IF EXISTS Seance CASCADE;
DROP TABLE IF EXISTS Transaction CASCADE;
DROP TABLE IF EXISTS Programmateur CASCADE;
DROP TABLE IF EXISTS Reservation CASCADE;
DROP TABLE IF EXISTS Distributeur CASCADE;
DROP TABLE IF EXISTS Contrat_De_Diffusion CASCADE;
DROP TABLE IF EXISTS Date CASCADE;
DROP TABLE IF EXISTS Billet CASCADE;
DROP TABLE IF EXISTS Message CASCADE;


/**********************************************************************************************************************/

create table Distributeur
(
    id_distri SERIAL PRIMARY KEY,
    nom       VARCHAR(50) NOT NULL,
    vente     BOOLEAN     not null --true si le film a ete vendu false sinon
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

create table Spectateur
(
    id_spec    SERIAL PRIMARY KEY,
    age        INTEGER NOT NULL,
    solde_spec INTEGER NOT NULL

);
/**********************************************************************************************************************/

create table Billet
(
    id_billet     SERIAL PRIMARY KEY,
    numero_billet INTEGER NOT NULL,
    prix_billet   FLOAT   NOT NULL check ( prix_billet > 0 ),-- si l'user est un abonne alors le prix du billet aura une reduction sinon prix total 100%
    vendu         boolean Not null default false
);

/**********************************************************************************************************************/

create table Seance
(
    id_seance       SERIAL PRIMARY KEY,
    date_seance     TIMESTAMP NOT NULL,
    nb_places_dispo INTEGER   NOT NULL,

    id_film         INTEGER   NOT NULL REFERENCES Film (id_film),
    id_billet       INTEGER   NOT NULL REFERENCES Billet (id_billet)

);

/**********************************************************************************************************************/

create table Transaction
(
    id_trans      SERIAL PRIMARY KEY,
    trans_spec    INTEGER   NOT NULL REFERENCES Spectateur (id_spec),
    date_payement timestamp NOT NULL,
    quantité      INTEGER   NOT NULL,
    id_seance     INTEGER   NOT NULL REFERENCES Seance (id_seance)

);







/**********************************************************************************************************************/

create table Programmateur
(
    id_prog SERIAL PRIMARY KEY,
    nom     VARCHAR(50) NOT NULL,
    solde   float       not null check ( solde > 0 ),

    id_spec INTEGER     NOT NULL REFERENCES Spectateur (id_spec)
);


/**********************************************************************************************************************/

create table Abonne
(
    id_abo   SERIAL PRIMARY KEY,
    nom      VARCHAR(50)  NOT NULL,
    prenom   VARCHAR(50)  NOT NULL,
    sexe     VARCHAR(50)  NOT NULL,
    email    VARCHAR(255) NOT NULL,
    type_abo varchar(255) NOT NULL -- true = abonnement -26 ans ilimité false = abonnement +26 ans
) INHERITS (Spectateur);


/**********************************************************************************************************************/

create TABLE Contrat_De_Diffusion
(
    contrat         VARCHAR(255) PRIMARY KEY,
    montant_contrat INTEGER   NOT NULL,
    licence         text      not null,
    date_signature  TIMESTAMP NOT NULL,

    id_prog         INTEGER   NOT NULL REFERENCES Programmateur (id_prog),
    id_dist         INTEGER   NOT NULL REFERENCES Distributeur (id_distri)

);
/**********************************************************************************************************************/

create TABLE Date
(
    date_actuelle TIMESTAMP PRIMARY KEY
);


/**********************************************************************************************************************/

create table Message
(
    id_message  SERIAL PRIMARY KEY,
    expediteur  VARCHAR   NOT NULL,
    date_envoie TIMESTAMP NOT NULL,

    id_spec     INTEGER   NOT NULL REFERENCES Spectateur (id_spec)
);


/**********************************************************************************************************************/

create table Reservation
(
    id_resa   SERIAL PRIMARY KEY,
    date_resa timestamp NOT NULL,
    type_resa boolean   not null, -- true si abo false sinon

    id_spec   INTEGER   NOT NULL REFERENCES Spectateur (id_spec)
);

/**********************************************************************************************************************/

