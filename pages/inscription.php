
<style>

  .background{
    background: url("../images/seller.jpg");
    background-size: 100% 100%;
    float: left;
    width: 60%;
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
                        </div>
                      </div>
                      <div class="form-row">
	                    	<label for="">
	                    		Répéter le mot de passe *
	                    	</label>
	                    	<div class="form-holder">
                          <input type="password" class="form-control" id="Password2" placeholder="Répéter le Mot de passe">
                        </div>
                      </div>
                      <select class="select" multiple data-mdb-clear-button="true">
  <option value="1">One</option>
  <option value="2">Two</option>
  <option value="3">Three</option>
  <option value="4">Four</option>
  <option value="5">Five</option>
</select>
	                </section>
	                
					<!-- SECTION 2 -->
	                <h4></h4>
	                <section>
                    <div class="form-row">
                      <label for="autocomplete">Adresse Postale *</label>
                      <input type="text" name="autocomplete" class="form-control" id="autocomplete" value="<?php echo isset($_POST["autocomplete"]) ? $_POST["autocomplete"] : ''; ?>" required>
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
                      <div class="form-group">
                        <label for="isphonevisible">Numéro de téléphone visible ? <a href="#" data-toggle="tooltip" data-bs-placement="right" title="Permet d'afficher aux clients le numéro de téléphone sur l'application">ⓘ</a></label>
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
                        <input type="text" class="form-control" id="tvaNumber" placeholder="000000000">
                      </div>
                    </div>
                    
                    <div class="form-row">
                      <label class="mr-sm-2" for="companyType">Type d'entreprise</label>
                      <div class="form-holder">
                      <select class="form-select" aria-label="Default select example">
  <option selected>Open this select menu</option>
  <option value="1">One</option>
  <option value="2">Two</option>
  <option value="3">Three</option>
</select>
                      </div>
                    </div>
	                </section>

	                <!-- SECTION 3 -->
	                <h4></h4>
	                <section>
					<div class="category1">
                <div class="form-group">
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
                      <option>Restaurant</option>
                    </select>
                  </div>
                </div>
              </div>
              <div class="category2">
                <div class="form-group">
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

              <div class="category3">
                <div class="form-group">
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

              <div class="category4">
                <div class="form-group">
                  <div class="color-2">
                    <select data-placeholder="Tags Santé" name="select[]" multiple class="chosen-select" tabindex="8">
                      <option>Pharmacie</option>
                      <option>Aide à la personne</option>
                    </select>
                  </div>
                </div>
              </div>

              <div class="category5">
                <div class="form-group">
                  <div class="color-2">
                    <select data-placeholder="Tags Culture et loisirs" name="select[]" multiple class="chosen-select" tabindex="8">
                      <option>Parc d'attraction</option>
                      <option>Musée</option>
                      <option>Tourisme</option>
                    </select>
                  </div>
                </div>
              </div>
			  <div class="category1">
                <div class="form-group">
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
                      <option>Restaurant</option>
                    </select>
                  </div>
                </div>
              </div>
              <div class="category2">
                <div class="form-group">
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

              <div class="category3">
                <div class="form-group">
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

              <div class="category4">
                <div class="form-group">
                  <div class="color-2">
                    <select data-placeholder="Tags Santé" name="select[]" multiple class="chosen-select" tabindex="8">
                      <option>Pharmacie</option>
                      <option>Aide à la personne</option>
                    </select>
                  </div>
                </div>
              </div>

              <div class="category5">
                <div class="form-group">
                  <div class="color-2">
                    <select data-placeholder="Tags Culture et loisirs" name="select[]" multiple class="chosen-select" tabindex="8">
                      <option>Parc d'attraction</option>
                      <option>Musée</option>
                      <option>Tourisme</option>
                    </select>
                  </div>
                </div>
              </div>
	                </section>

	                <!-- SECTION 4 -->
	                <h4></h4>
	                <section>
	                    <div class="checkbox-circle">
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
						</div>
	                </section>
					<!-- SECTION 5 -->
	                <h4></h4>
	                <section>
	                    <div class="checkbox-circle">
							
							<label>
								<input type="radio" name="billing method" value="Cash on delivery">hello
								<span class="checkmark"></span>
								<div class="tooltip">
									Pay with cash upon delivery.
								</div>
							</label>
						</div>
	                </section>
            	</div>
            
    
</form>

