DROP TABLE IF EXISTS Films CASCADE;
DROP TABLE IF EXISTS Spectateurs CASCADE;
DROP TABLE IF EXISTS Reservation CASCADE;
DROP TABLE IF EXISTS Seance CASCADE;
DROP TABLE IF EXISTS Salle CASCADE;
DROP TABLE IF EXISTS Cinema CASCADE;
DROP TABLE IF EXISTS Payement CASCADE;
DROP TABLE IF EXISTS Programmateurs CASCADE;
DROP TABLE IF EXISTS Distributeurs CASCADE;
DROP TABLE IF EXISTS Contrat_De_Diffusion CASCADE;

create table Distributeurs
(
    id_distri SERIAL PRIMARY KEY

);

CREATE TABLE Films
(
    id_films    SERIAL PRIMARY KEY,
    titre       VARCHAR(255) NOT NULL,
    genre       VARCHAR(255) NOT NULL,
    nationalite VARCHAR(50)  NOT NULL,
    langue      VARCHAR(50)  NOT NULL,
    synopsis    text         NOT NULL,
    prix_film   FLOAT        NOT NULL,
    id_distri   INTEGER      not null,

    CONSTRAINT distri_film foreign key (id_distri)
        REFERENCES Distributeurs (id_distri)
);

create table Seances
(
    id_seances SERIAL PRIMARY KEY,
    date       timestamp not null,
    tarif      integer   not null,
    id_films   INTEGER   NOT NULL
        REFERENCES Films (id_films),
    id_salles  INTEGER   NOT NULL
        REFERENCES Seances (id_salles)
);

create table Salles
(
    id_salles    SERIAL PRIMARY KEY,
    ecrans       INTEGER NOT NULL, -- check si le nombre d'ecran est superieur ou non a la capacite de films qui seront produit  --
    nb_place_max integer not null, --check pour connaitre le nombre de place maximales
    id_cine      INTEGER NOT NULL,

    CONSTRAINT salles_cine FOREIGN KEY (id_cine)
        REFERENCES Cinema (id_cine)
);   

CREATE TABLE Cinema
(
    id_cine      SERIAL PRIMARY KEY,
    adresse      VARCHAR(255) NOT NULL,
    nb_salle_max INTEGER      NOT NULL, --check pour connaitre le nombre de salles maximales
    id_prog      INTEGER      NOT NULL,

    CONSTRAINT cinema_prog FOREIGN KEY (id_prog)
        REFERENCES Programmateurs (id_prog)
);

create table Programmateurs
(
    id_prog SERIAL PRIMARY KEY
);



create table Spectateurs
(
    id_spec SERIAL PRIMARY KEY,
    nom     VARCHAR(50)  NOT NULL,
    prenom  VARCHAR(50)  NOT NULL,
    age     INTEGER      NOT NULL,
    email   VARCHAR(255) NOT NULL,
    abonnes BOOLEAN      NOT NULL --true = reduction prix des billets false = payement du billet a 100%

);

create table Reservation
(
    id_resa     SERIAL PRIMARY KEY,
    date_resa   timestamp NOT NULL,
    prix        FLOAT     NOT NULL check ( prix >= 0 ), --si abonnée alors prix de la reservation = prix * 30%
    pseudo      INTEGER   NOT NULL,
    REFERENCES  Spectateurs(pseudo),
    id_payement INTEGER   NOT NULL,
    REFERENCES  Payement(id_payement),
    id_seances  INTEGER   NOT NULL
        REFERENCES Seances (id_seances)


);

create table Payement
(
    id_payement   SERIAL PRIMARY KEY,
    date_payement timestamp NOT NULL,
    transaction   float check ( transaction >= 0 ),
    recette       float check ( recette > 0 ), --prix de toute les transaction(cout total * cpit de production)
    benefice      float check ( benefice > 0),--
    id_resa       INTEGER   NOT NULL,

    CONSTRAINT payement_resa FOREIGN KEY (id_resa)
        REFERENCES Reservation (id_payement)

);


create TABLE Contrat_De_Diffusion
(
    --  id_distri SERIAL PRIMARY KEY,
    id_prog SERIAL PRIMARY KEY
);
