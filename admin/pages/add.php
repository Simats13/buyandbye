<?php include('includes/scripts.php'); ?>

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
    font-family: -apple-system,system-ui,"Segoe UI",Helvetica,Arial,sans-serif,"Apple Color Emoji","Segoe UI Emoji";
    font-size: 14px;
    font-weight: 600;
    line-height: 20px;
    padding: 6px 16px;
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
    font-size: 1.35vw;
    color: white;
    margin: 0 0 5% 0;
  }
</style>

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
      if(isset($_SESSION['errors']))
      {
          echo "<h5 class='alert alert-danger'>".$_SESSION['errors']."</h5>";
          unset($_SESSION['errors']);
      }
      ?>
    </div>

    <button class="button-3" role="button" data-toggle="modal" data-target="#addShop">Ajouter manuellement</button>
    <div class="modal fade" id="addShop" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
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
            Une fois la boutique créée, un e-mail sera envoyé au professionnel avec les informations entrées ci-dessous.<br>
            Il devra alors confirmer les informations et choisir un mot de passe pour son espace personnel.
            </div>
            <h3>Informations personnelles</h3>
            <form method="post" enctype="multipart/form-data">
              <div class="form-group">
                <label for="exampleFormControlInput1">Nom</label>
                <input type="text" name="ownerLastName" class="form-control" placeholder="Dupont">
              </div>
              <div class="form-group">
                <label for="autocomplete">Prénom</label>
                <input type="text" name="ownerFirstName" class="form-control" placeholder="Frédéric">
              </div>
              <div class="form-group">
                <label for="exampleFormControlInput1">Adresse E-Mail</label>
                 <input type="text" name="email" class="form-control" placeholder="email@email.com">
              </div>
                </div>
                  <div class="modal-footer">
                    <button class="btn btn-secondary" type="button" data-dismiss="modal">Annuler</button>
                    <button type="submit" value="" name="edit_listing" class="btn btn-primary">Enregistrer les modifications</button>
                  </div>
                </div>
              </div>
            </form>
    </div>

    <hr class="solid">

    <button class="button-3" role="button">Importer un fichier CSV</button>
  </div>
</div>