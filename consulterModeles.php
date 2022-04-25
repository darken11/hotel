<?php

/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


session_start();
include ('header.html');
if(!isset($_SESSION['login']))
include ('nav_general.html');
elseif($_SESSION['login']=="admin")
include('nav_admin.html');
?>
<div class="row-fluid">
<div class="span12  offset1">
<?php
    spl_autoload_register();
    $modeleleManager=new ModeleManager();
    $lesModeles= $modeleleManager->getList();
?>
    <center><table>
        <th>N° modèle</th>
        <th>Bain</th>
        <th>Douche</th>
        <th>WC</th>
        <th>Lits 2 personnes</th>
        <th>Lits 1 personne</th> 
 <?php
        for ($i=0;$i < count( $lesModeles);$i++)
        {
       echo "<tr>";
       echo "<td>";
       echo "<center><a href=consulterTarif.php?idModele=".  $lesModeles[$i][0]." >".$lesModeles[$i][0]."</a></center>";
       echo "</td>";
       for($j=1;$j<4;$j++)
       {
           echo "<td>";
           if( $lesModeles[$i][$j]==1)
               echo "<center><input type=checkbox  checked></center>";
               else { echo "<center><input type=checkbox ></center>";}
            echo "</td>";
       }
         for($j=4;$j<6;$j++)
       {
           echo "<td><center>".$lesModeles[$i][$j]."</center></td>" ;
          
       }  
        echo "</tr>";
        
        }
	
        

?>
    </table>
	</div>
</div>					
