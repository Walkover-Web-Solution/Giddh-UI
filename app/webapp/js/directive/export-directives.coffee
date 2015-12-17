angular.module('exportDirectives', []).directive('exportPdf', [
  '$rootScope'
  '$compile'
  ($rootScope, $compile) ->
    {
      restrict: 'A'
      link: (scope, elem, attr) ->
        docDefinition  = {}
        elem.on 'click', (e) ->
          docDefinition  = {
            content : [
              {
                heading: 'Walkover Web Solutions Pvt Ltd'
              }      
            ]
          }
          pdfMake.createPdf(docDefinition).open();
    }
])