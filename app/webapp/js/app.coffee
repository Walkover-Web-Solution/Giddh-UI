'use strict'
window.giddh = {}

giddh.serviceModule = angular.module("serviceModule", ["LocalStorageModule", "ngResource", "ui.bootstrap"])

giddh.webApp = angular.module("giddhWebApp",
  [
    "satellizer"
    "LocalStorageModule"
    "ngRoute"
    "perfect_scrollbar"
    "ngSanitize"
    "ui.bootstrap"
    "twygmbh.auto-height"
    "toastr"
    "ui.tree"
    "valid-number"
    "valid-date"
    "ledger"
    "angular.filter"
    "unique-name"
    "ui.router"
    "trialBalance"
    'ngFileUpload'
    "exportDirectives"
    "serviceModule"
    "chart.js"
    "ui.select"
  ]
)

giddh.webApp.config (localStorageServiceProvider) ->
  localStorageServiceProvider.setPrefix 'giddh'


giddh.webApp.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $urlRouterProvider.otherwise('/home')
  $stateProvider.state('/home',
    url: '/home'
    resolve: {
      companyServices: 'companyServices'
      localStorageService: 'localStorageService'
      getLedgerState: (companyServices, localStorageService) ->
        checkRole = (data) ->
          return {
          type: data.role.uniqueName
          data: data
          }
        onSuccess = (res) ->
          companyList = _.sortBy(res.body, 'shared')
          cdt = localStorageService.get("_selectedCompany")
          if not _.isNull(cdt) && not _.isEmpty(cdt) && not _.isUndefined(cdt)
            cst = _.findWhere(companyList, {uniqueName: cdt.uniqueName})
            console.info "data from localstorage match"
            checkRole(cst)
          else
            console.info "direct from api"
            checkRole(companyList[0])
        onFailure = (res) ->
          toastr.error('Failed to retrieve company list' + res.data.message)
        companyServices.getAll().then(onSuccess, onFailure)
    }
    templateUrl: '/public/webapp/views/demo.html'
    controller: 'homeController')
  .state('manage-company',
    url: '/manage-company'
    templateUrl: '/public/webapp/views/home.html'
    controller: 'companyController')
  .state('/thankyou',
    url: '/thankyou'
    templateUrl: '/public/webapp/views/thanks.html'
    controller: 'thankyouController')
  .state('/user',
    url: '/user'
    templateUrl: '/public/webapp/views/userDetails.html'
    controller: 'userController')
  .state('ledger',
    abstract: true
    url: '/ledger:uniqueName'
    templateUrl: '/public/webapp/views/ledger.html'
  )
  .state('ledger.ledgerContent',
    url: '/:unqName',
    views: {
      'accounts':{
        templateUrl: '/public/webapp/views/accounts.html'
        controller: 'accountController'
      }
      'ledgerContent':{
        templateUrl: '/public/webapp/views/ledgerContent.html'
        controller: 'ledgerController'
      }
    }
  )
  .state('Trial-Balance',
    url: '/trial-balance',
    templateUrl: '/public/webapp/views/trialBalance.html',
    controller: 'trialBalanceController'
  )
  .state('Profit-and-Loss',
    url: '/profit-and-loss',
    templateUrl: '/public/webapp/views/profitLoss.html',
    controller: 'profitLossController'
  )
  .state('Reports',
    url: '/reports',
    templateUrl: '/public/webapp/views/reports.html',
    controller: 'reportsController'
  )


  $locationProvider.html5Mode(false)
  return

giddh.webApp.run [
  '$rootScope'
  '$state'
  '$stateParams'
  '$location'
  '$window'
  'toastr'
  ($rootScope, $state, $stateParams, $location, $window, toastr) ->
    $rootScope.$on '$stateChangeStart', ->
      $rootScope.showLedgerBox = false

    # check IE browser version
    $rootScope.GetIEVersion = () ->
      ua = window.navigator.userAgent
      msie = ua.indexOf('MSIE ')
      trident = ua.indexOf('Trident/')
      edge = ua.indexOf('Edge/')
      if (msie > 0)
        toastr.error('For Best User Expreince, upgrade to IE 11+')
    $rootScope.GetIEVersion()
    # check browser
    $rootScope.msieBrowser = ()->
      ua = window.navigator.userAgent
      msie = ua.indexOf('MSIE')
      if msie > 0 or !!navigator.userAgent.match(/Trident.*rv\:11\./)
        return true
      else
        console.info window.navigator.userAgent, 'otherbrowser', msie
        return false
    # open window for IE
    $rootScope.openWindow = (url) ->
      win = window.open()
      win.document.write('sep=,\r\n', url)
      win.document.close()
      win.document.execCommand('SaveAs', true, 'abc' + ".xls")
      win.close()

    $rootScope.firstLogin = true
]

giddh.webApp.config ($httpProvider) ->
  $httpProvider.interceptors.push('appInterceptor')

giddh.webApp.factory 'appInterceptor', ['$q', '$location', '$log', 'toastr', '$timeout' 
  ($q, $location, $log, toastr, $timeout) ->
    request: (request) ->
      request
    response: (response) ->
      response

    responseError: (responseError) ->
      if responseError.status is 500
        #check if responseError.data contains error regarding Auth-Key
        isError = responseError.data.indexOf("`value` required in setHeader") 
        isAuthKeyError = responseError.data.indexOf("Auth-Key")
        #if Auth-Key Error found, redirect to login
        if isError != -1 and isAuthKeyError != -1
          toastr.error('Your Session has Expired, Please Login Again.')
          $timeout ( ->
            window.location.assign('/login')
          ), 2000
      else
        $q.reject responseError
]

# toastr setting
giddh.webApp.config (toastrConfig) ->
  angular.extend toastrConfig,
    maxOpened: 3
    closeButton: true
    preventDuplicates: false
    preventOpenDuplicates: true
    target: 'body'
  return

#for project lib helps check out
#bootstrap related - http://angular-ui.github.io/bootstrap/#/tooltip
#LocalStorageModule - https://github.com/grevory/angular-local-storage
#perfect_scrollbar - https://github.com/noraesae/perfect-scrollbar
#toastr = https://github.com/Foxandxss/angular-toastr
#angular filter - https://github.com/a8m/angular-filter#filterby
#file upload - https://github.com/danialfarid/ng-file-upload
