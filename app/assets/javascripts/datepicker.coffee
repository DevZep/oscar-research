$(document).on 'ready page:load', ->

  $('.date_filter, .input-group.date').datepicker
    autoclose: true,
    format: 'yyyy-mm-dd',
    todayHighlight: true,
    disableTouchKeyboard: true

  $('input.date[disabled="disabled"]').parent('.input-group.date').datepicker('remove')
