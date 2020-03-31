DROP FUNCTION IF EXISTS getDate();
DROP FUNCTION IF EXISTS creationFilm(id_films INTEGER, titre varchar, genre varchar, nationalite varchar, langues varchar, synopsis varchar, prix_film integer);
DROP FUNCTION IF EXISTS creationSpectateurs(id_spec INTEGER, nom varchar, prenom varchar, age int, email varchar, synopsis varchar);
DROP FUNCTION IF EXISTS creationReservation(id_resa INTEGER, date_resa TIMESTAMP, prix INTEGER);
DROP FUNCTION IF EXISTS creationSeances(id_seances INTEGER, date TIMESTAMP, tarif INTEGER);
DROP FUNCTION IF EXISTS creationSalles (id_salles INTEGER, ecrans INTEGER, nb_place_max INTEGER);
DROP FUNCTION IF EXISTS creationCinema (id_cinema INTEGER, adresse VARCHAR, nb_salle_max INTEGER);
DROP FUNCTION IF EXISTS creationPayement (id_payement INTEGER, date_payement INTEGER, prix_film INTEGER, recette INTEGER, benefice INTEGER);
DROP FUNCTION IF EXISTS creationProgrammateur(id_prog INTEGER);
DROP FUNCTION IF EXISTS creationDistributeur(id_distri INTEGER);


DROP FUNCTION IF EXISTS addOneDay();
DROP FUNCTION IF EXISTS addOneWeek();
DROP FUNCTION IF EXISTS addOneMonth();


/***********************************************************************************************************/


-- Insert la date du jour dans la table si elle est vide. Retourne la date.
create or replace function getDate() returns timestamp as
$$
begin

    IF (SELECT COUNT(*) FROM Date) = 0 THEN
        INSERT INTO Date(date_actuelle) VALUES (CURRENT_DATE);
    END IF;
    RETURN (SELECT date_actuelle FROM Date LIMIT 1);

end;

$$ LANGUAGE plpgsql;

/***********************************************************************************************************/

------ Creation d'un film

create or replace function creationFilm(id_films INTEGER, titre VARCHAR(255), genre varchar(255),
                                        nationalite varchar(255), langues varchar(255), synopsis varchar(255),
                                        montant_film integer) returns void as
$$
begin
    if id_films is NULL OR id_films = 0 then
        RAISE EXCEPTION 'films is null' ;
    elsif titre is null or titre = '' then
        raise EXCEPTION 'titre is null' ;
    elsif genre is null or genre = '' then
        raise EXCEPTION 'genre is null';
    elsif nationalite is null or nationalite = '' then
        raise EXCEPTION 'nationalite is null';
    elsif langues is null or langues = '' then
        raise EXCEPTION 'langues is null';
    elsif synopsis is null or synopsis = '' then
        raise EXCEPTION 'synopsis is null';
    elsif montant_film is null then
        raise EXCEPTION 'montant is null';

    ELSE
        INSERT INTO Films(id_films, titre, genre, nationalite, langue, synopsis, prix_film, id_distri)
        VALUES (id_films, titre, genre, nationalite, langue, synopsis, prix_film, id_distri);
    end if;
end ;

$$ LANGUAGE plpgsql;

/***********************************************************************************************************/

--Creation d'un spectateurs ---

create or replace function creationSpectateurs(id_spec INTEGER, nom varchar, prenom varchar, age int,
                                               email varchar, abonnes boolean) returns void as
$$
begin
    if id_spec is null or id_spec = 0 then
        raise EXCEPTION 'spectateur is null' ;
    elsif nom is null or nom = '' then
        raise exception 'Name is null' ;
    elsif prenom is null or prenom = '' then
        raise exception 'Prenom is null' ;
    elsif age is null then
        raise exception 'age is null' ;
    elsif email is null then
        raise exception 'email is null' ;
    elsif abonnes is null then
        raise exception 'abonne is null';

    ELSE
        INSERT INTO Spectateurs(id_spec, nom, prenom, age, email, abonnes)
        VALUES (id_spec, nom, prenom, age, email, abonnes);
    end if;
end;
$$ LANGUAGE plpgsql;

/***********************************************************************************************************/

--Creation d'une reservation ---

create or replace function creationReservation(id_resa INTEGER, date_resa timestamp, prix INTEGER) returns void as
$$
begin
    if id_resa is null or id_resa = 0 then
        RAISE EXCEPTION 'reservation is null';
    elsif date_resa IS NULL or date_resa <= getDate() THEN
        RAISE EXCEPTION 'Date de reservation est valide';
    elsif prix is null then
        RAISE EXCEPTION 'Prix is null ';

    ELSE
        INSERT INTO Reservation(id_resa, date_resa, prix, id_spec, id_payement, id_seances)
        VALUES (id_resa, date_resa, prix, id_spec, id_payement, id_seances);
    end if;
end ;

$$ LANGUAGE plpgsql;

/***********************************************************************************************************/

--Creation d'une seances ---

CREATE OR REPLACE FUNCTION creationSeances(id_seances INTEGER, date_seance TIMESTAMP, tarif INTEGER) returns void as
$$
BEGIN
    if id_seances is null or id_seances = 0 then
        RAISE EXCEPTION 'seances is null' ;
    elsif date_seance is NULL OR date_seance >= getDate() THEN
        RAISE EXCEPTION 'Date de la seance est valide ' ;
    elsif tarif IS NULL THEN
        RAISE EXCEPTION 'Tarif is null';
    ELSE
        INSERT INTO Seances(id_seances, date_seance, tarif, id_films, id_salles)
        VALUES (id_seances, date_seance, tarif, id_films, id_salles);
    end if;
end;


$$ LANGUAGE plpgsql;

/***********************************************************************************************************/

--Creation d'une salle ---

CREATE OR REPLACE FUNCTION creationSalles(id_salles INTEGER, nb_places_max INTEGER, ecrans INTEGER) RETURNS VOID AS
$$
BEGIN
    IF id_salles is null or id_salles = 0 then
        RAISE EXCEPTION 'salles is null';
    elsif nb_places_max IS NULL then
        RAISE EXCEPTION 'le nombre de place est null ';
    elsif ecrans IS NULL THEN
        RAISE EXCEPTION 'le nombre d"ecran est null';

    ELSE
        INSERT INTO Salles(id_salles, ecrans, nb_places_max, id_cine)
        VALUES (id_salles, ecrans, nb_places_max, id_cine);

    end if;
end;
$$ LANGUAGE plpgsql;

/***********************************************************************************************************/


--creation d'un cinéma --

CREATE OR REPLACE FUNCTION creationCinema(id_cinema INTEGER, adresse VARCHAR, nb_salle_max INTEGER) RETURNS VOID AS
$$
BEGIN
    IF id_cinema is null or id_cinema = 0 THEN
        RAISE EXCEPTION 'cinema is null';
    elsif adresse is null or adresse = '' THEN
        RAISE EXCEPTION 'adressse is null';
    elsif nb_salle_max is null THEN
        RAISE EXCEPTION 'le nombre de salle est null';

    ELSE
        INSERT INTO Cinema(id_cine, adresse, nb_salle_max, id_prog)
        VALUES (id_cine, adresse, nb_salle_max, id_prog);
    end if;
end ;
$$ LANGUAGE plpgsql;

/***********************************************************************************************************/

--- creation d'une transaction

CREATE OR REPLACE FUNCTION creationPayement(id_payement INTEGER, date_payement INTEGER, prix_film INTEGER,
                                            recette INTEGER, benefice INTEGER) RETURNS VOID AS
$$
BEGIN
    IF id_payement is null or id_payement = 0 THEN
        RAISE EXCEPTION 'payement is null' ;
    elsif date_payement IS NULL OR date_payement >= getDate() THEN
        RAISE EXCEPTION 'Date de payement est valide';
    elsif prix_film IS NULL THEN
        RAISE EXCEPTION 'Le prix du film is null';
    elsif recette IS NULL THEN
        RAISE EXCEPTION 'recette is null';
    elsif benefice IS NULL THEN
        RAISE EXCEPTION 'benefice is null';
    ELSE
        INSERT INTO Payement(id_payement, date_payement, prix_film, recette, benefice, id_resa)
        VALUES (id_payement, date_payement, prix_film, recette, benefice, id_resa);
    end if;
end;
$$ LANGUAGE plpgsql;

/***********************************************************************************************************/

--creation Distributeur--

CREATE OR REPLACE FUNCTION creationDistributeur(id_distri INTEGER) RETURNS VOID AS
$$
BEGIN
    if id_distri is null or id_distri = 0 then
        raise exception 'distributeur is null';
    ELSE
        INSERT INTO Distributeurs(id_distri) VALUES (id_distri);
    end if;

end;
$$ LANGUAGE plpgsql;

/***********************************************************************************************************/


--creation Programmateur--


CREATE OR REPLACE FUNCTION creationProgrammateur(id_prog INTEGER) RETURNS VOID AS
$$
BEGIN
    if id_prog is null or id_prog = 0 then
        raise exception 'distributeur is null';
    ELSE
        INSERT INTO Programmateurs(id_prog) VALUES (id_prog);
    end if;

end;
$$ LANGUAGE plpgsql;



/***********************************************************************************************************/


-----  Ajout d'une journée a la table Date -----


CREATE OR REPLACE FUNCTION addOneDay() RETURNS VOId AS
$$
BEGIN
    UPDATE Date SET date_actuelle = getDate() + interval '1 day' where date_actuelle = getDate();
end;
$$ LANGUAGE plpgsql;

-----  Ajout d'une semaine a la table Date -----

CREATE OR REPLACE FUNCTION addOneWeek() RETURNS VOId AS
$$
BEGIN
    UPDATE Date SET date_actuelle = getDate() + interval '1 week' where date_actuelle = getDate();
end;
$$ LANGUAGE plpgsql;

-----  Ajout d'une mois a la table Date -----

CREATE OR REPLACE FUNCTION addOneMonth() RETURNS VOId AS
$$
BEGIN
    UPDATE Date SET date_actuelle = getDate() + interval '1 month ' where date_actuelle = getDate();
end;
$$ LANGUAGE plpgsql;


/***********************************************************************************************************/

CREATE OR REPLACE FUNCTION achatBillet ()