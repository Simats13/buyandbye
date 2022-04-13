<style>
    #page {
        padding: 0 5%;
    }

    @media screen and (min-height: 550px) and (max-height: 700px) {
        .card-body {
            display: flex;
            height: 55vh;
        }
    }

    @media screen and (min-height: 700px) and (max-height: 850px) {
        .card-body {
            display: flex;
            height: 65vh;
        }
    }

    @media screen and (min-height: 850px) and (max-height: 1000px) {
        .card-body {
            display: flex;
            height: 70vh;
        }
    }

    @media screen and (min-height: 1000px) and (max-height: 1200px) {
        .card-body {
            display: flex;
            height: 75vh;
        }
    }

    @media screen and (min-height: 1200px) and (max-height: 1400px) {
        .card-body {
            display: flex;
            height: 78vh;
        }
    }

    @media screen and (min-height: 1400px) {
        .card-body {
            display: flex;
            height: 80vh;
        }
    }

    #discussions {
        overflow: auto;
        width: 40%;
        background-color: #F8F8F8;
        border-radius: 0.5rem;
        padding: 1%;
    }

    #messagesZone {
        overflow: auto;
        width: 100%;
        padding: 0 4%;

        display: flex;
        justify-content: center;
        align-items: center;
    }

    #message-form {
        margin-top: 20px;
        text-align: center;
        display: none;
    }

    #choose {
        display: block;
        text-align: center;
    }

    .client-message-container, .pro-message-container {
        display: flex;
        margin-top: 15px;
    }

    .pro-message-container {
        flex-direction: row-reverse;
        text-align: right;
    }

    .client-message-container .message {
        background-color: #eee;
    }

    .message {
        text-align: left;
        background-color: #00BFFF;
        border-radius: 0.75rem;
        color: black;
        display: inline-block;
        padding: 3px 14px;
        max-width: 25em;
        word-wrap: break-word
    }

    .nameAndMessage {
        width: 50%;
    }

    .timestamp {
        font-size: .8em;
        text-align: right;
    }

    .discussionSpacing img {
        width: 4em;
        height: 4em;
        margin-right: 20px;
        border-radius: 0.3rem;
    }

    .discussion-container {
        display: flex;
        padding: 10px;
        cursor: pointer;
        background-color: white;
        border-radius: 0.3rem;
        margin-bottom: 0.5vw;
        box-shadow: 5px 5px 5px #F0F0F0, -5px -5px 5px #F0F0F0, -5px 5px 5px #F0F0F0, 5px -5px 5px #F0F0F0;
    }

    .form-group {
        display: flex;
    }

    .form-control {
        border-radius: 12px;
        border: 1px solid #F0F0F0;
        font-size: small;
    }

    .form-control:focus {
        box-shadow: none
    }

    .form-control::placeholder {
        font-size: small;
        color: #C4C4C4
    }

    #submit {
        border: none;
        background-color: white;
        color: #00BFFF;
        font-size: x-large;
        transition-property: font-size color;
        transition-duration: 1s;
    }

    #submit:disabled {
        color: lightgrey;
        font-size: medium;
    }

    /* Scrollbar */
    /* width */
    ::-webkit-scrollbar {
    width: 8px;
    }

    /* Track */
    ::-webkit-scrollbar-track {
    box-shadow: inset 0 0 5px grey; 
    border-radius: 10px;
    }
    
    /* Handle */
    ::-webkit-scrollbar-thumb {
    background: #C0C0C0; 
    border-radius: 10px;
    }

    /* Handle on hover */
    ::-webkit-scrollbar-thumb:hover {
    background: #A9A9A9; 
    }
</style>

<div id="page">

    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">Discussions en cours</h6>
        </div>

        <div class="card-body">
            <div id="discussions"></div>
            <!-- Affiche les messages et la zone de texte en colonne -->
            <div id="messagesZone">
                <div id="messages"></div>
                    <form id="message-form" action="#">
                        <div class="form-group">
                            <textarea class="form-control" id="message" rows="2" placeholder="Votre message"></textarea>
                            <button id="submit" disabled type="submit"><i class="fas fa-paper-plane"></i></button>
                        </div>
                    </form>
                    <p id="choose">Choisissez une conversation sur votre gauche<br>pour lancer une discussion</p>
                </div>
            </div>
        </div>
    </div>
</div>
<script type='module' src='/professional/js/messages.js'></script>