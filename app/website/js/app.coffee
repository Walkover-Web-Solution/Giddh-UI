
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
  "razor-pay"
  "internationalPhoneNumber"
  ]
)
app.config (ipnConfig) ->
  ipnConfig.autoFormat = false

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

angular.module('razor-pay',[]).
directive 'razorPay', ['$compile', '$filter', '$document', '$parse', '$rootScope', '$timeout', 'toastr', ($compile, $filter, $document, $parse, $rootScope, $timeout, toastr) ->
  {
  restrict: 'A'
  scope: false
  transclude: false
  link: (scope, element, attrs) ->
    scope.proceedToPay = (e, amount) ->
      options = {
        key: scope.wlt.razorPayKey
#        key: "rzp_live_xGAsAZIdwkmLJW"
        amount: amount
        name: scope.wlt.company.name
        description: "Pay for " + scope.wlt.contentType + " #" + scope.wlt.contentNumber
        handler: (response)->
# hit api after success
#          console.log response, "response after success"
          sendThis = {
            companyUniqueName: scope.wlt.company.uniqueName
            uniqueName: scope.wlt.contentNumber
            paymentId: response.razorpay_payment_id
          }
          scope.successPayment(sendThis)
          # need to call payment api
        prefill:
          name: scope.wlt.consumer.name
          email: scope.wlt.consumer.email
          contact: scope.wlt.consumer.contactNo
        order_id: scope.wlt.orderId
        notes: {
          order_id: scope.wlt.orderId
        }
      }
      rzp1 = new Razorpay(options)
      rzp1.open()
      e.preventDefault()

    element.on 'click', (e) ->
      diff = scope.removeDotFromString(scope.wlt.amount)
      scope.proceedToPay(e, Number(scope.wlt.amount)*100)
  }
]
app.controller 'paymentCtrl', [
  '$scope', 'toastr', '$http', '$location', '$rootScope', '$filter', '$sce'
  ($scope, toastr, $http, $location, $rootScope, $filter, $sce) ->
    urlSearch = window.location.search
    searchArr = urlSearch.split("=")
    $scope.randomUniqueName = searchArr[1]
    data = {}
    data.randomNumber = $scope.randomUniqueName
    $scope.wlt = {
      Amnt:100
      orderId: ""
    }
    $scope.basicInfo = {
      name: 'ravi soni'
      email: 'ravisoni@walkover.in'
    }
    $scope.pdfFile = ""
    $scope.showInvoice = false
    $scope.removeDotFromString = (str) ->
      return Math.floor(Number(str))

    $scope.b64toBlob = (b64Data, contentType, sliceSize) ->
      contentType = contentType or ''
      sliceSize = sliceSize or 512
      byteCharacters = atob(b64Data)
      byteArrays = []
      offset = 0
      while offset < byteCharacters.length
        slice = byteCharacters.slice(offset, offset + sliceSize)
        byteNumbers = new Array(slice.length)
        i = 0
        while i < slice.length
          byteNumbers[i] = slice.charCodeAt(i)
          i++
        byteArray = new Uint8Array(byteNumbers)
        byteArrays.push byteArray
        offset += sliceSize
      blob = new Blob(byteArrays, type: contentType)
      blob
    $scope.getDetails = () ->
      $http.post('/invoice-pay-request', data).then(
        (response) ->
          $scope.wlt = response.data.body
#          str = $scope.wlt.content + "/" + $scope.wlt.contentNumber
#          data = $scope.b64toBlob(str, "application/pdf", 512)
#          blobUrl = URL.createObjectURL(data)
#
          $scope.content = "data:application/pdf;base64," + $scope.wlt.content
          $scope.pdfFile = $sce.trustAsResourceUrl($scope.content);
          $scope.contentHtml = $sce.trustAsHtml($scope.wlt.htmlContent)
          $scope.showInvoice = true
        (error) ->
          toastr.error(error.data.message)
      )

    $scope.successPayment = (data) ->
      if $scope.wlt.contentType == "invoice"
        $http.post('/invoice/pay', data).then(
          (response) ->
            toastr.success(response.data.body)
          (error) ->
            toastr.error(error.data.message)
        )
      else if $scope.wlt.contentType == "proforma"
        $http.post('/proforma/pay', data).then(
          (response) ->
            toastr.success(response.body)
          (error) ->
            toastr.error(error.data.message)
        )

    $scope.downloadInvoice = () ->
      dataUri = 'data:application/pdf;base64,' + $scope.wlt.content
      a = document.createElement('a')
      a.download = $scope.wlt.contentNumber+".pdf"
      a.href = dataUri
      a.click()

    $scope.getDetails()
]

app.controller 'homeCtrl', [
  '$scope', 'toastr', '$http', 'vcRecaptchaService', '$rootScope', '$location',
  ($scope, toastr, $http, vcRecaptchaService, $rootScope, $location) ->
    $scope.showLoginBox = false
    $scope.toggleLoginBox = (e) ->
      $scope.showLoginBox = !$scope.showLoginBox
      e.stopPropagation()

    $scope.resources = [
      'https://test-fs8eefokm8yjj.stackpathdns.com/public/website/images/Giddh.mp4'
    ]
    $scope.poster = 'https://test-fs8eefokm8yjj.stackpathdns.com/public/website/images/new/banner.jpg'
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

      $http.post('/contact/submitDetails', data).then((response) ->
        $scope.formSubmitted = true
        if(response.status == 200 && _.isUndefined(response.data.status))
          $scope.responseMsg = "Thanks! we will get in touch with you soon"
        else
          $scope.responseMsg = response.data.message
      )

    $(document).on('click', (e) ->
      $scope.showLoginBox = false
    )
    $scope.goTo = (state) ->
      window.location = state
      
    $scope.goToNewTab = (state) ->
      window.open(state,"_blank")


    $scope.geo = {}
    $scope.geo.country = 'IN'
    getLocation = () ->
      @success = (res) ->
        $scope.geo = res.data

      @failure = (res) ->
        console.log res
        #toastr.error(res.data)

      $http.get('/user-location').then(@success, @failure)

    getLocation()
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
    #stoken: '6LcgBiATAAAAACj5K_70CDbRUSyGR1R7e9gckO1w'
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
    $rootScope.loginPage = false
    $rootScope.signupPage = false
    $rootScope.fixedHeader = false
    $rootScope.showBlack = false
    loc = window.location.pathname
    if loc == "/index" or loc == "/"
      $rootScope.whiteLinks = true
    if loc == "/magic"
      $rootScope.magicLinkPage = true
      $rootScope.fixedHeader = false
      $rootScope.showBlack = true
    if loc == "/login"
      $rootScope.whiteLinks = true
      $rootScope.loginPage = true
    if loc == "/about"
      $rootScope.whiteLinks = true
      $rootScope.fixedHeader = true
    if loc == "/payment"
      $rootScope.showBlack = true
    if loc == "/signup"
      $rootScope.whiteLinks = true
      $rootScope.signupPage = true
  
    ##detect if browser is IE##
    isIE = ->
      ua = navigator.userAgent

      ### MSIE used to detect old browsers and Trident used to newer ones###

      is_ie = ua.indexOf('MSIE ') > -1 or ua.indexOf('Trident/') > -1
      is_ie

    $rootScope.browserIE = false

    if isIE()
      $rootScope.browserIE = true
      window.location.pathname = '/IE' 
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
  ($scope, toastr, $http, $location, $rootScope, $filter, FileSaver) ->
    ml = this
    $rootScope.magicLinkPage = true
    $scope.magicReady = false
    $scope.magicLinkId = window.location.search.split('=')
    $scope.magicLinkId = $scope.magicLinkId[1]
    $scope.ledgerData = []
    $scope.magicUrl = '/magic-link'
    $scope.downloadInvoiceUrl = $scope.magicUrl + '/download-invoice'
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
    $scope.isCompoundEntry = false


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
          $scope.countTotalTransactions()
          $scope.magicReady = true
          $scope.showError = false
          $scope.assignDates($scope.ledgerData.ledgers[0].entryDate, $scope.ledgerData.ledgers[$scope.ledgerData.ledgers.length-1].entryDate)
        (error)->
          toastr.error(error.data.message)
          $scope.magicReady = true
          $scope.showError = true
      )

    $scope.downloadInvoice = (invoiceNumber) ->
      @success = (res) ->
        blobData = ml.b64toBlob(res.data.body, "application/pdf", 512)
        FileSaver.saveAs(blobData, invoiceNumber + ".pdf")
      @failure = (res) ->
        toastr.error(res.message)
      _data = {
        id: $scope.data.id
        invoiceNum: invoiceNumber
      }
      $http.post($scope.downloadInvoiceUrl, data:_data).then @success, @failure  

    $scope.getData($scope.data)

    ml.b64toBlob = (b64Data, contentType, sliceSize) ->
      contentType = contentType or ''
      sliceSize = sliceSize or 512
      # b64Data = b64Data.replace(/\s/g, '')
      byteCharacters = atob(b64Data)
      byteArrays = []
      offset = 0
      while offset < byteCharacters.length
        slice = byteCharacters.slice(offset, offset + sliceSize)
        byteNumbers = new Array(slice.length)
        i = 0
        while i < slice.length
          byteNumbers[i] = slice.charCodeAt(i)
          i++
        byteArray = new Uint8Array(byteNumbers)
        byteArrays.push byteArray
        offset += sliceSize
      blob = new Blob(byteArrays, type: contentType)
      blob

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
        data.uLname = ""

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

    $scope.entryTotal = {}
    $scope.entryTotal.amount = ''
    $scope.entryTotal.type = ''

    $scope.checkCompEntry = (ledger) ->
      #$scope.entryTotal = ledger.total
      unq = ledger.uniqueName
      ledger.isCompoundEntry = true
      _.each $scope.ledgerData.ledgers, (lgr) ->
        if unq == lgr.uniqueName
          lgr.isCompoundEntry = true
        else
          lgr.isCompoundEntry = false

    $scope.creditTotal = 0
    $scope.debitTotal = 0
    $scope.countTotalTransactions = () ->
      $scope.creditTotal = 0
      $scope.debitTotal = 0
      $scope.dTxnCount = 0
      $scope.cTxnCount = 0
      if $scope.ledgerData.ledgers.length > 0
        _.each $scope.ledgerData.ledgers, (ledger) ->
          if ledger.transactions.length > 0
            _.each ledger.transactions, (txn) ->
              txn.isOpen = false
              if txn.type == 'DEBIT'
                $scope.dTxnCount += 1
                $scope.debitTotal += Number(txn.amount)
              else
                $scope.cTxnCount += 1
                $scope.creditTotal += Number(txn.amount)


]


app.controller 'successCtrl', [
  '$scope', 'toastr', '$http', '$location', '$rootScope', '$filter',
  ($scope, toastr, $http, $location, $rootScope, $filter) ->
    urlSearch = window.location.search
    searchArr = urlSearch.split("=")
    LoginId = searchArr[1]
    url = '/ebanks/login'
    data = {
      loginId : LoginId
    }
    
    $http.put(url, data).then(
      (success)->
        
      (error)->

    )

]

app.controller 'verifyEmailCtrl', [
  '$scope', 'toastr', '$http',
  ($scope, toastr, $http) ->
    urlSearch = window.location.search
    if !_.isEmpty(urlSearch)
      searchArr = urlSearch.split("&")
      emailAddress = searchArr[0].split("=")[1]
      companyUniqueName = searchArr[1].split("=")[1]
      scope = searchArr[2].split("=")[1]
      data = {}
      data.companyUname = companyUniqueName
      data.emailAddress = emailAddress
      data.scope = scope
      url = '/verify-email'

      $http.post(url, data).then(
        (success)->
          console.log(success)
        (error)->
          console.log(error)

      )
]

app.directive 'numbersOnly', ->
  {
    require: 'ngModel'
    link: (scope, element, attr, ngModelCtrl) ->

      fromUser = (text) ->
        if text
          transformedInput = text.replace(/[^0-9]/g, '')
          if transformedInput != text
            ngModelCtrl.$setViewValue transformedInput
            ngModelCtrl.$render()
          return transformedInput
        undefined

      ngModelCtrl.$parsers.push fromUser
      return

  }

app.directive 'numberSelect', ->
  {
    require: 'ngModel'
    link: (scope, element, attr, ngModelCtrl) ->
      $(element).intlTelInput()
      scope.intlNumber = $(element).intlTelInput("getNumber")

      scope.$watch('intlNumber', (newVal, oldVal) ->
        if newVal != oldVal
          console.log newVal
      )

      $(element).on("countrychange", (e, countrydata) ->
        console.log countrydata
      )

  }

# resources locations
# video background- https://github.com/2013gang/angular-video-background
# angular-fullPage.js- https://github.com/hellsan631/angular-fullpage.js
# angular-recaptcha- https://github.com/VividCortex/angular-recaptcha
