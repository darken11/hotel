<?php
session_start();
spl_autoload_register();
include ('header.html');
include('nav_general.html');
?>
<form action="listerChambresDispo.php" method=post>

<div class="row-fluid">
<div class="span1  offset1">
Dates:
</div>
<div class="span2">
<?php
$calendrierManager=new calendrierManager();
$lesJours=$calendrierManager->getList();

?>
  	<select name=laDate id=lesdates onChange=go()>
	<option value=0> </option>
	<?php
	foreach($lesJours as $jour)
	{
           
	?>
        <option value= <?php echo $jour->getDateJ()?>> <?php echo $jour->getDateJ();?></option>
	<?php
	}

	?>
        </select>
	

</div>
<div class="row-fluid">
<div class="span1  offset1">
Chambres disponibles
</div>
<div class="span2">

   <select name=chambresDispo id=listeChambresDispo >
   </select>
	

</div>
</div>
</form>

</form>


</body>
</html>
