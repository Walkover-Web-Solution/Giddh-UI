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
    "LocalStorageModule"
    "vAccordion"
    "trialBalance"
    # "file-model"
  ]
)

app.config (localStorageServiceProvider) ->
  localStorageServiceProvider.setPrefix 'giddh'

# app.config ($locationProvider, $routeProvider) ->
#   $locationProvider.html5Mode({
#     enabled: false,
#     requireBase: false
#   })
#   $routeProvider
#   .when('/home',
#     controller: 'companyController',
#     templateUrl: '/public/webapp/views/home.html',
#     firstTimeUser: false
#   )
#   .when('/thankyou',
#     controller: 'thankyouController',
#     templateUrl: '/public/webapp/views/thanks.html'
#   )
#   .when('/ledger',
#     controller: 'ledgerController',
#     templateUrl: '/public/webapp/views/ledger.html'
#   )
#   .when('/user',
#     controller: 'userController',
#     templateUrl: '/public/webapp/views/userDetails.html'
#   )
#   .otherwise redirectTo: '/home'

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
  # .state('transaction-card-details',
  #   url:'/transaction-card-details',
  #   templateUrl:'/public/webapp/views/cardDetails.html',
  #   controller:'trialBalanceController'
  #   )
  # .state('ledger.accounts',
  #   url:'',
  #   templateUrl:'/public/webapp/views/accounts.html'
  #   )
  $locationProvider.html5Mode(false)
  return



app.run [
  '$rootScope'
  '$state'
  '$stateParams'
  '$location'
  ($rootScope, $state, $stateParams, $location) ->
    $rootScope.$on '$stateChangeStart', ->
      if $state.current.name == 'ledger.ledgerContent'
        $rootScope.$broadcast 'refreshLedger'
      $rootScope.showLedgerBox = false
      return
    return
]

app.config ($httpProvider) ->
  $httpProvider.interceptors.push('appInterceptor')

app.factory 'appInterceptor', ['$q', '$location', '$log',
  ($q, $location, $log) ->
    response: (response) ->
      response

    responseError: (responseError) ->
      if responseError.status is 0
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
