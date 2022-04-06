<!-- <script type="text/javascript" src="js/mdb.min.js"></script> -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
		<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/js/materialize.min.js"></script> -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.19.0/jquery.validate.min.js"></script>
<script src="js/chosen.jquery.min.js"></script>

        <!--===============================================================================================-->
	<!-- <script src="vendor/jquery/jquery-3.2.1.min.js"></script> -->
	<!--===============================================================================================-->
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>

<!-- <script src="vendor/bootstrap/js/bootstrap.min.js"></script> -->
	
<!-- <script src="vendor/select2/select2.min.js"></script> -->
	<!--===============================================================================================-->
<!-- <script src="vendor/daterangepicker/moment.min.js"></script>
<script src="vendor/daterangepicker/daterangepicker.js"></script> -->
	<!--===============================================================================================-->
<!-- <script src="vendor/countdowntime/countdowntime.js"></script> -->
	<!--===============================================================================================-->
<script src="js/main.js"></script>

		<!-- JQUERY STEP -->
<script src="js/jquery.steps.js"></script>
    
<script>

$(document).ready(function() {
    $("body").tooltip({ selector: '[data-toggle=tooltip]' });
});
</script>

<script
  src="https://maps.google.com/maps/api/js?key=AIzaSyAEKsQP_j7i0BEjWX1my8_CFL_8sZMPvVk&libraries=places&region=fr&callback=initAutocomplete"
  type="text/javascript">
</script>




<script>
  $(document).ready(function () {
    $("#lat_area").addClass("d-none");
    $("#long_area").addClass("d-none");
  
    
  });
  $(document).ready(function(){
        $('#add_form input[type="text"]').blur(function(){
          if(!$(this).val()){
            $(this).addClass("border border-danger");
          } else{
            $(this).removeClass("border border-danger");
          }
        });
      });
  google.maps.event.addDomListener(window, 'load', initialize);

  function initialize() {
    var input = document.getElementById('autocomplete');
    var autocomplete = new google.maps.places.Autocomplete(input);
    autocomplete.addListener('place_changed', function () {
      var place = autocomplete.getPlace();
      $('#latitude').val(place.geometry['location'].lat());
      $('#longitude').val(place.geometry['location'].lng());
      // // --------- show lat and long ---------------
      // $("#lat_area").removeClass("d-none");
      // $("#long_area").removeClass("d-none");
    });
  }
</script>

<script>
  function readURL(input) {
      if (input.files && input.files[0]) {
          var reader = new FileReader();

          reader.onload = function (e) {
              $('#imagePreview')
                  .attr('src', e.target.result)
                  .removeAttr('hidden')
                  .height(200);
          };

          reader.readAsDataURL(input.files[0]);
      }
  };
  $(function () {
    var input = document.getElementById("autocomplete");
    var autocomplete = new google.maps.places.Autocomplete(input);


  });

</script>

<!-- <script>var form = $("#registerPage");

form.validate({
    errorPlacement: function errorPlacement(error, element) {
        element.before(error);
    },
    rules: {
        confirm: {
            equalTo: "#password"
        },
		specialNumber: {
			pattern: /^(6|8|10|12)$/
		}
    }
});

form.children("#wizard").steps({
    headerTag: "h4",
    bodyTag: "section",
    transitionEffect: "fade",
    onStepChanging: function(event, currentIndex, newIndex) {
        form.validate().settings.ignore = ":disabled,:hidden";
        
        return form.valid();
    },
    onFinishing: function(event, currentIndex) {
        form.validate().settings.ignore = ":disabled";
        return form.valid();
    },
    onFinished: function(event, currentIndex) {
        alert("Submitted!");
    }
});
</script> -->

<script>$(function(){
  $("#registerPage").validate({
            errorClass: "error",
            rules:{
              ownerLastName:{
                  required: true,
                  minlength: 2,
                  maxlength: 15,
              },
              ownerFirstName:{
                  required: true,
                  minlength: 2,
                  maxlength: 15,
              },
              emai:{
                  required: true,
                  email: true,
              },
              personnalphone:{
                  required: true,
                  minlength: 10,
                  maxlength: 10,
              },
              password1:{
                  required: true,
                  minlength: 6,
                  maxlength: 10,
              },
              password2:{
                required: true,
                equalTo : "#Password1"
              },
              autocomplete:{
                  required: true,
              },
            },
            messages:{
              ownerLastName: {
                required: "Nom de famille requis",
                minlength: "Votre nom de famille doit comporter au moins 2 caractères",
                maxlength: "Votre nom de famille doit comporter au maximum 15 caractères",
              
            },
              ownerFirstName: {
                  required: "Prénom requis",
                  minlength: "Votre prénom doit comporter au moins 2 caractères",
                  maxlength: "Votre prénom doit comporter au maximum 5 caractères",
              },
              email: {
                  required: "Email requis",
                  email: "Veuillez entrer un email valide",
              },
              personnalphone: {
                  required: "Numéro de téléphone requis",
                  minlength: "Votre numéro de téléphone doit comporter 10 chiffres",
                  maxlength: "Votre numéro de téléphone doit comporter 10 chiffres",
              },
              password1: {
                  required: "Mot de passe requis",
                  minlength: "Votre mot de passe doit comporter au moins 6 caractères",
                  maxlength: "Votre mot de passe doit comporter au maximum 10 caractères",
              },
              password2: {
                required: "Veuillez entrer le même mot de passe",
                equalTo: "Veuillez entrer le même mot de passe",
              },
              autocomplete: {
                  required: "Veuillez entrer une adresse valide",
              },
            },
          });
	$("#wizard").steps({
        headerTag: "h4",
        bodyTag: "section",
        transitionEffect: "fade",
        enableAllSteps: false,
        saveState: true,
        transitionEffectSpeed: 500,

        onStepChanging: function (event, currentIndex, newIndex) {
          
          if (newIndex < currentIndex) {
                return true;
            }

        if($("#registerPage").valid()){
          if ( newIndex === 1 ) {
                $('.steps ul').addClass('step-2');
            } else {
                $('.steps ul').removeClass('step-2');
            }
            if ( newIndex === 2 ) {
                $('.steps ul').addClass('step-3');
            } else {
                $('.steps ul').removeClass('step-3');
            }

            if ( newIndex === 3 ) {
                $('.steps ul').addClass('step-4');
                $('.actions ul').addClass('step-last');
            } else {
                $('.steps ul').removeClass('step-4');
                $('.actions ul').removeClass('step-last');
            }
			      if ( newIndex === 4 ) {
                $('.steps ul').addClass('step-5');
                $('.actions ul').addClass('step-last');
            } else {
                $('.steps ul').removeClass('step-5');
                $('.actions ul').removeClass('step-last');
            }  
        }
        return $("#registerPage").valid();

           
        },
        onFinishing: function (event, currentIndex){
          $("#registerPage").validate().settings.ignore = ":disabled";
        return $("#registerPage").valid();
      },
    onFinished: function (event, currentIndex)
    {
        alert("Submitted!");
    },
        labels: {
            finish: "Finaliser",
            next: "Suivant",
            previous: "Retour"
        }
        
    });
    // Custom Steps Jquery Steps
    // if(){}
    if($("#registerPage").valid()){
    $('.wizard > .steps li a').click(function(){
                $(this).parent().addClass('checked');
              $(this).parent().prevAll().addClass('checked');
              $(this).parent().nextAll().removeClass('checked');
              });}
    // Custom Button Jquery Steps
    $('.forward').click(function(){
    	$("#wizard").steps('next');
    });
    $('.backward').click(function(){
        $("#wizard").steps('previous');
        
    });
    // Checkbox
    $('.checkbox-circle label').click(function(){
        $('.checkbox-circle label').removeClass('active');
        $(this).addClass('active');
    });
    
});
</script>