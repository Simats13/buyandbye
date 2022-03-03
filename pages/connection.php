<div class="wrapper"> 
			<div class="image-holder">
				<img src="../images/logo.png" alt="">
			</div>
			
<form class="login100-form validate-form" method="post" style="width: 100%;">
	<span class="login100-form-title p-b-43">
		Connexion Espace Buy&Bye
	</span>

	<?php 
        if(isset($_SESSION['status'])){
            echo "<h5 class='alert alert-danger'>".$_SESSION['status']."</h5>";
             unset($_SESSION['status']);
        }

		if(isset($_SESSION['success'])){
            echo "<h5 class='alert alert-success'>".$_SESSION['success']."</h5>";
            unset($_SESSION['success']);
        }           
    ?>
	<span class="login100-form-title p-b-43">
	</span>


	<div class="wrap-input100 validate-input" data-validate="Veuillez entrer une adresse e-mail valide : ex@abc.xyz">
		<input class="input100" type="text" name="email">
		<span class="focus-input100"></span>
		<span class="label-input100">Email</span>
	</div>


	<div class="wrap-input100 validate-input" data-validate="Veuillez entrer un mot de passe">
		<input class="input100" type="password" name="password">
		<span class="focus-input100"></span>
		<span class="label-input100">Mot de passe</span>
	</div>

	<div class="flex-sb-m w-full p-t-3 p-b-32">
		<div class="form-check">
			<input class="form-check-input" id="ckb1"  name="remember-me" type="checkbox" value="" id="flexCheckDefault">
			<label class="form-check-label" for="ckb1">
				Se souvenir de moi
			</label>
		</div>

		<div>
			<a href="?page=reset" class="txt1">
				Mot de passe oublié ?
			</a>
		</div>
	</div>


	<div class="container-login100-form-btn">
		<button class="login100-form-btn" name="login">
			Connexion
		</button>
	</div>
	<br>
	<div>
		<a href="?page=inscription" class="txt1">
			<h6>Pas de compte ? Créez-en un !</h6>
		</a>
	</div>
</form>
</div>