insert into abonne(solde_spec,  nom, prenom, sexe, age, email, type_abo)
values (100,  'travolta', 'john', 'M', 56, 'jontravolta@gmail.com', 'CE'),
       (100,  'samuel', 'jackson', 'M', 56, 'jackson@gmail.com', 'CE'),
       (20, 'uma', 'thurman', 'M', 56, 'thurman@gmail.com', 'CE'),
       (100, 'ving', 'rhames', 'M', 53, 'rhames@gmail.com', 'CE'),
       (24, 'tim', 'roth', 'M', 52, 'jontravolta@gmail.com', '+26 ans'),
       (22,  'hervey', 'keitel', 'M', 56, 'keitel@gmail.com', '+26 ans'),
       (30, 'quentin', 'tarantino', 'M', 72, 'quentin@gmail.com', 'CE'),
       (100, 'momo', 'ansari', 'M', 28, 'painlibanais@gmail.com', '+26 ans'),
       (100, 'brady', 'will', 'M', 27, 'brady@gmail.com', '+26 ans'),
       (100, 'cheikh', 'mans_not_hot', 'M', 29, 'patviera@gmail.com', 'CE');

\echo '\n---Copy de FILMS'

COPY film from 'Desktop/projetbd/Projet_Cinema/movies.csv' with  (format  csv);


select * from spectateur;
