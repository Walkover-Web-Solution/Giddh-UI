
app = angular.module("giddhApp", [
  "satellizer"
  "ui.bootstrap"
  "LocalStorageModule"
  "ngResource"
  "toastr"
  "ngVidBg"
  "fullPage.js"
  "vcRecaptcha"
  "valid-number"
  ]
)

angular.module('valid-number', []).
directive 'validNumber', ->
  {
  require: '?ngModel'
  link: (scope, element, attrs, ngModelCtrl) ->
    if !ngModelCtrl
      return
    ngModelCtrl.$parsers.push (val) ->
      if angular.isUndefined(val)
        val = ''
      if _.isNull(val)
        val = ''
      clean = val.replace(/[^0-9\.]/g, '')
      decimalCheck = clean.split('.')
      if !angular.isUndefined(decimalCheck[1])
        decimalCheck[1] = decimalCheck[1].slice(0, 2)
        clean = decimalCheck[0] + '.' + decimalCheck[1]
      if val != clean
        ngModelCtrl.$setViewValue clean
        ngModelCtrl.$render()
      clean
    element.on 'keypress', (event) ->
      if event.keyCode == 32
        event.preventDefault()
      return
    return

  }

app.controller 'homeCtrl', [
  '$scope', 'toastr', '$http', 'vcRecaptchaService', '$rootScope', '$location',
  ($scope, toastr, $http, vcRecaptchaService, $rootScope, $location) ->
    $scope.resources = [
      '/public/website/images/Giddh.mp4'
    ]
    $scope.poster = '/public/website/images/new/banner.jpg'
    $scope.fullScreen = true
    $scope.muted = false
    $scope.zIndex = '0'
    $scope.playInfo = {}
    $scope.pausePlay = true

    $scope.formSubmitted = false
    $scope.formProcess = false

    $scope.pageOptions = {
      sectionsColor: ['#1bbc9b', '#FFF6E7', '#E3422E', '#4BBFC3', '#7BAABE', '#FFF6E7', '#FFF6E7', '#E34A26']
      navigation: true
      navigationPosition: 'right'
      scrollingSpeed: 800
      scrollOverflow: true
      responsiveWidth: 600
      responsiveHeight: 400
    }
    $rootScope.homePage = true
    $rootScope.pricingPage = false

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

    $scope.captchaKey = '6LcgBiATAAAAAMhNd_HyerpTvCHXtHG6BG-rtcmi'


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

      $http.post('https://giddh.com/contact/submitDetails', data).then((response) ->
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


app.config (vcRecaptchaServiceProvider)->
  vcRecaptchaServiceProvider.setDefaults({
    key: '6LcgBiATAAAAAMhNd_HyerpTvCHXtHG6BG-rtcmi'
    # theme: 'dark'
    stoken: '6LcgBiATAAAAACj5K_70CDbRUSyGR1R7e9gckO1w'
    # size: 'compact'
  })

# app.config [
#   '$locationProvider'
#   ($locationProvider) ->
#     $locationProvider.html5Mode({
#       enabled: true
#       requireBase: false
#     })
# ]

app.run [
  '$rootScope'
  '$window'
  ($rootScope, $window)->
    $rootScope.magicLinkPage = false
    $rootScope.whiteLinks = false
    loc = window.location.pathname
    if loc == "/index" or loc == "/" or loc == "/login"
      $rootScope.whiteLinks = true
    if loc == "/magic"
      $rootScope.magicLinkPage = true

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

app.controller 'magicCtrl', [
  '$scope', 'toastr', '$http', '$location', '$rootScope', '$filter',
  ($scope, toastr, $http, $location, $rootScope, $filter) ->
    $rootScope.magicLinkPage = true
    $scope.magicReady = false
    $scope.magicLinkId = window.location.search.split('=')
    $scope.magicLinkId = $scope.magicLinkId[1]
    $scope.ledgerData = []
    $scope.magicUrl = '/magic-link'
    $scope.today = new Date()
    $scope.fromDate = {date: new Date()}
    $scope.toDate = {date: new Date()}
    $scope.fromDatePickerIsOpen = false
    $scope.toDatePickerIsOpen = false
    $scope.dateOptions = {
      'year-format': "'yy'",
      'starting-day': 1,
      'showWeeks': false,
      'show-button-bar': false,
      'year-range': 1,
      'todayBtn': false
    }
    $scope.format = "dd-MM-yyyy"
    $scope.showError = false
    $scope.accountName = ''


    $scope.fromDatePickerOpen = ->
      this.fromDatePickerIsOpen = true

    $scope.toDatePickerOpen = ->
      this.toDatePickerIsOpen = true
    
    $scope.data = {
      id: $scope.magicLinkId
    }  

    $scope.filterLedgers = (ledgers) ->
      _.each ledgers, (lgr) ->
        lgr.hasDebit = false
        lgr.hasCredit = false
        if lgr.transactions.length > 0
          _.each lgr.transactions, (txn) ->
            if txn.type == 'DEBIT'
              lgr.hasDebit = true
            else if txn.type == 'CREDIT'
              lgr.hasCredit = true

    $scope.assignDates = (fromDate,toDate) ->
      fdArr = fromDate.split('-')
      tdArr = toDate.split('-')
      from = new Date(fdArr[1] + '/' + fdArr[0] + '/' + fdArr[2])
      to = new Date(tdArr[1] + '/' + tdArr[0] + '/' + tdArr[2])
      $scope.fromDate.date = from
      $scope.toDate.date = to

    $scope.getData = (data) ->
      $scope.magicReady = false
      _data = data
      $http.post($scope.magicUrl, data:_data).then(
        (success)->
          $scope.accountName = success.data.body.account.name
          $scope.ledgerData = success.data.body.ledgerTransactions
          $scope.filterLedgers($scope.ledgerData.ledgers)
          $scope.magicReady = true
          $scope.showError = false
          $scope.assignDates($scope.ledgerData.ledgers[0].entryDate, $scope.ledgerData.ledgers[$scope.ledgerData.ledgers.length-1].entryDate)
        (error)->
          toastr.error(error.data.message)
          $scope.magicReady = true
          $scope.showError = true
      )

    $scope.getData($scope.data)

    $scope.getDataByDate = () ->
      $scope.data.from = $filter('date')($scope.fromDate.date, 'dd-MM-yyyy')
      $scope.data.to = $filter('date')($scope.toDate.date, 'dd-MM-yyyy')
      $scope.getData($scope.data)

    #for contact form
        # check string has whitespace
    $scope.hasWhiteSpace = (s) ->
      return /\s/g.test(s)

    $scope.validateEmail = (emailStr)->
      pattern = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
      return pattern.test(emailStr)

    $scope.captchaKey = '6LcgBiATAAAAAMhNd_HyerpTvCHXtHG6BG-rtcmi'

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

      $http.post('https://giddh.com/contact/submitDetails', data).then((response) ->
          $scope.formSubmitted = true
          if(response.status == 200 && _.isUndefined(response.data.status))  
            $scope.responseMsg = "Thanks! will get in touch with you soon"
          else
            $scope.responseMsg = response.data.message
        )



] 

# resources locations
# video background- https://github.com/2013gang/angular-video-background
# angular-fullPage.js- https://github.com/hellsan631/angular-fullpage.js
# angular-recaptcha- https://github.com/VividCortex/angular-recaptcha
