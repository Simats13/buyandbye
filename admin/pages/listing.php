<?php 
$collectionReference = $firestore->collection('magasins');
$documents = $collectionReference->documents();
?>

<link rel="stylesheet" href="css/chosen.css">
<link rel="stylesheet" href="fonts/icomoon/style.css">
<!-- <link rel="stylesheet" href="css/style.css"> -->
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
</style>
<script
  src="https://maps.google.com/maps/api/js?key=AIzaSyAEKsQP_j7i0BEjWX1my8_CFL_8sZMPvVk&libraries=places&region=fr&callback=initAutocomplete"
  type="text/javascript"></script>
<div id="spinner_load"></div>
<div class="container-fluid">

  <!-- DataTables Example -->
  <div class="card shadow mb-4">
    <div class="card-header py-3">
      <h6 class="m-0 font-weight-bold text-primary">Listing de toutes les entreprises</h6>
    </div>

    <div class="card-body">
      <?php
    if(isset($_SESSION['status']))
    {
        echo "<h5 class='alert alert-danger'>".$_SESSION['status']."</h5>";
        unset($_SESSION['status']);
    }
    ?>

      <?php
    if(isset($_SESSION['errors']))
    {
        echo "<h5 class='alert alert-danger'>".$_SESSION['errors']."</h5>";
        unset($_SESSION['errors']);
    }
    ?>


      <div class="table-responsive">

        <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
          <thead>
            <tr>
              <th>Nom de l'entreprise</th>
              <th>Adresse</th>
              <th>Email Associée</th>
              <th>Téléphone Associée</th>
              <th>Modification</th>
            </tr>
          </thead>
          <tbody>

            <?php $count = 0;?>

            <?php foreach ($documents as $document) { ?>

            <tr>
              <td><?= $document['name']?></td>
              <td><?= $document['adresse']?></td>
              <td><?= $document['email']?></td>
              <td><?= $document['phone']?></td>
              <td>
                <button class="btn btn-outline-primary" value="<?=$document['name']?>" title="<?=$document['name']?> "
                  data-toggle="modal" data-target="#editShop<?=$count?>">
                  <i class="far fa-edit"></i>
                </button>
                <button class="btn btn-outline-danger" value="<?=$document['name']?>" title="<?=$document['name']?> "
                  data-toggle="modal" data-target="#deleteShop<?=$count?>">
                  <i class="far fa-trash-alt"></i>
                </button>
              </td>
            </tr>

            <!-- Fenêtre modale de suppression d'entreprise -->
            <div class="modal fade" id="deleteShop<?=$count?>" tabindex="-1" role="dialog"
              aria-labelledby="exampleModalLabel" aria-hidden="true">
              <div class="modal-dialog" role="document">
                <div class="modal-content">
                  <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">Vous êtes sur le point de supprimer la page de
                      <?=$document['name']?></h5>
                    <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                      <span aria-hidden="true">×</span>
                    </button>
                  </div>
                  <div class="modal-body">Cette action est définitive, si vous souhaitez le supprimer veuillez cliquer
                    sur le bouton "Supprimer" ci-dessous. </div>
                  <div class="modal-footer">
                    <button class="btn btn-secondary" type="button" data-dismiss="modal">Annuler</button>

                    <form method="POST">

                      <button type="submit" value="<?=$document->id()?>" name="delete_listing"
                        class="btn btn-danger">Supprimer</button>

                    </form>
                  </div>
                </div>
              </div>
            </div>

            <!-- Fenêtre modale d'édition d'entreprise -->
            <div class="modal fade" id="editShop<?=$count?>" tabindex="-1" role="dialog"
              aria-labelledby="exampleModalLabel" aria-hidden="true">
              <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                  <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">Edition de l'entreprise <?=$document['name']?></h5>
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

                    <form method="post" enctype="multipart/form-data">
                      <div class="conteneur">
                        <div class="flex">
                          <h3>Informations personnelles</h3>
                        </div>
                        <div class="flex onMouseover">
                          <h3>ⓘ</h3>
                          <span class="textOver">Informations personnelles de la personne propriétaire de l'entreprise,
                            elles n'apparaîtront pas sur l'application mobile</span>
                        </div>
                      </div>
                      <div class="form-group">
                        <label for="lastname">Nom</label>
                        <input type="text" name="ownerLastName" id="lastname" class="form-control"
                          placeholder="ex: Dupont" value="<?=$document['lname']?>" required>
                      </div>
                      <div class="form-group">
                        <label for="firstname">Prénom</label>
                        <input type="text" name="ownerFirstName" id="firstname" class="form-control"
                          placeholder="ex: Frédéric" value="<?=$document['fname']?>" required>
                      </div>
                      <div class="form-group">
                        <label for="siretnumber">Numéro de SIRET</label>
                        <input type="text" name="siretNumber" class="form-control" id="siretnumber"
                          placeholder="ex: 123 456 789 00012" value="<?=$document['siretNumber']?>" required>
                      </div>
                      <div class="form-group">
                        <label for="tvanumber">Numéro de TVA</label>
                        <input type="text" name="tvaNumber" class="form-control" id="tvanumber"
                          placeholder="ex: FR 00 123456789" value="<?=$document['tvaNumber']?>" required>
                      </div>
                      <div class="conteneur">
                        <div class="flex">
                          <h3>Informations de l'entreprise</h3>
                        </div>
                        <div class="flex onMouseover">
                          <h3>ⓘ</h3>
                          <span class="textOver">Toutes ces informations présentes ci-dessous sont affichées sur
                            l'application mobile</span>
                        </div>
                      </div>
                      <div class="form-group">
                        <label for="exampleFormControlInput1">Nom de l'entreprise</label>
                        <input type="text" name="companyName" class="form-control" id="exampleFormControlInput1"
                          placeholder="Dupont SAS" value="<?=$document['name']?>" required>
                      </div>


                      <!-- Script permettant l'ajout de l'autocomplétion d'adresse -->

                      <script>
                        google.maps.event.addDomListener(window, 'load', initialize);

                        function initialize() {
                          var input = document.getElementById('autocomplete_<?=$document->id()?>');
                          var autocomplete = new google.maps.places.Autocomplete(input);
                          autocomplete.addListener('place_changed', function () {
                            var place = autocomplete.getPlace();
                            $('#latitude_<?=$document->id()?>').val(place.geometry['location'].lat());
                            $('#longitude_<?=$document->id()?>').val(place.geometry['location'].lng());

                          });
                        };
                        $(function () {
                          var input = document.getElementById("autocomplete_<?=$document->id()?>");
                          var autocomplete = new google.maps.places.Autocomplete(input);

                          $('#my-modal').modal('show');
                        });
                      </script>

                      <style>
                        .pac-container {
                          z-index: 10000 !important;
                        }
                      </style>
                      <div class="form-group">
                        <label for="autocomplete"> Adresse de l'entreprise </label>
                        <input type="text" name="autocomplete" id="autocomplete_<?=$document->id()?>"
                          class="form-control" placeholder="Avenue des Champs-Elysée, Paris"
                          value="<?=$document['adresse']?>" required>
                        <input type="hidden" name="latitude" id="latitude_<?=$document->id()?>" class="form-control"
                          value="<?=$document['position']['geopoint']->latitude()?>">
                        <input type="hidden" name="longitude" id="longitude_<?=$document->id()?>" class="form-control"
                          value="<?=$document['position']['geopoint']->longitude()?>">
                      </div>
                      <div class="form-group">
                        <label for="exampleFormControlInput1">Adresse E-Mail</label>
                        <input type="text" name="email" class="form-control" id="exampleFormControlInput1"
                          placeholder="email@email.com" value="<?=$document['email']?>" required>
                      </div>
                      <div class="form-group">
                        <label for="exampleFormControlInput1">Numéro de téléphone</label>
                        <!-- <input type="text" name="phone" class="form-control" id="exampleFormControlInput1"
                          placeholder="01 02 03 04 05" value="" required> -->
                        <input type="tel" id="phone" class="form-control" name="phone" value="<?=$document['phone']?>"
                          pattern="[0-9]{2}.[0-9]{2}.[0-9]{2}.[0-9]{2}.[0-9]{2}" required>
                      </div>
                      <div class="form-group">
                        <label for="exampleFormControlTextarea1">Description</label>
                        <textarea class="form-control" name="description" id="exampleFormControlTextarea1" rows="3"
                          required><?=$document['description']?></textarea>
                      </div>

                      <div class="form-group">
                        <label class="mr-sm-2" for="companyType_<?=$count?>">Type d'entreprise</label>
                        <select value="" class="custom-select mr-sm-2 companyType_<?=$count?>"
                          id="companyType_<?=$count?>" name="companyType">
                          <option value="Magasin"
                            <?php if($document['type'] == "Magasin" ) echo 'selected="selected"';?>>Magasin</option>
                          <option value="Service"
                            <?php if($document['type'] == "Service" ) echo 'selected="selected"';?>>Service</option>
                          <option value="Restaurant"
                            <?php if($document['type'] == "Restaurant" ) echo 'selected="selected"';?>>Restaurant
                          </option>
                          <option value="Santé" <?php if($document['type'] == "Santé" ) echo 'selected="selected"';?>>
                            Santé</option>
                          <option value="Culture & Loisirs"
                            <?php if($document['type'] == "Culture & Loisirs" ) echo 'selected="selected"';?>>Culture &
                            Loisirs</option>
                        </select>
                      </div>

                      <!-- Script permettant la gestion des catégories -->
                      <script>
                        $(function () {
                          $(".chosen-select").chosen({
                            max_selected_options: 3,
                            width: '100%'
                          });
                        });
                        $(document).ready(function () {
                          $(".category1_<?=$count?>").addClass("d-none");
                          $(".category2_<?=$count?>").addClass("d-none");
                          $(".category3_<?=$count?>").addClass("d-none");
                          $(".category4_<?=$count?>").addClass("d-none");
                          $(".category5_<?=$count?>").addClass("d-none");

                          if ($(".companyType_<?=$count?>").val() == "Magasin") {
                            $(".category1_<?=$count?>").removeClass("d-none");
                          } else if ($(".companyType_<?=$count?>").val() == "Service") {
                            $(".category2_<?=$count?>").removeClass("d-none");
                          } else if ($(".companyType_<?=$count?>").val() == "Restaurant") {
                            $(".category3_<?=$count?>").removeClass("d-none");
                          } else if ($(".companyType_<?=$count?>").val() == "Santé") {
                            $(".category4_<?=$count?>").removeClass("d-none");
                          } else if ($(".companyType_<?=$count?>").val() == "Culture & Loisirs") {
                            $(".category5_<?=$count?>").removeClass("d-none");
                          }

                        });

                        $(".companyType_<?=$count?>").on('change', function () {

                          if ($(this).val() == 'Magasin') {
                            $(".category1_<?=$count?>").removeClass("d-none");


                            $(".category2_<?=$count?>").addClass("d-none");
                            $(".category3_<?=$count?>").addClass("d-none");
                            $(".category4_<?=$count?>").addClass("d-none");
                            $(".category5_<?=$count?>").addClass("d-none");
                          } else if ($(this).val() == 'Service') {
                            $(".category2_<?=$count?>").removeClass("d-none");
                            $("#select2_<?=$count?> option:selected").remove();
                            $('#select2_<?=$count?> :selected').remove();
                            $(".category1_<?=$count?>").addClass("d-none");
                            $(".category3_<?=$count?>").addClass("d-none");
                            $(".category4_<?=$count?>").addClass("d-none");
                            $(".category5_<?=$count?>").addClass("d-none");

                          } else if ($(this).val() == 'Restaurant') {
                            $(".category3_<?=$count?>").removeClass("d-none");

                            $(".category2_<?=$count?>").addClass("d-none");
                            $(".category1_<?=$count?>").addClass("d-none");
                            $(".category4_<?=$count?>").addClass("d-none");
                            $(".category5_<?=$count?>").addClass("d-none");

                          } else if ($(this).val() == 'Santé') {
                            $(".category4_<?=$count?>").removeClass("d-none");

                            $(".category2_<?=$count?>").addClass("d-none");
                            $(".category3_<?=$count?>").addClass("d-none");
                            $(".category1_<?=$count?>").addClass("d-none");
                            $(".category5_<?=$count?>").addClass("d-none");

                          } else if ($(this).val() == 'Culture & Loisirs') {
                            $(".category5_<?=$count?>").removeClass("d-none");

                            $(".category2_<?=$count?>").addClass("d-none");
                            $(".category3_<?=$count?>").addClass("d-none");
                            $(".category4_<?=$count?>").addClass("d-none");
                            $(".category1_<?=$count?>").addClass("d-none");

                          }
                        });
                      </script>


                      <div class="category1_<?=$count?>">
                        <div class="form-group">
                          <div class="color-2">
                            <select data-placeholder="Tags Magasin" name="select[]" id="select1_<?=$count?>" multiple
                              class="chosen-select" tabindex="8">
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Electroménager") echo 'selected="selected"';} ?>>
                                Electroménager</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Jeux-Vidéos") echo 'selected="selected"';} ?>>
                                Jeux-Vidéos</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "High-Tech") echo 'selected="selected"';} ?>>
                                High-Tech</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Alimentation") echo 'selected="selected"';} ?>>
                                Alimentation</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Films & Séries") echo 'selected="selected"';} ?>>
                                Vêtements</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Chaussures") echo 'selected="selected"';} ?>>
                                Films & Séries</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Bricolage") echo 'selected="selected"';} ?>>
                                Chaussures</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Montres & Bijoux") echo 'selected="selected"';} ?>>
                                Bricolage</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Menuiserie") echo 'selected="selected"';} ?>>
                                Montres & Bijoux</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Téléphonie") echo 'selected="selected"';} ?>>
                                Téléphonie</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Restaurant") echo 'selected="selected"';} ?>>
                                Restaurant</option>
                            </select>
                          </div>
                        </div>
                      </div>

                      <div class="category2_<?=$count?>">
                        <div class="form-group">
                          <div class="color-2">
                            <select data-placeholder="Tags Service" name="select[]" id="select2_<?=$count?>" multiple
                              class="chosen-select" tabindex="8">
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Menuiserie") echo 'selected="selected"';} ?>>
                                Menuiserie</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Plomberie") echo 'selected="selected"';} ?>>
                                Plomberie</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Piscine") echo 'selected="selected"';} ?>>
                                Piscine</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Meubles") echo 'selected="selected"';} ?>>
                                Meubles</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Vêtements") echo 'selected="selected"';} ?>>
                                Vêtements</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Gestion de patrimoine") echo 'selected="selected"';} ?>>
                                Gestion de patrimoine</option>
                            </select>
                          </div>
                        </div>
                      </div>

                      <div class="category3_<?=$count?>">
                        <div class="form-group">
                          <div class="color-2">
                            <select data-placeholder="Tags Restaurant" name="select[]" id="select3_<?=$count?>" multiple
                              class="chosen-select" tabindex="8">
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Français") echo 'selected="selected"';} ?>>
                                Français</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Local") echo 'selected="selected"';} ?>>
                                Local</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Italien") echo 'selected="selected"';} ?>>
                                Italien</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Fast-Food") echo 'selected="selected"';} ?>>
                                Fast-Food</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Asiatique") echo 'selected="selected"';} ?>>
                                Asiatique</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Pizzeria") echo 'selected="selected"';} ?>>
                                Pizzeria</option>
                            </select>
                          </div>
                        </div>
                      </div>

                      <div class="category4_<?=$count?>">
                        <div class="form-group">
                          <div class="color-2">
                            <select data-placeholder="Tags Santé" name="select[]" id="select4_<?=$count?>" multiple
                              class="chosen-select" tabindex="8">
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Pharmacie") echo 'selected="selected"';} ?>>
                                Pharmacie</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Aide à la personne") echo 'selected="selected"';} ?>>
                                Aide à la personne</option>
                            </select>
                          </div>
                        </div>
                      </div>

                      <div class="category5_<?=$count?>">
                        <div class="form-group">
                          <div class="color-2">
                            <select data-placeholder="Tags Culture et loisirs" name="select[]" id="select5_<?=$count?>"
                              multiple class="chosen-select" tabindex="8">
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Parc d'attraction") echo 'selected="selected"';} ?>>
                                Parc d'attraction</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Musée") echo 'selected="selected"';} ?>>
                                Musée</option>
                              <option
                                <?php foreach ($document['mainCategorie'] as $selection) { if($selection == "Tourisme") echo 'selected="selected"';} ?>>
                                Tourisme</option>
                            </select>
                          </div>
                        </div>
                      </div>

                      <div class="form-group ">
                        <label for="exampleColorInput" class="form-label">Couleur de l'interface</label>
                        <input type="color" class="form-control form-control-color" name="color" id="exampleColorInput"
                          style="width:50px" value="#<?=$document['colorStore']?>" title="Choissisez une couleur">
                      </div>

                      <div class="form-group">
                        <div class="form-check">
                          <input class="form-check-input" name="livraison" type="checkbox" value="" id="defaultCheck1"
                            <?php if($document['livraison'] == true) { echo "checked";}?>>
                          <label class="form-check-label" name="livraison" for="defaultCheck1">
                            Livraison à domicile
                          </label>
                        </div>
                      </div>
                      <div class="form-group">
                        <label for="exampleColorInput" class="form-label">Changer la bannière</label><br>
                        <img src="<?=$document['imgUrl']?>" class="img-thumbnail img-fluid"
                          alt="<?=$document['imgUrl']?>">
                        <input type="hidden" name="old_banniere" id="old_banniere" value="<?=$document['imgUrl']?>"><br>
                        <input type="file" name="banniere" id="banniere">
                      </div>
                  </div>
                  <div class="modal-footer">
                    <button class="btn btn-secondary" type="button" data-dismiss="modal">Annuler</button>
                    <button type="submit" value="<?=$document->id()?>" name="edit_listing"
                      class="btn btn-primary">Enregistrer les modifications</button>
                    </form>
                  </div>
                </div>
              </div>
            </div>
            <?php $count++;?>
            <?php } ?>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>


<!-- <script>

    
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
google.maps.event.addDomListener(window, 'load', initialize);
function initialize() {
    var input = document.getElementById('autocomplete');
    var autocomplete = new google.maps.places.Autocomplete(input);
    autocomplete.addListener('place_changed', function() {
        var place = autocomplete.getPlace();
        $('#latitude').val(place.geometry['location'].lat());
        $('#longitude').val(place.geometry['location'].lng());

    });
  }
</script>

<script>
    $("#companyType").on('change', function() {

if ($(this).val() == 'Magasin'){
   $(".category1").removeClass("d-none");

   $("#category2").addClass("d-none");
   $("#category3").addClass("d-none");
   $("#category4").addClass("d-none");
   $("#category5").addClass("d-none");
} else if ($(this).val() == 'Service'){
   $("#category2").removeClass("d-none");

   $(".category1").addClass("d-none");
   $("#category3").addClass("d-none");
   $("#category4").addClass("d-none");
   $("#category5").addClass("d-none");

}else if ($(this).val() == 'Restaurant'){
   $("#category3").removeClass("d-none");

   $("#category2").addClass("d-none");
   $(".category1").addClass("d-none");
   $("#category4").addClass("d-none");
   $("#category5").addClass("d-none");

}else if ($(this).val() == 'Santé'){
    $("#category4").removeClass("d-none");

   $("#category2").addClass("d-none");
   $("#category3").addClass("d-none");
   $(".category1").addClass("d-none");
   $("#category5").addClass("d-none");

}else if ($(this).val() == 'Culture & Loisirs'){
    $("#category5").removeClass("d-none");

   $("#category2").addClass("d-none");
   $("#category3").addClass("d-none");
   $("#category4").addClass("d-none");
   $(".category1").addClass("d-none");

}
});
  $(function () {
    var input = document.getElementById("autocomplete");
    var autocomplete = new google.maps.places.Autocomplete(input);

    $('#my-modal').modal('show');
  });



</script> -->