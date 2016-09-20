$(document).ready(function(){
  var $tab_items = $('#tabs h2');
  checkToggle();

  $('#expand').on('click', function(){
    $tab_items.addClass('active');
    checkToggle();
  });
  $('#collapse').on('click', function(){
    $tab_items.removeClass('active');
    checkToggle();
  });

  $tab_items.on('click', function(){
    var item = $(this);

    if(item.hasClass('active')){
      item.removeClass('active');
      checkToggle();
    }else{
      item.addClass('active');
      checkToggle();
    };
  });

  function checkToggle(){
    if( $('h2.active').length  == $tab_items.length ){
      $('#expand').addClass('disable');
    }else{
      $('#expand').removeClass('disable');
    };

    if($('h2.active').length == 0){
      $('#collapse').addClass('disable');
    }else{
      $('#collapse').removeClass('disable');
    };
  };

})();
