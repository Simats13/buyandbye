<?php 
session_start();

include("../config/dbconfig.php");
use Kreait\Firebase\Exception\Auth\FailedToVerifyToken;
use Kreait\Firebase\Exception\Auth\FailedToVerifySessionCookie;

if(isset($_SESSION['cookie'])){
    $sessionCookieString = $_SESSION['cookie'];
    try {
        $verifiedSessionCookie = $auth->verifySessionCookie($sessionCookieString);
            
        $uid = $verifiedSessionCookie->claims()->get('sub');
        
        $user = $auth->getUser($uid);
    } 
    
    catch(InvalidToken $e)
    {
        
        $_SESSION['expiry_status'] = "Votre session a expiré, veuillez vous authentifier de nouveau !";
        header("Location:/admin/logout.php");
        exit();
    }

    // catch(InvalidArgumentException $e)
    // {
       
    //     $_SESSION['expiry_status'] = "Votre session a expiré, veuillez vous authentifier de nouveau !";
    //     header("Location:/admin/logout.php");
    //     exit();
    // } 
    
    catch (FailedToVerifyToken $e) {
       
        $_SESSION['expiry_status'] = "Votre session a expiré, veuillez vous authentifier de nouveau !";
        header("Location:/admin/logout.php");
        exit();
    }
    
    catch (FailedToVerifySessionCookie $e) {
        $_SESSION['expiry_status'] = "Votre session a expiré, veuillez vous authentifier de nouveau !";
        header("Location:/admin/logout.php");
        exit();
    }
    
    catch(\Kreait\Firebase\Exception\Auth\UserNotFound $e)
    {
        $_SESSION['expiry_status'] = "Utilisateur introuvable, veuillez vous authentifier de nouveau ou créer un compte !";
        header("Location:/admin/logout.php");
        exit();
    }

    catch(Exception $e){
        $_SESSION['expiry_status'] = "Utilisateur introuvable, veuillez vous authentifier de nouveau ou créer un compte !";
        header("Location:/admin/logout.php");
        exit();
    }

}else{
    if(isset($_SESSION['verified_user_id']))
    {
        $uid = $_SESSION['verified_user_id'];
        $idTokenString = $_SESSION['idToken'];
    
        
        
            try
            {
                $verifiedIdToken = $auth->verifyIdToken($idTokenString);
                $uid = $verifiedIdToken->claims()->get('sub');
        
                $user = $auth->getUser($uid);
            }
            catch(InvalidToken $e)
            {
                $_SESSION['expiry_status'] = "Votre session a expiré, veuillez vous authentifier de nouveau !";
                header("Location:/admin/logout.php");
                exit();
            }
            catch(InvalidArgumentException $e)
            {
                $_SESSION['expiry_status'] = "Votre session a expiré, veuillez vous authentifier de nouveau !";
                header("Location:/admin/logout.php");
                exit();
            } catch (FailedToVerifyToken $e) {
                $_SESSION['expiry_status'] = "Votre session a expiré, veuillez vous authentifier de nouveau !";
                header("Location:/admin/logout.php");
                exit();
            }catch(Kreait\Firebase\Exception\Auth\UserNotFound $e)
            {
                $_SESSION['expiry_status'] = "Utilisateur introuvable, veuillez vous authentifier de nouveau ou créer un compte !";
                header("Location:/admin/logout.php");
                exit();
            }
            catch(Exception $e){
                $_SESSION['expiry_status'] = "Utilisateur introuvable, veuillez vous authentifier de nouveau ou créer un compte !";
                header("Location:/admin/logout.php");
                exit();
            }
        
    
       
       
    
    }else{
        $_SESSION['status'] = "Veuillez vous authenfier afin d'accéder à la page demandée";
        header("Location:../index.php");
        exit();
    }
}





?>