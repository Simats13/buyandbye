<?php
// Récupère toutes les commandes du professionnel
$uid = $_SESSION['verified_user_id'];
$commands = $firestore->collection('commandes');
$query = $commands->where('users', 'array-contains', $uid);
$snapshot = $query->documents();
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
        padding: 1% 4%;
        font-size: 2vw;
        border-radius: 8px;
        transition-duration: 0.4s;
    }

    button:hover {
        box-shadow: 0 12px 16px 0 rgba(0,0,0,0.24), 0 17px 50px 0 rgba(0,0,0,0.19);
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
</style>

<div id="page">
    <h1>Voir mes commandes</h1>
    <?php
    function getCommands($snapshot, $firestore, $statut) {
        foreach ($snapshot as $document) {
            $ids = $document['users'][0] . $document['users'][1];
            // Récupère les commandes dont le statut est 0 (en attente)
            $statut0 = $firestore->collection('commandes')->document($ids)->collection("commands");
            $query0 = $statut0->where('statut', '=', 0);
            $snapshot0 = $query0->documents();
            // Récupère les commandes dont le statut est 1 (en cours)
            $statut1 = $firestore->collection('commandes')->document($ids)->collection("commands");
            $query1 = $statut1->where('statut', '=', 1);
            $snapshot1 = $query1->documents();
            // Récupère les commandes dont le statut est 2 (terminé)
            $statut2 = $firestore->collection('commandes')->document($ids)->collection("commands");
            $query2 = $statut2->where('statut', '=', 2);
            $snapshot2 = $query2->documents();
                foreach (${'snapshot' . $statut} as $doc) {
                    printf('ID de commande : ' . $doc['id']);
                    echo nl2br("\n");
                }
        }
    }
    ?>

    <button id="button1" onclick="button1()">En attente</button>
    <button id="button2" onclick="button2()">En cours</button>
    <button id="button3" onclick="button3()">Terminées</button>
    <br><br>

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