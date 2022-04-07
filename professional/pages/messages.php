<style>
    #page {
        padding: 0 5%;
    }

    #message-form {
        margin-top: 20px;
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

    .message {
        background-color: #00BFFF;
        border: 1px solid #00BFFF;
        border-radius: 0.75rem;
        color: black;
        display: inline-block;
        padding: 2px 10px;
    }

    .timestamp {
        font-size: .75em;
    }

    img {
        width: 2em;
        height: 2em;
    }

    .discussion-container {
        border: 5px solid black;
    }
</style>

<div id="page">
    <h1>Messagerie</h1>

    <p>Liste des discussions :</p>

    <div id="discussions">
    </div>

    <!-- Fenêtre modale de discussion -->
    <div class="modal fade" id="showDiscussion" tabindex="-1" role="dialog"
    aria-labelledby="exampleModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">Discussion</h5>
                    <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">×</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div id="messages"></div>
                        <form id="message-form" action="#">
                            <input id="message" type="text" autocomplete="off">
                            <label for="message">Message...</label>
                            <button id="submit" disabled type="submit">Send</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script type='module' src='/professional/js/messages.js'></script>