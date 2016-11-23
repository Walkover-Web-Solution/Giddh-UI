angular.module('trialBalance', []).directive('exportReport', [
  '$rootScope'
  '$compile'
  ($rootScope, $compile) ->
    {
      restrict: 'A'
      link: (scope, elem, attr) ->

        isIE = false

        GetIEVersion = ->
          sAgent = window.navigator.userAgent
          Idx = sAgent.indexOf('MSIE')
          if Idx > 0
            parseInt sAgent.substring(Idx + 5, sAgent.indexOf('.', Idx))
          else if ! !navigator.userAgent.match(/Trident\/7\./)
            11
          else
            0

        if GetIEVersion() > 0
          isIE = true
        else
          isIE = false

        elem.on 'click', (e) ->
          switch attr.report
            when 'group-wise'
              if !isIE
                elem.attr
                  'href': scope.uriGroupWise
                  'download': scope.fnGroupWise
              else
                win = window.open()
                win.document.write('sep=,\r\n',scope.csvGW)
                win.document.close()
                win.document.execCommand('SaveAs',true, scope.fnGroupWise + ".csv")
                win.close()

            when 'condensed'
              if !isIE
                elem.attr
                  'href': scope.uriCondensed
                  'download': scope.fnCondensed
              else
                win = window.open()
                win.document.write('sep=,\r\n',scope.csvCond)
                win.document.close()
                win.document.execCommand('SaveAs',true, scope.fnCondensed + ".csv")
                win.close()
            when 'account-wise'
              if !isIE
                elem.attr
                  'href': scope.uriAccountWise
                  'download': scope.fnAccountWise
              else
                win = window.open()
                win.document.write('sep=,\r\n',scope.csvAW)
                win.document.close()
                win.document.execCommand('SaveAs',true, scope.fnAccountWise + ".csv")
                win.close()
            when 'profit-and-loss'
              if !isIE
                elem.attr
                  'href': scope.profitLoss
                  'download': scope.fnProfitLoss
              else
                win = window.open()
                win.document.write('sep=,\r\n',scope.csvPL)
                win.document.close()
                win.document.execCommand('SaveAs',true, scope.fnProfitLoss + ".csv")
                win.close()
          e.stopPropagation()

    }
]).filter 'recType', ->
  (input, value) ->
    if value != 0
      switch input
        when 'DEBIT'
          input = " Dr."
        when 'CREDIT'
          input = " Cr."
      input
    else
      input = ""
      input

.filter 'truncate', ->
  (value, wordwise, max, tail) ->
    if !value
      return ''
    max = parseInt(max, 10)
    if !max
      return value
    if value.length <= max
      return value
    value = value.substr(0, max)
    if wordwise
      lastspace = value.lastIndexOf(' ')
      if lastspace != -1
        value = value.substr(0, lastspace)
    value + (tail or ' …')

.filter 'highlight', ->
  (text, search, caseSensitive) ->
    if text and (search or angular.isNumber(search))
      text = text.toString()
      search = search.toString()
      if caseSensitive
        text.split(search).join '<mark class="ui-match">' + search + '</mark>'
      else
        text.replace new RegExp(search, 'gi'), '<mark class="ui-match">$&</mark>'
    else
      text

.directive('trialAccordion', [
  '$rootScope'
  '$compile'
  '$timeout'
  ($rootScope, $compile, $timeout) ->
    {
      restrict: 'A'
      link: (scope, elem, attr) ->

        # padding value
        scope.padLeft = 20

        showChild = ->
            if elem.siblings().hasClass('isHidden') 
                elem.siblings().removeClass('isHidden')
                elem.siblings().fadeIn(100)
            else 
                elem.siblings().fadeOut(100)
                elem.siblings().addClass('isHidden')
              
        # expand all
        expandAll = ->
          angular.element('.table-container').find('.isHidden').not('.account.isHidden').show().removeClass('isHidden')
          angular.element('.add-manage-grouplist').find('.isHidden').not('.account.isHidden').show().removeClass('isHidden')
          scope.expanded = true

        #collapse all
        collapseAll = ->
          $timeout (->
            angular.element('.table-container').find("[trial-accordion]").not("[trial-accordion = 'expandAll']").siblings().hide().addClass('isHidden')
            angular.element('.add-manage-grouplist').find("[trial-accordion]").not("[trial-accordion = 'expandAll']").siblings().hide().addClass('isHidden')
            scope.expanded = false
          ),100

        elem.on 'click', (e) ->
          if attr.trialAccordion != 'expandAll' && attr.trialAccordion != 'collapseAll' && attr.trialAccordion != 'search'
            showChild()

          if attr.trialAccordion == 'expandAll'
            expandAll()
          else if attr.trialAccordion == 'collapseAll'
            collapseAll()

        elem.on 'keyup', (e) ->
          if !_.isUndefined(scope.keyWord)
            if scope.keyWord.length > 2
              expandAll()
            else
              collapseAll()
    }
])
.filter 'accntsrch', ->
  (input, search) ->
    srch = search.toLowerCase()
    result = []

    checkIndex = (src, str) ->
      if src.indexOf(str) != -1
        true
      else 
        false     

    if _.isEmpty(srch)
      _.each input, (grp) ->
        grp.accountDetails = grp.beforeFilter
      input
    else

      _.each input, (grp) ->
        grp.accountDetails = grp.beforeFilter
        matchCase = ''
        grpName = grp.groupName.toLowerCase()
        grpUnq = grp.groupUniqueName.toLowerCase()
        grpSyn = if !_.isNull(grp.groupSynonyms) then grp.groupSynonyms.toLowerCase() else ''
        accounts = []
        if checkIndex(grpName, srch) || checkIndex(grpUnq, srch) || checkIndex(grpSyn, srch) 
          matchCase = 'Group'
          if grp.beforeFilter.length > 0
            _.each grp.beforeFilter, (acc) ->
              accName = acc.name.toLowerCase()
              accUnq = acc.uniqueName.toLowerCase()
              accMergeAcc = acc.mergedAccounts.toLowerCase()
              if checkIndex(accName, srch) || checkIndex(accUnq, srch) || checkIndex(accMergeAcc, srch)
                matchCase = 'Account'
              if checkIndex(accName, srch) || checkIndex(accUnq, srch) || checkIndex(accMergeAcc, srch) && checkIndex(grpName, srch) || checkIndex(grpUnq, srch) || checkIndex(grpSyn, srch) 
                matchCase = 'Group and Account'

              if matchCase == 'Account'
                accounts.push(acc)
                
        else  
          if grp.beforeFilter.length > 0
            _.each grp.beforeFilter, (acc) ->
              accName = acc.name.toLowerCase()
              accUnq = acc.uniqueName.toLowerCase()
              accMergeAcc = acc.mergedAccounts.toLowerCase()
              if checkIndex(accName, srch) || checkIndex(accUnq, srch) || checkIndex(accMergeAcc, srch)
                matchCase = 'Account'
                accounts.push(acc)
              grp.accountDetails = accounts

        switch matchCase
          when 'Group'
            result.push(grp)
          when 'Account'
            result.push(grp)
          when 'Group and Account'
            result.push(grp)

      result

.directive('leftMargin', [
  '$rootScope'
  '$compile'
  '$timeout'
  ($rootScope, $compile, $timeout) ->
    {
      restrict: 'A'
      link: (scope, elem, attr) ->
        # if attr.dragAround == 'true' 
        #   $(elem).draggable()

        #   $(elem).on('drag', (e)->
        #     if $(elem).hasClass('fixed-panel')
        #       $(elem).removeClass('fixed-panel')
        #       $(elem).css('bottom','initial')
        #   )

          getLeftSectionWidth = () ->
            left = $('.col-xs-2.greyBg').width()

          setPanelLeftPos = (left) ->
            $(elem).find('.ledger-panel').css('left', left + 45)

          window.addEventListener('resize', (e) ->
            left = getLeftSectionWidth()
            setPanelLeftPos(left)
          )

          $(document).ready((e)->
            left = getLeftSectionWidth()
            setPanelLeftPos(left)
          )
    }
])

.directive 'optionList', ['$window', '$timeout', ($window, $timeout) ->

  link: (scope, elem, attr) ->

    btn = $(elem).find('#showHide')
    target = $(elem).find('.ol-options')


    btn.on 'click', (e) ->

      target.toggle("slide", {direction: "right"}, 300)



]


.directive 'triggerFocus', ['$window', '$timeout', ($window, $timeout) ->

  link: (scope, elem, attr) ->

    idx = parseInt(attr.index)
    tL = attr.txnlength - 1
    txn = JSON.parse(attr.txn)

    if idx == tL && txn.particular.name == "" && txn.particular.uniqueName == "" && txn.amount == 0
      $(elem).trigger('click')
    
]


.directive 'inputFocus', ['$window', '$timeout', ($window, $timeout) ->
  scope: 
    isOpen: '=isOpen'
  link: (scope, elem, attr) ->

    scope.$watch('isOpen', (newVal, oldVal) ->
      if newVal
        $timeout ( ->
          $(elem).trigger('focus')
        ), 200
    )
    
]

.directive 'setDropOverflow', ['$window', '$timeout', ($window, $timeout) ->
  link: (scope, elem, attr) ->

    $(elem).parent().parent().css({
      'max-height':150
      'max-width':300
      'overflow':'scroll'
    })
    
]

.directive 'coverPage', ['$window', '$timeout', ($window, $timeout) ->
  restrict: "EA"
  link: (scope, elem, attr) ->
    interval = Number(attr.timeout) || 2000

    setHeight = () ->
      top = $(elem).offset().top || 108
      exclude = $(window).innerHeight() - top
      height = $(window).innerHeight() - top
      $(elem).css("height", height)

    angular.element($window).on 'resize', ->
      setHeight()

    $timeout ( ->
      angular.element($window).triggerHandler('resize')
    ), interval
]

.directive 'customSort', ['$window', '$timeout', '$scope', '$filter', ($window, $timeout, $scope, $filter) ->
  restrict: "A"
  transclude: true
  scope: {
    order: '='
    sort: '='
  }
  template :"<a ng-click='sort_by(order)' style='color: #555555;'>"+
    "<span ng-transclude></span>"+
    "<i ng-class='selectedCls(order)'></i>"+
    "</a>"
link: (scope, elem, attr) ->
  scope.sort_by = (newSortingOrder) ->
    sort = scope.sort;

    if sort.sortingOrder == newSortingOrder
      sort.reverse = !sort.reverse

    sort.sortingOrder = newSortingOrder

  scope.selectedCls = (column) ->
    if column == scope.sort.sortingOrder
      ('icon-chevron-' + ((scope.sort.reverse) ? 'down' : 'up'))
    else
      'icon-sort'

]

.directive 'getFullHeight', ['$window', '$timeout', ($window, $timeout) ->
  restrict: "EA"
  link: (scope, elem, attr) ->
    setHeight = () ->
      height = $(window).innerHeight()
      $(elem).css({"height": height, "overflow-y":"auto"})
    
    $(window).on('resize', (e) ->
      setHeight()
    )

    setHeight()
]


.directive 'ledgerScroller', ['$window', '$timeout','$parse', ($window, $timeout, $parse) ->
  restrict: "EA"
  link: (scope, elem, attrs) ->
    invoker = $parse(attrs.scrolled)

    $(elem).on('scroll', (e) ->
      if $(elem).scrollTop()+$(elem).innerHeight() <= elem[0].scrollHeight
        invoker(scope, {top : $(elem).scrollTop(), height:elem[0].scrollHeight})
    )

]

.directive 'setPopoverPosition', ['$window', '$timeout', ($window, $timeout) ->
  restrict: "EA"
  link: (scope, elem, attrs) ->
    
    # setPos = () ->
    #   $timeout ( ->
    #     frame = $(window).height() / 3 * 2
    #     offset = $(elem).offset().top
        
    #     if offset > frame
    #       attrs.$set("popoverPlacement", "top")
    #     else
    #       attrs.$set("popoverPlacement", "bottom")

    #   ), 500

    # setPos()

    $(elem).on('mouseover', (e)->
      if e.pageY > $(window).height() / 3 * 2
        attrs.$set("popoverPlacement", "top")
      else
        attrs.$set("popoverPlacement", "bottom")
    )

    # $(elem).find('input').on('focus', (e) ->
    #   if $(e.currentTarget).offset().top > $(window).height() / 3 * 2
    #     attrs.$set("popoverPlacement", "top")
    #   else
    #     attrs.$set("popoverPlacement", "bottom")
    # )

]