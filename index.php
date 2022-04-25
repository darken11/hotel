<?php
session_start();
require_once('header.html');
			
		if(!isset($_SESSION['login']))
		include ('nav_general.html');
		elseif($_SESSION['login']=="admin")
		include('nav_admin.html');
		?>
		
	
				<div id="info">
					<?php
					include('accueil.html');
					?>
			
				</div>
		</div>

	    
		
	</body>
