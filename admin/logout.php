<?php
// Initialize the session
// include('../auth.php');
session_start();
 
unset($_SESSION['verified_user_id']);
unset($_SESSION['idToken']);
unset($_SESSION['status']);

if(isset($_SESSION['expiry_status']))
{
    $_SESSION['status'] = "La session a expiré, veuillez vous authentifier de nouveau !";
    unset($_SESSION['expiry_status']);
}else{
    $_SESSION['success'] = "Vous êtes déconnecté !";

}
  
// Redirect to login page
header("location: ../");
exit();
?>