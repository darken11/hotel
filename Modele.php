<?php

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of Modele
 *
 * @author francoise
 */
class Modele {
    //put your code here
private $_id_Modele;
private $_bain;
private $_douche;
private $_wc;
private $_nbreLit2;
private $_nbreLit1;
public function getId_Modele()
{
    return  $_id_Modele;
}
public function getBain()
{
    return  $_bain;
}
public function getDouche()
{
    return  $_douche;
}
public function getWc()
{
    return  $_wc;
}
public function getNbreLit2()
{
    return   $_nbreLit2;
}
public function getNbreLit1()
{
    return  $_nbreLit1;
}
public function setId_Modele($id_modele)
{
     $this->_id_Modele=$id_modele;
}
public function setBain($bain)
{
     $this->_bain=$bain;
}
public function setDouche($douche)
{
    return  $this->_douche=$douche;
}
public function setWc($wc)
{
    return  $this->_wc=$wc;
}
public function setNbreLit2($nblit2)
{
    return   $this->_nbreLit2=nblit2;
}
public function setNbreLit1($nblit1)
{
    return  $this->_nbreLit1=$nblit1;
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
 public function __construct(array $donnees)
	{
		$this->hydrate($donnees);
	}
}
