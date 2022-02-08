

<style>
  .padding {
    padding: 0 10%;
  }

  /* Bouton importer manuellement */
  .button-3 {
    appearance: none;
    background-color: #2ea44f;
    border: 1px solid rgba(27, 31, 35, .15);
    border-radius: 6px;
    box-shadow: rgba(27, 31, 35, .1) 0 1px 0;
    box-sizing: border-box;
    color: #fff;
    cursor: pointer;
    display: inline-block;
    font-family: -apple-system, system-ui, "Segoe UI", Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji";
    font-size: 14px;
    font-weight: 600;
    line-height: 20px;
    padding: 1vw 0;
    margin: 5% 35%;
    position: relative;
    text-align: center;
    text-decoration: none;
    user-select: none;
    -webkit-user-select: none;
    touch-action: manipulation;
    vertical-align: middle;
    white-space: nowrap;
    font-size: 1.25vw;
  }

  .button-3:focus:not(:focus-visible):not(.focus-visible) {
    box-shadow: none;
    outline: none;
  }

  .button-3:hover {
    background-color: #2c974b;
  }

  .button-3:focus {
    box-shadow: rgba(46, 164, 79, .4) 0 0 0 3px;
    outline: none;
  }

  .button-3:disabled {
    background-color: #94d3a2;
    border-color: rgba(27, 31, 35, .1);
    color: rgba(255, 255, 255, .8);
    cursor: default;
  }

  .button-3:active {
    background-color: #298e46;
    box-shadow: rgba(20, 70, 32, .2) 0 1px 0 inset;
  }

  /* or separator */
  hr.solid {
    margin: 0 30%;
    border-top: 2px solid #bbb;
  }

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

  .pac-container {
    z-index: 10000 !important;
  }

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
</style>
<link rel="stylesheet" href="css/chosen.css">
<link rel="stylesheet" href="fonts/icomoon/style.css">

<div class="padding">
  <div class="card shadow mb-4">
    <div class="card-header py-3">
      <h6 class="m-0 font-weight-bold text-primary">Enregistrer une nouvelle entreprise</h6>
    </div>

    <!-- Affiche les erreurs de PHP si il y en a -->
    <div class="card-body">
      <?php
      if(isset($_SESSION['status']))
      {
          echo "<h5 class='alert alert-danger'>".$_SESSION['status']."</h5>";
          unset($_SESSION['status']);
      }
      ?>

      <?php
        if(isset($_SESSION['success']))
        {
            echo "<h5 class='alert alert-success'>".$_SESSION['success']."</h5>";
            unset($_SESSION['success']);
        }
      ?>

      <?php
      if(isset($_SESSION['errors']))
      {
          echo "<h5 class='alert alert-danger'>".$_SESSION['errors']."</h5>";
          unset($_SESSION['errors']);
      }
      ?>
    </div>

    <div class="d-flex justify-content-center">
						<button class="btn btn-success" style="background-color:#2ea44f;" role="button" data-toggle="modal" data-target="#addShop">Ajouter manuellement
						</button>
				</div>

        <hr class="mt-2 mb-3"/>

    <!-- <button class="button-3" role="button" data-toggle="modal" data-target="#addShop">Ajouter manuellement</button> -->
    <!-- Popup ajout d'un manuel d'un magasin -->
    <div class="modal fade" id="addShop" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel"
      aria-hidden="true">
      <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="exampleModalLabel">Ajout manuel</h5>
            <button class="close" type="button" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">×</span>
            </button>
          </div>
          <div class="modal-body">
            <div class="popup-header">
              Une fois la boutique créée, un e-mail sera envoyé au professionnel avec les informations entrées
              ci-dessous.<br>
              Il devra alors confirmer les informations et choisir un mot de passe pour son espace personnel.
            </div>
            <div class="conteneur">
              <div class="flex">
                <h3>Informations personnelles</h3>
              </div>
              <div class="flex onMouseover">
                <h3>ⓘ</h3>
                <span class="textOver">Informations personnelles de la personne propriétaire de l'entreprise</span>
              </div>
            </div>
            <form method="post" enctype="multipart/form-data">
              <div class="form-group">
                <label for="lastname">Nom</label>
                <input type="text" name="ownerLastName" id="lastname" class="form-control" placeholder="ex: Dupont" required>
              </div>
              <div class="form-group">
                <label for="firstname">Prénom</label>
                <input type="text" name="ownerFirstName" id="firstname" class="form-control" placeholder="ex: Frédéric" required>
              </div>
              <div class="form-group">
                <label for="mail">Adresse E-Mail</label>
                <input type="text" name="email" id="mail" class="form-control" placeholder="ex: email@email.com" required>
              </div>
              <br>
              <h3>Informations de l'entreprise</h3>
              <div class="form-group">
                <label for="enterprisename">Nom</label>
                <input type="text" name="enterpriseName" class="form-control" id="enterprisename"
                  placeholder="ex: Dupont SAS" required>
              </div>
              <div class="form-group">
                <label for="autocomplete">Adresse</label>
                <input type="text" name="autocomplete" class="form-control" id="autocomplete" required>
                <input type="hidden" name="latitude" id="latitude" class="form-control" >  
                <input type="hidden" name="longitude" id="longitude" class="form-control" >
              </div>
              <div class="form-group">
                <label for="enterprisephone">Numéro de téléphone</label>
                <!-- <input type="text" name="enterprisePhone" class="form-control" id="enterprisephone"
                  placeholder="ex: 01 02 03 04 05" required> -->
                  <input type="tel" id="enterprisePhone" class="form-control" name="enterprisePhone"   placeholder="ex: 01 02 03 04 05"
                  pattern="^((\+\d{1,3}(-| )?\(?\d\)?(-| )?\d{1,5})|(\(?\d{2,6}\)?))(-| )?(\d{3,4})(-| )?(\d{4})(( x| ext)\d{1,5}){0,1}$"
                          required>
              </div>

              <div class="form-group">
                <div class="conteneur">
                  <div class="flex"><label for="isphonevisible">Numéro de téléphone visible ?</label></div>
                  <div class="flex onMouseover">ⓘ
                    <span class="textOver">Afficher le numéro de téléphone aux clients ?</span>
                  </div>
                </div>
                <input type="checkbox" name="isPhoneVisible" id="isphonevisible">
              </div>

              <!-- <div class="form-group">
                <div class="conteneur">
                  <div class="flex"><label for="isrestaurant">L'entreprise est-elle un restaurant ?</label></div>
                  <div class="flex onMouseover">ⓘ
                    <span class="textOver">L'entreprise créée est-elle un restaurant ou un bar ?<br>Si oui, ajoute la
                      possibilité d'importer des menus</span>
                  </div>
                </div>
                <input type="checkbox" name="isRestaurant" id="isrestaurant" class>
              </div> -->
              <div class="form-group">
                <label for="livraison">L'entreprise propose-t-elle la livraison de produit ?</label><br>
                <input type="checkbox" name="livraison" id="livraison" >
              </div>
              <div class="form-group">
                <label for="exampleFormControlTextarea1">Description</label>
                <textarea class="form-control" name="description" id="exampleFormControlTextarea1"
                  rows="3" required></textarea>
              </div>
              <div class="form-group">
                <label class="mr-sm-2" for="companyType">Type d'entreprise</label>
                <select value="" class="custom-select mr-sm-2 companyType" name="companyType" id="companyType" required>
                  <option value="" selected disabled hidden>Veuillez choisir un type d'entreprise</option>
                  <option value="Magasin">Magasin</option>
                  <option value="Service">Service</option>
                  <option value="Restaurant">Restaurant</option>
                  <option value="Santé">Santé</option>
                  <option value="Culture & Loisirs">Culture & Loisirs</option>
                </select>
              </div>

              <!-- Script permettant la gestion des catégories -->
              <script>
                $(function(){
                    $(".chosen-select").chosen({
                      max_selected_options: 3,
                      width: '100%'
                    }); 
                });
                $(document).ready(function () {
                  $(".category1").addClass("d-none");
                  $(".category2").addClass("d-none");
                  $(".category3").addClass("d-none");
                  $(".category4").addClass("d-none");
                  $(".category5").addClass("d-none");
                  
                  if ($(".companyType").val() == "Magasin") {
                      $(".category1").removeClass("d-none");
                  }else if ($(".companyType").val() == "Service"){
                      $(".category2").removeClass("d-none");
                  }else if ($(".companyType").val() == "Restaurant"){
                      $(".category3").removeClass("d-none");
                  }else if ($(".companyType").val() == "Santé"){
                      $(".category4").removeClass("d-none");
                  }else if ($(".companyType").val() == "Culture & Loisirs"){
                      $(".category5").removeClass("d-none");
                  }

                });
                
                $(".companyType").on('change', function() {

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
              });
              </script>               
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

              <div class="form-group">
                <label for="siretnumber">Numéro de SIRET</label>
                <input type="text" name="siretNumber" class="form-control" id="siretnumber"
                  placeholder="ex: 123 456 789 00012" required>
              </div>
              <div class="form-group">
                <label for="tvanumber">Numéro de TVA</label>
                <input type="text" name="tvaNumber" class="form-control" id="tvanumber"
                  placeholder="ex: FR 00 123456789" required>
              </div>
              <div class="form-group ">
                <label for="exampleColorInput" class="form-label">Couleur de l'interface</label>
                <input type="color" class="form-control form-control-color" name="color" id="exampleColorInput"
                  style="width:50px" title="Choissisez une couleur">
              </div>
              <label for="banniere">Ajouter une image de couverture</label><br>
              <input type="file" name="banniere" id="banniere" onchange="readURL(this);"><br><br>
              <img id="imagePreview" src="#" hidden />
              

              <!-- Boutons de validation et d'annulation -->
              <div class="modal-footer">
                <button class="btn btn-secondary" type="button" data-dismiss="modal">Annuler</button>
                <button type="submit" name="add_enterprise" class="btn btn-primary">Ajouter une entreprise</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>


    
    <div class="d-flex justify-content-center">
						<button class="btn btn-success " style="background-color:#2ea44f;" role="button" data-toggle="modal" data-target="#addShop">Importer un fichier CSV
						</button>
				</div>
        <br>
  </div>
</div>

<script
  src="https://maps.google.com/maps/api/js?key=AIzaSyAEKsQP_j7i0BEjWX1my8_CFL_8sZMPvVk&libraries=places&region=fr&callback=initAutocomplete"
  type="text/javascript"></script>

<script>
  $(document).ready(function () {
    $("#lat_area").addClass("d-none");
    $("#long_area").addClass("d-none");
  });
  google.maps.event.addDomListener(window, 'load', initialize);

  function initialize() {
    var input = document.getElementById('autocomplete');
    var autocomplete = new google.maps.places.Autocomplete(input);
    autocomplete.addListener('place_changed', function () {
      var place = autocomplete.getPlace();
      $('#latitude').val(place.geometry['location'].lat());
      $('#longitude').val(place.geometry['location'].lng());
      // // --------- show lat and long ---------------
      // $("#lat_area").removeClass("d-none");
      // $("#long_area").removeClass("d-none");
    });
  }
</script>

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
  $(function () {
    var input = document.getElementById("autocomplete");
    var autocomplete = new google.maps.places.Autocomplete(input);

    $('#my-modal').modal('show');

  });

</script>