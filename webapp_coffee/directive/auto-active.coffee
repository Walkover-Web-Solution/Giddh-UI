'use strict'

angular.module('giddhApp').directive 'datePicker', ['$filter', ($filter) ->
  restrict: 'A'
  scope: false
  link: (scope, element) ->

    setActive = ->
      elem = undefined
      fURL = undefined
      path = undefined
      pathT = undefined
      fURL = $location.absUrl().split('/')
      pathT = fURL.reverse()
      path = pathT[0]
      if path
        elem = angular.element('.nav li a.' + path)
        elem.addClass 'active'
      else
        elem = angular.element('.nav li a.home')
        elem.addClass 'active'

    setActive()
    scope.$on '$locationChangeSuccess', setActive
    return
]