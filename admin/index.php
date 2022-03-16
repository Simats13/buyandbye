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

/* PARTIE RESERVEE A LA PAGE LISTING
 * Fonction permettant de supprimer une entreprise dans la BDD Firebase
 * Fonction permettant d'éditer une entreprise dans la BDD Firebase
 */

 /* Suppression d'une entreprise */
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

/* Edition d'une entreprise */
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
    $livraison = isset($_POST['livraison']) ? true : false;
    $siretnumber = htmlspecialchars(trim($_POST['siretNumber']));
    $tvanumber = htmlspecialchars(trim($_POST['tvaNumber']));
    $color = htmlspecialchars(trim(ltrim($_POST['color'],"#")));
    $description = htmlspecialchars(trim($_POST['description']));
    $longitude = htmlspecialchars(trim($_POST['longitude']));
    $latitude = htmlspecialchars(trim($_POST['latitude']));
    $type = htmlspecialchars(trim($_POST['companyType']));
    $password = randomPassword();
    $count = 0;
    if(isset($_POST['select'])){
        $tags = $_POST['select'];
    }else{
        $tags = array("Aucun Tag");
    }

    $geohash = $g->encode($latitude,$longitude,9);

    //Création de l'utilisateur sur Firebase
    $userProperties = [
        'email' => $mail,
        'emailVerified' => false,
        'password' => $password,
        'displayName' => $firstname.' '.$lastname,
        'disabled' => false,
    ];
    try {
        $createdUser = $auth->createUser($userProperties); // Création de l'utilisateur sur Firebase avec les propriétés en haut
        try {
            
            $user = $auth->getUserByEmail($mail);
            $uid = $user->uid;
            $auth->setCustomUserClaims($uid, ['shop' => true,]);
        } catch (Kreait\Firebase\Exception\Auth\UserNotFound $e) {
            
            $_SESSION['status'] = "Erreur";
            header("Location:?page=add");
        } catch (Exception $e) {
            
            $_SESSION['status'] = "Erreur";
            header("Location:?page=add");
        }   
    } catch (Kreait\Firebase\Exception\Auth\EmailExists $e){
        
        $_SESSION['status'] = "L'adresse mail que vous avez entré existe déjà <br>  ERROR C-01";
        // header("Location:?page=add");

    }
    catch (Exception $e) {
        echo $e->getMessage();
        $_SESSION['status'] = "Erreur";
    }
   
    


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
            'count' => $count,
            'isPhoneVisible' => $isphonevisible,
            'siretNumber' => $siretnumber,
            'tvaNumber' => $tvanumber,
            'colorStore' => $color,
            'description' => $description,
            'position' => ['geohash' => $geohash, 'geopoint' => new \Google\Cloud\Core\GeoPoint($latitude,$longitude)],
            'mainCategorie' => $tags,
            'type' => $type,
        ];
        
        $firestore->collection('magasins')->document($uid)->set($data);
   

        if($_FILES["banniere"]['size'] != 0){
            $image_url = checkImageParameters($storage, $uid) ?: "https://www.themeta.news/wp-content/themes/meta/img/noimage.jpg";
        }else{
            $image_url = "https://www.themeta.news/wp-content/themes/meta/img/noimage.jpg";
        }
       
        $firestore->collection('magasins')->document($uid)->update([
            ['path' => 'imgUrl', 'value' => $image_url],
            ['path' => 'id', 'value' => $uid]
        ]);

        $_SESSION['success'] = "L'entreprise a correctement été créée !";
        $tag = implode(",", $tags); //Conversion du tableau tags en chaîne de caractère
        // Envoi automatique de mail
        $mails = new PHPMailer(true);
        $mails->IsSMTP();
        $mails->Host = 'ssl://mail.buyandbye.fr';          //Adresse IP ou DNS du serveur SMTP
        $mails->Port = 465;                                //Port TCP du serveur SMTP
        $mails->SMTPAuth = 1;                              //Utiliser l'identification
        //$mail->SMTPDebug = 2;                           // enables SMTP debug information (for testing)

        if($mails->SMTPAuth){
        $mails->SMTPSecure = 'ssl';                      //Protocole de sécurisation des échanges avec le SMTP
        $mails->Username   = 'no-reply@buyandbye.fr';    //Adresse email à utiliser
        $mails->Password   = '0Wz7Bg&n(}-lOjn3NJ';       //Mot de passe de l'adresse email à utiliser
        }

        $mails->CharSet  = 'UTF-8';
        $mails->From     = 'no-reply@buyandbye.fr';        //L'email à afficher pour l'envoi
        $mails->FromName = 'Mail automatique Buy&Bye';     //L'alias à afficher pour l'envoi

        $mails->Subject  = 'Création de boutique Bye&Bye'; //Le sujet du mail
        $mails->WordWrap = 50; 			                  //Nombre de caracteres pour le retour a la ligne automatique
        $mails->MsgHTML("
            
    <!doctype html>
    <html lang='fr-FR'>

    <head>
        <meta content='text/html; charset=utf-8' http-equiv='Content-Type' />
        <title>Ajout de votre boutique #INSERER_NOM - Petite Camargue</title>
        <meta name='description' content='Modification du Mot de Passe - Petite Camargue'>
        <style type='text/css'>
            a:hover {text-decoration: underline !important;}
        </style>
    </head>

    <body marginheight='0' topmargin='0' marginwidth='0' style='margin: 0px; background-color: #f2f3f8;' leftmargin='0'>
        <!--100% body table-->
        <table cellspacing='0' border='0' cellpadding='0' width='100%' bgcolor='#f2f3f8'
            style='@import url(https://fonts.googleapis.com/css?family=Rubik:300,400,500,700|Open+Sans:300,400,600,700); font-family: Open Sans, sans-serif;'>
            <tr>
                <td>
                    <table style='background-color: #f2f3f8; max-width:670px;  margin:0 auto;' width='100%' border='0'
                        align='center' cellpadding='0' cellspacing='0'>
                        <tr>
                            <td style='height:80px;'>&nbsp;</td>
                        </tr>
                        <tr>
                            <td style='text-align:center;'>
                            <a href='http://localhost' title='logo' target='_blank'>
                                <img width='200' height='200' src='https://firebasestorage.googleapis.com/v0/b/oficium-11bf9.appspot.com/o/assets%2Ficon.png?alt=media&token=9fda9e86-7943-4395-ae4e-76eda2c09479' title='logo' alt='logo'>
                            </a>
                            </td>
                        </tr>
                        <tr>
                            <td style='height:20px;'>&nbsp;</td>
                        </tr>
                        <tr>
                            <td>
                                <table width='95%' border='0' align='center' cellpadding='0' cellspacing='0'
                                    style='max-width:670px;background:#fff; border-radius:3px; text-align:center;-webkit-box-shadow:0 6px 18px 0 rgba(0,0,0,.06);-moz-box-shadow:0 6px 18px 0 rgba(0,0,0,.06);box-shadow:0 6px 18px 0 rgba(0,0,0,.06);'>
                                    <tr>
                                        <td style='height:40px;'>&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td style='padding:0 35px;'>
                                            <h1 style='color:#1e1e2d; font-weight:500; margin:0;font-size:32px;font-family:Rubik,sans-serif;'>Récapitulatif de vos informations</h1>
                                            <span
                                                style='display:inline-block; vertical-align:middle; margin:29px 0 26px; border-bottom:1px solid #cecece; width:100px;'></span>
                                                <p style='color:#455056; font-size:15px;line-height:24px; margin:0;text-align: justify;'>
                                                    Voici un récapitulatif de toutes les informations qui ont été renseignées lors de l'inscription sur le site. Vous pouvez les modifier à tout moment depuis votre espace personnel. <strong> Certaines informations n'appaîtront pas sur l'application mobile ! </strong>
                                                </p>
                                                <h2 style='display: flex;'>Identifiants de Connexion : </h2>
                                                <ul style='display: table;text-align: left;'>
                                                    <li>Email : $mail </li>
                                                    <li>Mot de Passe : $password </li>
                                                </ul>
                                                <h2 style='display: flex;'>Informations Personnels : </h2>

                                            <ul style='display: table;text-align: left;'>
                                                <li>Nom : $lastname </li>
                                                <li>Prénom : $firstname</li>
                                                <li>Adresse Email : $mail </li>
                                                <li>Téléphone : $enterprisephone</li>

                                            </ul>
                                            <h2 style='display: flex; text-align: left;'>Informations de votre Entreprise : </h2>
                                            <ul style='display: table; text-align: left;'>
                                                <li>Nom de l'Entreprise : $enterprisename </li>
                                                <li>Adresse de l'Entreprise : $autocomplete </li>
                                                <li>Type d'Entreprise : $type</li>
                                                <li>Numéro de Siret : $siretnumber </li>
                                                <li>Numéro de TVA : $tvanumber </li>
                                                <li>Description : $description</li>
                                                <li>Livraison à domicile : ".($livraison == true ? "Oui" : "Non")."</li>
                                                <li>Téléphone visible sur l'application : ".($isphonevisible == true ? "Oui" : "Non")." </li>
                                                <li>Tags associés : $tag </li>
                                                <li>Couleur de l'Entreprise : <input type='color' class='form-control form-control-color' name='color' id='exampleColorInput'
                                                    style='width:30px; height: 30px;' value='$color' disabled='disabled' ></li>
                                                <li>Bannière de l'Entreprise :   <ul><li style='list-style-type: none;'><img height='200' src='$image_url' alt=''></li></ul> </li>
                                            </ul>
                                            
                                            <a href='http://localhost'
                                                style='background:#6675df;text-decoration:none !important; font-weight:500; margin-top:35px; color:#fff;text-transform:uppercase; font-size:14px;padding:10px 24px;display:inline-block;border-radius:50px;'>Modifier
                                                ma boutique</a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style='height:40px;'>&nbsp;</td>
                                    </tr>
                                </table>
                            </td>
                        <tr>
                            <td style='height:20px;'>&nbsp;</td>
                        </tr>
                        <tr>
                            <td style='text-align:center;'>
                                <p style='font-size:14px; color:rgba(69, 80, 86, 0.7411764705882353); line-height:18px; margin:0 0 0;'>&copy; <strong>Buy & Bye</strong></p>
                            </td>
                        </tr>
                        <tr>
                            <td style='height:80px;'>&nbsp;</td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <!--/100% body table-->
    </body>

    </html>
        ");
        $mails->IsHTML(true);

        $mails->AddAddress($_POST['email']);
        $mails->send();

        /*if(!$mail->send()) {
            echo 'Mailer Error: ' . $mail->ErrorInfo;
        } else {
            echo 'Message has been sent';
        }*/    
    }



    
}
?>

<!-- INCLUS LES PAGES PHP  -->
<?php include('includes/scripts.php'); ?>
<?php include('includes/header.php'); ?>
<?php include('includes/navbar.php'); ?>

<?php include('pages/'.$page.'.php');?>
<?php include('includes/footer.php'); ?>


</body>

</html>