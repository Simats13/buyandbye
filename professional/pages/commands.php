<?php
$uid = $_SESSION['verified_user_id'];
$commands = $firestore->collection('commandes')->document("dnGbdRAWrPMZYcLK98a5fowRLHJ2UaIZiq3TCrhAkeqYixauTs6UBhK2");
$document = $commands->snapshot();

$commands2 = $firestore->collection('commandes')->document("dnGbdRAWrPMZYcLK98a5fowRLHJ2UaIZiq3TCrhAkeqYixauTs6UBhK2")->collection("commands");
$snapshot = $commands2->documents();
?>

<script>
    function button1() {
        document.getElementById("button1").style.color = "black";
        document.getElementById("button2").style.color = "white";
        document.getElementById("button3").style.color = "white";
    }

    function button2() {
        document.getElementById("button1").style.color = "white";
        document.getElementById("button2").style.color = "black";
        document.getElementById("button3").style.color = "white";
    }

    function button3() {
        document.getElementById("button1").style.color = "white";
        document.getElementById("button2").style.color = "white";
        document.getElementById("button3").style.color = "black";
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
        background-color: #3C9F40;
        box-shadow: 0 12px 16px 0 rgba(0,0,0,0.24), 0 17px 50px 0 rgba(0,0,0,0.19);
    }

    button:focus {
        outline: none;
    }
</style>

<div id="page">
    <h1>Voir mes commandes</h1>
    <p>Bonjour <?=$document['users'][0]?></p>
    <?php
    foreach ($snapshot as $doc) {
        printf($doc['reference']);
        echo nl2br("\n");
    }
    ?>

    <button id="button1" onclick="button1()" style="color: black;">En attente</button>
    <button id="button2" onclick="button2()">En cours</button>
    <button id="button3" onclick="button3()">Terminées</button>
    <br><br>

    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">Commandes en attente</h6>
        </div>

        <div class="card-body">
            <p>Bonjour</p>
        </div>
    </div>
</div>