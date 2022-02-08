<?php 
session_start();
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;
include('config/dbconfig.php');
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
if(isset($_SESSION['cookie'])){
	$_SESSION['status'] = "Vous êtes déjà connecté";
	header('Location: /admin/index.php');
	exit();
}else{
	if(isset($_SESSION['verified_user_id']))
	{
		$_SESSION['status'] = "Vous êtes déjà connecté";
		header('Location: /admin/index.php');
		exit();
	}
}




if(isset($_POST['login']))
{
    $email = htmlspecialchars(trim($_POST['email']));
    $password = htmlspecialchars(trim($_POST['password']));
	$fiveMinutes = 300;
	$oneWeek = new \DateInterval('P7D');
	$cookie = isset($_POST['remember-me']) ? true : false; 
    

    try
    {
        $user = $auth->getUserByEmail($email);
        try
        {
            $signInResult = $auth->signInWithEmailAndPassword($email, $password);
            $idTokenString = $signInResult->idToken();

			if($cookie == true){
				$sessionCookieString = $auth->createSessionCookie($idTokenString, $oneWeek);
				try {
					$verifiedSessionCookie = $auth->verifySessionCookie($sessionCookieString);
					$uid = $verifiedSessionCookie->claims()->get('sub');
					$_SESSION['cookie'] = $sessionCookieString;
					$_SESSION['verified_user_id'] = $uid;
					$_SESSION['status'] = "Connexion réussie !";
					header('Location: /admin/index.php');
					exit();
				} catch (\Kreait\Firebase\Exception\Auth\FailedToCreateSessionCookie $e) {
					echo $e->getMessage();
					$_SESSION['status'] = "Erreur, veuillez réessayer ultérieurement";
					header('Location: /');
					// exit();
				} catch(\Kreait\Firebase\Exception\Auth\FailedToVerifySessionCookie $e){
					echo $e->getMessage();
					$_SESSION['status'] = "Erreur, veuillez réessayer ultérieurement";
					header('Location: /');
					// exit();
				}
			}else{
				try {
					$verifiedIdToken = $auth->verifyIdToken($idTokenString, false);
					$uid = $verifiedIdToken->claims()->get('sub');
					$_SESSION['verified_user_id'] = $uid;
					$_SESSION['idToken'] = $idTokenString;
					$_SESSION['status'] = "Connexion réussie !";
					header('Location: /admin/index.php');
					exit();
				} catch (\Kreait\Firebase\Exception\Auth\FailedToVerifyToken $e) 
				{
					echo $e->getMessage();
					$_SESSION['status'] = "Erreur, veuillez réessayer ultérieurement";
					header('Location: /');
					// exit();
				}catch (\Kreait\Firebase\Exception\Auth\IssuedInTheFuture $e)
				{
					echo $e->getMessage();
					$verifiedIdToken = (new Parser())->parse($this->idToken);
				}
				return $verifiedIdToken->getClaims();
			}


            

        }
		
        catch(\Kreait\Firebase\Exception\Auth\FailedToVerifySessionCookie $e)
        {
			echo $e->getMessage();
            $_SESSION['status'] = "Erreur, veuillez réessayer ultérieurement";
            header('Location:/');
            // exit();
        }
		catch(Exception $e)
	{
		echo $e->getMessage();
		$_SESSION['status'] = "Erreur, veuillez réessayer ultérieurement";
		header('Location:/');
		// exit();
	}
   
    } 
    catch(\Kreait\Firebase\Exception\Auth\UserNotFound $e)
    {
		
        $_SESSION['status'] = "Mauvais couple d'identifiants, veuillez réessayer !";
        header('Location:/');
        exit();
    }catch (\Kreait\Firebase\Auth\SignIn\FailedToSignIn $e){
		$_SESSION['status'] = "Mauvais couple d'identifiants, veuillez réessayer !";
        header('Location:/');
        exit();
	}catch(Exception $e)
	{
		echo $e->getMessage();
		$_SESSION['status'] = "Mauvais couple d'identifiants, veuillez réessayer !";	
		header('Location:/');
		exit();
	}
	
	
    
    

}

if(isset($_POST['reset'])){
	$email = htmlspecialchars(trim($_POST['email']));
	$link = $auth->getPasswordResetLink($email);
	$url = parse_url($link);
	parse_str($url['query'], $parms);
	$oobCode = $parms['oobCode'];
	$lien = "localhost/?page=reset_confirm&oobCode=$oobCode";
	$_SESSION['success'] = "L'email a bien été envoyé !";
	 // Envoi automatique de mail
	 $mail = new PHPMailer(true);
	 $mail->IsSMTP();
	 $mail->Host = 'ssl://mail.buyandbye.fr';          //Adresse IP ou DNS du serveur SMTP
	 $mail->Port = 465;                                //Port TCP du serveur SMTP
	 $mail->SMTPAuth = 1;                              //Utiliser l'identification
	 //$mail->SMTPDebug = 2;                           // enables SMTP debug information (for testing)
 
	 if($mail->SMTPAuth){
	   $mail->SMTPSecure = 'ssl';                      //Protocole de sécurisation des échanges avec le SMTP
	   $mail->Username   = 'no-reply@buyandbye.fr';    //Adresse email à utiliser
	   $mail->Password   = '0Wz7Bg&n(}-lOjn3NJ';       //Mot de passe de l'adresse email à utiliser
	 }
 
	 $mail->CharSet  = 'UTF-8';
	 $mail->From     = 'no-reply@buyandbye.fr';        //L'email à afficher pour l'envoi
	 $mail->FromName = 'Mail automatique Buy&Bye';     //L'alias à afficher pour l'envoi
 
	 $mail->Subject  = 'Rénitialisation Mot de Passe boutique Bye&Bye'; //Le sujet du mail
	 $mail->WordWrap = 50; 			                  //Nombre de caracteres pour le retour a la ligne automatique
	 $mail->MsgHTML("
		 
		<!doctype html>
		<html lang='fr-FR'>

		<head>
			<meta content='text/html; charset=utf-8' http-equiv='Content-Type' />
			<title>Modification du Mot de Passe - Petite Camargue</title>
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
									<img width='200' height='200' src='https://firebasestorage.googleapis.com/v0/b/la-petite-camargue.appspot.com/o/assets%2Flogo%2Fcamargue.png?alt=media&token=8a6c0b55-fa07-4121-a2df-07ff2bc74fb6' title='logo' alt='logo'>
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
												<h1 style='color:#1e1e2d; font-weight:500; margin:0;font-size:32px;font-family:Rubik,sans-serif;'>Rénitialisation de votre mot de passe</h1>
												<span
													style='display:inline-block; vertical-align:middle; margin:29px 0 26px; border-bottom:1px solid #cecece; width:100px;'></span>
												<p style='color:#455056; font-size:15px;line-height:24px; margin:0;'>
													Si vous souhaitez rénitialiser votre mot de passe veuillez cliquer sur le lien ci-dessous. Si vous en avez pas fait la demande, veuillez ne pas prendre compte de cet email.
												</p>
												<a href='$lien'
													style='background:#6675df;text-decoration:none !important; font-weight:500; margin-top:35px; color:#fff;text-transform:uppercase; font-size:14px;padding:10px 24px;display:inline-block;border-radius:50px;'>Modifier
													mon Mot de Passe</a>
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
									<p style='font-size:14px; color:rgba(69, 80, 86, 0.7411764705882353); line-height:18px; margin:0 0 0;'>&copy; <strong>La Petite Camargue</strong></p>
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
	 $mail->IsHTML(true);
 
	 $mail->AddAddress($email);
	 $mail->send();
 
	header('Location: ../../');
	exit();


}

if(isset($_POST['resetConfirm'])){

	$oobCode = $_POST['resetConfirm']; // Extract the OOB code from the request url (not scope of the SDK (yet :)))
	$newPassword = htmlspecialchars(trim($_POST['password2']));
	$invalidatePreviousSessions = true; // default, will revoke current user refresh tokens

	try {
		$auth->confirmPasswordReset($oobCode, $newPassword, $invalidatePreviousSessions);
		$_SESSION['success'] = "Votre mot de passe a bien été changé !";
		header('Location: ../../');
		exit();
	} catch (\Kreait\Firebase\Exception\Auth\ExpiredOobCode $e) {
		// Handle the case of an expired reset code
		$_SESSION['status'] = "Votre demande de réinitialisation du mot de passe a expiré ou ce lien a déjà été utilisé.
		Veuillez en refaire la demande.";
		header('Location: ../../');
		exit();
	} catch (\Kreait\Firebase\Exception\Auth\InvalidOobCode $e) {
		// Handle the case of an invalid reset code
		$_SESSION['status'] = "Votre demande de réinitialisation du mot de passe a expiré ou ce lien a déjà été utilisé.
		Veuillez en refaire la demande.";
		header('Location: ../../');
		exit();
	} catch (\Kreait\Firebase\Exception\AuthException $e) {
		// Another error has occurred
		$_SESSION['status'] = "Votre demande de réinitialisation du mot de passe a expiré ou ce lien a déjà été utilisé.
		Veuillez en refaire la demande.";
		header('Location: ../../');
		exit();
	}

}




?>
<!DOCTYPE html>
<html lang="en">
<head>
	<title>Panel Admin - Petite Camargue</title>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
<!--===============================================================================================-->	
	<link rel="icon" type="image/png" href="images/icons/favicon.ico"/>
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="vendor/bootstrap/css/bootstrap.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="fonts/font-awesome-4.7.0/css/font-awesome.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="fonts/Linearicons-Free-v1.0.0/icon-font.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="vendor/animate/animate.css">
<!--===============================================================================================-->	
	<link rel="stylesheet" type="text/css" href="vendor/css-hamburgers/hamburgers.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="vendor/animsition/css/animsition.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="vendor/select2/select2.min.css">
<!--===============================================================================================-->	
	<link rel="stylesheet" type="text/css" href="vendor/daterangepicker/daterangepicker.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="css/util.css">
	<link rel="stylesheet" type="text/css" href="css/main.css">
<!--===============================================================================================-->
</head>
<body style="background-color: #666666;">
	
	<div class="limiter">
		<div class="container-login100">
			<div class="wrap-login100">

				<?php include('pages/'.$page.'.php');?>

				<div class="login100-more" style="background-image: url('images/background.jpg');">
				</div>
			</div>
		</div>
	</div>
	
	

	
	
<!--===============================================================================================-->
	<script src="vendor/jquery/jquery-3.2.1.min.js"></script>
<!--===============================================================================================-->
	<script src="vendor/animsition/js/animsition.min.js"></script>
<!--===============================================================================================-->
	<script src="vendor/bootstrap/js/popper.js"></script>
	<script src="vendor/bootstrap/js/bootstrap.min.js"></script>
<!--===============================================================================================-->
	<script src="vendor/select2/select2.min.js"></script>
<!--===============================================================================================-->
	<script src="vendor/daterangepicker/moment.min.js"></script>
	<script src="vendor/daterangepicker/daterangepicker.js"></script>
<!--===============================================================================================-->
	<script src="vendor/countdowntime/countdowntime.js"></script>
<!--===============================================================================================-->
	<script src="js/main.js"></script>

</body>
</html>