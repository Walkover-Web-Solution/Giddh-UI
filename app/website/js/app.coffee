
app = angular.module("giddhApp", [
  "satellizer"
  "LocalStorageModule"
  "ngResource"
  "toastr"
  "ngVidBg"
  ]
)

app.controller 'homeCtrl', [
  '$scope', 'toastr', '$http'
  ($scope, toastr, $http) ->
    $scope.resources = [
      'https://s3-us-west-2.amazonaws.com/coverr/mp4/Coverr-beach2.mp4'
    ]
    $scope.poster = '/public/website/images/new/banner.jpg'
    $scope.fullScreen = true
    $scope.muted = false
    $scope.zIndex = '0'
    $scope.playInfo = {}
    $scope.pausePlay = true

    $scope.formSubmitted = false
    $scope.formProcess = false

    $scope.socialList= [
      # {
      #   name: "Google",
      #   url: "javascript:void(0)",
      #   class: "gplus"
      # }
      {
        name: "Facebook"
        url: "http://www.facebook.com/giddh"
        class: "fb"
      }
      {
        name: "Linkedin"
        url: "javascript:void(0)"
        class: "in"
      }
      {
        name: "Twitter"
        url: "https://twitter.com/giddhcom/"
        class: "twit"
      }
      # {
      #   name: "Youtube"
      #   url: "http://www.youtube.com/watch?v=p6HClX7mMMY"
      #   class: "yt"
      # }
      # {
      #   name: "RSS"
      #   url: "http://blog.giddh.com/feed/"
      #   class: "rss"
      # }
    ]

    # check string has whitespace
    $scope.hasWhiteSpace = (s) ->
      return /\s/g.test(s)

    $scope.validateEmail = (emailStr)->
      pattern = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
      return pattern.test(emailStr)
    
    $scope.submitForm =(data)->
      $scope.formProcess = true
      #check and split full name in first and last name
      if($scope.hasWhiteSpace(data.name))
        unameArr = data.name.split(" ")
        data.uFname = unameArr[0]
        data.uLname = unameArr[1]
      else
        data.uFname = data.name
        data.uLname = "  "

      if not($scope.validateEmail(data.email))
        toastr.warning("Enter valid Email ID", "Warning")
        return false

      data.company = ''

      if _.isEmpty(data.message)
        data.message = 'test'

      $http.post('http://localhost:8000/contact/submitDetails', data).then((response) ->
          $scope.formSubmitted = true
          if(response.status == 200 && _.isUndefined(response.data.status))  
            $scope.responseMsg = "Thanks! will get in touch with you soon"
          else
            $scope.responseMsg = response.data.message
        )
]

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

# resources locations
# video background- https://github.com/2013gang/angular-video-background
