'use strict'

angular.module('giddhApp').directive 'datePicker', ['$filter', ($filter) ->
  scope: {
    ngModel: '='
  }
  (scope, element) ->
    today = new Date()
    element.datetimepicker
      defaultSelect: false
      yearStart:today.getFullYear()
      minDate:$filter('date')(today,"MMM dd, yyyy")
      minTime:$filter('date')(today,"HH:mm")
      onChangeDateTime: (currentTime,$input)->
        setDateTime($input, currentTime, scope)

    setDateTime = (ele, val, scope) ->
      scope.$apply(()->
        scope.selectedExpiryDate = $filter('date')(val,"MMM dd, yyyy HH:mm")
      )
]