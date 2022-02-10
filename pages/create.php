<style>
    .conteneur {
        display: flex;
        padding: 0 0 10% 0;
    }

    .flex {
        padding: 0 2% 0 0;
    }

    .onMouseover .textOver {
        visibility: hidden;
        width: 10%;
        background-color: black;
        color: #fff;
        text-align: center;
        border-radius: 6px;
        margin: 5px 0;

        /* Position the tooltip */
        position: absolute;
        margin: 2% -5%;
        z-index: 1;
    }

    .onMouseover {
        color: black;
    }

    .onMouseover:hover .textOver {
        visibility: visible;
    }
</style>

<form class="login100-form validate-form" method="post" style="width: 100%; height: 100%;">
    <span class="login100-form-title p-b-40">
        Création d'espace professionnel
        <br> Buy&Bye
    </span>

    <div class="conteneur">
        <div class="flex">
            <h4>Informations personnelles</h4>
        </div>
        <div class="flex onMouseover">
            <h6>ⓘ</h6>
            <span class="textOver">Informations personnelles de la personne propriétaire de l'entreprise</span>
        </div>
    </div>

    <div class="wrap-input100 validate-input" data-validate="Veuillez entrer un nom de famille">
        <input class="input100" type="text" name="nom">
        <span class="focus-input100"></span>
        <span class="label-input100">Nom</span>
    </div>
    <div class="wrap-input100 validate-input" data-validate="Veuillez entrer un prénom">
        <input class="input100" type="text" name="prenom">
        <span class="focus-input100"></span>
        <span class="label-input100">Prénom</span>
    </div>
    <div class="wrap-input100 validate-input" data-validate="Veuillez entrer une adresse e-mail valide : ex@abc.xyz">
        <input class="input100" type="text" name="email">
        <span class="focus-input100"></span>
        <span class="label-input100">Adresse Email</span>
    </div>
    <br>
    <div class="container-login100-form-btn">
        <button class="login100-form-btn" style="background:#B33030" name="create">
            Passer à la suite
        </button>
    </div>

    <?php
        if(isset($_POST['create'])) {
            $nom = htmlspecialchars(trim($_POST['nom']));
            $prenom = htmlspecialchars(trim($_POST['prenom']));
            $email = htmlspecialchars(trim($_POST['email']));

            print("$nom . $prenom . $email");
        } else {
            print("Informations not set");
        }
    ?>
</form>