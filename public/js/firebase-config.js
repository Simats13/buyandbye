const config = {
    apiKey: "AIzaSyAv2iTNQFg0osczdG_1qaF5pRJmKpyuiw8",
    authDomain: "oficium-11bf9.firebaseapp.com",
    databaseURL: "https://oficium-11bf9-default-rtdb.firebaseio.com",
    projectId: "oficium-11bf9",
    storageBucket: "oficium-11bf9.appspot.com",
    messagingSenderId: "731468105971",
    appId: "1:731468105971:web:5aaf6dc9ba39f0c7034f86",
    measurementId: "G-72T0C89SV6"
  };
  
  export function getFirebaseConfig() {
      if (!config || !config.apiKey) {
        throw new Error('No Firebase configuration object provided.' + '\n' +
        'Add your web app\'s configuration object to firebase-config.js');
      } else {
        return config;
      }
    }