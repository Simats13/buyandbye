<style>
    #page {
        padding: 0 5%;
    }
</style>

<div id="page">
    <h1>Messagerie</h1>

    <div id="messages"></div>
    <form id="message-form" action="#">
        <input id="message" type="text" autocomplete="off">
        <label for="message">Message...</label>
        <button id="submit" disabled type="submit">Send</button>
    </form>
</div>

<script type='module' src='/professional/js/messages.js'></script>