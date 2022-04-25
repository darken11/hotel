<?php

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of Disponibilite
 *
 * @author francoise
 */
class Disponibilite {
    //put your code here
    private $_numero;
    private $_datej;
    public function getNumero()
    {
        return $this->_numero;
    }
    public function getDateJ()
    {
        return $this->_datej;
    }
    public function setNumero($numero)
    {
         $this->_numero=$numero;
    }
    public function setDateJ($dateJ)
    {
        $this->_datej=$dateJ;
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
