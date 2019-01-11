OSCAR.Initializer =
  exec: (pageName) ->
    if pageName && OSCAR[pageName]
      OSCAR[pageName]['init']()
  
  currentPage: ->
    return '' unless $('body').attr('id')

    bodyId      = $('body').attr('id').split('-')
    controller  = OSCAR.Util.capitalize(bodyId[0])
    action      = OSCAR.Util.capitalize(bodyId[1])
    controller + action

  init: ->
    OSCAR.Initializer.exec('Common')
    if @currentPage()
      OSCAR.Initializer.exec(@currentPage())

$(document).on 'ready page:load', ->
  OSCAR.Initializer.init()