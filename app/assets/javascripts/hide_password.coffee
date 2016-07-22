$ ->

  show_password = $('.show_password')
  password      = $('input[id*=password]')

  show_password.on 'click', ->
    if password.attr('type') == 'text'
      password.attr('type', 'password');
    else
      password.attr('type', 'text');
