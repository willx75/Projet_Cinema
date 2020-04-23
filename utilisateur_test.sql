select creationabonne('riri', 'stephan', 'ariane', 'F', 25, 'riri@outlook.fr', 'Etudiant');
select creationabonne('will', 'njangui', 'wilfried', 'M', 27, 'will@outlook.fr', 'Etudiant');
select *from abonne;

select creationspectateurs(2,300);
select *from spectateur ;

select *
from billet;

insert into film(id_film, titre, genre, nationalite, langue, synopsis, prix_film)
VALUES (2, 'avengers', 'action', 'us', 'en', 'blblblblblbbbb', '300');
select* from film;
select *
from seance;
insert into seance (date_seance, nb_places_vendu, nb_places_max, id_film)
VALUES ('2020-01-01', 222, 500, 2);


select reserve(1,2);