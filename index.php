<?php 
session_start();
include('config/dbconfig.php');
if(isset($_SESSION['verified_user_id']))
{
    $_SESSION['status'] = "Vous êtes déjà connecté";
    header('Location: /admin/index.php');
    exit();
}


if(isset($_POST['login']))
{
    $email = htmlspecialchars(trim($_POST['email']));
    $password = htmlspecialchars(trim($_POST['password']));
	
    

    try
    {
        $user = $auth->getUserByEmail($email);
        try
        {
            $signInResult = $auth->signInWithEmailAndPassword($email, $password);
            $idTokenString = $signInResult->idToken();

			echo $idTokenString;


            try {
                $verifiedIdToken = $auth->verifyIdToken($idTokenString, false);
                $uid = $verifiedIdToken->claims()->get('sub');
                $_SESSION['verified_user_id'] = $uid;
                $_SESSION['idToken'] = $idTokenString;
                $_SESSION['status'] = "Connexion réussie !";
                header('Location: /admin/index.php');
                exit();
            } catch (FailedToVerifyToken $e) 
			{
				
                $_SESSION['status'] = "Erreur, veuillez réessayer ultérieurement";
                header('Location: /');
                exit();
            }catch (IssuedInTheFuture $e)
			{
				$verifiedIdToken = (new Parser())->parse($this->idToken);
			}
			return $verifiedIdToken->getClaims();

        }
		
        catch(Exception $e)
        {
			echo $e->getMessage();
            $_SESSION['status'] = "Mauvais couple d'identifiants, veuillez réessayer !";
			
            // header('Location:/');
            // exit();
        } 
   
    } 
    catch(\Kreait\Firebase\Exception\Auth\UserNotFound $e)
    {
        $_SESSION['status'] = "Mauvais couple d'identifiants, veuillez réessayer !";
        header('Location:/');
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
				<form class="login100-form validate-form" method="post">
					<span class="login100-form-title p-b-43">
						Panel Administration
                       <br> Petite Camargue
					</span>

                    <?php 
                    if(isset($_SESSION['status'])){
                        echo "<h5 class='alert alert-danger'>".$_SESSION['status']."</h5>";
                        unset($_SESSION['status']);
                    }

					if(isset($_SESSION['success'])){
                        echo "<h5 class='alert alert-success'>".$_SESSION['success']."</h5>";
                        unset($_SESSION['success']);
                    }
                    
                    ?>
                    <span class="login100-form-title p-b-43">
						
					</span>
					
					
					<div class="wrap-input100 validate-input" data-validate = "Veuillez entrer une adresse e-mail valide : ex@abc.xyz">
						<input class="input100" type="text" name="email">
						<span class="focus-input100"></span>
						<span class="label-input100">Email</span>
					</div>
					
					
					<div class="wrap-input100 validate-input" data-validate="Veuillez entrer un mot de passe">
						<input class="input100" type="password" name="password">
						<span class="focus-input100"></span>
						<span class="label-input100">Mot de passe</span>
					</div>

					<div class="flex-sb-m w-full p-t-3 p-b-32">
						<div class="contact100-form-checkbox">
							<input class="input-checkbox100" id="ckb1" type="checkbox" name="remember-me">
							<label class="label-checkbox100" for="ckb1">
								Se souvenir de moi
							</label>
						</div>

						<div>
							<a href="#" class="txt1">
								Mot de passe oublié ?
							</a>
						</div>
					</div>
			

					<div class="container-login100-form-btn">
						<button class="login100-form-btn" name="login">
							Connexion
						</button>
					</div>
					
		
				</form>

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