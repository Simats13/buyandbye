'use strict';

import {
  getFirestore,
  collection,
  query,
  orderBy,
  limit,
  doc,
  getDoc,
  onSnapshot,
  where
} from 'https://www.gstatic.com/firebasejs/9.6.10/firebase-firestore.js';

// Charge les discussions et écoute de nouvelles discussions
export function loadDiscussions() {
  const recentDiscussionsQuery = query(collection(getFirestore(), 'commonData'), where("users", "array-contains", "dnGbdRAWrPMZYcLK98a5fowRLHJ2"), orderBy('timestamp'), limit(12));

  // Requête d'écoute
  onSnapshot(recentDiscussionsQuery, function(snapshot) {
    snapshot.docChanges().forEach(function(change) {
      if (change.type === 'removed') {
        deleteDiscussion(change.doc.id);
      } else {
        var discussion = change.doc.data();
        displayDiscussion(change.doc.id, discussion.timestamp, discussion.lastMessage, discussion.users);
      }
    });
  });
}

// Supprime l'affichage du message
function deleteDiscussion(id) {
  var div = document.getElementById(id);
  if (div) {
    div.parentNode.removeChild(div);
  }
}

// Affiche la discussion sur la page
function displayDiscussion(id, timestamp, message, userIds) {
  var div = document.getElementById(id) || createAndInsertDiscussion(id, timestamp);

  var userInfo = getClientInfos(userIds[1]);
  userInfo.then(function(result) {
    div.querySelector('.discussionName').textContent = result.lname + ' ' + result.fname;
    div.querySelector('.discussionPic').setAttribute('src', result.imgUrl);
  })

  var timestampElement = div.querySelector('.timestamp')
  timestampElement.textContent = formatedTimestamp(timestamp);

  var messageElement = div.querySelector('.lastMessage');
  messageElement.textContent = message;
  messageElement.innerHTML = messageElement.innerHTML.replace(/\n/g, '<br>');

  // Fait défiler jusqu'à la nouvelle discussion
  setTimeout(function() {div.classList.add('visible')}, 1);
  discussionListElement.scrollTop = discussionListElement.scrollHeight;
  page.focus();
}

// Récupère les infos du client
async function getClientInfos(userId) {
    const clientInfos = query(doc(getFirestore(), 'users', userId));
    const docSnap = await getDoc(clientInfos);
    return docSnap.data();
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

function createAndInsertDiscussion(id, timestamp) {
  const container = document.createElement('div');
  container.innerHTML = DISCUSSION_TEMPLATE;
  const div = container.firstChild;
  div.setAttribute('id', id);

  // Si le timestamp est nul, on suppose qu'il y a une nouvelle discussion
  // https://stackoverflow.com/a/47781432/4816918
  timestamp = timestamp ? timestamp.toMillis() : Date.now();
  div.setAttribute('timestamp', timestamp);
  
  // Cherche où insérer la nouvelle discussion
  const existingDiscussions = discussionListElement.children;
  if (existingDiscussions.length === 0) {
    discussionListElement.appendChild(div);
  } else {
    let discussionListNode = existingDiscussions[0];

    while (discussionListNode) {
      const discussionListNodeTime = discussionListNode.getAttribute('timestamp');

      if (!discussionListNodeTime) {
        throw new Error(
          `Child ${discussionListNode.id} has no 'timestamp' attribute`
        );
      }

      if (discussionListNodeTime > timestamp) {
        break;
      }

      discussionListNode = discussionListNode.nextSibling;
    }

    discussionListElement.insertBefore(div, discussionListNode);
  }

  return div;
}

var discussionListElement = document.getElementById('discussions');
var page = document.getElementById('page');

// Template de discussion
var DISCUSSION_TEMPLATE =
'<div class="discussion-container">' +
  '<div>' +
    '<div class="DiscussPicName">' +
      '<div class="discussionSpacing"><img class="discussionPic"></div>' +
      '<div class="discussionName"></div>' +
    '</div>' +
    '<div class="lastMessage"></div>' +
    '<div class="timestamp"></div>' +
  '</div>' +
'</div>';

/*
  '<div><button class="btn btn-outline-danger" data-toggle="modal" data-target="#showDiscussion">Ouvrir la discussion</button></div>' +
*/