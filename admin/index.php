<?php
include('../auth.php');
// include('includes/main-functions.php'); 

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

#Fonction permettant de supprimer une entreprise dans la BDD Firebase
if(isset($_POST['delete_listing']))
{
    $collectionReference = $firestore->collection('test');
    $documents = $collectionReference->documents();
    $doc = $_POST['delete_listing'];
    $deleteResult = $collectionReference->document($doc)->delete();
    if($deleteResult)
    {
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


if(isset($_POST['edit_listing'])){
    // print_r($_POST);
    $email = htmlspecialchars(trim($_POST['companyName']));
    $adress = htmlspecialchars(trim($_POST['autocomplete']));
    $description = htmlspecialchars(trim($_POST['description']));
    $color = htmlspecialchars(trim($_POST['color']));
    $clickandcollect = htmlspecialchars(trim($_POST['clickandcollect']));
    print_r($clickandcollect);
    $target_file = $_FILES["banniere"]["name"];
    $uploadOk = 1;
    $imageFileType = strtolower(pathinfo($target_file,PATHINFO_EXTENSION));

// Check if image file is a actual image or fake image
if(isset($_POST["banniere"])) {
    $check = getimagesize($_FILES["banniere"]["tmp_name"]);
    if($check !== false) {
        echo "File is an image - " . $check["mime"] . ".";
        $uploadOk = 1;
    } else {
        echo "File is not an image.";
        $uploadOk = 0;
    }
    }

    // Check file size
    if ($_FILES["banniere"]["size"] > 500000) {
    echo "Sorry, your file is too large.";
    $uploadOk = 0;
    }

    // Allow certain file formats
    if($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg"
    && $imageFileType != "gif" ) {
    echo "Sorry, only JPG, JPEG, PNG & GIF files are allowed.";
    $uploadOk = 0;
    }

    // Check if $uploadOk is set to 0 by an error
    if ($uploadOk == 0) {
    echo "Sorry, your file was not uploaded.";
    // if everything is ok, try to upload file
    } else {
        $anotherBucket = $storage->getBucket('la-petite-camargue.appspot.com');
        $anotherBucket->upload(
            file_get_contents($_FILES['banniere']['tmp_name']),
            [
                'name' => "$id/banniere.".$imageFileType
            ]
        );
        $id = $_POST['edit_listing'];
        $image_url = "https://firebasestorage.googleapis.com/v0/b/la-petite-camargue.appspot.com/o/$id%2Fbanniere.$imageFileType?alt=media";      
    }

    // $data = [
        //     'name' => 'Los Angeles',
        //     'state' => 'CA',
        //     'country' => 'USA'
        // ];
        // $db->collection('samples/php/cities')->document('LA')->set($data);
}

    
?>

<!-- INCLUS LES PAGES PHP  -->
<?php include('includes/header.php');  ?>
<?php include('includes/navbar.php'); ?>

    <?php
    include('pages/'.$page.'.php');
    ?>



<?php include('includes/footer.php'); ?>

</body>
</html>
