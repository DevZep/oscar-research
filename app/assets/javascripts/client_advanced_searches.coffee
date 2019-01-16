class OSCAR.ClientAdvancedSearches
  constructor: () ->
    @filterTranslation   = ''

  initSelect2Selected: ->
    $('.rule-filter-container select').on 'select2-selected', ->
      setTimeout ( ->
        $('.rule-operator-container select, .rule-value-container select').select2(width: '180px')
      )

  showAllColumns: ->
    $('.all-visibility input#columns_show_all').on 'ifChecked', ->
      $('.check-columns-visibility input.i-checks').iCheck('check')
      $('#columns_show_all').val('1')
    $('.all-visibility input#columns_show_all').on 'ifUnchecked', ->
      $('.check-columns-visibility input.i-checks').iCheck('uncheck')
      $('#columns_show_all').val('0')
    $('.visibility input.i-checks').on 'ifUnchecked', ->
      $('#columns_show_all').val('0')
    $('.visibility input.i-checks').on 'ifChecked', ->
      $('#columns_show_all').val('0')

  getTranslation: ->
    @filterTranslation =
      addFilter: $('#builder').data('filter-translation-add-filter')
      addGroup: $('#builder').data('filter-translation-add-group')
      deleteGroup: $('#builder').data('filter-translation-delete-group')

  ######################################################################################################################

  initBuilderFilter: ->
    builderFields = $('#client-builder-fields').data('fields')
    advanceSearchBuilder = new OSCAR.AdvancedFilterBuilder($('#builder'), builderFields, @filterTranslation)
    advanceSearchBuilder.initRule()
    @.basicFilterSetRule()
    @.initSelect2()
    @.initRuleOperatorSelect2($('#builder'))

  initSelect2: ->
    $('.rule-filter-container select').select2(width: '250px')
    $('.rule-operator-container select, .rule-value-container select').select2(width: 'resolve')

  basicFilterSetRule: ->
    basicQueryRules = $('#builder').data('basic-search-rules')
    unless basicQueryRules == undefined or _.isEmpty(basicQueryRules.rules)
      $('#builder').queryBuilder('setRules', basicQueryRules)

  initRuleOperatorSelect2: (rowBuilderRule) ->
    operatorSelect = $(rowBuilderRule).find('.rule-operator-container select')
    $(operatorSelect).on 'select2-close', ->
      setTimeout ( ->
        $(rowBuilderRule).find('.rule-value-container select').select2(width: '180px')
      )


  handleSearch: ->
    self = @
    $('#search').on 'click', ->
      basicRules = $('#builder').queryBuilder('getRules', { skip_empty: true, allow_invalid: true })

      if (_.isEmpty(basicRules.rules) and !basicRules.valid) or (!(_.isEmpty(basicRules.rules)) and basicRules.valid)
        $('#builder').find('.has-error').remove()
        $('#client_advanced_search_basic_rules').val(self.handleStringfyRules(basicRules))
        self.handleSelectFieldVisibilityCheckBox()
        $('#advanced-search').submit()


  handleStringfyRules: (rules) ->
    rules = JSON.stringify(rules)
    return rules.replace(/null/g, '""')

  handleSelectFieldVisibilityCheckBox: ->
    checkedFields = $('.visibility .checked input, .all-visibility .checked input')
    $('form#advanced-search').append(checkedFields)

  ######################################################################################################################

  addRuleCallback: ->
    self = @
    $('#builder').on 'afterCreateRuleFilters.queryBuilder', (_e, obj) ->
      self.initSelect2()
      self.handleSelectOptionChange(obj)

  handleSelectOptionChange: (obj)->
    self = @
    if obj != undefined
      rowBuilderRule = obj.$el[0]
      ruleFiltersSelect = $(rowBuilderRule).find('.rule-filter-container select')
      $(ruleFiltersSelect).on 'select2-close', ->
        setTimeout ( ->
          self.initSelect2()
          self.initRuleOperatorSelect2(rowBuilderRule)
        )

  ######################################################################################################################

  handleSaveQuery: ->
    self = @
    $('#submit-query').on 'click', ->
      basicRules = $('#builder').queryBuilder('getRules', { skip_empty: true, allow_invalid: true })
      if (_.isEmpty(basicRules.rules) and !basicRules.valid) or (!(_.isEmpty(basicRules.rules)) and basicRules.valid)
        $('#builder').find('.has-error').remove()

      $('#advanced_search_queries').val(self.handleStringfyRules(basicRules))
      self.handleAddColumnPickerToInput()

  handleAddColumnPickerToInput: ->
    columnsVisibility = new Object
    $('.visibility, .all-visibility').each ->
      checkbox = $(@).find('input[type="checkbox"]')
      if $(checkbox).prop('checked')
        attrName = $(checkbox).attr('name')
        columnsVisibility[attrName] = $(checkbox).val()
    $('#advanced_search_field_visible').val(JSON.stringify(columnsVisibility))

  validateSaveQuery: ->
    $('#advanced_search_name').keyup ->
      if $(@).val() != ''
        $('#submit-query').removeClass('disabled').removeAttr('disabled')
      else
        $('#submit-query').addClass('disabled').attr('disabled', 'disabled')
