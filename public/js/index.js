// import * as Config from "./config.js"
// firebase.initializeApp(Config.firebaseConfig)

// firebase.auth().onAuthStateChanged((user) => {
//   // updateUIbyAuth()
//   if (user) {
//     alert("user is logged in")

//   } else {
//     alert("user is logged out")
    
//   }
// })



// const loginButton = document.getElementById("login");
// loginButton.addEventListener("click", () => {
//   var email = document.getElementById("email").value
//   var password = document.getElementById("password").value
//   signInWithEmailAndPassword(email, password);
// });
// const logoutButton = document.getElementById("logout")

// logoutButton.addEventListener("click", () => {
//   firebase.auth().signOut();

// })






// // firebase.auth().onAuthStateChanged((user) => {
// //   // updateUIbyAuth()
// //   if (user) {
// //     // User is signed in.
// //     console.log(user.displayName)
// //     // var displayName = user.displayName
// //     // var email = user.email
// //     // var emailVerified = user.emailVerified
// //     // var photoURL = user.photoURL
// //     // var isAnonymous = user.isAnonymous
// //     // var uid = user.uid
// //     // var providerData = user.providerData
// //     // ...
// //   } else {
// //     // User is signed out.
// //     // ...
// //   }
// // })


// // const getIdToken = () => {
// //   return new Promise((resolve, reject) => {
// //     firebase
// //       .auth()
// //       .currentUser.getIdToken()
// //       .then((token) => {
// //         resolve(token)
// //       })
// //       .catch((e) => {
// //         reject(e)
// //       })
// //   })
// // }
// const signInWithEmailAndPassword = (email, password) => {
//   return new Promise((resolve, reject) => {
//     firebase
//       .auth()
//       .signInWithEmailAndPassword(email, password)
//       .then((user) => {
//         resolve(user)
//       })
//       .catch((e) => {
//         reject(e)
//       })
//   })
// }
// // const profileEl = {}
// // profileEl.picture = document.querySelector("#profile-picture")
// // profileEl.email = document.querySelector("#profile-email")
// // profileEl.displayName = document.querySelector("#profile-name")

// // function updateUIbyAuth() {
// //   if (!!firebase.auth().currentUser) {
// //     console.log(firebase.auth().currentUser.displayName);
// //     // loginButton.style.display = "none"
// //     // logoutButton.style.display = "block"
// //     // profileEl.picture.src = firebase.auth().currentUser.photoURL
// //     // profileEl.email.innerHTML = firebase.auth().currentUser.email
// //     // profileEl.displayName.innerHTML = firebase.auth().currentUser.displayName
// //     // document.querySelector(".profile-section").style.visibility = "visible"
// //   } else {
// //     document.querySelector(".profile-section").style.visibility = "hidden"
// //     loginButton.style.display = "block"
// //     logoutButton.style.display = "none"
// //   }
// // }