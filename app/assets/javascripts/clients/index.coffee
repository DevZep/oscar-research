OSCAR.ClientsIndex = do ->
  _init = ->
    _enableSelect2()
    _columnsVisibility()
    _fixedHeaderTableColumns()
    _setDefaultCheckColumnVisibilityAll()
    _initAdavanceSearchFilter()
    _toggleCollapseFilter()
    _handleAutoCollapse()

  _hideClientFilters = ->
    dataFilters = $('#client-search-form .datagrid-filter')
    displayColumns = '#client_grid_given_name, #client_grid_family_name, #client_grid_gender, #client_grid_slug, #client_grid_status, #client_grid_user_ids'
    $(dataFilters).hide()
    $(dataFilters).children("#{displayColumns}").parents('.datagrid-filter').show()

  _handleAutoCollapse = ->
    params = window.location.search.substr(1)

    if params.includes('client_advanced_search')
      $("button[data-target='#client-advance-search-form']").trigger('click')
    else
      $("button[data-target='#client-search-form']").trigger('click')

  _toggleCollapseFilter = ->
    $('#client-search-form').on 'show.bs.collapse', ->
      $('#client-advance-search-form').collapse('hide')

    $('#client-advance-search-form').on 'show.bs.collapse', ->
      $('#client-search-form').collapse('hide')

  _checkClientSearchForm = ->
    $("button.query").on 'click', ->
      form = $(@).attr('class')
      if form.includes('client-advance-search')
        $('#filter_form').hide()
      else
        $('#filter_form').show()
        _hideClientFilters()
        # _enableSelect2()

  _initAdavanceSearchFilter = ->
    advanceFilter = new OSCAR.ClientAdvancedSearches()
    advanceFilter.initBuilderFilter()
    advanceFilter.getTranslation()
    advanceFilter.handleSearch()
    advanceFilter.addRuleCallback()
    advanceFilter.handleSaveQuery()
    advanceFilter.validateSaveQuery()
    advanceFilter.initSelect2Selected()
    advanceFilter.showAllColumns()

  _setDefaultCheckColumnVisibilityAll = ->
    if $('.visibility .checked').length == 0
      $('.all-visibility #all_').iCheck('check')

  _infiniteScroll = ->
    $("table.clients .page").infinitescroll
      navSelector: "ul.pagination" # selector for the paged navigation (it will be hidden)
      nextSelector: "ul.pagination a[rel=next]" # selector for the NEXT link (to page 2)
      itemSelector: "table.clients tbody tr" # selector for all items you'll retrieve
      loading: {
        img: 'http://i.imgur.com/qkKy8.gif'
        msgText: $('.clients-table').data('info-load')
      }
      donetext: $('.clients-table').data('info-end')
      binder: $('.clients-table .dataTables_scrollBody')

  _handleCreateCsiDomainReport = ->
    element = $('#cis-domain-score')
    csiData = element.data('csi-domain')
    csiTitle = element.data('title')
    csiyAxisTitle = element.data('yaxis-title')

    report = new OSCAR.ReportCreator(csiData, csiTitle, csiyAxisTitle, element)
    report.lineChart()

  _handleCreateCaseReport = ->
    element = $('#case-statistic')
    caseData = element.data('case-statistic')
    caseTitle =  element.data('title')
    caseyAxisTitle =  element.data('yaxis-title')

    report = new OSCAR.ReportCreator(caseData, caseTitle, caseyAxisTitle, element)
    report.lineChart()

  _enableSelect2 = ->
    $('#clients-index select').select2
      minimumInputLength: 0,
      allowClear: true

  _formatReportxAxis = ->
    Highcharts.setOptions global: useUTC: false

  _handleHideShowReport = ->
    $('#client-statistic').click ->
      $('#client-statistic-body').slideToggle("slow")
      _handleResizeWindow()

  _clickMenuResizeChart = ->
    $('.minimalize-styl-2').click ->
      setTimeout (->
        _handleResizeWindow()
      ), 220

  _handleResizeWindow = ->
    window.dispatchEvent new Event('resize')

  _columnsVisibility = ->
    $('.columns-visibility').click (e) ->
      e.stopPropagation()

    allCheckboxes = $('.all-visibility #all_')

    allCheckboxes.on 'ifChecked', ->
      $('.visibility input[type=checkbox]').iCheck('check')
    allCheckboxes.on 'ifUnchecked', ->
      $('.visibility input[type=checkbox]').iCheck('uncheck')

  _fixedHeaderTableColumns = ->
    $('table.clients thead tr').clone(true).appendTo 'table.clients thead'
    $('table.clients thead tr:eq(1) th').each (i) ->
      title = $(@).text()
      if i != 6
        $(@).html "<input type='text' name='#{i == 1 && "gender"}' />"
      else
        $(@).html "&nbsp;"

      $('input', @).on 'keyup change', ->
        if table.column(i).search() != @value && i != 1
          table.column(i).search(@value).draw()
        return
      return

    table = $('table.clients').DataTable(
        "scrollY": "200px"
        "sScrollX": "auto"
        'sScrollY': 'auto'
        'bAutoWidth': true
        'orderCellsTop': true
        'fixedHeader': true
        'pageLength': 20
        'dom': 'Birtp'
        'buttons': [
          {
            extend: 'excelHtml5',
            messageTop: 'The information in this table is copyright to OSCaR Research.',
            customize: ( xlsx )->
                # var sheet = xlsx.xl.worksheets['sheet1.xml'];
                styles = xlsx.xl['styles.xml']
                # $('row c[r^="C"]', sheet).attr( 's', '2' );
                $('fonts font name', styles).attr('val', 'Khmer OS Content')
          }
        ]
      )

    $('table.clients thead tr:eq(1) th input[name="gender"]').on 'keyup', ->
      table.columns(1).search("^" + @value, true, false).draw();
      return

    $('.dt-button').appendTo('#action-btns')
    toXlsText = $('#export-to-xls').val()
    $('.dt-button').addClass('btn btn-primary')
    .html("<i class='fa fa-download'></i> #{toXlsText}")
    .removeClass('dt-button buttons-excel buttons-html5');

  _cssClassForlabelDynamic = ->
    $('.dynamic_filter').prev('label').css( "display", "block" )
    $('.dynamic_filter').find('.select2-search').remove('div')

  _restrictNumberFilter = ->
    arr = ["all_domains", "domain_1a", "domain_1b", "domain_2a", "domain_2b", "domain_3a", "domain_3b", "domain_4a", "domain_4b", "domain_5a", "domain_5b", "domain_6a", "domain_6b"]
    $(arr).each (k, v) ->
      $(".#{v}.value").keydown (e) ->
        charCode = if e.which then e.which else e.keyCode
        if charCode != 46 and charCode > 31 and (charCode < 48 or charCode > 57)
          return false
        true

    $('input.age.float_filter').keydown (e) ->
      if $.inArray(e.keyCode, [
          46
          8
          9
          27
          13
          110
          190
        ]) != -1 or e.keyCode == 65 and e.ctrlKey == true or e.keyCode == 67 and e.ctrlKey == true or e.keyCode == 88 and e.ctrlKey == true or e.keyCode >= 35 and e.keyCode <= 41
        return
      if (e.shiftKey or e.keyCode < 48 or e.keyCode > 57) and (e.keyCode < 96 or e.keyCode > 105)
        e.preventDefault()
      return



  _handleScrollTable = ->
    $(window).load ->
      ua = navigator.userAgent
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
        $('.clients-table .dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4
        _handleResizeWindow()

  { init: _init }
