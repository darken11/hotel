<?php

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of DisponibiliteManager
 *
 * @author francoise
 */
class DisponibiliteManager {
    //put your code here
    private $_db;
	public function __construct()
	{
		$this->_db=connectionSingleton::getInstance()->dbh;
		$this->_db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		//Configure un attribut du gestionnaire de base de données.
		//PDO::ATTR_ERRMODE : rapport d'erreurs. 
		//PDO::ERRMODE_EXCEPTION : émet une exception. 
		
	}
	
	
	public function getListByDate($dateJ)
	{
		
		$requete=$this->_db->prepare('select * from disponibilite where dateJ like :dateJ');
		$requete->bindValue(':dateJ',$dateJ);
                try {
                    
               
                    
                $requete->execute();
		//PDOStatement::fetchAll() — Retourne un tableau contenant toutes les lignes du jeu d'enregistrements.
                 //Le tableau représente chaque ligne comme soit un tableau de valeurs des colonnes, soit un objet avec des propriétés correspondant à chaque nom de colonne. 
		$result=$requete->fetchAll(PDO::FETCH_BOTH);
                var_dump($result);
                $lesDispo=array();
			foreach($result as $donnee)
				{
		
				$lesDispo[]=new Disponibilite($donnee);
				
				}
                             
			return $lesDispo;
			}
		catch(error $e)
		{
			return $e;
		}

		}
}

?>
 

