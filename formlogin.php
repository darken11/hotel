<?php
include ('header.html');
include ('nav_general.html');
?>		
		<div class="row-fluid">
				<div class="span5 offset2">
					<form class="form-inline well" action="validerLogin.php" method=post>
					<div class="input-append">
						<div class="control-group">
							<div class="controls">
							<input type="text" id="login" name="login" placeholder="Login" required><br/>
							<input type="password" name="password"placeholder="Password"required>				
							<button type="submit" class="btn btn-primary pull-right">Envoyer</button>
							<div class="alert alert-error hide">
							<h4 class="alert-heading">Erreur !
							<br/>
							Vous devez entrer au moins 4 caractères  pour le login! 
							</h4>
							</div>
							</div>
						</div>
					</div>
					</form>
				</div>
			</div>			
		</div>
<script>
	$( "form" ).submit(function( event ) {
 
		if($("#login").val().length < 4){
				$("#login").addClass("error");
				$("div.alert").show("slow").delay(4000).hide("slow");
				return false;
			}

		});


 
</script>









