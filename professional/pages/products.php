<?php
// Récupère tous les produits et services du professionnel
$uid = $_SESSION['verified_user_id'];
$products = $firestore->collection('magasins')->document($uid)->collection('produits');
$snapshot = $products->documents();
?>

<script>
</script>

<style>
    #page {
        padding: 0 5%;
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
                        foreach ($snapshot as $product) {
                            $query = $products->document($product->id());
                            $product = $query->snapshot();
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
