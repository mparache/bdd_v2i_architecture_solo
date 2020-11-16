/*******************************************************************************/

--                        Création des tables

/*******************************************************************************/


DROP TABLE IF EXISTS Detecte CASCADE;
DROP TABLE IF EXISTS Capteur CASCADE;
DROP TABLE IF EXISTS Station_base CASCADE;
DROP TABLE IF EXISTS Special CASCADE;
DROP TABLE IF EXISTS Camion CASCADE;
DROP TABLE IF EXISTS Moto CASCADE;
DROP TABLE IF EXISTS Voiture CASCADE;
DROP TABLE IF EXISTS Vehicule CASCADE;
DROP TABLE IF EXISTS Controle_routier CASCADE;
DROP TABLE IF EXISTS Travaux CASCADE;
DROP TABLE IF EXISTS Alerte_meteo CASCADE;
DROP TABLE IF EXISTS Accident CASCADE;
DROP TABLE IF EXISTS Evenement CASCADE;




CREATE TABLE  Evenement (
  horodatage TIMESTAMP PRIMARY KEY
);

CREATE TABLE Accident (
  horodatage TIMESTAMP NOT NULL,
  FOREIGN KEY (horodatage) REFERENCES Evenement(horodatage),
  gravite VARCHAR,
  nb NUMERIC,
  type_vehicule JSON NOT NULL
);

-- type_vehicule est de la forme [type_vehicule1, type_vehicule2, ...]

CREATE TABLE Alerte_meteo (
  horodatage TIMESTAMP NOT NULL,
  FOREIGN KEY (horodatage) REFERENCES Evenement(horodatage),
  temps VARCHAR,
  temperature NUMERIC
);

CREATE TABLE Travaux (
  horodatage TIMESTAMP NOT NULL,
  FOREIGN KEY (horodatage) REFERENCES Evenement(horodatage)
);

CREATE TABLE Controle_routier (
  horodatage TIMESTAMP NOT NULL,
  FOREIGN KEY (horodatage) REFERENCES Evenement(horodatage)
);




CREATE TABLE Station_base (
  identifiant NUMERIC PRIMARY KEY,
  position JSON NOT NULL,
  commune JSON NOT NULL
);

-- position sera de la forme {latitude : NUMERIC, longitude : NUMERIC} 
-- commune sera de la forme {nom : VARCHAR, CP : NUMERIC}


CREATE TABLE Vehicule (
  immatriculation VARCHAR PRIMARY KEY,
  marque VARCHAR,
  modele VARCHAR,
  annee_prod NUMERIC,
  station NUMERIC,
  FOREIGN KEY (station) REFERENCES Station_base(identifiant)
);

CREATE TABLE Voiture (
  immatriculation VARCHAR NOT NULL,
  FOREIGN KEY (immatriculation) REFERENCES Vehicule(immatriculation)
);

CREATE TABLE Moto (
  immatriculation VARCHAR NOT NULL,
  FOREIGN KEY (immatriculation) REFERENCES Vehicule(immatriculation),
  cylindre NUMERIC
);

CREATE TABLE Camion (
  immatriculation VARCHAR NOT NULL,
  FOREIGN KEY (immatriculation) REFERENCES Vehicule(immatriculation),
  transport_vehicule BOOLEAN NOT NULL,
  capacite NUMERIC
);

CREATE TABLE Special (
  immatriculation VARCHAR NOT NULL,
  FOREIGN KEY (immatriculation) REFERENCES Vehicule(immatriculation),
  type VARCHAR
);




CREATE TABLE Capteur (
  immatriculation VARCHAR,
  identifiant NUMERIC,
  num_serie NUMERIC PRIMARY KEY,
  modele VARCHAR,
  FOREIGN KEY (immatriculation) REFERENCES Vehicule(immatriculation),
  FOREIGN KEY (identifiant) REFERENCES Station_base(identifiant),
  CHECK ((immatriculation IS NULL AND identifiant IS NOT NULL) OR ( immatriculation IS NOT NULL AND identifiant IS NULL))
);




CREATE TABLE Detecte (
  capteur NUMERIC NOT NULL,
  evenement DATE NOT NULL,
  FOREIGN KEY (capteur) REFERENCES Capteur(num_serie),
  FOREIGN KEY (evenement) REFERENCES Evenement(horodatage)
);

/*******************************************************************************/

--                       Création des vues

/*******************************************************************************/

-- Lister les véhicules intervenant dans un accident

CREATE VIEW liste_vehicules_accident(horodatage, type_vehicule) AS
SELECT horodatage, t.*  FROM Accident  a, JSON_ARRAY_ELEMENTS(a.type_vehicule) t;



-- Lister tous les véhicules dans une région (ici on liste les véhicules de Compiegnes)

CREATE VIEW liste_vehicules(immatriculation, marque, modele) AS
SELECT v.immatriculation, v.marque, v.modele FROM Vehicule v, Station_base s WHERE v.station = s.identifiant AND s.commune->>'nom' = 'Compiègne';



-- Lister toutes les communications liées à une station de base

CREATE VIEW liste_communications_vehicules(immatriculation, marque, modele) AS
SELECT v.immatriculation, v.marque, v.modele FROM Vehicule v WHERE v.station = '275';
-- ici on liste tous les véhicules ayant communiqué avec la station dont l'identifiant est '12345'



-- Trouver le véhicule le plus proche d'un certain type, par exemple, un camion de pompiers, véhicule SAMU, etc. ou un certain modèle : toutes les Citroën C5, ...

CREATE VIEW vehicules_proche1(immatriculation, marque, modele) AS
SELECT v.immatriculation, v.marque, v.modele FROM Vehicule v WHERE v.marque = 'Citroën' AND v.modele = 'C5';
-- pour trouver toutes les Citroën C5

CREATE VIEW vehicules_proche2(immatriculation, marque, modele) AS
SELECT v.immatriculation, v.marque, v.modele FROM Vehicule v, Special s WHERE v.immatriculation = s.immatriculation AND s.type = 'pompier';
-- pour trouver tous les véhicules pompiers



-- Vues pour les contraintes sur les héritages par référence

CREATE VIEW vAccident AS
SELECT * FROM Evenement NATURAL JOIN Accident;

CREATE VIEW vAlerte_meteo AS
SELECT * FROM Evenement NATURAL JOIN Alerte_meteo;

CREATE VIEW vTravaux AS
SELECT * FROM Evenement NATURAL JOIN Travaux;

CREATE VIEW vControle_routier AS
SELECT * FROM Evenement NATURAL JOIN Controle_routier;


CREATE VIEW vVoiture AS
SELECT * FROM Vehicule NATURAL JOIN Voiture;

CREATE VIEW vMoto AS
SELECT * FROM Vehicule NATURAL JOIN Moto;

CREATE VIEW vCamion AS
SELECT * FROM Vehicule NATURAL JOIN Camion;

CREATE VIEW vSpecial AS
SELECT * FROM Vehicule NATURAL JOIN Special;



/*******************************************************************************/

--                       Création des utilisateurs

/*******************************************************************************/

/*
CREATE USER Mateo;
GRANT ALL PRIVILEGES TO Mateo;

CREATE USER utilisateur;
GRANT INSERT ON Vehicule TO utilisateur;
GRANT INSERT ON Moto TO utilisateur;
GRANT INSERT ON Voiture TO utilisateur;
GRANT INSERT ON Camion TO utilisateur;
GRANT INSERT ON Special TO utilisateur;
*/


/*******************************************************************************/

--                       Ajout dans les tables

/*******************************************************************************/

INSERT INTO Evenement VALUES ('2020-06-14 23:46:13');
INSERT INTO Evenement VALUES ('2020-06-15 06:11:01');
INSERT INTO Evenement VALUES ('2020-06-15 7:58:06');
INSERT INTO Evenement VALUES ('2020-06-15 8:01:26');
INSERT INTO Evenement VALUES ('2020-06-15 13:45:00');
INSERT INTO Evenement VALUES ('2020-06-15 16:20:49');

INSERT INTO Accident VALUES ('2020-06-15 7:58:06','accident grave',3,'["Moto","Voiture","Voiture"]');
INSERT INTO Accident VALUES ('2020-06-15 8:01:26','accident peu important',2,'["Voiture","Special"]');

INSERT INTO Alerte_meteo VALUES ('2020-06-15 06:11:01','verglas',-6);

INSERT INTO Travaux VALUES ('2020-06-15 13:45:00');

INSERT INTO Controle_routier VALUES('2020-06-14 23:46:13');
INSERT INTO Controle_routier VALUES('2020-06-15 16:20:49');

INSERT INTO Station_base VALUES (275,'{"latitude" : "48.8", "longitude" : "2.3"}','{"nom" : "Paris", "CP" : "75000"}');
INSERT INTO Station_base VALUES (276,'{"latitude" : "49.4", "longitude" : "2.8"}','{"nom" : "Compiègne", "CP" : "60200"}');
INSERT INTO Station_base VALUES (277,'{"latitude" : "49.2", "longitude" : "4.0"}','{"nom" : "Reims", "CP" : "51100"}');

INSERT INTO Vehicule VALUES ('56-ALO-89','Volvo','F88-49T',1970,276);
INSERT INTO Vehicule VALUES ('42-BDG-26','Kawazaki','Ninja 650',2020,275);
INSERT INTO Vehicule VALUES ('10-DHI-45','Citroën','C5',2008,275);
INSERT INTO Vehicule VALUES ('77-KFP-85','Renault','Gamme G',1989,276);
INSERT INTO Vehicule VALUES ('03-LPS-55','Porsche','Cayenne III',2019,277);

INSERT INTO Voiture VALUES ('10-DHI-45');
INSERT INTO Voiture VALUES ('03-LPS-55');

INSERT INTO Moto VALUES ('42-BDG-26',649);

INSERT INTO Camion VALUES ('56-ALO-89',FALSE,0);

INSERT INTO Special VALUES ('77-KFP-85','pompier');

INSERT INTO Capteur(immatriculation,num_serie,modele) VALUES ('42-BDG-26',102,'Modele SFT-2');
INSERT INTO Capteur(immatriculation,num_serie,modele) VALUES ('10-DHI-45',103,'Modele SFT-2');
INSERT INTO Capteur(immatriculation,num_serie,modele) VALUES ('03-LPS-55',104,'Modele SFT-2');
INSERT INTO Capteur(identifiant,num_serie,modele) VALUES (275,105,'Modele SFT-2');
INSERT INTO Capteur(immatriculation,num_serie,modele) VALUES ('77-KFP-85',89,'Modele SFT-1');
INSERT INTO Capteur(immatriculation,num_serie,modele) VALUES ('56-ALO-89',90,'Modele SFT-1');
INSERT INTO Capteur(identifiant,num_serie,modele) VALUES (276,91,'Modele SFT-1');

/*
INSERT INTO Detecte VALUES (102,'2020-06-15 7:58:06');
INSERT INTO Detecte VALUES (89,'2020-06-15 8:01:26');
*/

/*******************************************************************************/

--            Vues liées contraintes liées aux héritages ou aux associations

/*******************************************************************************/
-- C1, C2 ET C3 sont trois vues qui doivent être vides
CREATE VIEW vLivreFilmMemeCode(codeLivre) AS
SELECT Livre.code FROM Livre, Film WHERE Livre.code = Film.code GROUP BY Livre.code;
CREATE VIEW vFilmEnregistrementMemeCode(codeFilm) AS
SELECT Film.code FROM EnregistrementMusical, Film WHERE EnregistrementMusical.code = Film.code GROUP BY Film.code;
CREATE VIEW vEnregistrementLivreMemeCode(codeEnregistrementMusical) AS
SELECT EnregistrementMusical.code FROM Livre, EnregistrementMusical WHERE EnregistrementMusical.code = Livre.code GROUP BY EnregistrementMusical.code ;



-- Vue pour vérifier qu'il y a au plus deux sanctions par prêt :
CREATE VIEW vnbSanctionsTropEleve(idPret,Nombre) AS
SELECT p.id,count(s.id) AS Nombre FROM Pret p LEFT JOIN Sanction s ON p.id = s.Pret GROUP BY p.id HAVING count(s.id) > 2;

--  Vue pour vérifier que les adhérents qui subissent des sanctions sont bien ceux qui le méritent dans Sanction -> pret . adherent  = Sanction -> Adherent
CREATE VIEW vadherentPbSanction(idAdherent)AS
SELECT Sanction.adherent FROM Pret,Sanction WHERE Sanction.pret = Pret.id AND Sanction.adherent <> Pret.adherent GROUP BY Sanction.adherent;




/*******************************************************************************/

--                        Réponse aux besoins donnés

/*******************************************************************************/
-- Question 1 : Faciliter aux adhérents la recherche des documents et la gestion de leur emprunt
/* Vue pour voir les emprunts d'un utilisateur donné (ici l'utisateur $adhe)
CREATE VIEW ListePret (id,titreL,titreE,titreF) AS
SELECT Exemplaire.id, Livre.titre, EnregistrementMusical.titre, Film.Titre FROM ((((Adherent LEFT JOIN Pret ON Adherent.numcarte=Pret.adherent)
LEFT JOIN Exemplaire ON Exemplaire.id=Pret.exemplaire)
LEFT JOIN Livre  ON Exemplaire.codeLivre = Livre.code)
LEFT JOIN Film  ON Exemplaire.codeFilm = Film.code)
LEFT JOIN EnregistrementMusical ON Exemplaire.codeEnregistrement = EnregistrementMusical.code
WHERE Pret.rendu=False AND Adherent.numCarte = $adhe
*/

--Vue pour que les adhérents puissent voir l'ensemble des exemplaires disponibles
CREATE VIEW vExemplaireDispo(code,ftitre,ltitre,etitre) AS
SELECT id, f.titre,l.titre,e.titre FROM ((Exemplaire LEFT JOIN Livre l ON Exemplaire.codeLivre = l.code) LEFT JOIN Film f ON Exemplaire.codeFilm = f.code) LEFT JOIN EnregistrementMusical e
ON Exemplaire.codeEnregistrement = e.code
WHERE disponibilite = 'disponible'
AND etat<>'abime'
GROUP BY id, f.titre,l.titre,e.titre ;

/* Vue pour que les adhérents trouvent les exemplaires disponibles à partir d'un titre qu'ils ont fournis
CREATE VIEW ChercherDocument (id,titreL,titreE,titreF) AS
SELECT Exemplaire.id, Livre.titre, EnregistrementMusical.titre, Film.Titre
FROM ((Exemplaire LEFT JOIN Livre  ON Exemplaire.codeLivre = Livre.code)
LEFT JOIN Film  ON Exemplaire.codeFilm = Film.code)
LEFT JOIN EnregistrementMusical ON Exemplaire.codeEnregistrement = EnregistrementMusical.code
WHERE EnregistrementMusical.titre=$titre OR Livre.Titre=$titre OR Film.Titre=$titre
AND Exemplaire.disponibilte='disponible'
AND Exemplaire.etat<>'abime';
*/

-- Question 2 : Faciliter la gestion des ressources, ajout et modification

-- Commande pour ajouter des films : Sachant que l'utilisateur aura rentré les valeurs précédées par des $, certains éléments pourront être NULL
--INSERT INTO Livre(code,titre,dateApparition,editeur,genre,codeClassification,langue,auteur,editeurLivre)
-- VALUES ($ISBN,$titre,TO_DATE($date,'YYYYMMDD'),$editeur,$genre,$classification,$langue,$auteur,$editeurLivre);
-- INSERT INTO Exemplaire(id,etat,disponibilite,codeLivre) VALUES ($id,$etat,'disponible',$code);
-- INSERT INTO Exemplaire(id,etat,disponibilite,codeLivre) VALUES ($id2,$etat2,'disponible',$code);
-- ...



-- Commande pour ajouter des films : Sachant que l'utilisateur aura rentré les valeurs précédées par des $, certains éléments pourront être NULL
-- INSERT INTO Film(code,titre,dateApparition,editeur, genre,codeClassification,longueur,synopsis,realisateur)
-- VALUES ($code,$titre,TO_DATE($date,'YYYYMMDD'),$editeur,$genre,$classification,$longueur,$synopsis,$realisateur);
-- INSERT INTO Realisation VALUES ($code,*langue1);
-- INSERT INTO Realisation VALUES ($code,*langue2);
-- ...
-- INSERT INTO Exemplaire(id,etat,disponibilite,codeFilm) VALUES ($id,$etat,'disponible',$code);
-- INSERT INTO Exemplaire(id,etat,disponibilite,codeFilm) VALUES ($id2,$etat2,'disponible',$code);
-- ...


-- Commande pour ajouter des films : Sachant que l'utilisateur aura rentré les valeurs précédées par des $, certains éléments pourront être NULL
--INSERT INTO EnregistrementMusical(code,titre,dateApparition,editeur,genre,codeClassification,longueur,compositeur,interprete)
-- VALUES ($code,$titre,TO_DATE($date,'YYYYMMDD'),$editeur,$genre,$classification,$longueur,$compositeur,$interprete);
-- INSERT INTO Exemplaire(id,etat,disponibilite,codeFilm) VALUES ($id,$etat,'disponible',$code);
-- INSERT INTO Exemplaire(id,etat,disponibilite,codeFilm) VALUES ($id2,$etat2,'disponible',$code);
-- ...

--Commande pour update le synopsis d'un film qui a déjà été recherché par le membre du personnel
--UPDATE Film SET synopsis =$update  WHERE code =$code;

-- Commande pour ajouter des exemplaires à une ressource que l'on récupère via son id et le type, que l'on aura récupéré via le titre puis une sélection du membre
-- INSERT INTO Exemplaire(id,etat,disponibilite,codeFilm) VALUES ($id,$etat,'disponible',$code);
-- INSERT INTO Exemplaire(id,etat,disponibilite,codeLivre) VALUES ($id,$etat,'disponible',$code);
-- INSERT INTO Exemplaire(id,etat,disponibilite,codeEnregistrement) VALUES ($id,$etat,'disponible',$code);

-- Question 3 : Faciliter au personnel la gestion des prêts, des retards mais aussi avoir la liste des adhérents qui peuvent emprunter
-- Vue pour afficher les retards
CREATE VIEW PretsEnRetard (NumCarteAdherant,NomAdherent,idExemplaire) AS
SELECT Adherent.numCarte,Adherent.nom,Pret.exemplaire FROM Adherent,Pret
WHERE Pret.rendu=FALSE
AND  Pret.DateDebut + Pret.duree * INTERVAL '1 day' <= current_date
AND Pret.adherent=adherent.NumCarte;

-- Vue pour vérifier que les adhérents peuvent emprunter
CREATE VIEW vNb_Pret (numCarte, nb) AS
SELECT Adherent.numCarte, COUNT(*) AS Nb_Pret FROM Adherent, Pret
WHERE Adherent.numCarte=Pret.adherent
AND Pret.rendu=false
GROUP BY Adherent.numCarte;

CREATE VIEW vadhe_ok (numcarte,nom,prenom) AS
SELECT a.numcarte,a.nom,a.prenom FROM  (((adherent a LEFT JOIN sanction s ON a.numCarte=s.adherent)
LEFT JOIN pret p ON a.numCarte=p.adherent) JOIN adhesion ad ON a.numCarte=ad.adherent)LEFT JOIN  vNb_pret n ON  a.numCarte=n.numCarte
WHERE a.blacklist=false
AND (s.remboursement IS NULL OR s.remboursement=true )
AND (s.datefinsanction IS NULL OR s.datefinsanction<current_date)
AND ad.datefin>current_date
AND (n.nb IS NULL OR n.nb<5)
GROUP BY a.numcarte,a.nom,a.prenom;


-- Question 4 : Facilitation la gestion des utilisateurs et de leurs données
--Creation des USERS
/*
CREATE USER UnAdherent;
CREATE USER UnMembrePersonnel;

GRANT SELECT ON Livre,Film,EnregistrementMusical,vExemplaire TO UnAdherent;

GRANT ALL PRIVILEGES ON Livre TO UnMembrePersonnel;
GRANT ALL PRIVILEGES ON Film TO UnMembrePersonnel;
GRANT ALL PRIVILEGES ON EnregistrementMusical TO UnMembrePersonnel;
GRANT ALL PRIVILEGES ON Contributeur TO UnMembrePersonnel;
GRANT ALL PRIVILEGES ON Langue TO UnMembrePersonnel;
GRANT ALL PRIVILEGES ON Exemplaire TO UnMembrePersonnel;
GRANT ALL PRIVILEGES ON Pret TO UnMembrePersonnel;
GRANT ALL PRIVILEGES ON Sanction TO UnMembrePersonnel;
GRANT ALL PRIVILEGES ON Joue TO UnMembrePersonnel;
GRANT ALL PRIVILEGES ON Adhesion TO UnMembrePersonnel;
GRANT ALL PRIVILEGES ON Adherent TO UnMembrePersonnel;
GRANT ALL PRIVILEGES ON Realisation TO UnMembrePersonnel;

GRANT SELECT ON vnbEmpruntsEnregistrement TO UnMembrePersonnel;
GRANT SELECT ON vnbEmpruntsFilm TO UnMembrePersonnel;
GRANT SELECT ON vnbEmpruntsLivre TO UnMembrePersonnel;
GRANT SELECT ON vLivreFilmMemeCode TO UnMembrePersonnel;
GRANT SELECT ON vFilmEnregistrementMemeCode TO UnMembrePersonnel;
GRANT SELECT ON vadherentPbSanction TO UnMembrePersonnel;
GRANT SELECT ON nbSanctionsTropEleve TO UnMembrePersonnel;
GRANT SELECT ON vEnregistrementLivreMemeCode TO UnMembrePersonnel;
GRANT SELECT ON vadhe_ok TO UnMembrePersonnel;


Récupération de tous les adhérents
SELECT * FROM Adherent;
Récupération de tous les membres du personnel
SELECT * FROM MembrePersonnel;


-- Ajout d'un Adherent blacklisté par le numéro de sa carte
--UPDATE Adherent SET blacklist = True  WHERE numCarte =$numCarte;

-- Ajout d'un UPDATE pour changer de mail mais adaptable à téléphone, adresse à partir du numéro de la carte
--UPDATE Adherent SET mail = $mail  WHERE numCarte =$numCarte;
*/

-- Question 5 : Statistiques sur ressources avec % d'emprunts d'une ressource / emprunts de toutes les ressources

CREATE VIEW vnbEmprunts(nombre)AS
SELECT Count(*) FROM Pret;
-- Ces 3 vues servent à compter le nombre d'emptunts d'une ressource
CREATE VIEW vnbEmpruntsLivre(code,titre,NbEmpruntsDelivre,pourcentagetotal) AS
SELECT codeLivre,titre, COUNT(*) AS NbEmpruntsDelivre,(COUNT(*)*100/nombre) AS pourcentagetotal FROM Exemplaire,Pret,Livre,vnbEmprunts
WHERE Exemplaire.codeLivre IS NOT NULL
AND Exemplaire.id=Pret.exemplaire
AND Exemplaire.codeLivre = Livre.code
GROUP BY codeLivre,titre,nombre;

CREATE VIEW vnbEmpruntsFilm(code,titre,NbEmpruntsDeFilm,pourcentagetotal) AS
SELECT codeFilm, titre,COUNT(*) AS NbEmpruntsDeFilm ,(COUNT(*)*100/nombre) AS pourcentagetotal FROM Exemplaire,Pret,Film,vnbEmprunts
WHERE Exemplaire.codeFilm IS NOT NULL
AND Exemplaire.id=Pret.exemplaire
AND Exemplaire.codeFilm = Film.code
GROUP BY codeFilm,titre,nombre;

CREATE VIEW vnbEmpruntsEnregistrement(code,titre,NbEmpruntsDEnregistrement,pourcentagetotal) AS
SELECT codeEnregistrement,titre, COUNT(*) AS NbEmpruntsDEnregistrement,(COUNT(*)*100/nombre) AS pourcentagetotal FROM Exemplaire,Pret,EnregistrementMusical,vnbEmprunts
WHERE Exemplaire.codeEnregistrement IS NOT NULL
AND Exemplaire.id=Pret.exemplaire
AND Exemplaire.codeEnregistrement = EnregistrementMusical.code
GROUP BY codeEnregistrement,titre,nombre;

-- Vue qui donne le nombre de prêt par genre par type de ressources, ainsi on peut voir quel genre et type de ressources il préfère
CREATE VIEW StatistiquesAdherent (id) AS
SELECT Adherent.numcarte,livre.genre AS lgenre,film.genre AS fgenre,EnregistrementMusical.genre AS Egenre,COUNT(livre.code) AS cptLivre,COUNT(Film.code)AS cptFilm,COUNT(EnregistrementMusical.code)AS cptEnr
FROM ((((Adherent LEFT JOIN Pret ON Adherent.numcarte=Pret.adherent)
LEFT JOIN Exemplaire ON Exemplaire.id=Pret.exemplaire)
LEFT JOIN Livre  ON Exemplaire.codeLivre = Livre.code)
LEFT JOIN Film  ON Exemplaire.codeFilm = Film.code)
LEFT JOIN EnregistrementMusical ON Exemplaire.codeEnregistrement = EnregistrementMusical.code
GROUP BY Adherent.numcarte,livre.genre,film.genre,EnregistrementMusical.genre
ORDER BY Adherent.numcarte;
