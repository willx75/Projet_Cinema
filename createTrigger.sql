DROP FUNCTION IF EXISTS getDate();
DROP FUNCTION IF EXISTS creationFilm(id_films INTEGER, titre varchar, genre varchar, nationalite varchar, langues varchar, synopsis varchar, prix_film integer);
DROP FUNCTION IF EXISTS creationTransaction(id_trans INTEGER, date_payement timestamp, montant_trans FLOAT, quantite integer);
DROP FUNCTION IF EXISTS creationProgrammateur(id_prog INTEGER, nom varchar, solde bigint);
DROP FUNCTION IF EXISTS creationDistributeur(id_distri INTEGER, nom varchar, vente boolean);
DROP FUNCTION IF EXISTS creationContrat_Distribution(contrat varchar, montant_contrat FLOAT, licence text, date_signature TIMESTAMP);
DROP FUNCTION IF EXISTS creationBillet(id_billet integer, numero_billet INTEGER, prix_billet float);
DROP FUNCTION IF EXISTS creationMessage(id_message integer, expediteur varchar, date_envoi timestamp);
DROP FUNCTION IF EXISTS addOneDay();
DROP FUNCTION IF EXISTS addOneWeek();
DROP FUNCTION IF EXISTS addOneMonth();
--inscription --
DROP FUNCTION IF EXISTS creationAbonne(varchar, varchar, varchar, varchar, integer, varchar);
DROP FUNCTION IF EXISTS creationSpectateurs(id_spec INTEGER, solde int);
DROP FUNCTION IF EXISTS est_inscrit(varchar);
DROP FUNCTION IF EXISTS abonneExiste(id INTEGER);
DROP FUNCTION IF EXISTS unsubscribeAbonne(varchar, varchar);
DROP FUNCTION IF EXISTS getAge(integer);


--reservation --
DROP FUNCTION IF EXISTS reserve(id_spe integer, id_sea integer);
DROP FUNCTION IF EXISTS annul_reservation(id_spe integer, id_sea integer);
DROP FUNCTION IF EXISTS check_nb_resa(id_spe integer);
DROP FUNCTION IF EXISTS est_reserve(id_spe integer);
DROP FUNCTION IF EXISTS check_reservation() cascade;
DROP FUNCTION IF EXISTS seance_existe(id integer) cascade;

DROP FUNCTION IF EXISTS getNbPlace_total_vente(id_ticket integer);
DROP FUNCTION IF EXISTS supp_billet_acheter(integer);
DROP FUNCTION IF EXISTS nb_place_disponible(id integer);
--transaction --
DROP FUNCTION IF EXISTS get_solde_spec(int);
DROP FUNCTION IF EXISTS get_solde_programmateur(int);
DROP TRIGGER IF EXISTS after_insert_achat ON transaction;

--DROP TRIGGER IF EXISTS get_solde_spectateur ON Transaction;
--DROP TRIGGER IF EXISTS check_solde_prog ON transaction;
--DROP TRIGGER IF EXISTS check_solde_spec ON Transaction;
--------
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

--Creation d'une seance ---
CREATE OR REPLACE FUNCTION creationSeance(id_seance INTEGER, date_seance TIMESTAMP, nb_max INTEGER,
                                          nb_vendu INTEGER) returns void as
$$
BEGIN
    if id_seance is null or id_seance = 0 then
        RAISE EXCEPTION 'seances is null' ;
    elsif date_seance is NULL OR date_seance >= getDate() THEN
        RAISE EXCEPTION 'Date de la seance est valide ' ;
    elsif nb_max is NULL then
        raise exception 'nombre place est null';
    elsif nb_vendu is NULL then
        raise exception 'nombre place est null';
    ELSE
        INSERT INTO Seance(id_seance, date_seance, nb_places_max, nb_places_vendu)
        VALUES (id_seance, date_seance, nb_max, nb_vendu);
    end if;
end;

$$ LANGUAGE plpgsql;


/***********************************************************************************************************/

--- creation d'une transaction
CREATE OR REPLACE FUNCTION creationTransaction(id_trans INTEGER, date_payement timestamp,
                                               montant_trans FLOAT, quantite integer) RETURNS VOID AS
$$
BEGIN
    IF id_trans is null or id_trans = 0 THEN
        RAISE EXCEPTION 'payement is null' ;
    elsif date_payement IS NULL OR date_payement >= getDate() THEN
        RAISE EXCEPTION 'Date de payement est valide';
    elsif montant_trans IS NULL THEN
        RAISE EXCEPTION 'montant de la transaction is null';
    elsif quantite IS NULL THEN
        RAISE EXCEPTION 'quantité is null';

    ELSE
        INSERT INTO Transaction(id_trans, date_payement, montant_trans, quantite)
        VALUES (id_trans, date_payement, montant_trans, quantite);
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
CREATE OR REPLACE FUNCTION creationProgrammateur(id_prog INTEGER, nom text, solde bigint) RETURNS VOID AS
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
create or replace function creationContrat_Distribution(contrat varchar, montant float, licence text, date timestamp) returns void as
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
        INSERT INTO contrat_de_diffusion(contrat, montant_contrat, licence, date_signature)
        VALUES (contrat, montant_contrat, licence, date_signature);
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

-------------------------------------------inscription------------------------------------------------------

--creation d'un abonee
create or replace function creationAbonne(pseudo varchar, name varchar, pnom varchar, sexe varchar, age int,
                                          mail varchar, typeabo varchar) returns void as
$$
begin
    insert into abonne(pseudo, nom, prenom, sexe, age, email, type_abo)
    values (pseudo, name, pnom, sexe, age, mail, typeabo);
end;
$$ language plpgsql;

--Creation d'un spectateurs ---
create or replace function creationSpectateurs(id_spec INTEGER, solde int) returns void as
$$
begin
    if id_spec is null or id_spec = 0 then
        raise EXCEPTION 'spectateur is null' ;

    elsif solde is null then
        raise exception 'solde is null' ;

    ELSE
        INSERT INTO Spectateur(id_spec, solde_spec)
        VALUES (id_spec, solde);
    end if;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION abonneExiste(id INTEGER) RETURNS BOOLEAN AS
$$
BEGIN
    IF exists(select 1 from abonne where abonne.id_spec = id)
    then
        return true ;
    else
        raise exception 'cet abonne est introuvable';
    END IF;
end;

$$ LANGUAGE plpgsql;

create or replace function check_inscription() returns trigger as
$$
declare
    bool boolean;
begin
    if exists(select into bool
              from abonne
              where pseudo = new.pseudo and nom = new.nom and prenom = new.prenom and age = new.age)
    then
        raise exception 'abonne deja inscrit';
        return null;
    else
        return new ;
    end if;
end;

$$ language plpgsql;

create trigger before_insert_abonne
before insert on abonne
for each row
execute procedure check_inscription();

create or replace function est_inscrit(varchar) returns boolean as
$$
declare
    res boolean ;

begin
    select into res from abonne where nom = $1;
    if not found then
        res := false;
        return res;
    end if;

end;
$$
    language plpgsql;

create or replace function unsubscribeAbonne(varchar, varchar) returns void as
$$
begin
    delete from abonne where pseudo = $1 and email = $2 ;
end;
$$ language plpgsql;

-- fonction qui recupere age
create or replace function getAge(id_abo integer) returns integer as $$
declare _age integer;
begin
	select age into _age from abonne where id_spec = id_abo ;
	return _age;
end;
$$ language plpgsql;
/***********************************************************************************************************/

/***********************************************************************************************************/

-------------------------------------------reservation------------------------------------------------------

--verification de la reservation --
create or replace function est_reserve(id_spe integer) returns boolean as
$$
begin

    if exists(select 1 from reservation where reservation.fk_seance = id_spe)
    then
        raise notice 'Labo a deja reservé pour cette seance ';
        return false;
    else
        return true ;
    end if;
end;
$$ language plpgsql;

--- Le nombre de reservation qu'un abo peut faire est limité a 2
create or replace function check_nb_resa(id_spe integer) returns boolean as
$$
declare
    nbres boolean ;

begin
    select count(*) <= 2 into nbres from reservation where fk_spec = id_spe;
    if nbres is false
    then
        raise exception 'vous avez deja effectué une reservation';
    end if;
    return nbres;
end;
$$ language plpgsql;

create or replace function reserve(id_spe integer, id_sea integer) returns void as
$$
begin
    insert into reservation values (id_spe, id_sea);
end;
$$ language plpgsql;

create or replace function seance_existe(id integer) returns boolean as
$$
begin
    if exists(select 1 from seance where seance.id_seance = id) then
        return true;
    else
        raise exception 'Cette seance nexiste pas ';
        return false;
    end if;
end;
$$ language plpgsql;

create or replace function check_reservation() returns trigger as
$$
begin
    if (seance_existe(new.fk_seance) is false) or
       (abonneExiste(new.fk_spec) is false) or
       (est_inscrit(new.fk_spec) is false) or
       (est_reserve(new.fk_spec) is false) or
       (check_type_abo(new.fk_spec) is false) or
       (check_nb_resa(new.fk_spec) is false)
    then
        return null ;
    else
        return new;
    end if;
end;

$$ language plpgsql;

create trigger before_insert_reservation
    before insert
    on reservation
    for each row
execute procedure check_reservation();

create or replace function get_type_abo(id_spe integer) returns varchar as
$$
declare
    forfait varchar;
begin

    select type_abo into forfait from abonne where id_spec = id_spe;
    return forfait;

end;
$$ language plpgsql;

create or replace function check_type_abo(id_spe integer) returns boolean as
$$
begin
    if (get_type_abo(id_spe) = 'Abonnement -26') then
        return true ;
    elsif (get_type_abo(id_spe) = 'Abonnement +26') then
        return true ;
    elsif (get_type_abo(id_spe) = 'Etudiant') then
        return true ;
    elsif (get_type_abo(id_spe) = 'Comite Entreprise') then
        return true ;
    else
        return false ;
    end if;
end;
$$ language plpgsql;

create or replace function annul_reservation(id_spe integer, id_sea integer) returns void as
$$
begin
    delete from reservation where fk_spec = id_spe and fk_seance = id_sea ;
end;

$$ language plpgsql;


-------------------------------------------billet-----------------------------------------------------------

create or replace function getNbPlace_total_vente(id_ticket integer) returns void as
$$
begin

    select nb_places_max from seance where id_seance = id_ticket ;
end ;
$$ language plpgsql;

create or replace function nb_place_disponible(id integer) returns integer as
$$

begin

    SELECT sum(nb_places_max - nb_places_vendu) FROM seance where id_seance = id;


end;
$$ language plpgsql;


/***********************************************************************************************************/


/**create or replace function make_transaction(acheteur int, date_achat timestamp, qte integer) returns integer as
$$
declare
    int_tr integer;

begin
    --si le spectateur est toujours inscrit on procede au payement
    IF spectateurExiste($1)
    THEN
        insert into transaction(trans_spec, date_payement, quantité)
        values ($1, $2, $3)
        returning trans_spec
            into int_tr;
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
**/

/**create or replace function supp_billet_acheter(integer) returns void as
$$
begin
    delete from seance where id_billet = $1;
end;
$$ language plpgsql;
**/



create or replace function date_reservation() returns trigger as
$$
begin
    update reservation set date_resa= getDate() where fk_seance = new.fk_seance;
end;
$$ language plpgsql;

create trigger after_insert_reservation
    after insert
    on reservation
    for each row
execute procedure date_reservation();

-------------------------------------------transaction------------------------------------------------------

create or replace function achat_trigger() returns trigger as
$$
declare
    msg_final text ;
begin

    msg_final := 'Vous avez recu une commande de' || new.quantite || 'montant dun valeur de ' || new.montant_trans ||
                 'par : ' || new.trans_spec || '. Pour consulter la transaction, le numero est : ' || new.id_trans;

    raise notice 'message finale : % ', msg_final;
    insert into message(expediteur, date_envoie, id_spec, fk_trans, msg)
    VALUES ('gestionnaire', getdate(), new.trans_spec, new.id_trans, msg_final);
    return new;
end;
$$ language plpgsql;

CREATE TRIGGER after_insert_achat
    after insert
    ON transaction
    FOR EACH ROW
EXECUTE PROCEDURE achat_trigger();


-- recuperation du solde d'un spectateur
create or replace function get_solde_spec() returns trigger as
$$
declare
    res integer ;
BEGIN

    SELECT solde_spec
    INTO res
    FROM spectateur
    WHERE new.trans_spec = id_spec;

    IF 100 <= (SELECT montant_trans
               FROM transaction
               WHERE trans_spec = new.trans_spec) + new.montant_trans
    THEN
        RAISE exception 'Le solde du spectateur est insuffisant';
    ELSE
        UPDATE spectateur
        SET solde_spec = (res - new.montant_trans)
        WHERE id_spec = new.trans_spec;
    end if;
    RETURN res;
END;
$$ language plpgsql;


-- On verifie le solde d'un spectateur avant une transaction
create TRIGGER get_solde_spectateur
    before insert
    on Transaction
    FOR EACH ROW
EXECUTE PROCEDURE get_solde_spec();

create or replace function get_solde_programmateur(varchar) returns integer as
$$
declare
    res integer;
begin
    select solde into res from programmateur where nom = $1;
end;

$$ language plpgsql;
