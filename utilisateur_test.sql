select * from abonne ;

select creationabonne('zoumy','njangui','elodie','F',23,'zoumy@gmail.com','-26 ans');
insert into abonne(solde_spec, pseudo, nom, prenom, sexe, age, email, type_abo) VALUES (20,'wiil','njangui','wilfried','M',27,'will@gmail.com','+26 ans');
select * from abonne;

select *from spectateur ;
insert into  spectateur (id_spec, solde_spec) VALUES (3,100);


select *
from billet;

select * from gestionnaire ;

select * from seance ;

select * from distributeur ;
insert into distributeur (id_distri, nom, vente)
values (1,'UGC',true);


select  * from film ;
insert into  film (id_film, titre, genre, nationalite, langue, synopsis, prix_film, id_distri) VALUES (1,'avaenger','action','us','en','bbbbbbbbb',30000,1) ;

select * from seance ;
insert into seance(id_seance, date_seance,id_film) VALUES (1,getdate(),1);

select est_inscrit(2);

select seance_existe(1);

select est_reserve(2);
select *from reservation;



select reserve(1,1);
select reserve(2,2);


select * from transaction ;
select getdate();
select creationtransaction(1,30,1);