
app = angular.module("giddhApp", [
  "satellizer"
  "LocalStorageModule"
  "ngResource"
  "toastr"
  ]
)

app.config [
  '$authProvider'
  ($authProvider) ->
    $authProvider.google clientId: '641015054140-3cl9c3kh18vctdjlrt9c8v0vs85dorv2.apps.googleusercontent.com'
    $authProvider.twitter clientId: 'w64afk3ZflEsdFxd6jyB9wt5j'
    $authProvider.linkedin clientId: '75urm0g3386r26'

    # LinkedIn
    $authProvider.linkedin({
      url: '/auth/linkedin'
      authorizationEndpoint: 'https://www.linkedin.com/uas/oauth2/authorization'
      # redirectUri: "http://localhost:8000/login/"
      redirectUri: window.location.origin+"/login/"
      requiredUrlParams: ['state']
      scope: ['r_emailaddress']
      scopeDelimiter: ' '
      state: 'STATE'
      type: '2.0'
      popupOptions: { width: 527, height: 582 }
    })
]

app.config (localStorageServiceProvider) ->
  localStorageServiceProvider.setPrefix 'giddh'

app.run [
  '$rootScope'
  '$window'
  ($rootScope, $window)->
    
    #console.log window.location, "app run", window.location.origin
]
  


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
