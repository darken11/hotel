-- phpMyAdmin SQL Dump
-- version 4.1.14
-- http://www.phpmyadmin.net
--
-- Client :  127.0.0.1
-- Généré le :  Jeu 28 Août 2014 à 15:00
-- Version du serveur :  5.6.17
-- Version de PHP :  5.5.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de données :  `hotel`
--

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
