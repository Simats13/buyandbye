'use strict';

import { initializeApp } from 'https://www.gstatic.com/firebasejs/9.6.10/firebase-app.js';
import {
  getFirestore,
  collection,
  addDoc,
  query,
  orderBy,
  limit,
  onSnapshot,
  setDoc,
  updateDoc,
  doc,
  serverTimestamp,
} from 'https://www.gstatic.com/firebasejs/9.6.10/firebase-firestore.js';

import { getFirebaseConfig } from './firebase-config.js';

import { loadDiscussions } from './discussions.js';

// Executé quand le bouton d'envoi d'un message est pressé
function onMessageFormSubmit(e) {
  e.preventDefault();
  // Vérifie qu'un message est écrit
  if (messageInputElement.value) {
    saveMessage(messageInputElement.value).then(function() {
      // Vide le champ texte et désactive le bouton d'envoi
      resetMaterialTextfield(messageInputElement);
      toggleButton();
    });
  }
}

// Enregistre le message dans Firestore
async function saveMessage(messageText) {
  try {
    await addDoc(collection(getFirestore(), 'messages'), {
      name: 'Clément',
      text: messageText,
      timestamp: serverTimestamp()
    });
  }
  catch(error) {
    console.error('Error writing new message to Firebase Database', error);
  }
}

// Charge les messages et écoute de nouveaux messages
function loadMessages(clientID) {
  const recentMessagesQuery = query(collection(getFirestore(), "messages", clientID, "messages"), orderBy('timestamp', 'desc'), limit(12));
  console.log();
  
  // Requête d'écoute
  onSnapshot(recentMessagesQuery, function(snapshot) {
    snapshot.docChanges().forEach(function(change) {
      if (change.type === 'removed') {
        deleteMessage(change.doc.id);
      } else {
        var message = change.doc.data();
        displayMessage(change.doc.id, message.timestamp, message.message, message.imageUrl);
      }
    });
  });
}

// Affiche le message dans la popup
function displayMessage(id, timestamp, text, imageUrl) {
  var div = document.getElementById(id) || createAndInsertMessage(id, timestamp);

  var messageElement = div.querySelector('.message');

  if (text) { // Si le message est du texte
    messageElement.textContent = text;
    messageElement.innerHTML = messageElement.innerHTML.replace(/\n/g, '<br>');
  } else if (imageUrl) { // Si le message est une image
    var image = document.createElement('img');
    image.addEventListener('load', function() {
      messageListElement.scrollTop = messageListElement.scrollHeight;
    });
    image.src = imageUrl + '&' + new Date().getTime();
    messageElement.innerHTML = '';
    messageElement.appendChild(image);
  }

  // Fait défiler jusqu'au nouveau message
  setTimeout(function() {div.classList.add('visible')}, 1);
  messageListElement.scrollTop = messageListElement.scrollHeight;
  messageInputElement.focus();
}

// Supprime l'affichage du message
function deleteMessage(id) {
  var div = document.getElementById(id);
  if (div) {
    div.parentNode.removeChild(div);
  }
}

function createAndInsertMessage(id, timestamp) {
  const container = document.createElement('div');
  container.innerHTML = MESSAGE_TEMPLATE;
  const div = container.firstChild;
  div.setAttribute('id', id);

  // Si le timestamp est nul, on suppose qu'il y a un nouveau message
  // https://stackoverflow.com/a/47781432/4816918
  timestamp = timestamp ? timestamp.toMillis() : Date.now();
  div.setAttribute('timestamp', timestamp);

  // Cherche où insérer le nouveau message
  const existingMessages = messageListElement.children;
  if (existingMessages.length === 0) {
    messageListElement.appendChild(div);
  } else {
    let messageListNode = existingMessages[0];

    while (messageListNode) {
      const messageListNodeTime = messageListNode.getAttribute('timestamp');

      if (!messageListNodeTime) {
        throw new Error(
          `Child ${messageListNode.id} has no 'timestamp' attribute`
        );
      }

      if (messageListNodeTime > timestamp) {
        break;
      }

      messageListNode = messageListNode.nextSibling;
    }

    messageListElement.insertBefore(div, messageListNode);
  }

  return div;
}

// Vide le champ texte
function resetMaterialTextfield(element) {
  element.value = '';
}

// Change l'état du bouton
function toggleButton() {
  if (messageInputElement.value) {
    submitButtonElement.removeAttribute('disabled');
  } else {
    submitButtonElement.setAttribute('disabled', 'true');
  }
}

// Template de message
var MESSAGE_TEMPLATE =
'<div class="message-container">' +
  '<div class="message"></div>' +
  '<div class="timestamp"></div>' +
'</div>';

// Variables de récupération des éléments HTML
var messageListElement = document.getElementById('messages');
var messageFormElement = document.getElementById('message-form');
var messageInputElement = document.getElementById('message');
var submitButtonElement = document.getElementById('submit');

// Etat du bouton d'envoi
messageInputElement.addEventListener('keyup', toggleButton);
messageInputElement.addEventListener('change', toggleButton);

// Enregistre le message envoyé
messageFormElement.addEventListener('submit', onMessageFormSubmit);

const firebaseApp = initializeApp(getFirebaseConfig());
loadMessages("D8Sj8ggWF90yid1azab8");
loadDiscussions();

/*
La div "discussions" contient toutes les différentes conversations entre un professionnel et un client
Chaque div enfant a pour id celui de la conversation (à terme idPro + idClient)
Il faut arriver à faire passer cet ID à la fonction loadMessages pour faire appel au bon document
*/