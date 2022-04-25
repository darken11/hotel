<?php
session_start();
?>
<div class="row-fluid">
						<div class="span8 offset2">
							<nav class="navbar navbar-inverse">
								<div class="navbar-inner">
								<div class="nav">
									<ul class="nav">
								
										<li> <a href="accueil.html"> Accueil </a> </li>
										<?php
										
										if(isset($_SESSION['login']))
										{
										echo '<li> <a href="deconnecter.php"> Se déconnecter </a></li>';
										if($_SESSION['login']=="admin")
											{
											 echo'<li> <a href="ajoutSpecialite.php"> Ajouter spécialité </a> </li>';
											}
										}
										else 
										{
										echo '<li> <a href="login.html">Se connecter</a> </li>';
										}
										?>
										
										<li> <a href="#"> Nous contacter </a> </li>
										<li> <a href="consulterSpecialite.php"> Consulter les specialités </a> </li>
									</ul>
								</div>
							</div>
							</nav>
						</div>
		</div>		