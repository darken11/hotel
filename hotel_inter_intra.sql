-- phpMyAdmin SQL Dump
-- version 3.5.1
-- http://www.phpmyadmin.net
--
-- Client: localhost
-- Généré le: Jeu 14 Mars 2013 à 16:33
-- Version du serveur: 5.5.24-log
-- Version de PHP: 5.4.3

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de données: `hotel_inter_intra`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ajout_bebe`(IN `NORESERVATION` INT, OUT `v_nbrebebe` INT)
BEGIN

DECLARE v_datearrivee DATE;
DECLARE v_datedepart DATE;
--
-- Cette fonction permet d''ajouter un lit bébé dans une réservation
-- et retourne le nbre total de lits bébé réservés.

set  v_nbrebebe=0;
 SELECT nbre_bebe,date_arrivee,date_depart INTO v_nbrebebe,v_datearrivee,v_datedepart  FROM reservation r WHERE r.noreservation=noreservation;


    START TRANSACTION;
    IF v_nbrebebe<max_bebe(noreservation) AND 
       lit_bebe_disponible(noreservation)
       THEN
        set v_nbrebebe=v_nbrebebe+1;
       UPDATE reservation r SET nbre_bebe=v_nbrebebe 
       WHERE r.noreservation=noreservation;
       WHILE v_datearrivee <v_datedepart
       DO
       UPDATE calendrier c SET nbebedispo=nbebedispo-1
       WHERE datej=v_datearrivee ;
       SET v_datearrivee=ADDDATE(v_datearrivee,1);
       
       END WHILE;
	   COMMIT;
	ELSE
	ROLLBACK;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ajout_pour`(IN `noreservation` INT, IN `numero` INT, OUT `v_reponse` BOOLEAN)
BEGIN

DECLARE v_datearrivee DATE;
DECLARE v_datedepart DATE;
DECLARE v_nbrenuit INTEGER;
DECLARE v_nbre INTEGER;
DECLARE v_reponse BOOLEAN;


 set v_reponse=true;
-- Récupération des dates d''arrivée et de départ de la réservation

 SELECT date_arrivee,date_depart  INTO v_datearrivee,v_datedepart  FROM reservation  r WHERE r.noreservation=noreservation;
 set  v_nbrenuit=v_datedepart-v_datearrivee;
  SELECT COUNT(*) INTO v_nbre FROM disponibilite d
  WHERE d.numero=numero AND datej>=v_datearrivee AND datej<v_datedepart;
  IF v_nbre<v_nbrenuit
  THEN
   set v_reponse=false; 
  ELSE
  START TRANSACTION;
   SELECT COUNT(*) INTO v_nbre FROM disponibilite d
   WHERE d.numero=numero AND datej>=v_datearrivee AND datej<v_datedepart;
   IF v_nbre<v_nbrenuit
	THEN
	set v_reponse=false; 
	ROLLBACK;
	ELSE
	INSERT INTO pour values(noreservation,numero);
	SET v_reponse=true;
        COMMIT;
  
  END IF;
 END IF;
 
END$$

--
-- Fonctions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `ajout1jour`(j date,p int,n int) RETURNS int(11)
    DETERMINISTIC
begin

declare v_ret int;



select count(*) into v_ret from calendrier where datej like j;



if v_ret = 0

then

insert into calendrier values (j,p,n);

set v_ret = 1;

else

set v_ret = 0;

end if;



return v_ret;

end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `ajoutjours`(`debut` DATE, `fin` DATE, `periode` INT, `nbLits` INT) RETURNS int(11)
    DETERMINISTIC
begin
--
-- Cette fonction permet de déclarer une période d ouverture 
-- 1er paramètre: Début de la période d ouverture
-- 2me paramètre: Fin de la période d ouverture 
-- 3me paramètre: Le n° du code tarif à appliquer
-- 4me paramètre: Le nombre de lits bébé que possède l hotel.
-- Cette fonction retourne le nombre de jours effectivement insérés.
--
declare v_ret int;

declare v_date date;



set v_ret = 0;

set v_date = debut;



while v_date < fin

do

set v_ret = ajout1jour(v_date, periode, nbLits);



set v_date = adddate(v_date,1);

end while;



return v_ret;

end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `ajout_client`(nom char(32),prenom char(32),adresse char(32),npostal char(5),localite char(32),login char(32),password char(40)) RETURNS int(11)
    DETERMINISTIC
begin
declare v_ret int;
declare v_ret_login int;
select count(*) into v_ret from client c where c.nom like nom and c.prenom like prenom and c.adresse like adresse and c.localite like localite;
select count(*) into v_ret_login from client c where c.login like login;
if v_ret=0 and v_ret_login=0
then
	insert into client values (null,nom,prenom,adresse,npostal,localite,login,SHA1(password));
	set v_ret = last_insert_id();
else
	if v_ret=0
	then
		set v_ret = -2;
	else
		set v_ret=-1;
	end if;
end if;
return v_ret;
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `ajout_reservation`(noclient int ,date_arrivee date,date_depart date) RETURNS int(11)
    DETERMINISTIC
BEGIN
DECLARE v_nbrenuit int;
DECLARE v_njour int;
DECLARE v_noreservation int;
DECLARE v_count int;

--
-- Vérification que la date de départ est postérieure à la date d arrivée
--
set v_nbrenuit = date_depart - date_arrivee;
 IF v_nbrenuit > 0 
--
-- Vérification que l hotel est ouvert tous les jours entre
-- la date de départ et la date d arrivée
--
 THEN
 SELECT COUNT(*) INTO v_njour FROM calendrier 
 WHERE datej>=date_arrivee AND datej<date_depart;
 IF v_njour = v_nbrenuit 
--
-- Vérification que le n° de client existe
--
  
  THEN  
    SELECT count(*) INTO v_count FROM client c 
    WHERE c.noclient=noclient;
    IF v_count = 1
--
-- Génération d un numéro de réservation pour le client
--
  THEN
     
     INSERT INTO reservation(noreservation,noclient,date_arrivee,date_depart,
                 date_reservation,date_limiteacompte,date_versementacompte)
     VALUES (null,noclient,date_arrivee,date_depart,
                 now(),NULL,NULL);
    ELSE
     set v_noreservation=0;
    END IF;
 ELSE
   set v_noreservation=0;
 END IF;
 ELSE
   set v_noreservation=0;
 END IF;
 RETURN v_noreservation;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `chambre_reservable`(`numero` INT, `datearrivee` DATE, `datedepart` DATE) RETURNS tinyint(1)
    DETERMINISTIC
BEGIN

DECLARE v_nbrenuit int;
DECLARE v_nbre     int;
DECLARE v_reponse  boolean;
DECLARE v_count    int;

-- Cette fonction permet de tester la disponibilité
-- d''une date d''arrivée à une date de départ

 set v_reponse=true;
 set v_nbrenuit=datedepart-datearrivee; 
 
-- Vérification que la date de départ est postérieure à la 
-- date d''arrivée

 IF datedepart<=datearrivee 
 THEN
  set v_reponse=false;
 END IF;
-- Vérification que l''hotel est ouvert 

 SELECT count(*) INTO v_count FROM calendrier WHERE datej >= datearrivee and datej <= datedepart;
 IF v_count < v_nbrenuit
 THEN
 set v_reponse=false;
 END IF;
-- Vérification que la chambre est disponible pour toutes les nuitées

 SELECT COUNT(*) INTO v_nbre FROM disponibilite d  WHERE d.numero=numero AND datej >=datearrivee AND datej<datedepart;
 IF v_nbre<v_nbrenuit THEN
  set v_reponse=false; 
 END IF; 
 RETURN v_reponse;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `lit_bebe_disponible`(`noreservation` INT) RETURNS int(11)
    DETERMINISTIC
BEGIN
DECLARE v_count int;
DECLARE v_datearrivee DATE;
DECLARE v_datedepart DATE;
DECLARE v_reponse BOOLEAN;
DECLARE v_nbre int;

 set v_reponse=true;
 SELECT count(*) INTO v_count FROM reservation r WHERE r.noreservation=noreservation;
 IF v_count=1
 THEN
 select date_arrivee,date_depart into v_datearrivee, v_datedepart from reservation r where r.noreservation=noreservation;
  
  SELECT MIN(nbebedispo) INTO v_nbre FROM calendrier 
  WHERE datej>=v_datearrivee AND datej<v_datedepart;
  IF v_nbre=0 
  THEN
  set v_reponse=false;
  END IF;
 ELSE
  set v_reponse=false;
 END IF;
 RETURN v_reponse;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `max_bebe`(`NORESERVATION` INT) RETURNS int(11)
    DETERMINISTIC
BEGIN
--
-- Cette fonction précise le nombre maximum de lits
-- bébé mobilisables lors d''une réservation
--
DECLARE v_maxbebe INT;

 SELECT COUNT(*) INTO v_maxbebe FROM pour p,chambre c
 WHERE p.numero=c.numero AND p.noreservation=noreservation
 AND litbebe;
 RETURN v_maxbebe;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `modifie_prix`(`id_modele` INT, `code_tarif` INT, `prix` INT) RETURNS int(11)
    DETERMINISTIC
begin
--
-- Cette fonction modifie le prix des chambres
-- pour un modèle et une saison
--
declare v_prix int;
select prix into v_prix  from prix  p where p.id_modele = id_modele and p.code_tarif =code_tarif for update;
update prix p set p.prix=prix where p.id_modele=id_modele and p.code_tarif =code_tarif;
return 1;
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `modifie_prix_lit_bebe`(`code_tarif` INT, `prixlitbebe` INT) RETURNS int(11)
    DETERMINISTIC
begin
--
-- Cette fonction modifie le prix du lit bébé pour une  saison
--
declare v_prix int;
select prixlitbebe into v_prix  from tarif  t where t.code_tarif = code_tarif for update;
update tarif t set t.prixlitbebe=prixlitbebe where t.code_tarif =code_tarif;
return 1;
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `calendrier`
--

CREATE TABLE IF NOT EXISTS `calendrier` (
  `DATEJ` date NOT NULL,
  `CODE_TARIF` tinyint(4) NOT NULL,
  `NBEBEDISPO` tinyint(4) NOT NULL,
  PRIMARY KEY (`DATEJ`),
  KEY `CODE_TARIF` (`CODE_TARIF`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `calendrier`
--

INSERT INTO `calendrier` (`DATEJ`, `CODE_TARIF`, `NBEBEDISPO`) VALUES
('2013-03-01', 3, 5),
('2013-03-02', 3, 5),
('2013-03-03', 3, 5),
('2013-03-04', 3, 5),
('2013-03-05', 3, 5),
('2013-03-06', 3, 5),
('2013-03-07', 3, 5),
('2013-03-08', 3, 5),
('2013-03-09', 3, 5),
('2013-03-10', 3, 5),
('2013-03-11', 3, 5),
('2013-03-12', 3, 5),
('2013-03-13', 3, 5),
('2013-03-14', 3, 4),
('2013-03-15', 3, 5),
('2013-03-16', 3, 5),
('2013-03-17', 3, 5),
('2013-03-18', 3, 5),
('2013-03-19', 3, 5),
('2013-03-20', 3, 5),
('2013-04-01', 2, 5),
('2013-04-02', 2, 5),
('2013-04-03', 2, 5),
('2013-04-04', 2, 5),
('2013-04-05', 2, 5),
('2013-04-06', 2, 5),
('2013-04-07', 2, 5),
('2013-04-08', 2, 5),
('2013-04-09', 2, 5),
('2013-04-10', 2, 5),
('2013-04-11', 2, 5),
('2013-04-12', 2, 5),
('2013-04-13', 2, 5),
('2013-04-14', 2, 5),
('2013-04-15', 2, 5),
('2013-04-16', 2, 5),
('2013-04-17', 2, 5),
('2013-04-18', 2, 5),
('2013-04-19', 2, 5),
('2013-04-20', 2, 5),
('2013-04-21', 2, 5),
('2013-04-22', 2, 5),
('2013-04-23', 2, 5),
('2013-04-24', 2, 5),
('2013-04-25', 2, 5),
('2013-04-26', 2, 5),
('2013-04-27', 2, 5),
('2013-04-28', 2, 5),
('2013-04-29', 2, 5);

--
-- Déclencheurs `calendrier`
--
DROP TRIGGER IF EXISTS `tajoutjours`;
DELIMITER //
CREATE TRIGGER `tajoutjours` AFTER INSERT ON `calendrier`
 FOR EACH ROW begin

declare v_fin int;

declare v_numero int;

declare curchambre cursor for select numero from chambre;

declare continue handler for sqlstate '02000' set v_fin = 1;



set v_fin = 0;



open curchambre;



fetch curchambre into v_numero;



while v_fin = 0

do

insert into disponibilite values (v_numero,new.datej);

fetch curchambre into v_numero;

end while;



close curchambre;

end
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `chambre`
--

CREATE TABLE IF NOT EXISTS `chambre` (
  `NUMERO` char(4) NOT NULL,
  `ID_MODELE` tinyint(4) NOT NULL,
  `ETAGE` tinyint(4) NOT NULL,
  `LITBEBE` tinyint(1) NOT NULL,
  PRIMARY KEY (`NUMERO`),
  KEY `ID_MODELE` (`ID_MODELE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `chambre`
--

INSERT INTO `chambre` (`NUMERO`, `ID_MODELE`, `ETAGE`, `LITBEBE`) VALUES
('1', 1, 1, 0),
('2', 1, 1, 1),
('3', 4, 2, 0),
('4', 2, 2, 1),
('5', 3, 2, 0),
('6', 3, 2, 1),
('7', 4, 1, 0),
('8', 4, 2, 1);

-- --------------------------------------------------------

--
-- Structure de la table `client`
--

CREATE TABLE IF NOT EXISTS `client` (
  `NOCLIENT` int(11) NOT NULL AUTO_INCREMENT,
  `NOM` char(32) NOT NULL,
  `PRENOM` char(32) NOT NULL,
  `ADRESSE` char(32) DEFAULT NULL,
  `NPOSTAL` char(5) DEFAULT NULL,
  `LOCALITE` char(32) DEFAULT NULL,
  `LOGIN` char(32) DEFAULT NULL,
  `PASSWORD` char(40) DEFAULT NULL,
  PRIMARY KEY (`NOCLIENT`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Contenu de la table `client`
--

INSERT INTO `client` (`NOCLIENT`, `NOM`, `PRENOM`, `ADRESSE`, `NPOSTAL`, `LOCALITE`, `LOGIN`, `PASSWORD`) VALUES
(1, 'client1', 'client1', ' 1 rue1', '1000', 'ville1', 'client1', 'd642fef420c5baa4c72f53de9426f1ed699899e2');

-- --------------------------------------------------------

--
-- Structure de la table `disponibilite`
--

CREATE TABLE IF NOT EXISTS `disponibilite` (
  `NUMERO` char(4) NOT NULL,
  `DATEJ` date NOT NULL,
  PRIMARY KEY (`NUMERO`,`DATEJ`),
  KEY `NUMERO` (`NUMERO`),
  KEY `DATEJ` (`DATEJ`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `disponibilite`
--

INSERT INTO `disponibilite` (`NUMERO`, `DATEJ`) VALUES
('1', '2013-03-01'),
('2', '2013-03-01'),
('3', '2013-03-01'),
('4', '2013-03-01'),
('5', '2013-03-01'),
('6', '2013-03-01'),
('7', '2013-03-01'),
('8', '2013-03-01'),
('1', '2013-03-02'),
('2', '2013-03-02'),
('3', '2013-03-02'),
('4', '2013-03-02'),
('5', '2013-03-02'),
('6', '2013-03-02'),
('7', '2013-03-02'),
('8', '2013-03-02'),
('1', '2013-03-03'),
('2', '2013-03-03'),
('3', '2013-03-03'),
('4', '2013-03-03'),
('5', '2013-03-03'),
('6', '2013-03-03'),
('7', '2013-03-03'),
('8', '2013-03-03'),
('1', '2013-03-04'),
('2', '2013-03-04'),
('3', '2013-03-04'),
('4', '2013-03-04'),
('5', '2013-03-04'),
('6', '2013-03-04'),
('7', '2013-03-04'),
('8', '2013-03-04'),
('1', '2013-03-05'),
('2', '2013-03-05'),
('3', '2013-03-05'),
('4', '2013-03-05'),
('5', '2013-03-05'),
('6', '2013-03-05'),
('7', '2013-03-05'),
('8', '2013-03-05'),
('1', '2013-03-06'),
('2', '2013-03-06'),
('3', '2013-03-06'),
('4', '2013-03-06'),
('5', '2013-03-06'),
('6', '2013-03-06'),
('7', '2013-03-06'),
('8', '2013-03-06'),
('1', '2013-03-07'),
('2', '2013-03-07'),
('3', '2013-03-07'),
('4', '2013-03-07'),
('5', '2013-03-07'),
('6', '2013-03-07'),
('7', '2013-03-07'),
('8', '2013-03-07'),
('1', '2013-03-08'),
('2', '2013-03-08'),
('3', '2013-03-08'),
('4', '2013-03-08'),
('5', '2013-03-08'),
('6', '2013-03-08'),
('7', '2013-03-08'),
('8', '2013-03-08'),
('1', '2013-03-09'),
('2', '2013-03-09'),
('3', '2013-03-09'),
('4', '2013-03-09'),
('5', '2013-03-09'),
('6', '2013-03-09'),
('7', '2013-03-09'),
('8', '2013-03-09'),
('1', '2013-03-10'),
('2', '2013-03-10'),
('3', '2013-03-10'),
('4', '2013-03-10'),
('5', '2013-03-10'),
('6', '2013-03-10'),
('7', '2013-03-10'),
('8', '2013-03-10'),
('1', '2013-03-11'),
('2', '2013-03-11'),
('3', '2013-03-11'),
('4', '2013-03-11'),
('5', '2013-03-11'),
('6', '2013-03-11'),
('7', '2013-03-11'),
('8', '2013-03-11'),
('1', '2013-03-12'),
('2', '2013-03-12'),
('3', '2013-03-12'),
('4', '2013-03-12'),
('5', '2013-03-12'),
('6', '2013-03-12'),
('7', '2013-03-12'),
('8', '2013-03-12'),
('1', '2013-03-13'),
('2', '2013-03-13'),
('3', '2013-03-13'),
('4', '2013-03-13'),
('5', '2013-03-13'),
('6', '2013-03-13'),
('7', '2013-03-13'),
('8', '2013-03-13'),
('3', '2013-03-14'),
('4', '2013-03-14'),
('5', '2013-03-14'),
('6', '2013-03-14'),
('7', '2013-03-14'),
('8', '2013-03-14'),
('1', '2013-03-15'),
('2', '2013-03-15'),
('3', '2013-03-15'),
('4', '2013-03-15'),
('5', '2013-03-15'),
('6', '2013-03-15'),
('7', '2013-03-15'),
('8', '2013-03-15'),
('1', '2013-03-16'),
('2', '2013-03-16'),
('3', '2013-03-16'),
('4', '2013-03-16'),
('5', '2013-03-16'),
('6', '2013-03-16'),
('7', '2013-03-16'),
('8', '2013-03-16'),
('1', '2013-03-17'),
('2', '2013-03-17'),
('3', '2013-03-17'),
('4', '2013-03-17'),
('5', '2013-03-17'),
('6', '2013-03-17'),
('7', '2013-03-17'),
('8', '2013-03-17'),
('1', '2013-03-18'),
('2', '2013-03-18'),
('3', '2013-03-18'),
('4', '2013-03-18'),
('5', '2013-03-18'),
('6', '2013-03-18'),
('7', '2013-03-18'),
('8', '2013-03-18'),
('1', '2013-03-19'),
('2', '2013-03-19'),
('3', '2013-03-19'),
('4', '2013-03-19'),
('5', '2013-03-19'),
('6', '2013-03-19'),
('7', '2013-03-19'),
('8', '2013-03-19'),
('1', '2013-03-20'),
('2', '2013-03-20'),
('3', '2013-03-20'),
('4', '2013-03-20'),
('5', '2013-03-20'),
('6', '2013-03-20'),
('7', '2013-03-20'),
('8', '2013-03-20'),
('1', '2013-04-01'),
('2', '2013-04-01'),
('3', '2013-04-01'),
('4', '2013-04-01'),
('5', '2013-04-01'),
('6', '2013-04-01'),
('7', '2013-04-01'),
('8', '2013-04-01'),
('1', '2013-04-02'),
('2', '2013-04-02'),
('3', '2013-04-02'),
('4', '2013-04-02'),
('5', '2013-04-02'),
('6', '2013-04-02'),
('7', '2013-04-02'),
('8', '2013-04-02'),
('1', '2013-04-03'),
('2', '2013-04-03'),
('3', '2013-04-03'),
('4', '2013-04-03'),
('5', '2013-04-03'),
('6', '2013-04-03'),
('7', '2013-04-03'),
('8', '2013-04-03'),
('1', '2013-04-04'),
('2', '2013-04-04'),
('3', '2013-04-04'),
('4', '2013-04-04'),
('5', '2013-04-04'),
('6', '2013-04-04'),
('7', '2013-04-04'),
('8', '2013-04-04'),
('1', '2013-04-05'),
('2', '2013-04-05'),
('3', '2013-04-05'),
('4', '2013-04-05'),
('5', '2013-04-05'),
('6', '2013-04-05'),
('7', '2013-04-05'),
('8', '2013-04-05'),
('1', '2013-04-06'),
('2', '2013-04-06'),
('3', '2013-04-06'),
('4', '2013-04-06'),
('5', '2013-04-06'),
('6', '2013-04-06'),
('7', '2013-04-06'),
('8', '2013-04-06'),
('1', '2013-04-07'),
('2', '2013-04-07'),
('3', '2013-04-07'),
('4', '2013-04-07'),
('5', '2013-04-07'),
('6', '2013-04-07'),
('7', '2013-04-07'),
('8', '2013-04-07'),
('1', '2013-04-08'),
('2', '2013-04-08'),
('3', '2013-04-08'),
('4', '2013-04-08'),
('5', '2013-04-08'),
('6', '2013-04-08'),
('7', '2013-04-08'),
('8', '2013-04-08'),
('1', '2013-04-09'),
('2', '2013-04-09'),
('3', '2013-04-09'),
('4', '2013-04-09'),
('5', '2013-04-09'),
('6', '2013-04-09'),
('7', '2013-04-09'),
('8', '2013-04-09'),
('1', '2013-04-10'),
('2', '2013-04-10'),
('3', '2013-04-10'),
('4', '2013-04-10'),
('5', '2013-04-10'),
('6', '2013-04-10'),
('7', '2013-04-10'),
('8', '2013-04-10'),
('1', '2013-04-11'),
('2', '2013-04-11'),
('3', '2013-04-11'),
('4', '2013-04-11'),
('5', '2013-04-11'),
('6', '2013-04-11'),
('7', '2013-04-11'),
('8', '2013-04-11'),
('1', '2013-04-12'),
('2', '2013-04-12'),
('3', '2013-04-12'),
('4', '2013-04-12'),
('5', '2013-04-12'),
('6', '2013-04-12'),
('7', '2013-04-12'),
('8', '2013-04-12'),
('1', '2013-04-13'),
('2', '2013-04-13'),
('3', '2013-04-13'),
('4', '2013-04-13'),
('5', '2013-04-13'),
('6', '2013-04-13'),
('7', '2013-04-13'),
('8', '2013-04-13'),
('1', '2013-04-14'),
('2', '2013-04-14'),
('3', '2013-04-14'),
('4', '2013-04-14'),
('5', '2013-04-14'),
('6', '2013-04-14'),
('7', '2013-04-14'),
('8', '2013-04-14'),
('1', '2013-04-15'),
('2', '2013-04-15'),
('3', '2013-04-15'),
('4', '2013-04-15'),
('5', '2013-04-15'),
('6', '2013-04-15'),
('7', '2013-04-15'),
('8', '2013-04-15'),
('1', '2013-04-16'),
('2', '2013-04-16'),
('3', '2013-04-16'),
('4', '2013-04-16'),
('5', '2013-04-16'),
('6', '2013-04-16'),
('7', '2013-04-16'),
('8', '2013-04-16'),
('1', '2013-04-17'),
('2', '2013-04-17'),
('3', '2013-04-17'),
('4', '2013-04-17'),
('5', '2013-04-17'),
('6', '2013-04-17'),
('7', '2013-04-17'),
('8', '2013-04-17'),
('1', '2013-04-18'),
('2', '2013-04-18'),
('3', '2013-04-18'),
('4', '2013-04-18'),
('5', '2013-04-18'),
('6', '2013-04-18'),
('7', '2013-04-18'),
('8', '2013-04-18'),
('1', '2013-04-19'),
('2', '2013-04-19'),
('3', '2013-04-19'),
('4', '2013-04-19'),
('5', '2013-04-19'),
('6', '2013-04-19'),
('7', '2013-04-19'),
('8', '2013-04-19'),
('1', '2013-04-20'),
('2', '2013-04-20'),
('3', '2013-04-20'),
('4', '2013-04-20'),
('5', '2013-04-20'),
('6', '2013-04-20'),
('7', '2013-04-20'),
('8', '2013-04-20'),
('1', '2013-04-21'),
('2', '2013-04-21'),
('3', '2013-04-21'),
('4', '2013-04-21'),
('5', '2013-04-21'),
('6', '2013-04-21'),
('7', '2013-04-21'),
('8', '2013-04-21'),
('1', '2013-04-22'),
('2', '2013-04-22'),
('3', '2013-04-22'),
('4', '2013-04-22'),
('5', '2013-04-22'),
('6', '2013-04-22'),
('7', '2013-04-22'),
('8', '2013-04-22'),
('1', '2013-04-23'),
('2', '2013-04-23'),
('3', '2013-04-23'),
('4', '2013-04-23'),
('5', '2013-04-23'),
('6', '2013-04-23'),
('7', '2013-04-23'),
('8', '2013-04-23'),
('1', '2013-04-24'),
('2', '2013-04-24'),
('3', '2013-04-24'),
('4', '2013-04-24'),
('5', '2013-04-24'),
('6', '2013-04-24'),
('7', '2013-04-24'),
('8', '2013-04-24'),
('1', '2013-04-25'),
('2', '2013-04-25'),
('3', '2013-04-25'),
('4', '2013-04-25'),
('5', '2013-04-25'),
('6', '2013-04-25'),
('7', '2013-04-25'),
('8', '2013-04-25'),
('1', '2013-04-26'),
('2', '2013-04-26'),
('3', '2013-04-26'),
('4', '2013-04-26'),
('5', '2013-04-26'),
('6', '2013-04-26'),
('7', '2013-04-26'),
('8', '2013-04-26'),
('1', '2013-04-27'),
('2', '2013-04-27'),
('3', '2013-04-27'),
('4', '2013-04-27'),
('5', '2013-04-27'),
('6', '2013-04-27'),
('7', '2013-04-27'),
('8', '2013-04-27'),
('1', '2013-04-28'),
('2', '2013-04-28'),
('3', '2013-04-28'),
('4', '2013-04-28'),
('5', '2013-04-28'),
('6', '2013-04-28'),
('7', '2013-04-28'),
('8', '2013-04-28'),
('1', '2013-04-29'),
('2', '2013-04-29'),
('3', '2013-04-29'),
('4', '2013-04-29'),
('5', '2013-04-29'),
('6', '2013-04-29'),
('7', '2013-04-29'),
('8', '2013-04-29');

-- --------------------------------------------------------

--
-- Structure de la table `modele`
--

CREATE TABLE IF NOT EXISTS `modele` (
  `ID_MODELE` tinyint(4) NOT NULL AUTO_INCREMENT,
  `BAIN` tinyint(1) NOT NULL,
  `DOUCHE` tinyint(1) NOT NULL,
  `WC` tinyint(1) NOT NULL,
  `NBRELIT2` int(11) NOT NULL,
  `NBRELIT1` int(11) NOT NULL,
  PRIMARY KEY (`ID_MODELE`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=9 ;

--
-- Contenu de la table `modele`
--

INSERT INTO `modele` (`ID_MODELE`, `BAIN`, `DOUCHE`, `WC`, `NBRELIT2`, `NBRELIT1`) VALUES
(1, 1, 0, 1, 1, 0),
(2, 1, 0, 1, 0, 1),
(3, 0, 0, 0, 1, 0),
(4, 0, 1, 1, 1, 2),
(5, 0, 1, 1, 1, 1),
(6, 1, 1, 1, 1, 2),
(7, 1, 0, 1, 0, 2),
(8, 0, 1, 1, 0, 2);

-- --------------------------------------------------------

--
-- Structure de la table `pour`
--

CREATE TABLE IF NOT EXISTS `pour` (
  `NORESERVATION` int(11) NOT NULL,
  `NUMERO` char(4) NOT NULL,
  PRIMARY KEY (`NORESERVATION`,`NUMERO`),
  KEY `NORESERVATION` (`NORESERVATION`),
  KEY `NUMERO` (`NUMERO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `pour`
--

INSERT INTO `pour` (`NORESERVATION`, `NUMERO`) VALUES
(1, '1'),
(1, '2');

--
-- Déclencheurs `pour`
--
DROP TRIGGER IF EXISTS `t-insert_pour`;
DELIMITER //
CREATE TRIGGER `t-insert_pour` AFTER INSERT ON `pour`
 FOR EACH ROW begin

-- Procédure déclenchée automatiquement après une insertion
-- dans la table "pour" permettant de
-- supprimer la disponibilité de la chambre 


DECLARE v_datearrivee DATE;
DECLARE v_datedepart DATE;

-- Récupération des dates d''arrivée et de départ de la réservation
 SELECT date_arrivee,date_depart INTO v_datearrivee,v_datedepart  FROM reservation WHERE noreservation=NEW.noreservation;
 
-- Suppression de la disponibilité de la chambre

 DELETE FROM disponibilite
 WHERE numero=NEW.numero AND datej>=v_datearrivee AND datej<v_datedepart; 
 
END
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `prix`
--

CREATE TABLE IF NOT EXISTS `prix` (
  `ID_MODELE` tinyint(4) NOT NULL,
  `CODE_TARIF` tinyint(4) NOT NULL,
  `PRIX` int(11) NOT NULL,
  PRIMARY KEY (`ID_MODELE`,`CODE_TARIF`),
  KEY `ID_MODELE` (`ID_MODELE`),
  KEY `CODE_TARIF` (`CODE_TARIF`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `prix`
--

INSERT INTO `prix` (`ID_MODELE`, `CODE_TARIF`, `PRIX`) VALUES
(1, 1, 80),
(1, 2, 90),
(1, 3, 120),
(1, 4, 175);

-- --------------------------------------------------------

--
-- Structure de la table `reservation`
--

CREATE TABLE IF NOT EXISTS `reservation` (
  `NORESERVATION` int(11) NOT NULL AUTO_INCREMENT,
  `NOCLIENT` int(11) NOT NULL,
  `DATE_ARRIVEE` date NOT NULL,
  `DATE_DEPART` date NOT NULL,
  `PRIXTOTAL` int(11) DEFAULT '0',
  `NBRE_BEBE` int(11) DEFAULT '0',
  `ACOMPTE_DEMANDE` int(11) DEFAULT '0',
  `DATE_LIMITEACOMPTE` date DEFAULT NULL,
  `DATE_VERSEMENTACOMPTE` date DEFAULT NULL,
  `DATE_RESERVATION` date DEFAULT NULL,
  PRIMARY KEY (`NORESERVATION`),
  KEY `idClient` (`NOCLIENT`),
  KEY `DATE_ARRIVEE` (`DATE_ARRIVEE`),
  KEY `DATE_DEPART` (`DATE_DEPART`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Contenu de la table `reservation`
--

INSERT INTO `reservation` (`NORESERVATION`, `NOCLIENT`, `DATE_ARRIVEE`, `DATE_DEPART`, `PRIXTOTAL`, `NBRE_BEBE`, `ACOMPTE_DEMANDE`, `DATE_LIMITEACOMPTE`, `DATE_VERSEMENTACOMPTE`, `DATE_RESERVATION`) VALUES
(1, 1, '2013-03-14', '2013-03-15', 0, 1, 0, NULL, NULL, '2013-03-14');

-- --------------------------------------------------------

--
-- Structure de la table `tarif`
--

CREATE TABLE IF NOT EXISTS `tarif` (
  `CODE_TARIF` tinyint(4) NOT NULL AUTO_INCREMENT,
  `COULEUR` char(32) NOT NULL,
  `PRIXLITBEBE` int(11) NOT NULL,
  PRIMARY KEY (`CODE_TARIF`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=5 ;

--
-- Contenu de la table `tarif`
--

INSERT INTO `tarif` (`CODE_TARIF`, `COULEUR`, `PRIXLITBEBE`) VALUES
(1, 'Blanc', 5),
(2, 'Vert', 6),
(3, 'Bleu', 7),
(4, 'Rouge', 8);

--
-- Contraintes pour les tables exportées
--

--
-- Contraintes pour la table `calendrier`
--
ALTER TABLE `calendrier`
  ADD CONSTRAINT `calendrier_ibfk_1` FOREIGN KEY (`CODE_TARIF`) REFERENCES `prix` (`CODE_TARIF`);

--
-- Contraintes pour la table `chambre`
--
ALTER TABLE `chambre`
  ADD CONSTRAINT `chambre_ibfk_1` FOREIGN KEY (`ID_MODELE`) REFERENCES `modele` (`ID_MODELE`);

--
-- Contraintes pour la table `disponibilite`
--
ALTER TABLE `disponibilite`
  ADD CONSTRAINT `disponibilite_ibfk_1` FOREIGN KEY (`NUMERO`) REFERENCES `chambre` (`NUMERO`),
  ADD CONSTRAINT `disponibilite_ibfk_2` FOREIGN KEY (`DATEJ`) REFERENCES `calendrier` (`DATEJ`);

--
-- Contraintes pour la table `pour`
--
ALTER TABLE `pour`
  ADD CONSTRAINT `pour_ibfk_1` FOREIGN KEY (`NORESERVATION`) REFERENCES `reservation` (`NORESERVATION`),
  ADD CONSTRAINT `pour_ibfk_2` FOREIGN KEY (`NUMERO`) REFERENCES `chambre` (`NUMERO`);

--
-- Contraintes pour la table `prix`
--
ALTER TABLE `prix`
  ADD CONSTRAINT `prix_ibfk_1` FOREIGN KEY (`ID_MODELE`) REFERENCES `modele` (`ID_MODELE`),
  ADD CONSTRAINT `prix_ibfk_2` FOREIGN KEY (`CODE_TARIF`) REFERENCES `tarif` (`CODE_TARIF`);

--
-- Contraintes pour la table `reservation`
--
ALTER TABLE `reservation`
  ADD CONSTRAINT `reservation_ibfk_1` FOREIGN KEY (`NOCLIENT`) REFERENCES `client` (`NOCLIENT`),
  ADD CONSTRAINT `reservation_ibfk_2` FOREIGN KEY (`DATE_ARRIVEE`) REFERENCES `calendrier` (`DATEJ`),
  ADD CONSTRAINT `reservation_ibfk_3` FOREIGN KEY (`DATE_DEPART`) REFERENCES `calendrier` (`DATEJ`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
