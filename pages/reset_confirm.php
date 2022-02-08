<?php 

$oobCode = $_GET['oobCode']; // Extract the OOB code from the request url (not scope of the SDK (yet :)))

$action = 0;

try {
    $auth->verifyPasswordResetCode($oobCode);
    $action = 1;

} catch (\Kreait\Firebase\Exception\Auth\ExpiredOobCode $e) {
    // Handle the case of an expired reset code
    
} catch (\Kreait\Firebase\Exception\Auth\InvalidOobCode $e) {
    // Handle the case of an invalid reset code
  


} catch (\Kreait\Firebase\Exception\AuthException $e) {
    // Another error has occurred
    

}


?>

<?php if($action == 1) {
?>
<form class="login100-form validate-form" method="post" oninput='password2.setCustomValidity(password2.value != password1.value ? "Les mots de passe ne sont pas identiques !" : "")'>
					<span class="login100-form-title p-b-43">
						Modification Mot de Passe
                       <br> Petite Camargue
					</span>

                    <span class="login100-form-title p-b-43">
						
					</span>
					
					
					<div class="wrap-input100 validate-input" data-validate = "Veuillez entrer un mot de passe">
						<input class="input100" type="password" name="password1" required>
						<span class="focus-input100"></span>
						<span class="label-input100">Nouveau Mot de Passe</span>
					</div>
					
					
					<div class="wrap-input100 validate-input" data-validate="Veuillez entrer un mot de passe">
						<input class="input100" type="password" name="password2" required>
						<span class="focus-input100"></span>
						<span class="label-input100">Répéter le Mot de Passe</span>
					</div>			

					<div class="container-login100-form-btn">
						<button class="login100-form-btn" name="resetConfirm" value="<?=$oobCode?>">
							Modifier
						</button>
					</div>
					
		
				</form>
<?php }else{ ?>
    <form class="login100-form validate-form">
					<span class="login100-form-title p-b-43">
						Modification Mot de Passe
                       <br> Petite Camargue
					</span>

              
					
					<div class="card">
                        <div class="card-body">
                        Votre demande de réinitialisation du mot de passe a expiré ou ce lien a déjà été utilisé.
                        </div>
                    </div>

                    <br>
                    <div class="container-login100-form-btn">
						<a href="../../" class="login100-form-btn" >
							Retourner à la page d'accueil
                        </a>
					</div>
					
					
		
				</form>
<?php } ?>