<?php
$uid = $_SESSION['verified_user_id'];
// Récupère les informations d'un professionnel
$query = $firestore->collection('magasins')->document($uid);
$professional = $query->snapshot();
// Récupère tous les produits et services du professionnel
$query2 = $firestore->collection('magasins')->document($uid)->collection('produits');
$products = $query2->documents();

// Affiche le bon menu déroulant en fonction du type d'entreprise
function selectCategory($professional) {
    if ($professional['type'] == 'Magasin') {
        ?>
        <div class="form-group">
            <label class="mr-sm-2" for="category">Catégorie</label>
            <select class="custom-select mr-sm-2" name="category" id="category" required>
                <option selected disabled hidden>Veuillez choisir une catégorie</option>
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
        <?php
    } elseif ($professional['type'] == 'Service') {
        ?>
        <div class="form-group">
            <label class="mr-sm-2" for="category">Catégorie</label>
            <select class="custom-select mr-sm-2" name="category" id="category" required>
                <option selected disabled hidden>Veuillez choisir une catégorie</option>
                <option>Menuiserie</option>
                <option>Plomberie</option>
                <option>Piscine</option>
                <option>Meubles</option>
                <option>Vêtements</option>
                <option>Gestion de patrimoine</option>
            </select>
        </div>
        <?php
    } elseif ($professional['type'] == 'Restaurant') {
        ?>
        <div class="form-group">
            <label class="mr-sm-2" for="category">Catégorie</label>
            <select class="custom-select mr-sm-2" name="category" id="category" required>
                <option selected disabled hidden>Veuillez choisir une catégorie</option>
                <option>Français</option>
                <option>Local</option>
                <option>Italien</option>
                <option>Fast-Food</option>
                <option>Asiatique</option>
                <option>Pizzeria</option>
            </select>
        </div>
        <?php
    } elseif ($professional['type'] == 'Santé') {
        ?>
        <div class="form-group">
            <label class="mr-sm-2" for="category">Catégorie</label>
            <select class="custom-select mr-sm-2" name="category" id="category" required>
                <option selected disabled hidden>Veuillez choisir une catégorie</option>
                <option>Pharmacie</option>
                <option>Aide à la personne</option>
            </select>
        </div>
        <?php
    } elseif ($professional['type'] == 'Culture et loisirs') {
        ?>
        <div class="form-group">
            <label class="mr-sm-2" for="category">Catégorie</label>
            <select class="custom-select mr-sm-2" name="category" id="category" required>
                <option selected disabled hidden>Veuillez choisir une catégorie</option>
                <option>Parc d'attraction</option>
                <option>Musée</option>
                <option>Tourisme</option>
            </select>
        </div>
        <?php
    } else {
        echo "Problème de type d'entreprise. Veuillez contacter l'assistance.";
    }
 }
?>

<script>
</script>

<style>
    #page {
        padding: 0 5%;
    }

    #addButton {
        text-align: right;
    }

    #addProduct {
        padding: .5%;
        margin-right: 3%;
        margin-bottom: 1%;
    }

    .truncate {
        display: table;
        table-layout: fixed;
        width: 100%;
    }

    .truncated {
        overflow-x: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }
</style>

<div id="page">
    <h1>Gérer mes produits</h1>

    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">Mes produits</h6>
        </div>
        <div class="card-body">
            <div id="addButton">
                <button id="addProduct" class="btn btn-primary" data-toggle="modal" data-target="#add">Ajouter un produit</button>
            </div>

            <!-- Popup d'ajout d'un produit -->
            <div class="modal" id="add" tabindex="-1" role="dialog" aria-labelledby="addModal" aria-hidden="true">
                <div class="modal-dialog modal-lg" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="addModal">Ajouter un produit</h5>
                            <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">×</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <form method="POST" enctype="multipart/form-data">
                                <input type="hidden" name="uid" value="<?=$uid?>">
                                <div class="form-group">
                                    <label for="productname">Nom du produit</label>
                                    <input type="text" name="productName" id="productname" class="form-control" required>
                                </div>
                                <?php selectCategory($professional); ?>
                                <div class="form-group">
                                    <label for="description">Description</label>
                                    <textarea class="form-control" name="description" rows="3" required></textarea>
                                </div>
                                <div class="form-group">
                                    <label for="prix">Prix</label>
                                    <input type="text" name="prix" id="prix" class="form-control" required>
                                </div>
                                <div class="form-group">
                                    <label for="quantite">Quantité en stock</label>
                                    <input type="text" name="quantite" id="quantite" class="form-control" required>
                                </div>
                                <div class="form-group">
                                    <label for="reference">Référence</label>
                                    <input type="text" name="reference" id="reference" class="form-control" required>
                                </div>
                                <div class="form-group">
                                    <label for="visibilite">Faire apparaître le produit</label>
                                    <br>
                                    <input type="checkbox" name="visibilite" id="visibilite">
                                </div>
                                <div class="form-group">
                                    <label for="image">Image</label>
                                    <br>
                                    <input type="file" name="image" id="image">
                                </div>
                                <!-- Boutons de validation et d'annulation -->
                                <div class="modal-footer">
                                    <button class="btn btn-secondary" type="button" data-dismiss="modal">Annuler</button>
                                    <button type="submit" name="add_product" class="btn btn-primary">Ajouter le produit</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Affichage des produits -->
            <div class="table-responsive">
                <table class="table table-bordered" width="100%" cellspacing="0">
                    <thead>
                        <tr>
                            <th>Nom du produit</th>
                            <th>Catégorie</th>
                            <th>Description</th>
                            <th>Prix</th>
                            <th>Quantité</th>
                            <th>Référence</th>
                            <th>Modification</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php
                        foreach ($products as $product) {
                            $query3 = $query2->document($product->id());
                            $product = $query3->snapshot();
                            ?>
                            <tr>
                                <td style="width: 15%">
                                    <div class="truncate">
                                            <div class="truncated"><?=$product['nom']?></div>
                                        </div>
                                    </td>
                                <td><?=$product['categorie']?></td>
                                <td style="width: 25%">
                                    <div class="truncate">
                                        <div class="truncated"><?=$product['description']?></div>
                                    </div>
                                </td>
                                <td><?=$product['prix']?></td>
                                <td><?=$product['quantite']?></td>
                                <td><?=$product['reference']?></td>
                                <td>
                                    <button class="btn btn-outline-primary"><i class="far fa-edit"></i></button>
                                    <button class="btn btn-outline-danger"><i class="far fa-trash-alt"></i></button>
                                </td>
                            </tr>
                        <?php } ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
