<!-- Script permettant la gestion des catégories -->

  
<link rel="stylesheet" href="../css/chosen.css">
<link rel="stylesheet" href="../fonts/icomoon/style.css">


<style>
  .chosen-container-multi {
    border: none;
  }

  .chosen-container-multi .chosen-choices {
    background-image: none;
    padding: 7px;
    border: none !important;
    border-radius: 4px;
    -webkit-box-shadow: 0 1px 4px 0 rgba(0, 0, 0, 0.1) !important;
    box-shadow: 0 1px 4px 0 rgba(0, 0, 0, 0.1) !important;
  }

  .chosen-container-multi .chosen-choices li.search-choice {
    -webkit-box-shadow: none;
    box-shadow: none;
    padding-top: 7px;
    padding-bottom: 7px;
    padding-left: 10px;
    padding-right: 26px;
    border: none;
    background-image: none;
  }

  .chosen-container-multi .chosen-choices li.search-choice .search-choice-close {
    top: 9px;
    right: 8px;
  }

  .chosen-container-multi .chosen-choices li.search-field input[type="text"] {
    height: 32px;
    font-size: 14px;
  }

  .chosen-container .chosen-drop {
    border: none !important;
    -webkit-box-shadow: none !important;
    box-shadow: none !important;
    margin-top: 3px;
    border-radius: 4px;
    -webkit-box-shadow: 0 15px 30px 0 rgba(0, 0, 0, 0.2) !important;
    box-shadow: 0 15px 30px 0 rgba(0, 0, 0, 0.2) !important;
  }

  /*Colors*/
  .color-1 .chosen-container-multi .chosen-choices li.search-choice {
    background-color: #e5e4cc;
  }

  .color-2 .chosen-container-multi .chosen-choices li.search-choice {
    background-color: #c7f0db;
  }

  .color-3 .chosen-container-multi .chosen-choices li.search-choice {
    background-color: #d3f4ff;
  }
  .RightContent{
    /* background: url("../images/3883063.png"); */
    background-size:cover;
    background-color:#f3d4b7;

  };

.popup-header {
    padding: 1% 1%;
    background-color: #CCCCCC;
    font-size: 0.9em;
    color: white;
    margin: 0 0 5% 0;
  }

  .conteneur {
    display: flex;
  }

  .flex {
    padding: 0 2% 0 0;
  }

  .onMouseover .textOver {
    visibility: hidden;
    width: 30%;
    background-color: black;
    color: #fff;
    text-align: center;
    border-radius: 6px;
    margin: 5px 0;

    /* Position the tooltip */
    position: absolute;
    margin: 0 5%;
    z-index: 1;
  }

  .onMouseover {
    color: black;
  }

  .onMouseover:hover .textOver {
    visibility: visible;
  }
  
</style>
<div class="wrapper">
			<div class="image-holder">
				<img src="../images/3883063.png" alt="">
			</div>

<form method="post">

            	<div id="wizard">
                
                
            		<!-- SECTION 1 -->
	                <h4></h4>
	                <section>

                  <!-- Nom Prénom -->
	                  <div class="form-row form-group">
	                    <div class="form-holder">
                        <label for="lastname">Nom *</label>
                        <input type="text" name="ownerLastName" id="lastname" class="form-control" placeholder="ex: Dupont" value="<?php echo isset($_POST["ownerLastName"]) ? $_POST["ownerLastName"] : ''; ?>" required>
	                    </div>
	                    <div class="form-holder">
								        <label for="firstname">Prénom *</label>
                				<input type="text" name="ownerFirstName" id="firstname" class="form-control" placeholder="ex: Frédéric" value="<?php echo isset($_POST["ownerFirstName"]) ? $_POST["ownerFirstName"] : ''; ?>" required>
	                    </div>
	                  </div>

                    <!-- Adresse Email -->
	                  <div class="form-row">
                        <label for="mail">Adresse E-Mail *</label>
                        <input type="text" name="email" id="mail" class="form-control" placeholder="ex: email@email.com" value="<?php echo isset($_POST["email"]) ? $_POST["email"] : ''; ?>" required>
                    </div>


                    <!-- Numéro de téléphone -->
                    <div class="form-row">
                      <label for="personnalphone">Numéro de téléphone *</label>
                      <div class="form-holder">
                        <input type="tel" id="personnalphone" class="form-control" name="personnalphone"   placeholder="ex: 01 02 03 04 05"
                        pattern="^((\+\d{1,3}(-| )?\(?\d\)?(-| )?\d{1,5})|(\(?\d{2,6}\)?))(-| )?(\d{3,4})(-| )?(\d{4})(( x| ext)\d{1,5}){0,1}$"
                        value="<?php echo isset($_POST["personnalphone"]) ? $_POST["personnalphone"] : ''; ?>" required>
                      </div>	
                    </div>

	                    <div class="form-row">
	                    	<label for="">
	                    		Mot de passe *
	                    	</label>
	                    	<div class="form-holder">
                          <input type="password" class="form-control" id="Password1" placeholder="Mot de passe">
                          <i class="bi bi-eye-slash" id="togglePassword"></i>
                        </div>
                      </div>
                      <div class="form-row">
	                    	<label for="">
	                    		Répéter le mot de passe *
	                    	</label>
	                    	<div class="form-holder">
                          <input type="password" class="form-control" id="Password2" placeholder="Répéter le Mot de passe">
                          <i class="bi bi-eye-slash" id="togglePassword"></i>
                        </div>
                      </div>
                      
	                </section>
	                
					        <!-- SECTION 2 -->
	                <h4></h4>
	                <section>
                    <div class="form-row">
                      <label for="autocomplete">Adresse Postale *</label>
                      <input type="text" name="autocomplete" class="form-control" id="autocomplete" value="<?php echo isset($_POST["autocomplete"]) ? $_POST["autocomplete"] : ''; ?>" placeholder="Indiquer l'adresse postale complète" required>
                      <input type="hidden" name="latitude" id="latitude" class="form-control" value="<?php echo isset($_POST["latitude"]) ? $_POST["latitude"] : '0'; ?>" required >  
                      <input type="hidden" name="longitude" id="longitude" class="form-control" value="<?php echo isset($_POST["longitude"]) ? $_POST["longitude"] : '0'; ?>" required>
                    </div>	
	                	
                    <div class="form-row">
                      <label for="enterprisephone">Téléphone de l'entreprise *</label>
              
                      <input type="tel" id="enterprisePhone" class="form-control" name="enterprisePhone"   placeholder="ex: 01 02 03 04 05"
                      pattern="^((\+\d{1,3}(-| )?\(?\d\)?(-| )?\d{1,5})|(\(?\d{2,6}\)?))(-| )?(\d{3,4})(-| )?(\d{4})(( x| ext)\d{1,5}){0,1}$"
                      value="<?php echo isset($_POST["enterprisePhone"]) ? $_POST["enterprisePhone"] : ''; ?>" required>
                    </div>
                    <div class="form-row">
                    <label for="isphoneVisible">Numéro de téléphone visible ? <a data-toggle="tooltip" data-bs-placement="right" title="Permet d'afficher aux clients le numéro de téléphone sur l'application">ⓘ</a></label>
                      <div class="form-group">
                        <div class="form-check form-switch">
                          <input class="form-check-input" type="checkbox" name="isPhoneVisible" id="isphonevisible" <?php echo isset($_POST["livraison"]) ? "checked" : ''; ?>>
                          <label class="form-check-label" for="isPhoneVisible">Afficher le numéro de téléphone aux clients </label>
                        </div>
                      </div>
                    </div>
						
                    <div class="form-row form-group">
                      <div class="form-holder">
                      <label for="siritnumber">Numéro de SIRET *</label>
                        <input type="text" class="form-control" id="siretNumber" placeholder="000000000">  
                      </div>
                      <div class="form-holder">
                      <label for="siritnumber">Numéro de TVA *</label>
                        <div class="input-group">
                          
                            <span class="input-group-text">FR</span>
                            <input type="text" class="form-control" id="tvaNumber" placeholder="000000000">
                        </div>		
                      </div>
                    </div>
                    
                    <div class="form-row">
                      <label class="mr-sm-2" for="companyType">Type d'entreprise</label>
                      <select value="" class="form-select companyType" name="companyType" id="companyType" required>
                        <option value="" selected disabled hidden>Veuillez choisir un type d'entreprise</option>
                        <option value="Magasin"<?php echo isset($_POST["companyType"]) ? "selected" : ''; ?>>Magasin</option>
                        <option value="Service" <?php echo isset($_POST["companyType"]) ? "selected" : ''; ?>>Service</option>
                        <option value="Restaurant" <?php echo isset($_POST["companyType"]) ? "selected" : ''; ?>>Restaurant</option>
                        <option value="Santé" <?php echo isset($_POST["companyType"]) ? "selected" : ''; ?>>Santé</option>
                        <option value="Culture & Loisirs" <?php echo isset($_POST["companyType"]) ? "selected" : ''; ?>>Culture & Loisirs</option>
                      </select>
                    </div>
	                </section>

	                <!-- SECTION 3 -->
	                <h4></h4>
	                <section>
                    <script>  
                        $(function(){
                        $(".chosen-select").chosen({
                          max_selected_options: 3,
                          width: '100%'
                        }); 
                      });
                      
                    </script>
                    <div class="category1 d-none">                 
                      <div class="form-row">
                        <label class="mr-sm-2" for="companyType">Tags Entreprise <a data-toggle="tooltip" data-bs-placement="right" title="L'ajout de tags permet de mieux vous référencer au sein de l'application et auprès des clients !">ⓘ</a></label>
                          <div class="color-2">
                            <select data-placeholder="Tags Magasin" name="select[]" multiple class="chosen-select" tabindex="8">
                              <option>Electroménager</option>
                              <option>Jeux-Vidéos</option>
                              <option>High-Tech</option>
                              <option>Alimentation</option>
                              <option>Vêtements</option>
                              <option>Films & Séries</option>
                              <option>Chaussures</option>
                              <option>Bricolage</option>
                              <option>Montres & Bijoux</option>
                              <option>Téléphonie</option>
                            </select>
                          </div>
                      </div>
                    </div>
                    <div class="category2 d-none">
                      <div class="form-row">
                      <label class="mr-sm-2" for="companyType">Tags Entreprise <a data-toggle="tooltip" data-bs-placement="right" title="L'ajout de tags permet de mieux vous référencer au sein de l'application et auprès des clients !">ⓘ</a></label>
                        <div class="color-2">
                          <select data-placeholder="Tags Service" name="select[]" multiple class="chosen-select" tabindex="8">
                            <option>Menuiserie</option>
                            <option>Plomberie</option>
                            <option>Piscine</option>
                            <option>Meubles</option>
                            <option>Vêtements</option>
                            <option>Gestion de patrimoine</option>
                          </select>
                        </div>
                      </div>
                    </div>
                    <div class="category3 d-none">
                      <div class="form-row">
                      <label class="mr-sm-2" for="companyType">Tags Entreprise <a data-toggle="tooltip" data-bs-placement="right" title="L'ajout de tags permet de mieux vous référencer au sein de l'application et auprès des clients !">ⓘ</a></label>
                        <div class="color-2">
                          <select data-placeholder="Tags Restaurant" name="select[]" multiple class="chosen-select" tabindex="8">
                            <option>Français</option>
                            <option>Local</option>
                            <option>Italien</option>
                            <option>Fast-Food</option>
                            <option>Asiatique</option>
                            <option>Pizzeria</option>
                          </select>
                        </div>
                      </div>
                    </div>
                    <div class="category4 d-none">
                      <div class="form-row">
                      <label class="mr-sm-2" for="companyType">Tags Entreprise <a data-toggle="tooltip" data-bs-placement="right" title="L'ajout de tags permet de mieux vous référencer au sein de l'application et auprès des clients !">ⓘ</a></label>
                        <div class="color-2">
                          <select data-placeholder="Tags Santé" name="select[]" multiple class="chosen-select" tabindex="8">
                            <option>Pharmacie</option>
                            <option>Aide à la personne</option>
                          </select>
                        </div>
                      </div>
                    </div>
                    <div class="category5 d-none">
                      <div class="form-row">
                      <label class="mr-sm-2" for="companyType">Tags Entreprise <a data-toggle="tooltip" data-bs-placement="right" title="L'ajout de tags permet de mieux vous référencer au sein de l'application et auprès des clients !">ⓘ</a></label>
                        <div class="color-2">
                          <select data-placeholder="Tags Culture et loisirs" name="select[]" multiple class="chosen-select" tabindex="8">
                            <option>Parc d'attraction</option>
                            <option>Musée</option>
                            <option>Tourisme</option>
                          </select>
                        </div>
                      </div>
                    </div>
                    <!-- <div class="menu d-none">
                    <div class=" form-row">
                        <label for="exampleColorInput" class="form-label">Ajouter un menu <a data-toggle="tooltip" data-bs-placement="right" title="L'ajout d'un menu sur l'application permet à vos clients de connaître la composition de votre carte directement depuis l'application">ⓘ</a></label><br>                     
                        <img id="imagePreview_menu" src="#" hidden />
                        <input type="file" name="menu" id="menu" onchange="readURL(this);"><br><br>
                    </div>
                    </div>                   -->
                    <div class=" form-row">
                        <label for="banniere" class="form-label">Ajouter une bannière <a data-toggle="tooltip" data-bs-placement="right" title="L'ajout d'une bannière permet de faire ressortir la page de votre entreprise et ainsi de vous démarquer !">ⓘ</a></label><br>                     
                        <img id="imagePreview" src="#" hidden />
                        <input type="file" name="banniere" id="banniere" onchange="readURL(this);"><br><br>
                    </div>
                    <div class="form-row ">
                      <label for="color" class="form-label">Couleur de l'interface <a data-toggle="tooltip" data-bs-placement="right" title="Faites ressortir votre page en la mettant au couleur de votre entreprise !">ⓘ</a></label>
                      <div class="col-sm-2">                    
                        <input type="color" class="form-control-color" name="color" id="exampleColorInput" title="Choissisez une couleur">
                      </div>
                    </div>
                    <div class="form-row">
                      <label for="exampleFormControlTextarea1">Description <a data-toggle="tooltip" data-bs-placement="right" title="Une courte description permet de mettre en avant votre entreprise auprès des utilisateurs">ⓘ</a></label>
                      <textarea class="form-control" name="description" id="description"
                        rows="2" placeholder="Voici la description de mon entreprise" required><?php echo isset($_POST["description"]) ? $_POST["description"] : ''; ?></textarea>
                    </div>
                    <div class="form-row">
                      <label for="exampleFormControlTextarea1">Horaires d'ouverture <a data-toggle="tooltip" data-bs-placement="right" title="Les horaires d'ouverture permettent de mieux renseigner vos futurs clients">ⓘ</a></label>
                      <table class="table">
                        <thead>
                          <tr>
                            <th scope="col">Jours de la semaine</th>
                            <th scope="col">Première Ouverture</th>
                            <th scope="col">Première Fermeture</th>
                            <th scope="col">Deuxième Ouverture</th>
                            <th scope="col">Dexième Fermeture</th>
                          </tr>
                        </thead>
                        <tbody>
                          <tr>
                            <th scope="row">Lundi</th>
                            <td><input type="time" id="lundi_first_open" name="lundi_first_open"></td>
                            <td><input type="time" id="lundi_first_close" name="lundi_first_close"></td>
                            <td><input type="time" id="lundi_second_open" name="lundi_second_open"></td>
                            <td><input type="time" id="lundi_second_close" name="lundi_second_close"></td>
                          </tr>
                          <tr>
                            <th scope="row">Mardi</th>
                            <td><input type="time" id="mardi_first_open" name="mardi_first_open"></td>
                            <td><input type="time" id="mardi_first_close" name="mardi_first_close"></td>
                            <td><input type="time" id="mardi_second_open" name="mardi_second_open"></td>
                            <td><input type="time" id="mardi_second_close" name="mardi_second_close"></td>
                          </tr>
                          <tr>
                            <th scope="row">Mercredi</th>
                            <td><input type="time" id="mercredi_first_open" name="mercredi_first_open"></td>
                            <td><input type="time" id="mercredi_first_close" name="mercredi_first_close"></td>
                            <td><input type="time" id="mercredi_second_open" name="mercredi_second_open"></td>
                            <td><input type="time" id="mercredi_second_open" name="mercredi_second_close"></td>
                          </tr>
                          <tr>
                            <th scope="row">Jeudi</th>
                            <td><input type="time" id="jeudi_first_open" name="jeudi_first_open"></td>
                            <td><input type="time" id="jeudi_first_close" name="jeudi_first_close"></td>
                            <td><input type="time" id="jeudi_second_open" name="jeudi_second_open"></td>
                            <td><input type="time" id="jeudi_second_open" name="jeudi_second_close"></td>
                          </tr>
                          <tr>
                            <th scope="row">Vendredi</th>
                            <td><input type="time" id="vendredi_first_open" name="vendredi_first_open"></td>
                            <td><input type="time" id="vendredi_first_close" name="vendredi_first_close"></td>
                            <td><input type="time" id="vendredi_second_open" name="vendredi_second_open"></td>
                            <td><input type="time" id="vendredi_second_close" name="vendredi_second_close"></td>
                          </tr>
                          <tr>
                            <th scope="row">Samedi</th>
                            <td><input type="time" id="samedi_first_open" name="samedi_first_open"></td>
                            <td><input type="time" id="samedi_first_close" name="samedi_first_close"></td>
                            <td><input type="time" id="samedi_second_open" name="samedi_second_open"></td>
                            <td><input type="time" id="samedi_second_close" name="samedi_second_close"></td>
                          </tr>
                          <tr>
                            <th scope="row">Dimanche</th>
                            <td><input type="time" id="dimanche_first_open" name="dimanche_first_open"></td>
                            <td><input type="time" id="dimanche_first_close" name="dimanche_first_close"></td>
                            <td><input type="time" id="dimanche_second_open" name="dimanche_second_open"></td>
                            <td><input type="time" id="dimanche_second_close" name="dimanche_second_close"></td>
                          </tr>
                        </tbody>
                      </table>
                     </div>
	                </section>

	                <!-- SECTION 4 -->
	                <h4></h4>
	                <section>
                    FAIRE UNE PAGE TYPE PAIEMENT FORMULE
	                    <!-- <div class="checkbox-circle">
							<label class="active">
								<input type="radio" name="billing method" value="Direct bank transfer" checked>Direct bank transfer>
								<span class="checkmark"></span>
								<div class="tooltip">
									Make your payment directly into our bank account. Please use your Order ID as the payment reference. Your order will not be shipped until the funds have cleared in our account.
								</div>
							</label>
							<label>
								<input type="radio" name="billing method" value="Check payments">Check payments
								<span class="checkmark"></span>
								<div class="tooltip">
									Please send a check to Store Name, Store Street, Store Town, Store State / County, Store Postcode.
								</div>
							</label>
							<label>
								<input type="radio" name="billing method" value="Cash on delivery">Cash on delivery
								<span class="checkmark"></span>
								<div class="tooltip">
									Pay with cash upon delivery.
								</div>
							</label>
						</div> -->
	                </section>
					<!-- SECTION 5 -->
	                <h4></h4>
	                <section>
	                    <h4>Informations Personnelles</h4>
                      <div class="form-row form-group">
	                    <div class="form-holder">
                        <label for="resume_lastname">Nom </label>
                        <input type="text" name="resume_lastname" id="resume_lastname" class="form-control" value="" disabled>
	                    </div>
	                    <div class="form-holder">
								        <label for="resume_firstname">Prénom </label>
                				<input type="text" name="resume_firstname" id="resume_firstname" class="form-control" value="" disabled>
	                    </div>
	                  </div>

                    <!-- Adresse Email -->
	                  <div class="form-row">
                        <label for="mail">Adresse E-Mail </label>
                        <input type="text" name="resume_email" id="resume_email" class="form-control" value="" disabled>
                    </div>


                    <!-- Numéro de téléphone -->
                    <div class="form-row">
                      <label for="personnalphone">Numéro de téléphone</label>
                      <div class="form-holder">
                        <input type="tel" id="resume_personnalphone" class="form-control" name="resume_personnalphone"  value="" disabled>
                      </div>	
                    </div>
                      <h4>Informations sur l'entreprise</h4>
                      <h4>Personnalisation</h4>
                      <h4>Information Bancaires</h4>
	                </section>
            	</div>
            
    
</form>

</div>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script>
$(document).on('change','.companyType',function() {

if ($(this).val() == 'Magasin'){
  
	$(".category1").removeClass("d-none");

	$(".category2").addClass("d-none");
	$(".category3").addClass("d-none");
	$(".category4").addClass("d-none");
	$(".category5").addClass("d-none");
} else if ($(this).val() == 'Service'){
	$(".category2").removeClass("d-none");

	$(".category1").addClass("d-none");
	$(".category3").addClass("d-none");
	$(".category4").addClass("d-none");
	$(".category5").addClass("d-none");

}else if ($(this).val() == 'Restaurant'){
  $(".menu").removeClass("d-none");
	$(".category3").removeClass("d-none");

	$(".category2").addClass("d-none");
	$(".category1").addClass("d-none");
	$(".category4").addClass("d-none");
	$(".category5").addClass("d-none");

}else if ($(this).val() == 'Santé'){
	$(".category4").removeClass("d-none");

	$(".category2").addClass("d-none");
	$(".category3").addClass("d-none");
	$(".category1").addClass("d-none");
	$(".category5").addClass("d-none");

}else if ($(this).val() == 'Culture & Loisirs'){
	$(".category5").removeClass("d-none");

	$(".category2").addClass("d-none");
	$(".category3").addClass("d-none");
	$(".category4").addClass("d-none");
	$(".category1").addClass("d-none");

}
});</script>

<script>
    function readURL(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();

            reader.onload = function (e) {
                $('#imagePreview')
                    .attr('src', e.target.result)
                    .removeAttr('hidden')
                    .height(200);

            };


            reader.readAsDataURL(input.files[0]);
        }
    };
</script>