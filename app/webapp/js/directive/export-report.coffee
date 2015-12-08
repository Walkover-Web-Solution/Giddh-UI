angular.module('trialBalance', []).directive('exportReport', [
  '$rootScope'
  '$compile'
  ($rootScope, $compile) ->
    {
      restrict: 'A'
      link: (scope, elem, attr) ->
        elem.on 'click', (e) ->
          switch attr.report
            when 'group-wise'
              elem.attr
                'href': scope.uriGroupWise
                'download': scope.fnGroupWise
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
