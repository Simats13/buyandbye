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
    <!-- Popup ajout d'un manuel d'un magasin -->
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
            <div class="conteneur">
              <div class="flex"><h3>Informations personnelles</h3></div>
              <div class="flex onMouseover"><h3>ⓘ</h3>
                <span class="textOver">Informations personnelles de la personne propriétaire de l'entreprise</span>
              </div>
            </div>
            <form method="post" enctype="multipart/form-data">
              <div class="form-group">
                <label for="lastname">Nom</label>
                <input type="text" name="ownerLastName" id="lastname" class="form-control" placeholder="ex: Dupont">
              </div>
              <div class="form-group">
                <label for="firstname">Prénom</label>
                <input type="text" name="ownerFirstName" id="firstname" class="form-control" placeholder="ex: Frédéric">
              </div>
              <div class="form-group">
                <label for="mail">Adresse E-Mail</label>
                <input type="text" name="email" id="mail" class="form-control" placeholder="ex: email@email.com">
              </div>
              <br>
              <h3>Informations de l'entreprise</h3>
              <div class="form-group">
                <label for="enterprisename">Nom</label>
                <input type="text" name="enterpriseName" class="form-control" id="enterprisename" placeholder="ex: Dupont SAS">
              </div>
              <div class="form-group">
                <label for="enterpriseadress">Adresse</label>
                <input type="text" name="enterpriseAddress" class="form-control" id="enterpriseaddress" placeholder="ex: Avenue des Champs-Elysée, Paris">
              </div>
              <div class="form-group">
                <label for="enterprisephone">Numéro de téléphone</label>
                <input type="text" name="enterprisePhone" class="form-control" id="enterprisephone" placeholder="ex: 01 02 03 04 05">
              </div>

              <div class="form-group">
                <div class="conteneur">
                  <div class="flex"><label for="isphonevisible">Numéro de téléphone visible ?</label></div>
                  <div class="flex onMouseover">ⓘ
                    <span class="textOver">Afficher le numéro de téléphone aux clients ?</span>
                  </div>
                </div>
                <br>
                <input type="checkbox" name="isPhoneVisible" id="isphonevisible">
              </div>

              <div class="form-group">
                <div class="conteneur">
                  <div class="flex"><label for="isrestaurant">L'entreprise est-elle un restaurant ?</label></div>
                  <div class="flex onMouseover">ⓘ
                    <span class="textOver">L'entreprise créée est-elle un restaurant ou un bar ?<br>Si oui, ajoute la possibilité d'importer des menus</span>
                  </div>
                </div>
                <br>
                <input type="checkbox" name="isRestaurant" id="isrestaurant">
              </div>
              <div class="form-group">
                <label for="siretnumber">Numéro de SIRET</label>
                <input type="text" name="siretNumber" class="form-control" id="siretnumber" placeholder="ex: 123 456 789 00012">
              </div>
              <div class="form-group">
                <label for="tvanumber">Numéro de TVA</label>
                <input type="text" name="tvaNumber" class="form-control" id="tvanumber" placeholder="ex: FR 00 123456789">
              </div>
              <br>
              
              <!-- Boutons de validation et d'annulation -->
              <div class="modal-footer">
                <button class="btn btn-secondary" type="button" data-dismiss="modal">Annuler</button>
                <button type="submit" value="" name="edit_listing" class="btn btn-primary">Enregistrer les modifications</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <hr class="solid">

    <button class="button-3" role="button">Importer un fichier CSV</button>
  </div>
</div>