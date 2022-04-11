<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
<?php
// Récupère toutes les commandes du professionnel
$uid = $_SESSION['verified_user_id'];
$commands = $firestore->collection('commandes');
$query = $commands->where('users', 'array-contains', $uid);
$snapshot = $query->documents();

function getCommands($snapshot, $firestore, $statut, $uid) {
    # Premier compteur qui s'incrémente à chaque client différent
    $count1 = 0;
    ?>
    <div class="table-responsive">
        <table class="table table-bordered" id="dataTable" width="75%" cellspacing="0">
            <thead>
                <tr>
                    <th>Commande n°</th>
                    <th>Date</th>
                    <th>Nombre d'articles</th>
                    <th>Prix</th>
                    <th>Détail</th>
                </tr>
            </thead>
            <tbody>
                <?php
                # On boucle sur chaque client
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
                    # Second compteur qui s'incrémente à chaque commande d'un client
                    $count2 = 0;
                    # On boucle sur chaque commande d'un client
                    foreach ($snapshot1 as $doc) {
                    ?>
                    <tr>
                        <td><?=$doc['reference']?></td>
                        <td><?=date('d/m/Y à H:i', strtotime($doc['horodatage']))?></td>
                        <td><?php 
                        if ($doc['articles'] == 1) {
                            echo $doc['articles'] . ' article';
                        } else {
                            echo $doc['articles'] . ' articles';
                        }?></td>
                        <td><?=$doc['prix'] . '€'?></td>
                        <td>
                        <button class="btn btn-primary shadowButtons" data-toggle="modal" data-target="#commandDetails<?=$statut.$count1.$count2?>">
                            Voir le détail
                        </button>
                        </td>
                    </tr>

                    <!-- Chaque popup doit être unique sinon elle ne s'affiche pas -->
                    <!-- On lui attribue donc un id unique composé du statut de la commande et des 2 compteurs ci-dessus -->
                    <div class="modal fade" id="commandDetails<?=$statut.$count1.$count2?>" tabindex="-1" role="dialog" aria-labelledby="ModalLabel" aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title" id="ModalLabel">Informations sur la commande n°<?=$doc['reference']?></h5>
                                    <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                                        <span aria-hidden="true">×</span>
                                    </button>
                                </div>
                                <div class="modal-body">
                                    <?php
                                    echo 'Le ' . date('d/m/Y à H:i', strtotime($doc['horodatage']));
                                    echo nl2br("\n");
                                    if ($doc['articles'] == 1) {
                                        echo $doc['articles'] . ' article';
                                    } else {
                                        echo $doc['articles'] . ' articles';
                                    }
                                    echo nl2br("\n");
                                    echo 'Total : ' . $doc['prix'] . '€';
                                    echo nl2br("\n");
                                    // Affiche le mode de livraison
                                    // Vérifier les nombres par rapport à ce qui est rentré par l'app
                                    // 0 = C&C en préparation - 1 = domicile en préparation - 2 = C&C disponible - 3 = domicile livré
                                    if ($doc['livraison'] == 0 or $doc['livraison'] == 2) {
                                        $livraison = "Click & Collect";
                                    } else {
                                        $livraison = "Livraison à domicile";
                                    }
                                    echo 'Mode de livraison : ' . $livraison;
                                    echo nl2br("\n");
                                    echo 'Adresse client : ' . $doc['adresse'];
                                    echo nl2br("\n");
                                    # Récupère les produits de la commande
                                    $products = $firestore->collection('commandes')->document($ids)->collection('commands')->document($doc['id'])->collection('products');
                                    $snapshot2 = $products->documents();
                                    ?> 
                                    <div class="grid">
                                        <span>Image produit</span>
                                        <span>Nom</span>
                                        <span>Référence</span>
                                        <span>Prix unitaire</span>
                                        <span>Quantité</span>
                                    
                                        <?php
                                        foreach ($snapshot2 as $prod) {
                                            $product = $firestore->collection('magasins')->document($uid)->collection('produits')->document($prod['produit']);
                                            $snapshot3 = $product->snapshot();
                                            ?>
                                            <span><img src=<?=$snapshot3['images'][0]?> alt=<?=$snapshot3['nom']?>></span>
                                            <span><?=$snapshot3['nom']?></span>
                                            <span><?=$snapshot3['reference']?></span>
                                            <span><?=$snapshot3['prix']?>€</span>
                                            <span><?=$prod['quantite']?></span>
                                        <?php } ?> 
                                    </div>
                                    <button type="button" id="contactButton" class="btn btn-primary">Contacter client</button>
                                    <!-- ID client : $document['users'][1] -->
                                    <div class="modal-footer">
                                        <form method='POST'>
                                            <input type="hidden" name="ids" value="<?=$ids?>">
                                            <input type="hidden" name="docId" value="<?=$doc['id']?>">
                                            <button type="submit" class="btn btn-success waitingForm visible" name="accept">Accepter la commande</button>
                                            <button type="submit" class="btn btn-light waitingForm visible" name="refuse">Refuser la commande</button>
                                        </form>
                                        <form method='POST'>
                                            <input type="hidden" name="ids" value="<?=$ids?>">
                                            <input type="hidden" name="docId" value="<?=$doc['id']?>">
                                            <button type="submit" class="btn btn-success inProgressForm notVisible" name="validate">Valider la commande</button>
                                            <button type="submit" class="btn btn-light inProgressForm notVisible" name="cancel">Annuler la commande</button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <?php $count2++; }
                $count1++; } ?>
            </tbody>
        </table>
    </div>
<?php
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

    $(document).ready(function(){
        $("#button1").click(function(){
            $(".waitingForm").removeClass("notVisible");
            $(".inProgressForm").removeClass("visible");
            $(".waitingForm").addClass("visible");
            $(".inProgressForm").addClass("notVisible");
        });
    });

    $(document).ready(function(){
        $("#button2").click(function(){
            $(".waitingForm").removeClass("visible");
            $(".inProgressForm").removeClass("notVisible");
            $(".waitingForm").addClass("notVisible");
            $(".inProgressForm").addClass("visible");
        });
    });

    $(document).ready(function(){
        $("#button3").click(function(){
            $(".waitingForm, .inProgressForm").removeClass("visible");
            $(".waitingForm, .inProgressForm").addClass("notVisible");
        });
    });
</script>

<style>
    #page {
        padding: 0 5%;
    }

    #button1,
    #button2,
    #button3 {
        background-color: #4CAF50;
    }

    .shadowButtons {
        border: none;
        color: white;
        text-align: center;
        padding: 0.8% 3%;
        font-size: 1.2vw;
        border-radius: 8px;
        transition-duration: 0.4s;
    }

    .shadowButtons:hover {
        box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.24), 0 10px 16px rgba(0, 0, 0, 0.18);
    }

    .shadowButtons:focus {
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

    .grid {
        display: grid;
        grid-template-columns: repeat(5, 1fr);
        border-top: 1px solid black;
        border-right: 1px solid black;
    }

    .grid > span {
        padding: 8px 4px;
        border-left: 1px solid black;
        border-bottom: 1px solid black;
    }

    img {
        max-width: 5vw;
        max-height: 5vw;
    }

    .btn-light {
        background-color: #E8E8E8;
    }

    .visible {
        display: inline;
    }

    .notVisible {
        display: none;
    }

    #contactButton {
        margin-top: 1vw;
        margin-bottom: 1vw;
    }
</style>

<div id="page">
    <div id="buttons">
        <button class="shadowButtons" id="button1" onclick="button1()" style="background-color: #359738">En attente</button>
        <button class="shadowButtons" id="button2" onclick="button2()">En cours</button>
        <button class="shadowButtons" id="button3" onclick="button3()">Terminées</button>
    </div>
    
    <!-- Tableau des commandes en attente -->
    <div id="table1" class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">Commandes en attente</h6>
        </div>

        <div class="card-body">
            <?php getCommands($snapshot, $firestore, 0, $uid);?>
        </div>
    </div>

    <!-- Tableau des commandes en cours -->
    <div id="table2" class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">Commandes en cours</h6>
        </div>

        <div class="card-body">
            <?php getCommands($snapshot, $firestore, 1, $uid);?>
        </div>
    </div>

    <!-- Tableau des commandes terminées -->
    <div id="table3" class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">Commandes terminées</h6>
        </div>

        <div class="card-body">
            <?php getCommands($snapshot, $firestore, 2, $uid);?>
        </div>
    </div>
</div>