<?php
$uid = $_SESSION['verified_user_id'];
$docRef = $firestore->collection('magasins')->document($uid);
$document = $docRef->snapshot();
?>

<link rel="stylesheet" href="css/chosen.css">
<link rel="stylesheet" href="fonts/icomoon/style.css">





<style>
    #page {
        padding: 0 5%;
    }

    form {
        padding: 0 3%;
    }

    /* Met les éléments du formulaires dans des tableaux pour pouvoir les mettre à l'horizontale 2 par 2 */
    /*table,
    td {
        text-align: center;
        border: 1px solid #333;
    }*/

    table {
        margin-left: auto;
        margin-right: auto;
    }

    .middleColumn {
        width: 10vw;
    }

    /* Place les bulles au survol du ⓘ */
    .conteneur {
        display: flex;
    }

    .flex {
        padding: 0 1% 0 0;
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
</style>

<script
  src="https://maps.google.com/maps/api/js?key=AIzaSyAEKsQP_j7i0BEjWX1my8_CFL_8sZMPvVk&libraries=places&region=fr&callback=initAutocomplete"
  type="text/javascript"></script>

<div id="page">
    <h1>Mon entreprise</h1>
    <form method="post" enctype="multipart/form-data">
        <h3>Informations personnelles <a data-toggle="tooltip" data-bs-placement="right" title="Informations personnelles de la personne propriétaire de l'entreprise, elles n'apparaîtront pas sur l'application mobile">ⓘ</a></h3>


  
        <div class="form-group form-row">
            <div class="col">
            <label for="lastname">Nom</label>
                        <input type="text" name="ownerLastName" id="lastname" class="form-control"
                            placeholder="ex: Dupont" size="40" value="<?=$document['lname']?>" required>
            </div>
            <div class="col">
            <label for="firstname">Prénom</label>
                        <input type="text" name="ownerFirstName" id="firstname" class="form-control"
                            placeholder="ex: Frédéric" size="40" value="<?=$document['fname']?>" required>
            </div>
        </div>


        
        <h3>Informations de l'entreprise <a data-toggle="tooltip" data-bs-placement="right" title="Toutes ces informations présentes ci-dessous sont affichées sur l'application mobile">ⓘ</a></h3>


        <div class="form-group form-row">
            <div class="col">
                <label for="exampleFormControlInput1">Nom de l'entreprise</label>
                <input type="text" name="companyName" class="form-control" id="exampleFormControlInput1" size="40" placeholder="Dupont SAS" value="<?=$document['name']?>" required>
            </div>
            <div class="col">
                <label for="autocomplete"> Adresse de l'entreprise </label>
                <input type="text" name="autocomplete" id="autocomplete_<?=$document->id()?>" class="form-control" size="40" placeholder="Avenue des Champs-Elysée, Paris" value="<?=$document['adresse']?>" required>
                <input type="hidden" name="latitude" id="latitude_<?=$document->id()?>" class="form-control" value="<?=$document['position']['geopoint']->latitude()?>">
                <input type="hidden" name="longitude" id="longitude_<?=$document->id()?>" class="form-control" value="<?=$document['position']['geopoint']->longitude()?>">
            </div>
        </div>

        <div class="form-group form-row">
            <div class="col">
                <label for="siretnumber">Numéro de SIRET</label>
                <input type="text" name="siretNumber" class="form-control" id="siretnumber"placeholder="ex: 123 456 789 00012" value="<?=$document['siretNumber']?>" required>
            </div>
            <div class="col">
                <label for="tvanumber">Numéro de TVA</label>
                <input type="text" name="tvaNumber" class="form-control" id="tvanumber" placeholder="ex: FR 00 123456789" value="<?=$document['tvaNumber']?>" required>
            </div>
        </div>

        <div class="form-group form-row">
            <div class="col">
                <label for="exampleFormControlTextarea1">Description</label> 
                <textarea class="form-control" name="description" id="exampleFormControlTextarea1" rows="3" required><?=$document['description']?></textarea>
            </div>
        </div>


        <div class="form-group form-row">
            <div class="col">
                <label for="exampleFormControlInput1">Adresse E-Mail</label>
                <input type="text" name="email" class="form-control" id="exampleFormControlInput1" size="40" placeholder="email@email.com" value="<?=$document['email']?>" required>
            </div>
            <div class="col">
                <label for="exampleFormControlInput1">Numéro de téléphone personnel/entreprise</label>
                <input type="tel" id="phone" class="form-control" name="phone" size="40" value="<?=$document['phone']?>" pattern="[0-9]{10}" required>
            </div>
        </div>
        
        <div class="form-group form-row">
            <label class="mr-sm-2" for="companyType">Type d'entreprise</label>
            <select value="" class="custom-select mr-sm-2 companyType"
                id="companyType" name="companyType">
                <option value="Magasin"
                    <?php if($document['type'] == "Magasin" ) echo 'selected="selected"';?>>Magasin
                </option>
                <option value="Service"
                    <?php if($document['type'] == "Service" ) echo 'selected="selected"';?>>Service
                </option>
                <option value="Restaurant"
                    <?php if($document['type'] == "Restaurant" ) echo 'selected="selected"';?>>
                    Restaurant</option>
                <option value="Santé" <?php if($document['type'] == "Santé" ) echo 'selected="selected"';?>>
                    Santé
                </option>
                <option value="Culture & Loisirs"
                    <?php if($document['type'] == "Culture & Loisirs" ) echo 'selected="selected"';?>>
                    Culture & Loisirs
                </option>
            </select>
        </div>

        <label for="exampleFormControlInput1">Tags Entreprise</label>

        <div class="form-group form-row category1">
            
            <div class="color-2">
                <select data-placeholder="Tags Magasin" name="select[]" id="select1"
                    multiple class="chosen-select" tabindex="8">
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
    


        <div class="form-group form-row category2">
            <div class="color-2">
                <select data-placeholder="Tags Service" name="select[]" id="select2"
                    multiple class="chosen-select" tabindex="8">
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
    


        <div class="form-group form-row category3">
            <div class="color-2">
                <select data-placeholder="Tags Restaurant" name="select[]" id="select3"
                    multiple class="chosen-select" tabindex="8">
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
    


        <div class="form-group form-row category4">
            <div class="color-2">
                <select data-placeholder="Tags Santé" name="select[]" id="select4" multiple
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


    
        <div class="form-group form-row category5">
            <div class="color-2">
                <select data-placeholder="Tags Culture et loisirs" name="select[]"
                    id="select5" multiple class="chosen-select" tabindex="8">
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
        <div class="form-group form-row ">
            <div class="form-group col">
                <div class="form-group col-md-2">
                    <label for="exampleColorInput" class="form-label">Couleur de l'interface</label>
                    <input type="color" class="form-control form-control-color" name="color" id="exampleColorInput" style="width:50px; height:50px" value="#<?=$document['colorStore']?>" title="Choissisez une couleur">
                </div>
                <div class="form-check form-switch">
                        <input class="form-check-input" name="clickandcollect" type="checkbox" value="" id="defaultCheck1" <?php if($document['ClickAndCollect'] == true) { echo "checked";}?>>
                        <label class="form-check-label" name="clickandcollect" for="defaultCheck1"> Click & Collect </label>
                    </div>
                    <div class="form-check form-switch">
                        <input class="form-check-input" name="livraison" type="checkbox" value="" id="defaultCheck1" <?php if($document['livraison'] == true) { echo "checked";}?>>
                        <label class="form-check-label" name="livraison" for="defaultCheck1"> Livraison à domicile</label>
                    </div>
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" name="isPhoneVisible" id="isphonevisible" <?php if($document['isPhoneVisible'] == true) { echo "checked";}?>> 
                        <label class="form-check-label" for="isPhoneVisible">Afficher le numéro de téléphone aux clients <a  data-toggle="tooltip" data-bs-placement="right" title="Permet d'afficher aux clients le numéro de téléphone sur l'application">ⓘ</a></label>
                    </div>
            </div>
        </div>
        <div class="form-group">
            <label for="exampleColorInput" class="form-label">Changer la bannière</label><br>
            <img  id="old_banniere" src="<?=$document['imgUrl']?>" class="img-thumbnail img-fluid" alt="<?=$document['imgUrl']?>"
                style="max-width:600px; width:100%">
                <img id="imagePreview" src="#" hidden />
                <input type="file" name="banniere" id="banniere" onchange="readURL(this);"><br><br>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" type="button" data-dismiss="modal">Annuler</button>
            <button type="submit" value="<?=$document->id()?>" name="edit_enterprise"
                class="btn btn-primary">Enregistrer
                les modifications</button>
        </div>
     </div>


                
       

        
    </form>
</div>

<script>  function readURL(input) {
      if (input.files && input.files[0]) {
          var reader = new FileReader();

          reader.onload = function (e) {
              $('#imagePreview')
                  .attr('src', e.target.result)
                  .removeAttr('hidden')
                  .height(200);
                  $('#old_banniere').prop('hidden', 'hidden');
          
          };
         
         
          reader.readAsDataURL(input.files[0]);
      }
  };</script>

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

        <!-- Script permettant la gestion des catégories -->
<script>
    $(function () {
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
        } else if ($(".companyType").val() == "Service") {
            $(".category2").removeClass("d-none");
        } else if ($(".companyType").val() == "Restaurant") {
            $(".category3").removeClass("d-none");
        } else if ($(".companyType").val() == "Santé") {
            $(".category4").removeClass("d-none");
        } else if ($(".companyType").val() == "Culture & Loisirs") {
            $(".category5").removeClass("d-none");
        }

    });

    $(".companyType").on('change', function () {

        if ($(this).val() == 'Magasin') {
            $(".category1").removeClass("d-none");
            $(".category2").addClass("d-none");
            $(".category3").addClass("d-none");
            $(".category4").addClass("d-none");
            $(".category5").addClass("d-none");
        } else if ($(this).val() == 'Service') {
            $(".category2").removeClass("d-none");
            $("#select2 option:selected").remove();
            $('#select2 :selected').remove();
            $(".category1").addClass("d-none");
            $(".category3").addClass("d-none");
            $(".category4").addClass("d-none");
            $(".category5").addClass("d-none");

        } else if ($(this).val() == 'Restaurant') {
            $(".category3").removeClass("d-none");
            $(".category2").addClass("d-none");
            $(".category1").addClass("d-none");
            $(".category4").addClass("d-none");
            $(".category5").addClass("d-none");

        } else if ($(this).val() == 'Santé') {
            $(".category4").removeClass("d-none");

            $(".category2").addClass("d-none");
            $(".category3").addClass("d-none");
            $(".category1").addClass("d-none");
            $(".category5").addClass("d-none");

        } else if ($(this).val() == 'Culture & Loisirs') {
            $(".category5").removeClass("d-none");

            $(".category2").addClass("d-none");
            $(".category3").addClass("d-none");
            $(".category4").addClass("d-none");
            $(".category1").addClass("d-none");

        }
    });
</script>