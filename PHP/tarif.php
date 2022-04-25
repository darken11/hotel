<?php
class Tarif
{
private $_codeTarif;
private $_couleur;
private $_prixLitBebe;
public function __construct(array $donnees)
	{
		$this->hydrate($donnees);
	}
	
	public function getCodeTarif()
	{
		return $this->_codeTarif;
	}
	
	public function getCouleur()
	{
		return $this->_couleur;
	}
	public function getPrixLitBebe()
	{
		return $this->_prixLitBebe;
	}
	
	public function setCodeTarif($tarif)
	{
		$this->_codeTarif=$tarif;
	}
	public function setCouleur($couleur)
	{
		$this->_couleur=strtoupper($couleur);
	}
	public function setPrixLitBebe($prix)
	{
		$this->_prixLitBebe=$prix;
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