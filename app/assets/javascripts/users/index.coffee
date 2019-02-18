OSCAR.UsersIndex = do ->
  _init = ->
    _initDataTable()
    _getUserPath()

  _initDataTable = ->
    $('table.users thead tr').clone(true).appendTo 'table.users thead'
    search   = $('#search-translate').text()
    next     = $('#next-translate').text()
    previous = $('#previous-translate').text()
    $('table.users thead tr:eq(1) th').each (i) ->
      title = $(@).text()
      $(@).html '<input type="text" />'
      $('input', @).on 'keyup change', ->
        if table.column(i).search() != @value
          table.column(i).search(@value).draw()
        return
      return

    # $('table.users thead tr th:last-child input').hide()

    table = $('table.users').DataTable(
      # bServerSide: true
      # bFilter: false
      'dom': 'irtp'
      bLengthChange: false
      sAjaxSource: $('#users').data('source')
      "sScrollX": "auto"
      'sScrollY': 'auto'
      'bAutoWidth': true
      'orderCellsTop': true
      'fixedHeader': true
      'pageLength': 20
      # 'columnDefs': [ {
      #       'className': 'manage-column',
      #       'targets': -1,
      #       'data': null,
      #       'defaultContent': '<button class="btn btn-xs btn-success btn-outline edit-user-button"><span class="fa fa-pencil edit-user-button"></span></button>
      #                          <a data-confirm="Are you sure you want to delete?" class="btn btn-outline btn-danger btn-xs delete-user-button" rel="nofollow" data-method="delete"><i class="fa fa-trash delete-user-button"></i></a>'
      #   } ]

      'language':
          'search': search,
          'paginate': {
              previous: previous,
              next:     next
          },

    )
    setTimeout (->
      rows = $('#users-body > tr')
      $('td.manage-column').attr('align', 'center')
      $.each rows, (index, item) ->
        href = $($(item).find('td a')).attr('href')
        href = href.replace('?locale=en', '')
        $(item).attr('data-href', href)
        $($(item).find('a.edit-user-button')).attr('href', href + '/edit')
        $($(item).find('a.delete-user-button')).attr('href', href)
      ), 100

  _getUserPath = ->
    setTimeout (->
      return if $('table.users tbody tr').text().trim() == 'No results found' || $('table.users tbody tr').text().trim() == 'មិនមានលទ្ធផល' || $('table.users tbody tr').text().trim() == 'No data available in table'
      $('tbody#users-body tr').click (e) ->
        e.preventDefault()
        if ($(e.target).hasClass('btn') || $(e.target).hasClass('fa') || $(e.target).is('a')) and $(e.target).hasClass('edit-user-button')
          href = $(e.target.parentElement).context.href || $(e.target).context.href
          window.open(href, '_blank')
        else if ($(e.target).hasClass('btn') || $(e.target).hasClass('fa') || $(e.target).is('a')) and $(e.target).hasClass('delete-user-button')
          return
        else
          window.open($(@).data('href'), '_blank')
      ), 100

  {init: _init}
