$ ->

  show_password_wrapper = $('.show-password-wrapper')
  password      = $('input[id*=password]')

  show_password_wrapper.on 'click', ->
    if password.attr('type') == 'text'
      password.attr('type', 'password');
      show_password_wrapper.css('background-image', 'url(/assets/eye-open.png)');
      show_password_wrapper.attr('title', 'Show password');
    else
      password.attr('type', 'text');
      show_password_wrapper.css('background-image', 'url(/assets/eye-close.png)');
      show_password_wrapper.attr('title', 'Hide password');
