DROP FUNCTION IF EXISTS getDate();
DROP FUNCTION IF EXISTS creationFilm(id_films INTEGER, titre varchar, genre varchar, nationalite varchar, langues varchar, synopsis varchar, prix_film integer);
DROP FUNCTION IF EXISTS creationSpectateurs(id_spec INTEGER, age int);
DROP FUNCTION IF EXISTS creationAbonne(id_abo INTEGER, nom varchar, prenom varchar, email varchar);
DROP FUNCTION IF EXISTS creationReservation(id_resa INTEGER, date_resa TIMESTAMP, prix INTEGER);
DROP FUNCTION IF EXISTS creationSeances(id_seance INTEGER, date_seance TIMESTAMP, tarif_abo INTEGER, tarif_spec INTEGER, nb_places_dispo INTEGER);
DROP FUNCTION IF EXISTS creationCinema (id_cinema INTEGER, adresse VARCHAR, nb_salle_max INTEGER);
DROP FUNCTION IF EXISTS creationTransaction (id_payement INTEGER, date_payement INTEGER, prix_film INTEGER, recette INTEGER, benefice INTEGER);
DROP FUNCTION IF EXISTS creationProgrammateur(id_prog INTEGER, nom varchar, solde FLOAT);
DROP FUNCTION IF EXISTS creationDistributeur(id_distri INTEGER, nom varchar, vente boolean);
DROP FUNCTION IF EXISTS creationContrat_Distribution(contrat varchar, montant_contrat INTEGER, licence text, date_signature TIMESTAMP);
DROP FUNCTION IF EXISTS creationBillet(id_billet integer, numero_billet INTEGER, prix_billet float);
DROP FUNCTION IF EXISTS addOneDay();
DROP FUNCTION IF EXISTS addOneWeek();

DROP FUNCTION IF EXISTS addOneMonth();



DROP FUNCTION IF EXISTS reservation();
DROP FUNCTION IF EXISTS inscriptionAbonnes();
DROP FUNCTION IF EXISTS achatBillet ();


DROP TRIGGER IF EXISTS t_sexe_abonne ON abonne;
--signature du contrat avant transaction

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
                                        nationalite varchar(255), langue varchar(255), synopsis varchar(255),
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
    elsif langue is null or langue = '' then
        raise EXCEPTION 'langues is null';
    elsif synopsis is null or synopsis = '' then
        raise EXCEPTION 'synopsis is null';
    elsif montant_film is null then
        raise EXCEPTION 'montant is null';

    ELSE
        INSERT INTO Film(id_film, titre, genre, nationalite, langue, synopsis, prix_film, id_distri)
        VALUES (id_films, titre, genre, nationalite, langue, synopsis, prix_film, id_distri);
    end if;
end ;

$$ LANGUAGE plpgsql;

/***********************************************************************************************************/

--Creation d'un spectateurs ---

create or replace function creationSpectateurs(id_spec INTEGER, age int) returns void as
$$
begin
    if id_spec is null or id_spec = 0 then
        raise EXCEPTION 'spectateur is null' ;
    elsif age is null then
        raise exception 'age is null' ;

    ELSE
        INSERT INTO Spectateur(id_spec, age)
        VALUES (id_spec, age);
    end if;
end;
$$ LANGUAGE plpgsql;

/***********************************************************************************************************/

--creation d'un abonne

CREATE OR REPLACE function creationAbonne(id_abo INTEGER, nom varchar, prenom varchar, email varchar) returns void as
$$
BEGIN

    if id_abo is null or id_abo = 0 then
        raise EXCEPTION 'abonne is null' ;
    elsif nom is null or nom = ' ' then
        raise exception 'nom is null ';
    elsif prenom is null or prenom = ' ' then
        raise exception 'prenom is null ';
    elsif email is null or email = ' ' then
        raise exception 'prenom is null ';

    ELSE
        INSERT INTO Abonne(id_spec, age, id_abo, nom, prenom, sexe, email)
        VALUES (id_spec, age, id_abo, nom, prenom, sexe, email);

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
        INSERT INTO Reservation(id_resa, date_resa, prix, id_spec, id_trans, id_seances)
        VALUES (id_resa, date_resa, prix, id_spec, id_trans, id_seances);
    end if;
end ;

$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION check_nb_reservation (id_abo integer) RETURNS TRIGGER as 
$$
declare nb boolean 

BEGIN

SELECT COUNT (*)<1 INTO nb FROM Reservation where id 


END; 
$$ LANGUAGE plpgsql; 

/***********************************************************************************************************/

--Creation d'une seances ---

CREATE OR REPLACE FUNCTION creationSeances(id_seance INTEGER, date_seance TIMESTAMP, tarif_abo INTEGER,
                                           tarif_spec INTEGER, nb_places_dispo INTEGER) returns void as
$$
BEGIN
    if id_seance is null or id_seance = 0 then
        RAISE EXCEPTION 'seances is null' ;
    elsif date_seance is NULL OR date_seance >= getDate() THEN
        RAISE EXCEPTION 'Date de la seance est valide ' ;
    elsif tarif_abo IS NULL THEN
        RAISE EXCEPTION 'Tarif is null';
    elsif tarif_spec IS NULL THEN
        RAISE EXCEPTION 'Tarif is null';
    elsif nb_places_dispo is NULL then
        raise exception 'nombre place est null';
    ELSE
        INSERT INTO Seance(id_seance, date_seance, tarif_abo, tarif_spec, nb_places_dispo, id_salle)
        VALUES (id_seance, id_seance, date_seance, tarif_abo, tarif_spec, nb_places_dispo, id_salle);
    end if;
end;


$$ LANGUAGE plpgsql;


/***********************************************************************************************************/


--- creation d'une transaction

CREATE OR REPLACE FUNCTION creationTransaction(id_trans INTEGER, date_payement INTEGER,
                                               payement FLOAT) RETURNS VOID AS
$$
BEGIN
    IF id_trans is null or id_trans = 0 THEN
        RAISE EXCEPTION 'payement is null' ;
    elsif date_payement IS NULL OR date_payement >= getDate() THEN
        RAISE EXCEPTION 'Date de payement est valide';
    elsif payement IS NULL THEN
        RAISE EXCEPTION 'payement is null';

    ELSE
        INSERT INTO Transaction(id_trans, date_payement, payement, id_resa)
        VALUES (id_trans, date_payement, payement, id_resa);
    end if;
end;
$$ LANGUAGE plpgsql;

/***********************************************************************************************************/

--creation Distributeur--

CREATE OR REPLACE FUNCTION creationDistributeur(id_distri INTEGER, nom VARCHAR(50)) RETURNS VOID AS
$$
BEGIN
    if id_distri is null or id_distri = 0 then
        raise exception 'distributeur is null';
    elsif nom is null or nom = ' ' then
        raise exception 'nom is null' ;
    ELSE
        INSERT INTO Distributeur(id_distri, nom) VALUES (id_distri, nom);
    end if;

end;
$$ LANGUAGE plpgsql;

/***********************************************************************************************************/


--creation Programmateur--


CREATE OR REPLACE FUNCTION creationProgrammateur(id_prog INTEGER, nom varchar(255)) RETURNS VOID AS
$$
BEGIN
    if id_prog is null or id_prog = 0 then
        raise exception 'programmateur is null';
    elsif nom is null or nom = '' then
        raise exception 'nom is null';
    ELSE
        INSERT INTO Programmateur(id_prog, nom) VALUES (id_prog, nom);
    end if;

end;
$$ LANGUAGE plpgsql;


/***********************************************************************************************************/

----creation d'un contrat de diffusion  -----

create or replace function creationContrat_Distribution(contrat varchar, montant INTEGER, licence text) returns void as
$$
begin
    if contrat is null or contrat = '' then
        raise exception 'contrat is null';
    elsif montant is null or montant = 0 then
        raise exception 'montant is null';
    elsif licence is null or licence = '' then
        raise exception 'licence is null';
    ELSE
        INSERT INTO contrat_de_diffusion(contrat, montant, licence, id_prog, id_dist)
        VALUES (contrat, montant, licence, id_prog, id_dist);
    end if;
end;
$$ LANGUAGE plpgsql;


/***********************************************************************************************************/

----creation  Archive --

create or replace function creationArchive(recette integer, benefice INTEGER, date timestamp) returns void as
$$
begin
    if recette is null then
        raise exception 'contrat is null';
    elsif benefice is null then
        raise exception 'montant is null';
    elsif date is null or date >= getDate() then
        raise exception 'date de larchivage is bon';
    ELSE
        INSERT INTO archivage(recette, benefice, date) VALUES (recette, benefice, date);
    end if;

end;
$$ LANGUAGE plpgsql;

/***********************************************************************************************************/


--creation d'un billet
create or replace function creationBillet(id_billet integer, numero_billet INTEGER, prix_billet float) returns void as
$$
begin
    if id_billet is null or id_billet = 0 then
        raise exception 'billet est null';
    elsif numero_billet is null then
        raise exception 'numero de billet est null' ;
    elsif prix_billet is null then
        raise exception 'prix du billet est null';
    ELSE
        INSERT INTO Billet(id_billet, numero_billet, prix_billet) VALUES (id_billet, numero_billet, prix_billet);
    end if;
end;
$$ LANGUAGE plpgsql;


/***********************************************************************************************************/

-----  Ajout d'une journée a la table Date -----


CREATE OR REPLACE FUNCTION addOneDay() RETURNS void AS
$$
BEGIN
    UPDATE Date
    SET date_actuelle = getDate() + interval '1 day'
    where date_actuelle = getDate();
end;
$$ LANGUAGE plpgsql;

-----  Ajout d'une semaine a la table Date -----

CREATE OR REPLACE FUNCTION addOneWeek() RETURNS VOId AS
$$
BEGIN
    UPDATE Date
    SET date_actuelle = getDate() + interval '1 week'
    where date_actuelle = getDate();
end;
$$ LANGUAGE plpgsql;

-----  Ajout d'une mois a la table Date -----

CREATE OR REPLACE FUNCTION addOneMonth() RETURNS VOId AS
$$
BEGIN
    UPDATE Date
    SET date_actuelle = getDate() + interval '1 month '
    where date_actuelle = getDate();
end;
$$ LANGUAGE plpgsql;



/***********************************************************************************************************/
---    verifier le sexe des abonnes    ---


CREATE TRIGGER t_sexe_abonne
    BEFORE INSERT
    ON abonne
    FOR EACH ROW
EXECUTE PROCEDURE check_sexe_abonne();

CREATE FUNCTION check_sexe_abonne() RETURNS trigger AS
$$
BEGIN
    IF NEW.sexe != 'M' AND NEW.sexe != 'F' THEN
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;


/***********************************************************************************************************/

CREATE OR REPLACE FUNCTION achatBillet() RETURNS VOID AS
$$
BEGIN
end;
$$ LANGUAGE plpgsql;

/***********************************************************************************************************/
CREATE OR REPLACE FUNCTION inscriptionAbonnes() RETURNS VOID AS
$$
BEGIN


end;

$$ LANGUAGE plpgsql;


/***********************************************************************************************************/


CREATE OR REPLACE FUNCTION reservation() RETURNS TRIGGER AS
$$

BEGIN

end;
$$ LANGUAGE plpgqsql;


