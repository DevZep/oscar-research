OSCAR.UsersNew = OSCAR.UsersCreate = OSCAR.UsersEdit = OSCAR.UsersUpdate = do ->
  _init = ->
    _initSelect2()

  _initSelect2 = ->
    $('select').select2
      allowClear: true
      _clearSelectedOption()

  _clearSelectedOption = ->
    formAction = $('body').attr('id')
    $('#user_roles').val('') unless formAction.includes('edit')  
  { init: _init }