app = angular.module("giddhApp", ["satellizer", "LocalStorageModule", "ngResource"])

app.config (localStorageServiceProvider) ->
  localStorageServiceProvider.setPrefix 'giddh'

app.run ()->

do ->
  angular.module('giddhApp').directive 'autoActive', [
    '$location'
    ($location) ->
      {
      restrict: 'A'
      scope: false
      link: (scope, element) ->
        setActive = ->
          fURL = $location.absUrl().split('/')
          pathT = fURL.reverse()
          path = pathT[0]

          if path
            cElem = element.find('li a.' + path)
            cElem.addClass 'active'
          else
            cElem = element.find('.nav li a.home')
            cElem.addClass 'active'

        setActive()
        scope.$on '$locationChangeSuccess', setActive
      }
  ]