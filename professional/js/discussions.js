'use strict';

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

// Charge les discussions et écoute de nouvelles discussions
export function loadDiscussions() {
  const recentDiscussionsQuery = query(collection(getFirestore(), 'messages'), orderBy('timestamp', 'desc'), limit(12));
    
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
function displayDiscussion(id, timestamp, message, ids) {
  var div = document.getElementById(id) || createAndInsertDiscussion(id, timestamp);

  div.querySelector('.discussionName').textContent = ids[1];

  var messageElement = div.querySelector('.lastMessage');
  messageElement.textContent = message;
  messageElement.innerHTML = messageElement.innerHTML.replace(/\n/g, '<br>');

  //div.querySelector('discussionTimestamp').textContent = timestamp;

  // Fait défiler jusqu'à la nouvelle discussion
  setTimeout(function() {div.classList.add('visible')}, 1);
  discussionListElement.scrollTop = discussionListElement.scrollHeight;
  page.focus();
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
  '<div class="discussionSpacing"><div class="discussionPic"></div></div>' +
  '<div class="lastMessage"></div>' +
  '<div class="DiscussionName"></div>' +
  '<button class="btn btn-outline-danger" data-toggle="modal" data-target="#showDiscussion">Ouvrir la discussion</button>' +
'</div>';