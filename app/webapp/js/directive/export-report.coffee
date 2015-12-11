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
          isIe = false

        elem.on 'click', (e) ->
          switch attr.report
            when 'group-wise'
              if !isIE
                elem.attr
                  'href': scope.uriGroupWise
                  'download': scope.fnGroupWise
              else
                win = window.open("text/html", "replace")
                win.document.write(scope.csvGW)
                win.document.close()
                win.document.execCommand('SaveAs',true, scope.fnGroupWise + ".csv")
                win.close()

            when 'condensed'
              elem.attr
                'href': scope.uriCondensed
                'download': scope.fnCondensed
            when 'account-wise'
              elem.attr
                'href': scope.uriAccountWise
                'download': scope.fnAccountWise
          e.stopPropagation()

    }
]).filter 'recType', ->
  (input) ->
    switch input
      when 'DEBIT'
        input = " Dr."
      when 'CREDIT'
        input = " Cr."
    input
