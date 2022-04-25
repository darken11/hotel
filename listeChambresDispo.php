<?php

/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

spl_autoload_register();
	
	
	
	if (empty($_POST['dateJ']))
	{  
		exit();
	}
	
	$disponibiliteManager=new DisponibiliteManager();
	$lesdispo=$disponibiliteManager->getListByDate($_POST['dateJ']);

	$result = array();
	
	
	
	foreach ($lesdispo as $dispo)
	{   ?>
<option value= <?php echo $dispo->getNumero() ?>> <?php echo $dispo->getNumero()?></option>
	<?php
	}
