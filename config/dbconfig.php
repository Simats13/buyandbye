<?php 
require __DIR__.'/vendor/autoload.php';
use Kreait\Firebase\Factory;

   // $serviceAccount = ServiceAccount::fromJsonFile('oficium-11bf9-firebase-adminsdk-2w9v8-930d68fc97.json');
   $firebase = (new Factory)
      ->withServiceAccount(__DIR__.'/oficium-11bf9-firebase-adminsdk-2w9v8-930d68fc97.json');
      
   $database = $firebase->createFirestore();

   #Liaison avec la base de donnée firestore
   $firestore = $database->database();

   #Liaison avec le système d'authentification
   $auth = $firebase->createAuth();

   $storage = $firebase->createStorage();





?>