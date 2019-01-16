OSCAR.UsersIndex = do ->
  _init = ->
    _fixedHeaderTableColumns()
    _getUserPath()

  _fixedHeaderTableColumns = ->
    $('.users-table').removeClass('table-responsive')
    if !$('table.users tbody tr td').hasClass('noresults')
      $('table.users').dataTable(
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'bSort': false
        'sScrollY': 'auto'
        'bAutoWidth': true
        'sScrollX': '100%')
    else
      $('.users-table').addClass('table-responsive')

  _getUserPath = ->
    return if $('table.users tbody tr').text().trim() == 'No results found' || $('table.users tbody tr').text().trim() == 'មិនមានលទ្ធផល' || $('table.users tbody tr').text().trim() == 'No data available in table'
    $('table.users tbody tr').click (e) ->
      return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa') || $(e.target).is('a')
      window.open($(@).data('href'), '_blank')

  {init: _init}
