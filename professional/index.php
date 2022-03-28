<?php
use Sk\Geohash\Geohash;

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require '../config/vendor/phpmailer/phpmailer/src/Exception.php';
require '../config/vendor/phpmailer/phpmailer/src/PHPMailer.php';
require '../config/vendor/phpmailer/phpmailer/src/SMTP.php';

include('../auth.php');
include('../config/dbconfig.php'); 
$pages = scandir('pages/');
if(isset($_GET['page']) && !empty($_GET['page'])){
    if(in_array($_GET['page'].'.php',$pages)){
        $page = $_GET['page'];
    }else{
        $page = "error";
    }
}else{
    $page = "dashboard";
}


function randomPassword() {
    $alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    $pass = array(); //remember to declare $pass as an array
    $alphaLength = strlen($alphabet) - 1; //put the length -1 in cache
    for ($i = 0; $i < 12; $i++) {
        $n = rand(0, $alphaLength);
        $pass[] = $alphabet[$n];
    }
    return implode($pass); //turn the array into a string
}

// Generate 16 bytes (128 bits) of random data or use the data passed into the function.
function guidv4($data = null) {
    $data = $data ?? random_bytes(16);
    assert(strlen($data) == 16);

    // Set version to 0100
    $data[6] = chr(ord($data[6]) & 0x0f | 0x40);
    // Set bits 6-7 to 10
    $data[8] = chr(ord($data[8]) & 0x3f | 0x80);

    // Output the 36 character UUID.
    return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
}

// Vérifie si l'image est correcte, renvoie true si c'est le cas
function checkImageParameters($storage, $id) {
    
    // Verifie si l'image actuelle n'est pas fausse
    if($_FILES["banniere"]['size'] != 0) {
        $target_file = $_FILES["banniere"]["name"];
        $imageFileType = strtolower(pathinfo($target_file,PATHINFO_EXTENSION));
        $check = getimagesize($_FILES["banniere"]["tmp_name"]);
        $uploadOk = 1;
        if($check !== false) {
            $uploadOk = 1;
        } else {
            $_SESSION['errors'] = "Ce n'est pas une image, seuls les fichiers aux formats JPG, JPEG et PNG sont autorisés";
            $uploadOk = 0;
        }
        

        // Vérifie la taille de l'image, ne doit pas excéder 5 mo
        if ($_FILES["banniere"]["size"] > 5000000) {
        $_SESSION['errors'] = "Désolé votre image est trop large";
        $uploadOk = 0;
        }

        // Accepter certains types d'images (JPG PNG JPEG)
        if($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg" ) {
        $_SESSION['errors'] = "Désolé seuls les fichiers aux formats JPG, JPEG et PNG sont autorisés";
        $uploadOk = 0;
        }

        // Vérifie si la variable UPLOADOK est à 1 pour pouvoir uploader dans la base de données, si erreur le fichier n'est pas transmis dans la base de données
        if ($uploadOk == 0) {
        $_SESSION['status'] = "Désolé votre image n'a pas été téléchargée, veuilez réessayer";
        // if everything is ok, try to upload file
        } else {
            $anotherBucket = $storage->getBucket('la-petite-camargue.appspot.com');
            $anotherBucket->upload(
                file_get_contents($_FILES['banniere']['tmp_name']),
                [
                    'name' => "$id/banniere.".$imageFileType
                ]
            );
            
            $image_url = "https://firebasestorage.googleapis.com/v0/b/la-petite-camargue.appspot.com/o/$id%2Fbanniere.$imageFileType?alt=media";      
        }
    }
    return $image_url;
}

/** PARTIE RESERVEE A LA PAGE ENTREPRISE
 *  Fonction permettant d'éditer une entreprise dans la BDD Firebase
 */

// Edition d'une entreprise
if(isset($_POST['edit_enterprise'])){
    $g = new Geohash();
    $id = $_POST['edit_enterprise'];
    $lname = htmlspecialchars(trim($_POST['ownerLastName']));
    $fname = htmlspecialchars(trim($_POST['ownerFirstName']));
    $siretNb = htmlspecialchars(trim($_POST['siretNumber']));
    $tvaNb = htmlspecialchars(trim($_POST['tvaNumber']));
    $company = htmlspecialchars(trim($_POST['companyName']));
    $adress = htmlspecialchars(trim($_POST['autocomplete']));
    $email = htmlspecialchars(trim($_POST['email']));
    $phone = htmlspecialchars(trim($_POST['phone']));
    $description = htmlspecialchars(trim($_POST['description']));
    $type = htmlspecialchars(trim($_POST['companyType']));
    $tags = $_POST['select'] ?: array("Aucun Tag");
    $color = htmlspecialchars(trim(ltrim($_POST['color'],"#")));
    $clickandcollect = isset($_POST['clickandcollect']) ? true : false;
    $livraison = isset($_POST['livraison']) ? true : false; 
    $image_url = htmlspecialchars(trim($_POST['banniere']));
    $longitude = htmlspecialchars(trim($_POST['longitude']));
    $latitude = htmlspecialchars(trim($_POST['latitude']));
    $geohash = $g->encode($latitude,$longitude,9);

    if($_FILES["banniere"]['size'] != 0) {
        $image_url = checkImageParameters($storage, $id);
    }

    // Modifie les valeurs dans la BDD
    if(!isset($_SESSION['status'])){
        $firestore->collection("magasins")->document($id)->update([
            ['path' => 'lname', 'value' => $lname],
            ['path' => 'fname', 'value' => $fname],
            ['path' => 'siretNumber', 'value' => $siretNb],
            ['path' => 'tvaNumber', 'value' => $tvaNb],
            ['path' => 'name', 'value' => $company],
            ['path' => 'adresse', 'value' => $adress],
            ['path' => 'email', 'value' => $email],
            ['path' => 'phone', 'value' => $phone],
            ['path' => 'description', 'value' => $description],
            ['path' => 'type', 'value' => $type],
            ['path' => 'mainCategorie', 'value' => $tags],
            ['path' => 'colorStore', 'value' => $color],
            ['path' => 'ClickAndCollect', 'value' => $clickandcollect],
            ['path' => 'livraison', 'value' => $livraison],
            ['path' => 'position.geopoint', 'value' => new \Google\Cloud\Core\GeoPoint($latitude,$longitude)],
            ['path' => 'position.geohash', 'value' => $geohash],
            ['path' => 'imgUrl', 'value' => $image_url],
        ]);
    }
}

/* PARTIE RESERVEE A LA PAGE COMMANDS
 *  Fonction permettant de modifier l'état d'une commande
 */

if(isset($_POST['accept'])) {
    $ids = htmlspecialchars(trim($_POST['ids']));
    $docId = htmlspecialchars(trim($_POST['docId']));
    $firestore->collection('commandes')->document($ids)->collection('commands')->document($docId)
    ->update([
        ['path' => 'statut', 'value' => 1]
    ]);
}

if(isset($_POST['validate'])) {
    $ids = htmlspecialchars(trim($_POST['ids']));
    $docId = htmlspecialchars(trim($_POST['docId']));
    $firestore->collection('commandes')->document($ids)->collection('commands')->document($docId)
    ->update([
        ['path' => 'statut', 'value' => 2]
    ]);
}

if(isset($_POST['refuse']) or isset($_POST['cancel'])) {
    $ids = htmlspecialchars(trim($_POST['ids']));
    $docId = htmlspecialchars(trim($_POST['docId']));
    $firestore->collection('commandes')->document($ids)->collection('commands')->document($docId)
    ->delete();
}

/* PARTIE RESERVEE A LA PAGE PRODUCTS
 *  Fonctions permettant d'ajouter un produit, de le modifier et de le supprimer'
 */

 if(isset($_POST['add_product'])) {
    $uid = htmlspecialchars(trim($_POST['uid']));

    $name = htmlspecialchars(trim($_POST['productName']));
    $category = htmlspecialchars(trim($_POST['category']));
    $description = htmlspecialchars(trim($_POST['description']));
    $prix= htmlspecialchars(trim($_POST['prix']));
    $quantite = htmlspecialchars(trim($_POST['quantite']));
    $reference = htmlspecialchars(trim($_POST['reference']));
    $visibilite = isset($_POST['visibilite']) ? true : false;
    $uuid = guidv4();

    settype($prix, "double");
    settype($quantite, "integer");
    settype($reference, "integer");

    $data = [
        'categorie' => $category,
        'description' => $description,
        'nom' => $name,
        'prix' => $prix,
        'quantite' => $quantite,
        'reference' => $reference,
        'visible' => $visibilite,
        'id' => $uuid,
    ];

    $firestore->collection('magasins')->document($uid)->collection('produits')->document($uuid)->set($data);
 }

 // Suppression d'un produit
 if(isset($_POST['delete_product'])) {
    $uid = htmlspecialchars(trim($_POST['uid']));
    $docId = htmlspecialchars(trim($_POST['docId']));
    $delete = $firestore->collection('magasins')->document($uid)->collection('produits')->document($docId)->delete();
 }

 // Modification d'un produit

 if(isset($_POST['edit_product'])) {
    $uid = htmlspecialchars(trim($_POST['uid']));
    $docId = htmlspecialchars(trim($_POST['docId']));

    $name = htmlspecialchars(trim($_POST['productName']));
    $category = htmlspecialchars(trim($_POST['category']));
    $description = htmlspecialchars(trim($_POST['description']));
    $prix = htmlspecialchars(trim($_POST['prix']));
    $quantite = htmlspecialchars(trim($_POST['quantite']));
    $reference = htmlspecialchars(trim($_POST['reference']));
    $visibilite = isset($_POST['visibilite']) ? true : false;

    settype($prix, "float");
    settype($quantite, "int");
    settype($reference, "int");

    $firestore->collection('magasins')->document($uid)->collection('produits')->document($docId)->update([
        ['path' => 'nom', 'value' => $name],
        ['path' => 'categorie', 'value' => $category],
        ['path' => 'description', 'value' => $description],
        ['path' => 'prix', 'value' => $prix],
        ['path' => 'quantite', 'value' => $quantite],
        ['path' => 'reference', 'value' => $reference],
        ['path' => 'visible', 'value' => $visibilite],
    ]);
 }
?>

<!-- INCLUS LES PAGES PHP  -->
<?php include('includes/scripts.php'); ?>
<?php include('includes/header.php'); ?>
<?php include('includes/navbar.php'); ?>

<?php include('pages/'.$page.'.php'); ?>
<?php include('includes/footer.php'); ?>


</body>

</html>