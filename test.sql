select *
from abonne;
insert into abonne(solde_spec, id_abo, nom, prenom, sexe, age, email, type_abo)
VALUES (100, 1,'wiil', 'brady',  'M', 27, 'will@gmail.com', '+26 ans');
insert into abonne(solde_spec,id_abo, nom, prenom, sexe, age, email, type_abo)
VALUES (100, 2,'ste', 'ariane', 'F', 25, 'riri@gmail.com', '-26 ans');
insert into abonne(solde_spec, id_abo, nom, prenom, sexe, age, email, type_abo)
VALUES (100,3,'dgb', 'nil', 'M', 23, 'riri@gmail.com', '-26 ans');
select *
from abonne;

select * from spectateur;
select creationspectateurs(3,100);
select creationspectateurs(2,100);
select creationspectateurs(1,100);


select creationtransaction2(1, 30,1,getdate());
select creationtransaction2(2, 30,1,getdate());
select * from transaction;

select * from abonne ;

