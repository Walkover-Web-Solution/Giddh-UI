app = angular.module("giddhWebApp",
  [
    "satellizer"
    "LocalStorageModule"
    "ngRoute"
    "ngResource"
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
    "vAccordion"
    "trialBalance"
    'ngFileUpload'
  ]
)

app.config (localStorageServiceProvider) ->
  localStorageServiceProvider.setPrefix 'giddh'


app.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $urlRouterProvider.otherwise('/home')
  $stateProvider.state('/home',
    url: '/home'
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
  .state( 'ledger',
    abstract: true
    url: '/ledger:uniqueName'
    templateUrl: '/public/webapp/views/ledger.html'
    )
  .state('ledger.ledgerContent',
    url:'/:unqName',
    templateUrl:'/public/webapp/views/ledgerContent.html'
    controller: 'ledgerController'
    )
  .state('Trial-Balance',
    url:'/trial-balance',
    templateUrl:'/public/webapp/views/trialBalance.html',
    controller:'trialBalanceController'
    )
  $locationProvider.html5Mode(false)
  return

app.run [
  '$rootScope'
  '$state'
  '$stateParams'
  '$location'
  '$window'
  'toastr'
  ($rootScope, $state, $stateParams, $location, $window, toastr) ->
    $rootScope.$on '$stateChangeStart', ->
      $rootScope.showLedgerBox = false
    isIE = false

    GetIEVersion = ->
      ua = window.navigator.userAgent
      msie = ua.indexOf('MSIE ')
      trident = ua.indexOf('Trident/')
      edge = ua.indexOf('Edge/')
      if (msie > 0)
        toastr.error('For Best User Expreince, upgrade to IE 11+')
    GetIEVersion()
]

app.config ($httpProvider) ->
  $httpProvider.interceptors.push('appInterceptor')

app.factory 'appInterceptor', ['$q', '$location', '$log',
  ($q, $location, $log) ->
    response: (response) ->
      response

    responseError: (responseError) ->
      if responseError.status is 500
        window.location = "/login"
      else
        $q.reject responseError
]

# toastr setting
app.config (toastrConfig) ->
  angular.extend toastrConfig,
    maxOpened: 3
    closeButton: true
    preventDuplicates: false
    preventOpenDuplicates: true
    target: 'body'
  return

# confirm modal settings
app.value('$confirmModalDefaults',
  templateUrl: '/public/webapp/views/confirmModal.html',
  controller: 'ConfirmModalController',
  defaultLabels:
    title: 'Confirm'
    ok: 'OK'
    cancel: 'Cancel')

#for project lib helps check out
#bootstrap related - http://angular-ui.github.io/bootstrap/#/tooltip
#LocalStorageModule - https://github.com/grevory/angular-local-storage
#perfect_scrollbar - https://github.com/noraesae/perfect-scrollbar
#toastr = https://github.com/Foxandxss/angular-toastr
#angular filter - https://github.com/a8m/angular-filter#filterby
#file upload - https://github.com/danialfarid/ng-file-upload
