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
  $httpProvider.interceptors.push('giddhHttpResponseInterceptor')



app.factory 'giddhHttpResponseInterceptor', [
  '$q'
  '$location'
  '$log'
  ($q, $location, $log) ->
    $log.debug '$log is here to show you that this is a regular factory with injection'
    giddhInterceptor = { 
      response: (response) ->
        # console.log response, "response"
        response
      responseError: (responseError) ->
        console.log responseError, "responseError"
        if responseError.status is 0
          $location.path('/thankyou')
        else
          responseError
    }
    giddhInterceptor
]

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