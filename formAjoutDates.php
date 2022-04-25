<?php

/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

include ('header.html');
include ('nav_admin.html');
?>		
<div class="row-fluid">
 <div class="span10 offset1">
    <form class="form-inline well" action="ajouterDates.php" method=post>
        <label for ="">Date début</label>
        <input type="text" id="dateDebut" class="date">
        <label for ="">Date fin</label>
        <input type="text" id="dateFin" class="date">
        <label for ="">Nombre de lits bébé</label>
        <input type="text" id="nBebe" maxsize="1">
        <label for ="">Saison</label>
        <select></select>
         <input type="submit" >
        <span></span>

    </form>
 </div>
</div>
  <script src="./bootstrap/js/jquery-ui.js"></script>
 <script type="text/javascript">
 $(document).ready(function () {
     
 var date = new Date();          
           
$( ".date" ).datepicker({
altField: "#datepicker",
closeText: 'Fermer',
prevText: 'Précédent',
nextText: 'Suivant',
currentText: 'Aujourd\'hui',
monthNames: ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'],
monthNamesShort: ['Janv.', 'Févr.', 'Mars', 'Avril', 'Mai', 'Juin', 'Juil.', 'Août', 'Sept.', 'Oct.', 'Nov.', 'Déc.'],
dayNames: ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'],
dayNamesShort: ['Dim.', 'Lun.', 'Mar.', 'Mer.', 'Jeu.', 'Ven.', 'Sam.'],
dayNamesMin: ['D', 'L', 'M', 'M', 'J', 'V', 'S'],
weekHeader: 'Sem.',
dateFormat: 'dd-mm-yy',
minDate: new Date(date.getFullYear(),date.getMonth(), date.getDate()+1)
});
});  
$( "form" ).submit(function( event ) {
    
  
   if($( "input:first" ).val()==="" ||$( "#dateFin" ).val()==="")
   {
   $( "span" ).text( "Pas valide!" ).show().fadeOut( 2000 );
    event.preventDefault();
    }
    else
    {
        
          
    }

  
});
</script>
</body>
</html>
