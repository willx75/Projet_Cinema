--reservation --
DROP FUNCTION IF EXISTS get_billet_a_acheter(idseance integer, qte integer);
DROP FUNCTION IF EXISTS annul_reservation(id_spe integer, id_sea integer) CASCADE;
DROP FUNCTION IF EXISTS check_nb_resa(id_spe integer) CASCADE;
DROP FUNCTION IF EXISTS check_reservation() cascade;
--billet
DROP FUNCTION IF EXISTS getNbPlace_total_vente(id_ticket integer) cascade;
DROP FUNCTION IF EXISTS nb_place_disponible(id integer) cascade;
--transaction --
DROP FUNCTION IF EXISTS get_solde_spec(int) cascade;
DROP FUNCTION IF EXISTS get_solde_programmateur(int) cascade;
DROP TRIGGER IF EXISTS after_insert_achat ON transaction cascade;
DROP FUNCTION IF EXISTS check_inscription() cascade;

DROP TRIGGER IF EXISTS before_insert_abonne ON abonne cascade;



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


-------------------------------------------transaction------------------------------------------------------

create or replace function achat_trigger() returns trigger as
$$
declare
    msg_final text ;
begin

    msg_final := 'Vous avez recu une commande de' || new.quantite || 'montant dun valeur de ' || new.montant_trans ||
                 'par : ' || new.trans_spec || '. Pour consulter la transaction, le numero est : ' || new.id_trans;

    raise notice 'message finale : % ', msg_final;
    insert into message(expediteur, date_envoie, fk_abo, fk_trans, msg)
    VALUES ('gestionnaire', getdate(), new.trans_spec, new.id_trans, msg_final);
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