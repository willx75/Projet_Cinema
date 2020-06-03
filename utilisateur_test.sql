

select creationspectateurs(4, 100);
select *
from spectateur;

select *
from billet;

select *
from gestionnaire;


select *
from seance;

select *
from distributeur;
insert into distributeur (id_distri, nom, vente)
values (1, 'UGC', true);


select *
from film;
insert into film (id_film, titre, genre, nationalite, langue, prix_film, id_distri)
VALUES (1, 'avaenger', 'action', 'us', 'en', 30000, 1);

select *
from seance;
insert into seance(id_seance, date_seance, id_film)
VALUES (1, getdate(), 1);


select seance_existe(1);

select est_reserve(2);
select *
from reservation;



select reserve(6, 1);
select reserve(2, 2);


select *
from transaction;
select getdate();
