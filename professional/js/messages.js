'use strict';

import { initializeApp } from 'https://www.gstatic.com/firebasejs/9.6.10/firebase-app.js';
import {
  ref,
  getStorage,
  uploadBytesResumable,
  getDownloadURL,
} from 'https://www.gstatic.com/firebasejs/9.6.10/firebase-storage.js';
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

// Charge les messages et écoute de nouveaux messages
function loadMessages(docID) {
  const recentMessagesQuery = query(collection(getFirestore(), "commonData", docID, "messages"), orderBy('timestamp', 'desc'));
  
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

var clientImgUrl;
$(document).on('click', ".discussion-container", function() {
  // Récupère la photo de profil du client quand on sélectionne une discussion
  clientImgUrl = $(this).find(".discussionSpacing").find(".discussionPic").attr("src");
  // Masque le message de base et affiche la discussion souhaitée
  document.getElementById("choose").style.display = "none";
  document.getElementById("messagesZone").style.display = "block";
  document.getElementById("message-form").style.display = "block";
  document.getElementById("discussionHeader").style.display = "block";
  // Récupère l'id de la discussion sélectionnée, supprime l'ancienne discussion et affiche la nouvelle
  var id = $(this).attr("id");
  const oldMessages = document.getElementById('messages');
  oldMessages.innerHTML= '';
  loadMessages(id);
  // Donne l'id de la conversation au bouton d'envoi
  const sendButton = document.getElementById('submit');
  sendButton.setAttribute('class', id);
  // Récupère le nom du client et l'affiche en haut de la discussion
  const clientName = $(this).find(".nameAndMessage").find(".discussionName").text();
  document.getElementById('discussionHeader').textContent = clientName;
});

// Affiche le message dans la popup
function displayMessage(id, timestamp, text, sentByClient, imageUrl) {
  var div = document.getElementById(id) || createAndInsertMessage(id, timestamp);

  if(!sentByClient) {
    div.removeAttribute('class');
    div.setAttribute('class', 'pro-message-container');
  }

  var timestampElement = div.querySelector('.timestamp')
  timestampElement.textContent = formatedTimestamp(timestamp);

  if (div.classList[0] == "pro-message-container") {
    const proImgUrl = document.querySelector('.img-profile').getAttribute('src');
    div.querySelector('.discussionSpacing').querySelector('img').setAttribute('src', proImgUrl);
  } else {
    div.querySelector('.discussionSpacing').querySelector('img').setAttribute('src', clientImgUrl);
  }
  var messageElement = div.querySelector('.message');

  if (text) { // Si le message est du texte
    messageElement.textContent = text;
    messageElement.innerHTML = messageElement.innerHTML.replace(/\n/g, '<br>');
  } else if (imageUrl) { // Si le message est une image
    var image = document.createElement('img');
    image.onload = function() {
      messagesZone.scrollTop = messagesZone.scrollHeight;
    }
    image.src = imageUrl + '&' + new Date().getTime();
    messageElement.innerHTML = '';
    messageElement.appendChild(image);
  }

  // Fait défiler jusqu'au nouveau message
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

// Change l'état du bouton d'envoi de message
function toggleButton() {
  if (messageInputElement.value) {
    submitButtonElement.removeAttribute('disabled');
  } else {
    submitButtonElement.setAttribute('disabled', 'true');
  }
}

// Appelé lorsqu'un fichier est ajouté à la conversation
function onMediaFileSelected(event) {
  event.preventDefault();
  var file = event.target.files[0];

  // Efface le fichier sélectionné dans le champ de sélection de fichier
  messageFormElement.reset();

  // Vérifie que le fichier est une image
  if (!file.type.match('image.*')) {
    alert('Veuillez sélectionner une image');
    return;
  }
  
  saveImageMessage(file);
}

 // Enregistre dans Firebase le message contenant l'image
 // Enregistre d'abord l'image dans Storage
 async function saveImageMessage(file) {
  try {
    // 1 - On ajoute le message avec un icône de chargement et on le changera avec l'url de l'image
    const conversationId = document.getElementById('submit').getAttribute('class');
    const uploadTimestamp = serverTimestamp();
    const messageRef = await addDoc(collection(getFirestore(), 'commonData', conversationId, 'messages'), {
      isread: false,
      sentByClient: false,
      imageUrl: 'https://www.google.com/images/spin-32.gif?a',
      timestamp: uploadTimestamp
    });

    // 2 - Upload l'image image dans Cloud Storage.
    const filePath = `chatrooms/${conversationId}/${messageRef.id}/${file.name}`;
    const newImageRef = ref(getStorage(), filePath);
    const fileSnapshot = await uploadBytesResumable(newImageRef, file);
    
    // 3 - Génère l'url publique du fichier
    const publicImageUrl = await getDownloadURL(newImageRef);

    // 4 - Met à jour le message avec les infos de l'image
    await updateDoc(messageRef,{
      imageUrl: publicImageUrl,
      storageUri: fileSnapshot.metadata.fullPath
    });

    // 5 - Met à jour le contenu et le timestamp du dernier message
    await updateDoc(doc(getFirestore(), "commonData", conversationId), {
      lastMessage: 'Image',
      timestamp: uploadTimestamp
    });
  } catch (error) {
    console.error('There was an error uploading a file to Cloud Storage:', error);
  }
}

// Template de message
var MESSAGE_TEMPLATE =
'<div class="client-message-container">' +
  '<div class="discussionSpacing"><img class="messagePic"></div>' +
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
var mediaCaptureElement = document.getElementById('mediaCapture');
var imageButtonElement = document.getElementById('submitImage');

// Etat du bouton d'envoi
messageInputElement.addEventListener('keyup', toggleButton);
messageInputElement.addEventListener('change', toggleButton);

// Enregistre le message envoyé
messageFormElement.addEventListener('submit', onMessageFormSubmit);

// Ouvre la fenêtre de sélection de fichier lorsqu'on clique sur l'icone d'image
imageButtonElement.addEventListener('click', function(e) {
  e.preventDefault();
  mediaCaptureElement.click();
});
mediaCaptureElement.addEventListener('change', onMediaFileSelected);

initializeApp(getFirebaseConfig());
loadDiscussions();