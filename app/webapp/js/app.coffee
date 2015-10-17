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
    controller: 'companyController',
    templateUrl: '/public/webapp/views/thanks.html'
  )
  .when('/ledger',
    controller: 'ledgerController',
    templateUrl: '/public/webapp/views/ledger.html'
  )
  .otherwise redirectTo: '/home'
app.run(()->
)

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