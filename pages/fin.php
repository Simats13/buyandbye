
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

            <div  class="d-inline-block overflow-auto me-2 bg-white"  style=" height: 250px; ">
                <p> Lorem ipsum dolor sit amet consectetur adipisicing elit. Iure amet quaerat, quos, vero voluptatum ullam adipisci delectus odio dolore id consectetur veniam ad iste neque natus consequatur officia, voluptas ratione! Lorem, ipsum dolor sit amet consectetur adipisicing elit. Sed, ab natus! Illum asperiores modi harum non nostrum nobis mollitia. Neque nobis earum quae minus quaerat dolorem fugit, molestias commodi itaque. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Debitis nisi suscipit consequuntur in amet provident quos accusantium, laudantium tenetur voluptatibus cumque dolorum corrupti minima? Reprehenderit quia vel amet vero quaerat! Lorem ipsum dolor sit amet consectetur, adipisicing elit. Assumenda asperiores dolorum explicabo fugiat dolorem, dolor fugit neque numquam doloremque impedit dolore, similique cum quidem nulla, magni tempora culpa voluptatem laborum. Lorem ipsum, dolor sit amet consectetur adipisicing elit. Minus sequi, debitis, assumenda possimus ratione error aliquam nemo eos alias excepturi quod sint deserunt voluptatibus! Mollitia corporis repellat atque odio magnam? Lorem ipsum dolor sit amet consectetur adipisicing elit. Incidunt aliquid totam quasi explicabo corporis soluta, iusto porro nam voluptatum nulla ex itaque iure odio? Ab deserunt repudiandae alias aperiam illo? </p></div>

        <div class="flex-sb-m w-full p-t-3 p-b-32">
            <div class="contact100-form-checkbox">
                <input class="input-checkbox100" id="ckb1" type="checkbox" name="remember-me">
                <label class="label-checkbox100" for="ckb1">
                   J'accepte les conditions générales d'utilisation
                </label>
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

