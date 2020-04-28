--reservation --
DROP FUNCTION IF EXISTS get_billet_a_acheter(idseance integer, qte integer);
DROP FUNCTION IF EXISTS check_nb_resa(id_spe integer) CASCADE;
--billet
DROP FUNCTION IF EXISTS getNbPlace_total_vente(id_ticket integer) cascade;
DROP FUNCTION IF EXISTS nb_place_disponible(id integer) cascade;
--transaction --
DROP FUNCTION IF EXISTS get_solde_spec(int) cascade;
DROP FUNCTION IF EXISTS get_solde_programmateur(int) cascade;
DROP TRIGGER IF EXISTS after_insert_achat ON transaction cascade;
DROP FUNCTION IF EXISTS check_inscription() cascade;

DROP TRIGGER IF EXISTS before_insert_abonne ON abonne cascade;

DROP TRIGGER IF EXISTS before_add_billets ON billet;


/***********************************************************************************************************/

create or replace function check_inscription() returns trigger as
$$
declare
    bool boolean;
begin
    if exists(select into bool
              from abonne
              where pseudo = new.pseudo
                and nom = new.nom
                and prenom = new.prenom
                and age = new.age)
    then
        raise exception 'abonne deja inscrit';
    else
        return new ;
    end if;
end;

$$ language plpgsql;


/***********************************************************************************************************/

create or replace function date_reservation() returns trigger as
$$
begin
    update reservation set date_resa= getDate() where fk_seance = new.fk_seance;
end;
$$ language plpgsql;

/***********************************************************************************************************/

-------------------------------------------transaction------------------------------------------------------
--ajout de messages apres chaque transaction
create or replace function achat_trigger() returns trigger as
$$
declare
    msg_final text ;
begin

    msg_final := 'Vous avez recu une commande de' || new.quantite || 'montant dun valeur de ' || new.montant_trans ||
                 'par : ' || new.trans_spec || '. Pour consulter la transaction, le numero est : ' || new.id_trans;

    raise notice 'message finale : % ', msg_final;
    insert into message(expediteur, date_envoie, fk_abo, fk_trans, msg)
    VALUES ('gestionnaire', CURRENT_TIMESTAMP, new.trans_spec, new.id_trans, msg_final);
    return new;
end;
$$ language plpgsql;


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



create or replace function get_solde_programmateur(varchar) returns integer as
$$
declare
    res integer;
begin
    select solde into res from programmateur where nom_prog = $1;
end;

$$ language plpgsql;
/***********************************************************************************************************/

-------------------------------------------billet------------------------------------------------------

--Permet une vérification avant l’ajout d’un billet
/**
  a revoir cette fonction, l'update ne marche pas encore au niveau de l'insert
 */

CREATE OR REPLACE function update_add_billet() returns trigger as
$$
declare
    prix_max integer ;

begin

    IF (tg_op = 'INSERT') then
        select prix into prix_max from seance where id_seance = new.fk_seance;
        IF (prix_max <= new.prix_billet)
        THEN
            Raise EXCEPTION 'le prix du billet ne respecte pas les conditions % , prix max conseille %', new.prix_billet,prix_max;
        end if;
        IF (get_nb_billet_par_seance(new.fk_seance)) <= 99 -- si on a pas atteint le nombre de 100 billets pour la seance
        THEN
            RAISE NOTICE 'billet ajouter %', new.numero_billet;
            return NEW;
        ELSE
            RAISE EXCEPTION 'nombre de billets pour la seance dépassé, billet numero % refusé ' , new.id_billet;

        end if;
    ELSE
        return null;
    end if;
end;
$$ language plpgsql;




/********************************************************************************************************/


-------------trigger ---------


create trigger before_insert_abonne
    before insert
    on abonne
    for each row
execute procedure check_inscription();



create trigger before_insert_reservation
    before insert
    on reservation
    for each row
execute procedure check_reservation();

create trigger after_insert_reservation
    after insert
    on reservation
    for each row
execute procedure date_reservation();


CREATE TRIGGER after_insert_achat
    after insert
    ON transaction
    FOR EACH ROW
EXECUTE PROCEDURE achat_trigger();

-- On verifie le solde d'un spectateur avant une transaction
create TRIGGER get_solde_spectateur
    before insert
    on Transaction
    FOR EACH ROW
EXECUTE PROCEDURE get_solde_spec();



CREATE TRIGGER before_add_billets
    before INSERT
    ON billet
    FOR EACH ROW
EXECUTE PROCEDURE update_add_billet();