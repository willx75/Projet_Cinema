DROP FUNCTION IF EXISTS getDate();
DROP FUNCTION IF EXISTS creationFilm(id_films INTEGER, titre varchar, genre varchar, nationalite varchar, langues varchar, synopsis varchar, prix_film integer);
DROP FUNCTION IF EXISTS creationSpectateurs(id_spec INTEGER, age int, solde int);
DROP FUNCTION IF EXISTS creationAbonne(id_abo INTEGER, nom varchar, prenom varchar, email varchar, type_abo boolean);
DROP FUNCTION IF EXISTS creationReservation(id_resa INTEGER, date_resa TIMESTAMP, type_resa BOOLEAN);
DROP FUNCTION IF EXISTS creationSeance(id_seance INTEGER, date_seance TIMESTAMP, nb_places_dispo INTEGER);
DROP FUNCTION IF EXISTS creationTransaction (id_payement INTEGER, date_payement INTEGER, prix_film INTEGER, recette INTEGER, benefice INTEGER);
DROP FUNCTION IF EXISTS creationProgrammateur(id_prog INTEGER, nom varchar, solde FLOAT);
DROP FUNCTION IF EXISTS creationDistributeur(id_distri INTEGER, nom varchar, vente boolean);
DROP FUNCTION IF EXISTS creationContrat_Distribution(contrat varchar, montant_contrat INTEGER, licence text, date_signature TIMESTAMP);
DROP FUNCTION IF EXISTS creationBillet(id_billet integer, numero_billet INTEGER, prix_billet float);
DROP FUNCTION IF EXISTS creationMessage(id_message integer, expediteur varchar(255), date_envoi timestamp);
DROP FUNCTION IF EXISTS addOneDay();
DROP FUNCTION IF EXISTS addOneWeek();
DROP FUNCTION IF EXISTS addOneMonth();


--inscription --
DROP FUNCTION IF EXISTS spectateurExiste(id INTEGER);
DROP FUNCTION IF EXISTS abonneExiste(id integer);
DROP FUNCTION IF EXISTS unsubscribeAbonne(varchar, varchar);
DROP FUNCTION IF EXISTS inscriptionAbonne(int, varchar, varchar, varchar);

--reservation

---Transaction
DROP FUNCTION IF EXISTS get_solde_spec(int);
DROP FUNCTION IF EXISTS get_solde_programmateur(int);

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

create or replace function creationSpectateurs(id_spec INTEGER, age int, solde int) returns void as
$$
begin
    if id_spec is null or id_spec = 0 then
        raise EXCEPTION 'spectateur is null' ;
    elsif age is null then
        raise exception 'age is null' ;
    elsif solde is null then
        raise exception 'age is null' ;

    ELSE
        INSERT INTO Spectateur(id_spec, age, solde_spec)
        VALUES (id_spec, age, solde_spec);
    end if;
end;
$$ LANGUAGE plpgsql;

/***********************************************************************************************************/

--creation d'un abonne (pas sur encore revoir le boolean)

CREATE OR REPLACE function creationAbonne(id_abo INTEGER, nom varchar, prenom varchar, email varchar,
                                          type_abo boolean) returns void as
$$
declare
    res boolean ;
BEGIN

    if id_abo is null or id_abo = 0 then
        raise EXCEPTION 'abonne is null' ;
    elsif nom is null or nom = ' ' then
        raise exception 'nom is null ';
    elsif prenom is null or prenom = ' ' then
        raise exception 'prenom is null ';
    elsif email is null or email = ' ' then
        raise exception 'prenom is null ';
    elsif type_abo is NULL THEN
        RAISE EXCEPTION 'le type dabonne est null';
    ELSE

        IF type_abo = TRUE THEN -- si l'abonne est a moins de 26 ans
            SELECT age FROM spectateur where age <= 26;
            res = TRUE;
        ELSE
            res = FALSE;
        END IF;

        INSERT INTO Abonne(id_spec, age, id_abo, nom, prenom, sexe, email)
        VALUES (id_spec, age, id_abo, nom, prenom, sexe, email);

    end if;
end;

$$ LANGUAGE plpgsql;

/***********************************************************************************************************/

--Creation d'une reservation ---

create or replace function creationReservation(id_resa INTEGER, date_resa timestamp, type_resa BOOLEAN) returns void as
$$
begin
    if id_resa is null or id_resa = 0 then
        RAISE EXCEPTION 'reservation is null';
    elsif date_resa IS NULL or date_resa <= getDate() THEN
        RAISE EXCEPTION 'Date de reservation est valide';
    elsif type_resa is null then
        RAISE EXCEPTION 'type de resa is null ';

    ELSE
        INSERT INTO Reservation(id_resa, date_resa, type_resa, id_spec)
        VALUES (id_resa, date_resa, type_resa, id_spec);
    end if;
end ;

$$ LANGUAGE plpgsql;

/***********************************************************************************************************/

--Creation d'une seances ---

CREATE OR REPLACE FUNCTION creationSeance(id_seance INTEGER, date_seance TIMESTAMP, nb_places_dispo INTEGER) returns void as
$$
BEGIN
    if id_seance is null or id_seance = 0 then
        RAISE EXCEPTION 'seances is null' ;
    elsif date_seance is NULL OR date_seance >= getDate() THEN
        RAISE EXCEPTION 'Date de la seance est valide ' ;
    elsif nb_places_dispo is NULL then
        raise exception 'nombre place est null';
    ELSE
        INSERT INTO Seance(id_seance, date_seance, nb_places_dispo)
        VALUES (id_seance, id_seance, date_seance, nb_places_dispo);
    end if;
end;


$$ LANGUAGE plpgsql;


/***********************************************************************************************************/


--- creation d'une transaction

CREATE OR REPLACE FUNCTION creationTransaction(id_trans INTEGER, date_payement timestamp,
                                               quantite FLOAT) RETURNS VOID AS
$$
BEGIN
    IF id_trans is null or id_trans = 0 THEN
        RAISE EXCEPTION 'payement is null' ;
    elsif date_payement IS NULL OR date_payement >= getDate() THEN
        RAISE EXCEPTION 'Date de payement est valide';
    elsif quantite IS NULL THEN
        RAISE EXCEPTION 'quantité is null';

    ELSE
        INSERT INTO Transaction(id_trans, date_payement, quantité, id_seance)
        VALUES (id_trans, date_payement, quantité, id_seance);
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


CREATE OR REPLACE FUNCTION creationProgrammateur(id_prog INTEGER, nom varchar(255), solde FLOAT) RETURNS VOID AS
$$
BEGIN
    if id_prog is null or id_prog = 0 then
        raise exception 'programmateur is null';
    elsif nom is null or nom = '' then
        raise exception 'nom is null';
    elsif solde is null then
        raise exception 'solde is null';
    ELSE
        INSERT INTO Programmateur(id_prog, nom, solde, id_spec) VALUES (id_prog, nom, solde, id_spec);
    end if;

end;
$$ LANGUAGE plpgsql;


/***********************************************************************************************************/

----creation d'un contrat de diffusion  -----

create or replace function creationContrat_Distribution(contrat varchar, montant integer, licence text, date timestamp) returns void as
$$
begin
    if contrat is null or contrat = '' then
        raise exception 'contrat is null';
    elsif montant is null or montant = 0 then
        raise exception 'montant is null';
    elsif licence is null or licence = '' then
        raise exception 'licence is null';
    elsif date is null or date <= getDate() THEN
        RAISE EXCEPTION 'Date de la signature is valid';
    ELSE
        INSERT INTO contrat_de_diffusion(contrat, montant_contrat, licence, date_signature, id_prog, id_dist)
        VALUES (contrat, montant_contrat, licence, date_signature, id_prog, id_dist);
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


create or replace function creationMessage(id_message INTEGER, expediteur VARCHAR(255), date_envoi timestamp) returns void as
$$
begin
    if id_message is null or id_message = 0 then
        raise exception ' message is null' ;
    elsif expediteur is null or expediteur = '' then
        raise exception 'expediteur is null' ;
    elsif date_envoi is null or date_envoi <= getDate() then
        raise exception 'date envoie is valid';

    ELSE
        INSERT INTO message(id_message, expediteur, date_envoie, id_spec)
        VALUES (id_message, expediteur, date_envoie, id_spec);
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

CREATE FUNCTION check_sexe_abonne() RETURNS trigger AS
$$
BEGIN
    IF NEW.sexe != 'M' AND NEW.sexe != 'F' THEN
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_sexe_abonne
    BEFORE INSERT
    ON abonne
    FOR EACH ROW
EXECUTE PROCEDURE check_sexe_abonne();


/***********************************************************************************************************/


CREATE OR REPLACE FUNCTION spectateurExiste(id INTEGER) RETURNS BOOLEAN AS
$$
BEGIN
    IF exists(select 1 from spectateur where spectateur.id_spec = id)
    then
        return true ;
    else
        raise exception 'ce spectateur est introuvable';
    END IF;
end;

$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION abonneExiste(id integer) RETURNS BOOLEAN AS
$$
BEGIN
    IF exists(select 1 from abonne where abonne.id_spec = id)
    then
        return true ;
    else
        raise exception 'cet abonnee est introuvable';
    END IF;
end;

$$ LANGUAGE plpgsql;


create or replace function inscriptionAbonne(int, varchar, varchar, varchar) returns void as
$$
begin

    if abonneExiste($1) then
        raise notice 'labonne % existe deja', $1;
    ELSE
        insert into abonne(nom, prenom, email, type_abo) values ($1, $2, $3, $4);
    END if;

end ;
$$ language plpgsql;


create or replace function unsubscribeAbonne(varchar, varchar) returns void as
$$
begin
    delete from abonne where nom = $1 and prenom = $2 ;
end;
$$ language plpgsql;


/***********************************************************************************************************/
--RESERVATION

--verification de la reservation --

create or replace function est_reserve(id_spe integer) returns boolean as
$$
begin

    if exists(select 1 from reservation where reservation.id_resa = id_spe)
    then
        raise notice 'deja reserve';
        return false;
    else
        return true ;
    end if;
end;
$$ language plpgsql;

-- recuperation du solde d'un spectateur

create or replace function get_solde_spec(int) returns integer as
$$
declare
    res integer ;
begin
    select solde_spec into res from spectateur where id_spec = $1;
    return res;
end;
$$ language plpgsql;

create or replace function get_solde_programmateur(varchar) returns integer as
$$
declare
    res integer ;
begin
    select solde into res from programmateur where nom = $1 ;
end;

$$ language plpgsql;


/***********************************************************************************************************/


create or replace function make_transaction(acheteur int, date_achat timestamp, qte integer) returns integer as
$$
declare
    int_tr integer ;

begin
    --si le spectateur est toujours inscrit on procede au payement
    IF spectateurExiste($1)
    THEN
        insert into transaction(trans_spec, date_payement, quantité)
        values ($1, $2, $3)
        returning trans_spec into int_tr;
        if FOUND then
            Raise notice 'transaction numero % ' , int_tr;
            return int_tr;
        ELSE
            raise exception 'transaction impossible %', $1 ;
        end if;
    ELSE
        raise exception 'le spectateur existe plus % ', $1;
    end if;
end;

$$ language plpgsql;


create or replace function supp_billet_acheter(integer) returns void as
$$
begin
    delete from seance where id_billet = $1;
end;
$$ language plpgsql ;



/***********************************************************************************************************/


