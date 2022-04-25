<?php
class Employe
{
private $_login;
private $_password;
public function __construct(array $donnees)
	{
		$this->hydrate($donnees);
	}
	
	public function getLogin()
	{
		return $this->_login;
	}
	
	public function getPassword()
	{
		return $this->_password;
	}
	
	public function setLogin($login)
	{
		$this->_login=$login;
	}
	public function setPassword($password)
	{
		$this->_password=$password;
	}
	
	function hydrate(array $donnees)
	{
		foreach ($donnees as $key => $value)
		{
			$method='set'.ucfirst($key);
			if(method_exists($this,$method))
				$this->$method($value);				
		}
	}
}
?>