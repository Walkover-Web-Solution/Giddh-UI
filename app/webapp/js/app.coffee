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
  ]
)

app.config (localStorageServiceProvider) ->
  localStorageServiceProvider.setPrefix 'giddh'

app.config ($locationProvider, $routeProvider) ->
  $locationProvider.html5Mode({
    enabled: false,
    requireBase: false
  })
  $routeProvider
  .when('/home',
    controller: 'companyController',
    templateUrl: '/public/webapp/views/home.html',
    firstTimeUser: false
  )
  .when('/thankyou',
    controller: 'thankyouController',
    templateUrl: '/public/webapp/views/thanks.html'
  )
  .when('/ledger',
    controller: 'ledgerController',
    templateUrl: '/public/webapp/views/ledger.html'
  )
  .when('/user',
    controller: 'userController',
    templateUrl: '/public/webapp/views/userDetails.html'
  )
  .otherwise redirectTo: '/home'
app.run(()->
)

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
    # autoDismiss: false
    # containerId: 'toast-container'
    maxOpened: 3
    closeButton: true
    # newestOnTop: true
    # positionClass: 'toast-top-right'
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
#perfect_scrollbar - perfect_scrollbar
# toastr = https://github.com/Foxandxss/angular-toastr