<?php
spl_autoload_register();
class EmployeManager
{
	private $_db;
	public function __construct()
	{
		$this->_db=connectionSingleton::getInstance()->dbh;
		$this->_db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		//Configure un attribut du gestionnaire de base de données.
		//PDO::ATTR_ERRMODE : rapport d'erreurs. 
		//PDO::ERRMODE_EXCEPTION : émet une exception. 
		
	}
	
	
	public function getByCouleur($couleur)
	{
		
		$requete=$this->_db->prepare('select * from tarif where couleur like :couleur');
		$requete->bindValue(':couleur',$couleur);
		
		
		try{
			$requete->execute();
			$result=$requete->fetch();
			return $result;
			}
		catch(error $e)
		{
			return $e;
		}
	}
	public function getTarif()
	{
		$requete=$this->_db->prepare('select * from tarif ');
		try{
			$requete->execute();
			$result=$requete->fetch();
			return $result;
			}
		catch(error $e)
		{
			return $e;
		}
	}
}
?>