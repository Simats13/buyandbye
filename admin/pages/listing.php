<?php 
$collectionReference = $firestore->collection('test');
$documents = $collectionReference->documents();
?>

<link rel="stylesheet" href="css/chosen.css">
<link rel="stylesheet" href="fonts/icomoon/style.css">
<link rel="stylesheet" href="css/bootstrap.min.css">
<!-- <link rel="stylesheet" href="css/style.css"> -->

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
</style>
<div class="container-fluid">

  <!-- DataTables Example -->
  <div class="card shadow mb-4">
    <div class="card-header py-3">
      <h6 class="m-0 font-weight-bold text-primary">Listing de toutes les entreprises
        <!-- <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#addadminprofile">
              Add Admin Profile 
            </button> -->
      </h6>
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
                    <form method="post" enctype="multipart/form-data">
                      <div class="form-group">
                        <label for="exampleFormControlInput1">Nom de l'entreprise</label>
                        <input type="text" name="companyName" class="form-control" id="exampleFormControlInput1"
                          placeholder="Dupont SAS" value="<?=$document['name']?>">
                      </div>
                      <div class="form-group">
                        <label for="autocomplete"> Adresse de l'entreprise </label>
                        <input type="text" name="autocomplete" id="autocomplete" class="form-control"
                          placeholder="Avenue des Champs-Elysée, Paris" value="<?=$document['adresse']?>">
                      </div>
                      <div class="form-group">
                        <label for="exampleFormControlInput1">Adresse E-Mail</label>
                        <input type="text" name="email" class="form-control" id="exampleFormControlInput1"
                          placeholder="email@email.com" value="<?=$document['email']?>">
                      </div>
                      <div class="form-group">
                        <label for="exampleFormControlInput1">Numéro de téléphone</label>
                        <input type="text" name="phone" class="form-control" id="exampleFormControlInput1"
                          placeholder="01 02 03 04 05" value="<?=$document['phone']?>">
                      </div>
                      <div class="form-group">
                        <label for="exampleFormControlTextarea1">Description</label>
                        <textarea class="form-control" name="description" id="exampleFormControlTextarea1"
                          rows="3"><?=$document['description']?></textarea>
                      </div>

                      <div class="form-group">
                        <label class="mr-sm-2" for="companyType">Type d'entreprise</label>
                        <select value="" class="custom-select mr-sm-2" id="companyType">
                          <option>Magasin</option>
                          <option>Service</option>
                          <option>Restaurant</option>
                          <option>Santé</option>
                          <option>Culture & Loisirs</option>
                        </select>
                      </div>
                      <div class="form-group">
                        <div class="color-2">
                          <select data-placeholder="Catégories de magasin" multiple class="chosen-select" tabindex="8">
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



<?php include('includes/scripts.php'); ?>
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
      // $('#latitude').val(place.geometry['location'].lat());
      // $('#longitude').val(place.geometry['location'].lng());
      // // --------- show lat and long ---------------
      // $("#lat_area").removeClass("d-none");
      // $("#long_area").removeClass("d-none");
    });
  }
</script>

<script>
  $(function () {
    var input = document.getElementById("autocomplete");
    var autocomplete = new google.maps.places.Autocomplete(input);

    $('#my-modal').modal('show');
  });

  $('.companyType').change(function () {
    var selectedItem = $('.companyType').val();
    alert(selectedItem);
  });
</script>
<style>
  .pac-container {
    z-index: 10000 !important;
  }
</style>