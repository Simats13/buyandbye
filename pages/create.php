<script type="text/javascript">
    const pages = document.querySelectorAll(".page");
        const translateAmount = 100; 
        let translate = 0;
        slide = (direction) => {
        direction === "next" ? translate -= translateAmount : translate += translateAmount;
        pages.forEach(
            pages => (pages.style.transform = `translateX(${translate}%)`)
        );
        }
</script>

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

    button {
        cursor: pointer;
        transition: 0.3s ease-out;
    }

    button:hover{
        transform: scale(1.05);
    }

    .pages {
        display: flex;
        width: 200%;
        box-sizing: border-box;   
    }

    .page {
        width: 100%;
        height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-direction: column;
        gap: 10px;
        transition: all 0.7s;
        color: white;
    }

    .one{ background: orangered;}

    .two{ background-color: dodgerblue;}
</style>

<form class="login100-form validate-form" method="post" style="width: 100%;">
    <span class="login100-form-title p-b-40">
        Création d'espace professionnel
        <br> Buy&Bye
    </span>

    <!-- On met toutes les pages dans la même div pour effectuer les transitions -->
    <div class="pages">
        <!-- Page numéro 1 -->
        <div class="page one">
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
                <button class="login100-form-btn" style="background:#B33030" name="pageTwoButton">
                    Next
                </button>
            </div>
        </div>

        <!-- Page numéro 2 -->
        <div class="page two">
            <h2>Page 2</h2>
            <button class="login100-form-btn" style="background:#B33030" name="pageOneButton">
                Previous
            </button>
        </div>
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