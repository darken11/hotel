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
	
	
	public function getByLogin($login,$password)
	{
		echo $login;
		$requete=$this->_db->prepare('select count(*) from employe where login like :login and password like :password');
		$requete->bindValue(':login',$login);
		$requete->bindValue(':password',sha1($password));
		
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