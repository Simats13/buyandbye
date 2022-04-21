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
    const conversationId = document.getElementById('submit').getAttribute('class');
    saveMessage(messageInputElement.value, conversationId).then(function() {
      // Vide le champ texte et désactive le bouton d'envoi
      resetMaterialTextfield(messageInputElement);
      toggleButton();
    });
  }
}

// Enregistre le message dans Firestore
async function saveMessage(messageText, docID) {
  try {
    await addDoc(collection(getFirestore(), "commonData", docID, "messages"), {
      isread: false,
      sentByClient: false,
      message: messageText,
      timestamp: serverTimestamp()
    });

    await updateDoc(doc(getFirestore(), "commonData", docID), {
      lastMessage: messageText,
      timestamp: serverTimestamp()
    });
  }
  catch(error) {
    console.error('Error writing new message to Firebase Database', error);
  }
}

/*
  const button = div.querySelector('.discuss');
  button.addEventListener('click', function test() {
    const oldMessages = document.getElementById('messages');
    oldMessages.innerHTML= '';
    loadMessages(id);

    const sendButton = document.getElementById('submit');
    sendButton.setAttribute('class', id);
  });
*/

// Charge les messages et écoute de nouveaux messages
function loadMessages(docID) {
  const recentMessagesQuery = query(collection(getFirestore(), "commonData", docID, "messages"), orderBy('timestamp', 'desc'), limit(12));
  
  // Requête d'écoute
  onSnapshot(recentMessagesQuery, function(snapshot) {
    snapshot.docChanges().forEach(function(change) {
      if (change.type === 'removed') {
        deleteMessage(change.doc.id);
      } else {
        var message = change.doc.data();
        displayMessage(change.doc.id, message.timestamp, message.message, message.sentByClient, message.imageUrl);
      }
    });
  });
}

function showMessages() {
  $(document).on('click', ".discussion-container", function() {
    var id = $(this).attr("id");
    const oldMessages = document.getElementById('messages');
    oldMessages.innerHTML= '';
    loadMessages(id);

    const sendButton = document.getElementById('submit');
    sendButton.setAttribute('class', id);
  });
}

// Affiche le message dans la popup
function displayMessage(id, timestamp, text, sentByClient, imageUrl) {
  var div = document.getElementById(id) || createAndInsertMessage(id, timestamp);

  if(!sentByClient) {
    div.removeAttribute('class');
    div.setAttribute('class', 'pro-message-container');
  }

  var timestampElement = div.querySelector('.timestamp')
  timestampElement.textContent = formatedTimestamp(timestamp);

  div.querySelector('.discussionPic').setAttribute('src', 'https://devshift.biz/wp-content/uploads/2017/04/profile-icon-png-898.png')

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
  messagesZone.scrollTop = messagesZone.scrollHeight;
  messageInputElement.focus();
}

// Récupère le timestamp Firestore et l'affiche au format DD/MM/YYYY HH:mm:ss
// De base les nombres inférieurs à 10 n'ont pas de 0 au début (ex : 5/1/2000)
// On ajoute donc un 0 devant chaque nombre et on ne conserve que les 2 derniers
function formatedTimestamp(timestamp) {
  var convertedTimestamp = timestamp.toDate();
  var dateToDisplay = 'Le ' + ('0' + convertedTimestamp.getDate()).slice(-2) + '/' + ('0' + convertedTimestamp.getMonth()).slice(-2) + '/' + convertedTimestamp.getFullYear() + ' à ' +
    ('0' + convertedTimestamp.getHours()).slice(-2) + ':' + ('0' + convertedTimestamp.getMinutes()).slice(-2) + ':' + ('0' + convertedTimestamp.getSeconds()).slice(-2);
  return dateToDisplay;
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
'<div class="client-message-container">' +
  '<div class="discussionSpacing"><img class="discussionPic"></div>' +
  '<div class="content">' +
    '<div class="message"></div>' +
    '<div class="timestamp"></div>' +
  '</div>' +
'</div>';

// Variables de récupération des éléments HTML
var messageListElement = document.getElementById('messages');
var messageFormElement = document.getElementById('message-form');
var messagesZone = document.getElementById('messagesZone')
var messageInputElement = document.getElementById('message');
var submitButtonElement = document.getElementById('submit');

// Etat du bouton d'envoi
messageInputElement.addEventListener('keyup', toggleButton);
messageInputElement.addEventListener('change', toggleButton);

// Enregistre le message envoyé
messageFormElement.addEventListener('submit', onMessageFormSubmit);

initializeApp(getFirebaseConfig());
loadDiscussions();
showMessages();