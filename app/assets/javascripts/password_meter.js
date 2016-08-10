$(document).ready(function() {
  $('#password_meter').entropizer({
    target: '#user_password',
    maximum: 80,
    update: function(data, ui){

      ui.bar.css({
        'background-color': data.color,
        // 'width': data.percent + '%'
        'height': data.percent + '%'
      })

      var i;

      if (data.percent == 0) {
        $(".password-strength").remove();
      }

      if (data.percent > 25) {
        $(".password-strength").remove();
        for (i = 0; i < 1; i++) {
          $(".password-meter-anchor").after("<div class='password-strength'></div>");
          $(".password-strength").css( "background-color", "#ff2837" );
        }
      }
      if (data.percent > 50) {
        $(".password-strength").remove();
        for (i = 0; i < 2; i++) {
          $(".password-meter-anchor").after("<div class='password-strength'></div>");
          $(".password-strength").css( "background-color", "#ff2837" );
        }
      }
      if (data.percent > 75) {
        $(".password-strength").remove();
        for (i = 0; i < 3; i++) {
          $(".password-meter-anchor").after("<div class='password-strength'></div>");
          $(".password-strength").css( "background-color", "#ff8900" );
        }
      }
      // if (data.percent > 80) {
      //   $(".password-strength").remove();
      //   for (i = 0; i < 4; i++) {
      //     $(".password-meter-anchor").after("<div class='password-strength'></div>");
      //   }
      // }
      if (data.percent == 100) {
        $(".password-strength").remove();
        for (i = 0; i < 4; i++) {
          $(".password-meter-anchor").after("<div class='password-strength'></div>");
          $(".password-strength").css( "background-color", "#64be00" );
        }
      }
      // $(".password-strength").css( "background-color", data.color );

    }
  });

});