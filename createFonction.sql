DROP FUNCTION IF EXISTS getDate() CASCADE;
DROP FUNCTION IF EXISTS creationFilm(id_films INTEGER, titre varchar, genre varchar, nationalite varchar, langues varchar, synopsis varchar, prix_film integer) CASCADE;
DROP FUNCTION IF EXISTS creationTransaction(id_trans INTEGER, date_payement timestamp, montant_trans FLOAT, quantite integer) CASCADE;
DROP FUNCTION IF EXISTS creationProgrammateur(nom varchar, solde bigint) CASCADE;
DROP FUNCTION IF EXISTS creationDistributeur(id_distri INTEGER, nom varchar, vente boolean) CASCADE;
DROP FUNCTION IF EXISTS creationContrat_Distribution(contrat varchar, montant_contrat FLOAT, licence text, date_signature TIMESTAMP) CASCADE;
DROP FUNCTION IF EXISTS creationBillet(id_billet integer, numero_billet INTEGER, prix_billet float) CASCADE;
DROP FUNCTION IF EXISTS creationMessage(id_message integer, expediteur varchar, date_envoi timestamp) CASCADE;
DROP FUNCTION IF EXISTS creationseance(id_seance integer, date_seance timestamp) CASCADE;
DROP FUNCTION IF EXISTS addOneDay() CASCADE;
DROP FUNCTION IF EXISTS addOneWeek() CASCADE;
DROP FUNCTION IF EXISTS addOneMonth() CASCADE;
DROP FUNCTION IF EXISTS seance_existe(id integer) cascade;
DROP FUNCTION IF EXISTS est_reserve(id_spe integer) CASCADE;
DROP FUNCTION IF EXISTS reserve(id_spe integer, id_sea integer) CASCADE;

DROP FUNCTION IF EXISTS check_reservation() cascade;
DROP FUNCTION IF EXISTS annul_reservation(id_spe integer, id_sea integer) CASCADE;

--inscription --
DROP FUNCTION IF EXISTS creationabonne(pseudo varchar, name varchar, pnom varchar, sexe varchar, age integer, mail varchar, typeabo varchar) CASCADE;
DROP FUNCTION IF EXISTS est_inscrit(varchar) CASCADE;
DROP FUNCTION IF EXISTS abonneExiste(id INTEGER) CASCADE;
DROP FUNCTION IF EXISTS unsubscribeAbonne(varchar, varchar) CASCADE;
DROP FUNCTION IF EXISTS getAge(integer) CASCADE;


/**********************************************************************************************************/

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
CREATE OR REPLACE FUNCTION creationSeance(id_seance INTEGER, date_seance TIMESTAMP) returns void as
$$
BEGIN
    if id_seance is null or id_seance = 0 then
        RAISE EXCEPTION 'seances is null' ;
    elsif date_seance is NULL OR date_seance >= getDate() THEN
        RAISE EXCEPTION 'Date de la seance est valide ' ;

    ELSE
        INSERT INTO Seance(id_seance, date_seance)
        VALUES (id_seance, date_seance);
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
CREATE OR REPLACE FUNCTION creationProgrammateur(nom text, solde bigint) RETURNS VOID AS
$$
BEGIN

    if nom is null or nom = '' then
        raise exception 'nom is null';
    elsif solde is null then
        raise exception 'solde is null';
    ELSE
        INSERT INTO Programmateur(nom_prog, solde, id_spec) VALUES (nom, solde, id_spec);
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
create or replace function creationBillet(numero_billet INTEGER, prix_billet float) returns void as
$$
begin

    if numero_billet is null then
        raise exception 'numero de billet est null' ;
    elsif prix_billet is null then
        raise exception 'prix du billet est null';
    ELSE
        INSERT INTO Billet(numero_billet, prix_billet, fk_seance) VALUES (numero_billet, prix_billet, fk_seance);
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
        INSERT INTO message(id_message, expediteur, date_envoie)
        VALUES (id_message, expediteur, date_envoie);
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

/***********************************************************************************************************/

-------------------------------------------inscription------------------------------------------------------

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

create or replace function est_inscrit(integer) returns boolean as
$$
declare
    res boolean ;

begin
    select into res from abonne where id_spec = $1;
    if not found then
        res := false;
        return res;
    end if;
    return res;
end;
$$ language plpgsql;


create or replace function unsubscribeAbonne(varchar, varchar) returns void as
$$
begin
    delete from abonne where pseudo = $1 and email = $2 ;
end;
$$ language plpgsql;

-- fonction qui recupere age
create or replace function getAge(id_abo integer) returns integer as
$$
declare
    _age integer;
begin
    select age into _age from abonne where id_spec = id_abo;
    return _age;
end;
$$ language plpgsql;
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
    raise notice 'reservation canceled' ;
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


/***********************************************************************************************************/

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


--Fonction retournant les billets à acheter dans une seance
create or replace function get_billet_a_acheter(idseance integer, qte integer) returns setof billet AS
$$
declare
    res billet%rowtype;
begin
    for res in
        select * from billet where fk_seance = idseance and vendu = false order by billet.numero_billet limit qte
        LOOP
            return next res;
        end loop;
end;
$$ language plpgsql;



create or replace function supprimer_billet_vendu(id integer) returns void as
$$
begin
    delete from billet where fk_trans = id ;
end;
$$
    language plpgsql;

--apres rembourseement remise des bllets en ventes
create or replace function remise_billet_en_vente(id integer) returns void as
$$
declare
    res billet%rowtype;
begin
    raise notice 'remise billet en vente';
    for res in select from billet where fk_trans = id
        LOOP
            update billet set fk_trans = null, vendu = false where fk_trans = id;
            update seance set nb_places_max = nb_places_max + 1 where id_seance = res.fk_seance;
        end loop;
end;
$$ language plpgsql;

-- qui recupere le nombre de billet par seance
create or replace function get_nb_billet_par_seance(id integer) returns integer as
$$
DECLARE
    res integer;
BEGIN
    SELECT into res count(*) from billet where fk_seance = id;
    IF FOUND
    THEN
        return res ;
    ELSE
        raise exception ' recuperer le nombre de billet est impossible pour la seance %', $1;
    END IF;
END;
$$ language plpgsql;

---recupere la somme totale des billets que l'on a achetés
CREATE OR REPLACE FUNCTION get_somme_billet(id integer, max integer) returns integer as
$$
declare
    somme integer := 0 ;
    res   billet%rowtype;

begin
    FOR res in
        SELECT * from billet where fk_seance = id and vendu = false order by billet.numero_billet limit max
        LOOP
            somme := somme + res.prix_billet ;
        end loop;
    RETURN somme;
end;
$$ language plpgsql;


--recuperer les billets achetés par un spectateur sous forme de string
CREATE OR REPLACe function get_billet_acheter(idtrans integer) returns text as
$$
declare
    ligne text;
BEGIN
    --on recupere les elements du tableau qu'on convertie en sting pour affichage
    SELECT array_to_string(array(SELECT numero_billet into ligne from billet where fk_trans = idtrans), ',');
    IF FOUND
    THEN
        RAISE EXCEPTION 'billet trouvé achat trigger :  % ', ligne ;
    end if;
    return ligne;
end;
$$ language plpgsql;


--Fonction permettant l’achat de billets en fonction de l’ID d’une seance

create or replace function achat_billet_from_seance(idseance integer, qte integer, acheteur text) returns void as
$$
declare
    somme   integer := 0 ;
    res     billet%rowtype;
    seller  integer;
    id_t    integer;
    date_tr timestamp WITH TIME ZONE;

BEGIN

    FOR res IN
        SELECT *
        FROM Billet
        WHERE fk_seance = idseance
          AND vendu = FALSE
        LIMIT qte
        LOOP
            somme = somme + res.prix_billet ;
        END LOOP;
    IF (get_solde_spec()) THEN
        SELECT * FROM seance WHERE id_seance = idseance;
        id_t = creationTransaction(seller, somme, $2, date_tr);
        FOR res IN
            SELECT * FROM get_billet_a_acheter($1, $2)
            LOOP
                UPDATE billet set vendu = TRUE, fk_trans = id_t WHERE id_billet = res.id_billet;
                RAISE NOTICE 'achat billet %', res.id_billet;

                UPDATE seance set nb_places_max = nb_places_max - 1 WHERE id_seance = idseance;
            END LOOP;
        execute virement_gestionnaire($1, $2, (somme + 5));
        --execute virement_gestionnaire('benefices',$3,(somme+5));

    ELSE
        raise exception 'fond insuffisant % ',$3 ;
    end if;
end;

$$ language plpgsql;



--- creation d'une transaction
CREATE OR REPLACE FUNCTION creationTransaction(spectateur integer, montant_trans bigint, quantite integer,
                                               date_payement timestamp) RETURNS INTEGER AS
$$
DECLARE
    id_tr integer ;
BEGIN
    if abonneexiste(spectateur) then
        INSERT INTO Transaction(trans_spec, montant_trans, quantite, date_payement)
        VALUES ($1, $2, $3, $4)
        returning id_trans = id_tr;
        if FOUND THEN
            RAISE notice 'transaction numero %', id_tr;
            return id_tr;
        ELSE

            RAISE EXCEPTION 'transaction impossible ';
        end if;
    ELSE
        RAISE EXCEPTION 'labonne nexiste plus  ';
    END IF;
end ;
$$ LANGUAGE plpgsql;



create or replace function virement_transaction_achat(integer, text, bigint) returns void as
$$
begin
    UPDATE spectateur set solde_spec= solde_spec + $3 where id_spec = $1;
    UPDATE gestionnaire set soldes = soldes - $3 where type_frais = $2;
end;

$$ language plpgsql;


create or replace function virement_gestionnaire(integer, text, bigint) returns void as
$$
begin
    update spectateur set solde_spec = solde_spec - $3 where id_spec = $1;
    update gestionnaire set soldes = soldes + $3 where type_frais = $2;

end;
$$ language plpgsql;




