<?php
$uid = $_SESSION['verified_user_id'];
// Récupère les informations d'un professionnel
$query = $firestore->collection('magasins')->document($uid);
$professional = $query->snapshot();
// Récupère tous les produits et services du professionnel
$query2 = $firestore->collection('magasins')->document($uid)->collection('produits');
$products = $query2->documents();

// Affiche le bon menu déroulant en fonction du type d'entreprise
// Lorsque la fonction est appelée pour éditer un produit, on sélectionne la catégorie actuelle du produit
function selectCategory($professional, $edit, $product) {
    if ($professional['type'] == 'Magasin') {
        ?>
        <div class="form-group">
            <label class="mr-sm-2" for="category">Catégorie</label>
            <select class="custom-select mr-sm-2" name="category" id="category" required>
                <option selected disabled hidden>Veuillez choisir une catégorie</option>
                <option <?php if($edit and $product['categorie'] == "Electroménager") {echo 'selected';} ?>>Electroménager</option>
                <option <?php if($edit and $product['categorie'] == "Jeux-Vidéos") {echo 'selected';} ?>>Jeux-Vidéos</option>
                <option <?php if($edit and $product['categorie'] == "High-Tech") {echo 'selected';} ?>>High-Tech</option>
                <option <?php if($edit and $product['categorie'] == "Alimentation") {echo 'selected';} ?>>Alimentation</option>
                <option <?php if($edit and $product['categorie'] == "Vêtements") {echo 'selected';} ?>>Vêtements</option>
                <option <?php if($edit and $product['categorie'] == "Films & Séries") {echo 'selected';} ?>>Films & Séries</option>
                <option <?php if($edit and $product['categorie'] == "Chaussures") {echo 'selected';} ?>>Chaussures</option>
                <option <?php if($edit and $product['categorie'] == "Bricolage") {echo 'selected';} ?>>Bricolage</option>
                <option <?php if($edit and $product['categorie'] == "Montres & Bijoux") {echo 'selected';} ?>>Montres & Bijoux</option>
                <option <?php if($edit and $product['categorie'] == "Téléphonie") {echo 'selected';} ?>>Téléphonie</option>
                <option <?php if($edit and $product['categorie'] == "Restaurant") {echo 'selected';} ?>>Restaurant</option>
            </select>
        </div>
        <?php
    } elseif ($professional['type'] == 'Service') {
        ?>
        <div class="form-group">
            <label class="mr-sm-2" for="category">Catégorie</label>
            <select class="custom-select mr-sm-2" name="category" id="category" required>
                <option selected disabled hidden>Veuillez choisir une catégorie</option>
                <option <?php if($edit and $product['categorie'] == "Menuiserie") {echo 'selected';} ?>>Menuiserie</option>
                <option <?php if($edit and $product['categorie'] == "Plomberie") {echo 'selected';} ?>>Plomberie</option>
                <option <?php if($edit and $product['categorie'] == "Piscine") {echo 'selected';} ?>>Piscine</option>
                <option <?php if($edit and $product['categorie'] == "Meubles") {echo 'selected';} ?>>Meubles</option>
                <option <?php if($edit and $product['categorie'] == "Vêtements") {echo 'selected';} ?>>Vêtements</option>
                <option <?php if($edit and $product['categorie'] == "Gestion de patrimoine") {echo 'selected';} ?>>Gestion de patrimoine</option>
            </select>
        </div>
        <?php
    } elseif ($professional['type'] == 'Restaurant') {
        ?>
        <div class="form-group">
            <label class="mr-sm-2" for="category">Catégorie</label>
            <select class="custom-select mr-sm-2" name="category" id="category" required>
                <option selected disabled hidden>Veuillez choisir une catégorie</option>
                <option <?php if($edit and $product['categorie'] == "Français") {echo 'selected';} ?>>Français</option>
                <option <?php if($edit and $product['categorie'] == "Local") {echo 'selected';} ?>>Local</option>
                <option <?php if($edit and $product['categorie'] == "Italien") {echo 'selected';} ?>>Italien</option>
                <option <?php if($edit and $product['categorie'] == "Fast-Food") {echo 'selected';} ?>>Fast-Food</option>
                <option <?php if($edit and $product['categorie'] == "Asiatique") {echo 'selected';} ?>>Asiatique</option>
                <option <?php if($edit and $product['categorie'] == "Pizzeria") {echo 'selected';} ?>>Pizzeria</option>
            </select>
        </div>
        <?php
    } elseif ($professional['type'] == 'Santé') {
        ?>
        <div class="form-group">
            <label class="mr-sm-2" for="category">Catégorie</label>
            <select class="custom-select mr-sm-2" name="category" id="category" required>
                <option selected disabled hidden>Veuillez choisir une catégorie</option>
                <option <?php if($edit and $product['categorie'] == "Pharmacie") {echo 'selected';} ?>>Pharmacie</option>
                <option <?php if($edit and $product['categorie'] == "Aide à la personne") {echo 'selected';} ?>>Aide à la personne</option>
            </select>
        </div>
        <?php
    } elseif ($professional['type'] == 'Culture et loisirs') {
        ?>
        <div class="form-group">
            <label class="mr-sm-2" for="category">Catégorie</label>
            <select class="custom-select mr-sm-2" name="category" id="category" required>
                <option selected disabled hidden>Veuillez choisir une catégorie</option>
                <option <?php if($edit and $product['categorie'] == "Parc d'attraction") {echo 'selected';} ?>>Parc d'attraction</option>
                <option <?php if($edit and $product['categorie'] == "Musée") {echo 'selected';} ?>>Musée</option>
                <option <?php if($edit and $product['categorie'] == "Tourisme") {echo 'selected';} ?>>Tourisme</option>
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

    img {
        max-width: 25vw;
        max-height: 25vw;
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
                                <?php selectCategory($professional, false, 0); ?>
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
                            <th>Nom</th>
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
                        $count = 0;
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
                                    <button class="btn btn-outline-primary" value="<?=$product['nom']?>" title="<?=$product['nom']?>"
                                        data-toggle="modal" data-target="#editProduct<?=$count?>">
                                        <i class="far fa-edit"></i>
                                    </button>
                                    <button class="btn btn-outline-danger" value="<?=$product['nom']?>"
                                        data-toggle="modal" data-target="#deleteProduct<?=$count?>">
                                        <i class="far fa-trash-alt"></i>
                                    </button>
                                </td>
                            </tr>

                            <!-- Fenêtre modale de suppression d'un produit -->
                            <div class="modal fade" id="deleteProduct<?=$count?>" tabindex="-1" role="dialog"
                            aria-labelledby="exampleModalLabel" aria-hidden="true">
                                <div class="modal-dialog" role="document">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="exampleModalLabel">Vous êtes sur le point de supprimer le produit 
                                            <?=$product['nom']?></h5>
                                            <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                                            <span aria-hidden="true">×</span>
                                            </button>
                                        </div>
                                        <div class="modal-body">Cette action est définitive, si vous souhaitez le supprimer veuillez cliquer
                                            sur le bouton "Supprimer" ci-dessous. </div>
                                        <div class="modal-footer">
                                            <button class="btn btn-secondary" type="button" data-dismiss="modal">Annuler</button>

                                            <form method="POST">
                                                <input type="hidden" name="uid" value="<?=$uid?>">
                                                <input type="hidden" name="docId" value="<?=$product->id()?>">
                                                <button type="submit" value="<?=$product->id()?>" name="delete_product"
                                                    class="btn btn-danger">Supprimer</button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Fenêtre modale de modification d'un produit -->
                            <div class="modal" id="editProduct<?=$count?>" tabindex="-1" role="dialog"
                            aria-labelledby="exampleModalLabel" aria-hidden="true">
                                <div class="modal-dialog modal-lg" role="document">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="exampleModalLabel">Informations sur <?=$product['nom']?></h5>
                                            <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                                            <span aria-hidden="true">×</span>
                                            </button>
                                        </div>
                                        <form method="post" enctype="multipart/form-data">
                                            <div class="modal-body">
                                                <input type="hidden" name="uid" value="<?=$uid?>">
                                                <input type="hidden" name="docId" value="<?=$product->id()?>">
                                                
                                                <div class="form-group">
                                                    <label for="productname">Nom du produit</label>
                                                    <input type="text" name="productName" id="productname" class="form-control"
                                                    value="<?=$product['nom']?>" required>
                                                </div>
                                                <?php selectCategory($professional, true, $product); ?>
                                                <div class="form-group">
                                                    <label for="description">Description</label>
                                                    <textarea class="form-control" name="description" rows="3" 
                                                        required><?=$product['description']?></textarea>
                                                </div>
                                                <div class="form-group">
                                                    <label for="prix">Prix</label>
                                                    <input type="text" name="prix" id="prix" class="form-control"
                                                    value="<?=$product['prix']?>" required>
                                                </div>
                                                <div class="form-group">
                                                    <label for="quantite">Quantité en stock</label>
                                                    <input type="text" name="quantite" id="quantite" class="form-control"
                                                    value="<?=$product['quantite']?>" required>
                                                </div>
                                                <div class="form-group">
                                                    <label for="reference">Référence</label>
                                                    <input type="text" name="reference" id="reference" class="form-control"
                                                    value="<?=$product['reference']?>" required>
                                                </div>
                                                <div class="form-group">
                                                    <label for="visibilite">Faire apparaître le produit</label>
                                                    <br>
                                                    <input type="checkbox" name="visibilite" id="visibilite"
                                                    <?php if($product['visible'] == true) { echo "checked";}?>>
                                                </div>
                                                <label for="currentImage">Image actuelle</label>
                                                <br>
                                                <img src="<?=$product['images'][0]?>" class="img-thumbnail img-fluid"
                                                    id="currentImage" alt="<?=$product['images'][0]?>">
                                                <br><br>
                                                <div class="form-group">
                                                    <label for="image">Modifier l'image</label>
                                                    <br>
                                                    <input type="file" name="image" id="image">
                                                </div>
                                            </div>
                                            <div class="modal-footer">
                                                <!-- Boutons de validation et d'annulation -->
                                                <button class="btn btn-secondary" type="button" data-dismiss="modal">Annuler</button>

                                                <button type="submit" value="<?=$product->id()?>" name="edit_product"
                                                    class="btn btn-danger">Modifier</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        <?php $count++; } ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
