select * from abonne ;

select creationabonne('zoumy','njangui','elodie','F',23,'zoumy@gmail.com','-26 ans');
insert into abonne(solde_spec, pseudo, nom, prenom, sexe, age, email, type_abo) VALUES (20,'wiil','njangui','wilfried','M',27,'will@gmail.com','+26 ans');
select * from abonne;



select *
from billet;

select * from gestionnaire ;

select * seance ;
insert into seance (date_seance, nb_places_vendu, nb_places_max, id_film);

select * from distributeur ;
insert into distributeur (id_distri, nom, vente)
values (1,'UGC',true);


select  * from film ;
insert into  film (id_film, titre, genre, nationalite, langue, synopsis, prix_film, id_distri) VALUES (1,'avaenger','action','us','en','bbbbbbbbb',30000,1) ;

select * from seance ;
insert into seance(id_seance, date_seance,id_film) VALUES (1,getdate(),1);

select est_inscrit(2);

select seance_existe(2);

select est_reserve(2);
select *from reservation;
SELECT reserve(2, 1);