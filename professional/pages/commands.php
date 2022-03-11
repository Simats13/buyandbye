<?php
// Récupère toutes les commandes du professionnel
$uid = $_SESSION['verified_user_id'];
$commands = $firestore->collection('commandes');
$query = $commands->where('users', 'array-contains', $uid);
$snapshot = $query->documents();

function getCommands($snapshot, $firestore, $statut) {
    foreach ($snapshot as $document) {
        $ids = $document['users'][0] . $document['users'][1];

        if ($statut == 0) {
        // Récupère les commandes dont le statut est 0 (en attente)
            $statut1 = $firestore->collection('commandes')->document($ids)->collection("commands");
            $query1 = $statut1->where('statut', '=', 0);
            $snapshot1 = $query1->documents();
        } elseif ($statut == 1) {
        // Récupère les commandes dont le statut est 1 (en cours)
            $statut1 = $firestore->collection('commandes')->document($ids)->collection("commands");
            $query1 = $statut1->where('statut', '=', 1);
            $snapshot1 = $query1->documents();
        } else {
        // Récupère les commandes dont le statut est 2 (terminé)
            $statut1 = $firestore->collection('commandes')->document($ids)->collection("commands");
            $query1 = $statut1->where('statut', '=', 2);
            $snapshot1 = $query1->documents();
        }

        foreach ($snapshot1 as $doc) {
            ?>
            <div class="parent">
                <div class="left">
                    <?php
                    echo 'Date de commande : ' . date('d/m/Y à H:i', strtotime($doc['horodatage']));
                    echo nl2br("\n");
                    echo nl2br("\n");
                    echo 'Référence de commande : ' . $doc['reference'];
                    ?>
                </div>
                <div class="right">
                    <?php
                    if ($doc['articles'] == 1) {
                        echo $doc['articles'] . ' article';
                    } else {
                        echo $doc['articles'] . ' articles';
                    }
                    echo nl2br("\n");
                    echo nl2br("\n");
                    echo 'Prix : ' . $doc['prix'] . '€';
                    ?>
                </div>
            </div>
            <?php
        }
    }
}
?>

<script>
    function button1() {
        // Affiche le bon tableau et supprime les autres
        document.getElementById("table1").style.display = "block";
        document.getElementById("table2").style.display = "none";
        document.getElementById("table3").style.display = "none";
        // Met le bouton sélectionné en évidence et remet la couleur de base aux autres
        document.getElementById("button1").style.backgroundColor = "#359738";
        document.getElementById("button2").style.backgroundColor = "#4CAF50";
        document.getElementById("button3").style.backgroundColor = "#4CAF50";
    }

    function button2() {
        document.getElementById("table1").style.display = "none";
        document.getElementById("table2").style.display = "block";
        document.getElementById("table3").style.display = "none";
        document.getElementById("button1").style.backgroundColor = "#4CAF50";
        document.getElementById("button2").style.backgroundColor = "#359738";
        document.getElementById("button3").style.backgroundColor = "#4CAF50";
    }

    function button3() {
        document.getElementById("table1").style.display = "none";
        document.getElementById("table2").style.display = "none";
        document.getElementById("table3").style.display = "block";
        document.getElementById("button1").style.backgroundColor = "#4CAF50";
        document.getElementById("button2").style.backgroundColor = "#4CAF50";
        document.getElementById("button3").style.backgroundColor = "#359738";
    }
</script>

<style>
    #page {
        padding: 0 5%;
    }

    button {
        background-color: #4CAF50;
        border: none;
        color: white;
        text-align: center;
        padding: 0.8% 3%;
        font-size: 1.2vw;
        border-radius: 8px;
        transition-duration: 0.4s;
    }

    button:hover {
        box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.24), 0 10px 16px rgba(0, 0, 0, 0.18);
    }

    button:focus {
        outline: none;
    }

    #table1 {
        display: block;
    }

    #table2 {
        display: none;
    }

    #table3 {
        display: none;
    }

    .card-body {
        padding-left: 10vw;
        padding-right: 10vw;
    }

    #buttons {
        text-align: right;
        padding-bottom: 2.5vh;
    }

    .parent {
        clear: both;
        overflow: hidden;
        padding: 2vw;
        border-radius: 25px;
        margin-bottom: 3vw;
        box-shadow: rgba(50, 50, 93, 0.25) 0px 13px 27px -5px, rgba(0, 0, 0, 0.3) 0px 8px 16px -8px;
    }

    .left {
        float: left;
    }

    .right {
        float: right;
    }
</style>

<div id="page"> 
    <h1>Voir mes commandes</h1>
    <div id="buttons">
        <button id="button1" onclick="button1()" style="background-color: #359738">En attente</button>
        <button id="button2" onclick="button2()">En cours</button>
        <button id="button3" onclick="button3()">Terminées</button>
    </div>
    <!-- Tableau des commandes en attente -->
    <div id="table1" class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">Commandes en attente</h6>
        </div>

        <div class="card-body">
            <?php getCommands($snapshot, $firestore, 0);?>
        </div>
    </div>

    <!-- Tableau des commandes en cours -->
    <div id="table2" class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">Commandes en cours</h6>
        </div>

        <div class="card-body">
            <?php getCommands($snapshot, $firestore, 1);?>
        </div>
    </div>

    <!-- Tableau des commandes terminées -->
    <div id="table3" class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">Commandes terminées</h6>
        </div>

        <div class="card-body">
            <?php getCommands($snapshot, $firestore, 2);?>
        </div>
    </div>
</div>

<!-- Données à afficher : 'horodatage', 'reference' | 'articles', 'prix'