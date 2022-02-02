<?php
use Sk\Geohash\Geohash;

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

/** PARTIE RESERVEE A LA PAGE LISTING
 *  Fonction permettant de supprimer une entreprise dans la BDD Firebase
 *  Fonction permettant d'éditer une entreprise dans la BDD Firebase
 */

 /**Suppression d'une entreprise */
if(isset($_POST['delete_listing']))
{
    $collectionReference = $firestore->collection('test');
    $documents = $collectionReference->documents();
    $doc = $_POST['delete_listing'];
    $deleteResult = $collectionReference->document($doc)->delete();
    if($deleteResult)
    {
        $auth->deleteUser($doc);
        $_SESSION['status'] = "Entreprise supprimée";
        header('Location: ?page=listing');
        exit();
    }else
    {
        $_SESSION['status'] = "L'entreprise n'a pas été supprimée";
        header('Location: ?page=listing');
        exit();
    }
}

/**Edition d'une entreprise */
if(isset($_POST['edit_listing'])){
    $g = new Geohash();
    $id = $_POST['edit_listing'];
    $name = htmlspecialchars(trim($_POST['companyName']));
    $email = htmlspecialchars(trim($_POST['email']));
    $adress = htmlspecialchars(trim($_POST['autocomplete']));
    $description = htmlspecialchars(trim($_POST['description']));
    $color = htmlspecialchars(trim(ltrim($_POST['color'],"#")));
    $clickandcollect = isset($_POST['clickandcollect']) ? true : false;
    $livraison = isset($_POST['livraison']) ? true : false; 
    $image_url = htmlspecialchars(trim($_POST['old_banniere']));
    $phone = htmlspecialchars(trim($_POST['phone']));
    $longitude = htmlspecialchars(trim($_POST['longitude']));
    $latitude = htmlspecialchars(trim($_POST['latitude']));
    $type = htmlspecialchars(trim($_POST['companyType']));
    $tags = $_POST['select'] ?: array("Aucun Tag");
    $geohash = $g->encode($latitude,$longitude,9);

    if($_FILES["banniere"]['size'] != 0) {
        $image_url = checkImageParameters($storage, $id);
    }

    // Modifie les valeurs dans la BDD
    if(!isset($_SESSION['status'])){
 
        // $properties = [
        //     'displayName' => $name,
        //     'email' => $email,
        // ];

        // $updatedUser = $auth->updateUser($id, $properties);
 

        $firestore->collection("magasins")->document($id)->update([
            ['path' => 'ClickAndCollect', 'value' => $clickandcollect],
            ['path' => 'adresse', 'value' => $adress],
            ['path' => 'email', 'value' => $email],
            ['path' => 'imgUrl', 'value' => $image_url],
            ['path' => 'livraison', 'value' => $livraison],
            ['path' => 'name', 'value' => $name],
            ['path' => 'phone', 'value' => $phone],
            ['path' => 'description', 'value' => $description],
            ['path' => 'colorStore', 'value' => $color],
            ['path' => 'type', 'value' => $type],
            ['path' => 'mainCategorie', 'value' => $tags],
            ['path' => 'position.geopoint', 'value' => new \Google\Cloud\Core\GeoPoint($latitude,$longitude)],
            ['path' => 'position.geohash', 'value' => $geohash],
        ]);
    }
}

/** PARTIE RESERVEE A LA PAGE ADD
 *  Fonction permettant d'ajouter une entreprise dans la BDD Firebase
 */

if(isset($_POST['add_enterprise'])){
    $g = new Geohash();
    $lastname = htmlspecialchars(trim($_POST['ownerLastName']));
    $firstname = htmlspecialchars(trim($_POST['ownerFirstName']));
    $mail = htmlspecialchars(trim($_POST['email']));
    $enterprisename = htmlspecialchars(trim($_POST['enterpriseName']));
    $autocomplete = htmlspecialchars(trim($_POST['autocomplete']));
    $enterprisephone = htmlspecialchars(trim($_POST['enterprisePhone']));
    $isphonevisible = isset($_POST['isPhoneVisible']) ? true : false;
    $isrestaurant = isset($_POST['isRestaurant']) ? true : false;
    $livraison = isset($_POST['livraison']) ? true : false;
    $siretnumber = htmlspecialchars(trim($_POST['siretNumber']));
    $tvanumber = htmlspecialchars(trim($_POST['tvaNumber']));
    $color = htmlspecialchars(trim(ltrim($_POST['color'],"#")));
    $description = htmlspecialchars(trim($_POST['description']));
    $longitude = htmlspecialchars(trim($_POST['longitude']));
    $latitude = htmlspecialchars(trim($_POST['latitude']));
    $type = htmlspecialchars(trim($_POST['companyType']));
    if(isset($_POST['select'])){
        $tags = $_POST['select'];
    }else{
        $tags = array("Aucun Tag");
    }

    $geohash = $g->encode($latitude,$longitude,9);


    if(!isset($_SESSION['status'])){
 // Crée les valeurs dans la BDD
        $data = [
            'Lname' => $lastname,
            'Fname' => $firstname,
            'adresse' => $autocomplete,
            'email' => $mail,
            'name' => $enterprisename,
            'adresse' => $autocomplete,
            'phone' => $enterprisephone,
            'livraison' => $livraison,
            'isPhoneVisible' => $isphonevisible,
            'isRestaurant' => $isrestaurant, //NE SERT PLUS CAR TYPE == RESTAURANT
            'siretNumber' => $siretnumber,
            'tvaNumber' => $tvanumber,
            'colorStore' => $color,
            'description' => $description,
            'position' => ['geohash' => $geohash, 'geopoint' => new \Google\Cloud\Core\GeoPoint($latitude,$longitude)],
            'mainCategorie' => $tags,
            'type' => $type,
        ];
        $doc = $firestore->collection('magasins')->add($data);
        $docId = $doc->id();

        if($_FILES["banniere"]['size'] != 0){
            $image_url = checkImageParameters($storage, $docId) ?: "https://www.themeta.news/wp-content/themes/meta/img/noimage.jpg";
        }else{
            $image_url = "https://www.themeta.news/wp-content/themes/meta/img/noimage.jpg";
        }
       
        
        $firestore->collection('magasins')->document($docId)->update([
            ['path' => 'imgUrl', 'value' => $image_url],
            ['path' => 'id', 'value' => $docId]
        ]);
        
        //Création de l'utilisateur sur Firebase
        $userProperties = [
            'uid' => $docId,
            'email' => $mail,
            'emailVerified' => false,
            'password' => 'azerty',
            'displayName' => $firstname.' '.$lastname,
            'disabled' => false,
        ];
        
        $createdUser = $auth->createUser($userProperties);

        $_SESSION['success'] = "L'entreprise a correctement été créée !";
        
    }

    
}
?>

<!-- INCLUS LES PAGES PHP  -->
<?php include('includes/scripts.php'); ?>
<?php include('includes/header.php'); ?>
<?php include('includes/navbar.php'); ?>

<?php
    include('pages/'.$page.'.php');
    ?>



<?php include('includes/footer.php'); ?>


</body>

</html>