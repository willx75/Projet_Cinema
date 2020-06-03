create table Distributeur
(
    id_distri SERIAL PRIMARY KEY,
    nom       VARCHAR(50) NOT NULL,
    vente     BOOLEAN     not null --true si le film a ete vendu false sinon
);

/**********************************************************************************************************************/

CREATE TABLE Film
(
    id_film     SERIAL PRIMARY KEY,
    titre       VARCHAR(255) NOT NULL,
    genre       VARCHAR(255) NOT NULL,
    nationalite VARCHAR(50)  NOT NULL,
    langue      VARCHAR(50)  NOT NULL,
    prix_film   FLOAT        NOT NULL,
    id_distri   INTEGER REFERENCES Distributeur (id_distri)
);
/**********************************************************************************************************************/

create table Spectateur
(
    id_spec    SERIAL PRIMARY KEY NOT NULL ,
    solde_spec INTEGER
);


/**********************************************************************************************************************/

create table Seance
(
    id_seance       SERIAL PRIMARY KEY,
    date_seance     TIMESTAMP NOT NULL,
    prix            integer,
    nb_places_vendu INTEGER,
    nb_places_max   INTEGER,
    id_film         INTEGER REFERENCES Film (id_film)

);

/**********************************************************************************************************************/

create table Transaction
(
    id_trans      SERIAL PRIMARY KEY NOT NULL,
    trans_spec    INTEGER            NOT NULL REFERENCES Abonne (id_abo),
    date_payement timestamp          NOT NULL,
    montant_trans INTEGER            NOT NULL,
    quantite      integer            not null

);

/**********************************************************************************************************************/

create table Billet
(
    id_billet     SERIAL PRIMARY KEY,
    numero_billet INTEGER NOT NULL,
    prix_billet   FLOAT   NOT NULL check ( prix_billet > 0 ),
    qte_billet    integer not null default 1,
    vendu         boolean Not null default false,
    fk_seance     INTEGER NOT NULL REFERENCES Seance (id_seance),
    fk_trans      INTEGER NOT NULL REFERENCES Transaction (id_trans)
);

/**********************************************************************************************************************/

create table Abonne
(
    id_abo   INTEGER PRIMARY KEY NULL ,
    nom      VARCHAR(50)  NOT NULL,
    prenom   VARCHAR(50)  NOT NULL,
    sexe     VARCHAR(2)   NOT NULL,
    age      INTEGER      NOT NULL check (age >= 16),
    email    VARCHAR(255) NOT NULL,
    type_abo varchar(255) NOT NULL
) INHERITS (Spectateur);


/**********************************************************************************************************************/

create table Programmateur
(
    nom_prog    VARCHAR(50) PRIMARY KEY,
    fk_abo_prog INTEGER NOT NULL REFERENCES Abonne (id_abo)
);

/**********************************************************************************************************************/

create TABLE Contrat_De_Diffusion
(
    contrat         VARCHAR(255) PRIMARY KEY,
    montant_contrat INTEGER   NOT NULL,
    licence         text      not null,
    date_signature  TIMESTAMP NOT NULL,

    fk_prog         VARCHAR   NOT NULL REFERENCES Programmateur (nom_prog),
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
    id_message  SERIAL PRIMARY KEY NOT NULL,
    expediteur  VARCHAR            NOT NULL default 'gestionnaire',
    date_envoie TIMESTAMP          NOT NULL,
    msg         text,
    fk_abo_mess INTEGER            NOT NULL REFERENCES Abonne (id_abo),
    fk_trans    INTEGER            NOT NULL REFERENCES Transaction (id_trans)
);


/**********************************************************************************************************************/

create table Reservation
(
    fk_abo    INTEGER NOT NULL REFERENCES Abonne (id_abo),
    fk_seance INTEGER NOT NULL REFERENCES Seance (id_seance),
    PRIMARY KEY (fk_abo, fk_seance),
    date_resa timestamp

);

/**********************************************************************************************************************/

create table Gestionnaire
(
    type_frais varchar(50) primary key,
    soldes     real not null default 0
);