
<style>

.popup-header {
    padding: 1% 1%;
    background-color: #CCCCCC;
    font-size: 0.9em;
    color: white;
    margin: 0 0 5% 0;
  }
</style>
<form class="login100-form validate-form" method="post" style="width: 100%;">
	<span class="login100-form-title p-b-43">
		Inscription Entreprise
		<br> Buy&Bye
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
    <div class="popup-header">
              Une fois la boutique créée, un e-mail sera envoyé au professionnel avec les informations entrées
              ci-dessous.<br>
              Il devra alors confirmer les informations et choisir un mot de passe pour son espace personnel.
            </div>
            
  
    <div class="col">
      <input type="text" class="form-control" placeholder="First name">
    </div>
    <div class="col">
      <input type="text" class="form-control" placeholder="Last name">
    </div>
  


            <div>
                <a href="?page=reset" class="txt1">
                    Mot de passe oublié ?
                </a>
            </div>
        </div>

    	<div class="container-login100-form-btn">
		<a href="?page=inscription2" class="login100-form-btn" name="login">
			Inscription
		</a>
	
        
    </div>
    
</form>

