'use strict'
window.giddh = {}

giddh.serviceModule = angular.module("serviceModule", ["LocalStorageModule", "ngResource", "ui.bootstrap"])

giddh.webApp = angular.module("giddhWebApp",
  [
    "satellizer"
    "LocalStorageModule"
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
    "ngFileUpload"
    "exportDirectives"
    "serviceModule"
    "chart.js"
    "ui.select"
    "uiSwitch"
    "razor-pay"
    "ngCsv"
    "ngclipboard"
    "dashboard"
    "mgo-angular-wizard"
    "googlechart"
    "ngFileSaver"
    "gridster"
    "ui.tinymce"
    "daterangepicker"
    "inventory"
    "recurringEntry"
    "ui.mask"
    "nzTour"
  ]
)

giddh.webApp.config (localStorageServiceProvider) ->
  localStorageServiceProvider.setPrefix 'giddh'


giddh.webApp.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $urlRouterProvider.otherwise('/home')
  $locationProvider.hashPrefix('')
  # $rootScope.prefixThis = "https://test-fs8eefokm8yjj.stackpathdns.com"
  appendThis = ""
  $stateProvider.state('/home',
    url: '/home'
    resolve: {
      companyServices: 'companyServices'
      localStorageService: 'localStorageService'
      toastr: 'toastr'
      getLedgerState: (companyServices, localStorageService, toastr) ->
        user = {
          role :{
            uniqueName: undefined
          }
          firstLogin:true
        }
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
            if _.isUndefined(cst)
              a = checkRole(companyList[0])
              localStorageService.set("_selectedCompany", companyList[0])
              return a
            else
              a = checkRole(cst)
              localStorageService.set("_selectedCompany", cst)
              return a
          else
            localStorageService.set("_selectedCompany", companyList[0])
            if companyList.length < 1
              a = checkRole(user)
              return a
            else      
              a = checkRole(companyList[0])
              return a
        onFailure = (res) ->
          toastr.error('Failed to retrieve company list' + res.data.message)
        companyServices.getAll().then(onSuccess, onFailure)
    }
    templateUrl: '/public/webapp/views/demo.html'
    controller: 'homeController'
  )
  .state('Reports',
    url: '/reports'
    templateUrl: appendThis+'/public/webapp/Reports/reports.html',
    controller: 'reportsController',
    params: {'frmDt': null, 'toDt': null, 'type': null}
  )
  .state('audit-logs',
    url: '/audit-logs'
    templateUrl: appendThis+'/public/webapp/AuditLogs/audit-logs.html',
    controller:'logsController'
  )
  .state('search',
    url: '/search'
    templateUrl: appendThis+'/public/webapp/Search/searchContent.html'
    controller: 'searchController'
  )
  .state('invoice',
    url: ''
    abstract: true
    templateUrl: appendThis+'/public/webapp/views/home.html'
    controller: 'invoiceController'
  )
  .state('invoice.accounts',
    url: '/invoice'
    views:{
      'accounts':{
        templateUrl: appendThis+'/public/webapp/Invoice/invoiceAccounts.html'
      }
      'rightPanel':{
        abstract:true
        template: '<div ui-view></div>'
      }
    }
  )
  .state('invoice.accounts.invoiceId',
    url: '/:invId'
    templateUrl: appendThis+'/public/webapp/Invoice/invoiceContent.html'
  )
  .state('company'
    url: ''
    abstract: true
    templateUrl: appendThis+'/public/webapp/views/home.html'
    controller:'groupController'
  )
  .state('company.content',
    url: ''
    views:{
      'rightPanel':{
        abstract:true
        template: '<div ui-view="rightPanel"></div>'
        controller: 'companyController'
      }
    }
  )
  .state('company.content.manage',
    url: '/manage'
    views:{
      'rightPanel':{
        templateUrl: appendThis+'/public/webapp/ManageCompany/manageCompany.html'
      }
    }
  )
  .state('company.content.user',
    url: '/user'
    views:{
      'rightPanel':{
        templateUrl: appendThis+'/public/webapp/UserDetails/userDetails.html'
        controller: 'userController'
      }
    }
  )
  .state('company.content.tbpl',
    url: '/trial-balance-and-profit-loss',
    views:{
      'rightPanel':{
        templateUrl: appendThis+'/public/webapp/Tbpl/tbpl.html'
        controller: 'tbplController'
      }
    }
  )
  .state('company.content.ledgerContent',
    url: '/ledger/:unqName'
    views:{
      'rightPanel':{
        templateUrl: appendThis+'/public/webapp/Ledger/ledger-wrapper.html'
        # controller: 'newLedgerController'
        # controllerAs: 'lc'
      }
    }
  )
  # .state('company.content.ledgerContent1',
  #   url: '/ledger-paginated/:unqName'
  #   views:{
  #     # 'accountsList':{
  #     #   templateUrl: appendThis+'/public/webapp/views/accounts.html'
  #     # }
  #     'rightPanel':{
  #       templateUrl: appendThis+'/public/webapp/Ledger/ledgerPaginated.html'
  #       controller: 'ledgerController'
  #       controllerAs: 'ledgerCtrl'
  #     }
  #   }
  # )
  .state('dashboard',
    url: '/dashboard'
    templateUrl: appendThis+'/public/webapp/Dashboard/dashboard.html'
    controller: "dashboardController"
  )
  .state('inventory',
    url: '/inventory'
    templateUrl: '/public/webapp/Inventory/inventory.html'
    controller: 'stockController'
    controllerAs: 'stock'
  )
  .state('inventory.custom-stock',
    url: '/custom-stock'
    views:{
      'inventory-detail':{
        templateUrl: '/public/webapp/Inventory/partials/custom-stock-unit.html'
        controller: 'inventoryCustomStockController'
        controllerAs: 'vm'
      }
    }
  )
  .state('inventory.add-group',
    url: '/add-group/:grpId'
    views:{
      'inventory-detail':{
        templateUrl: '/public/webapp/Inventory/partials/add-group-stock.html'
      }
    }
  )
  .state('inventory.add-group.add-stock',
    url: '/add-group/:grpId/add-stock/:stockId'
    views:{
      'inventory-detail@inventory':{
        templateUrl: '/public/webapp/Inventory/partials/stock-operations.html',
        controller: 'inventoryAddStockController'
        controllerAs: 'vm'
      }
    }
  )
  .state('recurring-entry',
    url: '/recurring-entry'
    templateUrl: '/public/webapp/recurring-entry/recurring-entry.html'
    controller: 'recurringEntryController'
    controllerAs: 'recEntry'
  )
  .state('/thankyou',
    url: '/thankyou'
    templateUrl: appendThis+'/public/webapp/views/thanks.html'
    controller: 'thankyouController'
  )
  .state('proforma',
    url: ''
    abstract: true
    templateUrl: appendThis+'/public/webapp/views/home.html'
    controller: 'proformaController'
  )
  .state('proforma.accounts',
    url: '/proforma'
    views:{
      'accounts':{
        templateUrl: appendThis+'/public/webapp/invoice2/proforma/proformaAccounts.html'
      }
      'rightPanel':{
        abstract:true
        templateUrl: appendThis+'/public/webapp/invoice2/proforma/proformaContent.html'
      }
    }
  )
  .state('settings',
    url: '/settings'
    templateUrl: appendThis+'/public/webapp/Settings/settings.html'
    controller: 'settingsController'
  )
  .state('invoice2',
    url: '/invoice2'
    templateUrl: appendThis + '/public/webapp/invoice2/invoice2.html'
    controller: 'invoice2Controller'
  )
  $locationProvider.html5Mode(true)
  return

giddh.webApp.run [
  '$rootScope'
  '$state'
  '$stateParams'
  '$location'
  '$window'
  'toastr'
  'localStorageService'
  'DAServices'
  'groupService'
  '$http'
  ($rootScope, $state, $stateParams, $location, $window, toastr, localStorageService, DAServices, groupService, $http) ->
    
    # $rootScope.setState = (lastState, url, param) ->
    #   data = {
    #       "lastState": lastState,
    #       "companyUniqueName": $rootScope.selectedCompany.uniqueName
    #   }
    #   if url.indexOf('ledger') != -1
    #     data.lastState = data.lastState + '@' + param
    #   $http.post('/state-details', data).then(
    #       (res) ->
            
    #       (res) ->
            
    #   )


    $rootScope.$on('$stateChangeStart', (event, toState, toParams, fromState, fromParams)->
      $rootScope.showLedgerBox = false
      if _.isEmpty(toParams)
        $rootScope.selAcntUname = undefined
    )

    $rootScope.$on('$stateChangeSuccess', (event, toState, toParams, fromState, fromParams)->
      user = localStorageService.get('_userDetails')
      window.dataLayer.push({
        event: 'giddh.pageView',
        attributes: {
          route: $location.path()
        },
        userId: user.uniqueName
      });
      #$rootScope.setState(toState.name, toState.url, toParams.unqName)
    )
      #    # check IE browser version
      #    $rootScope.GetIEVersion = () ->
      #      ua = window.navigator.userAgent
      #      msie = ua.indexOf('MSIE ')
      #      trident = ua.indexOf('Trident/')
      #      edge = ua.indexOf('Edge/')
      #      if (msie > 0)
      #        toastr.error('For Best User Expreince, upgrade to IE 11+')
      #    $rootScope.GetIEVersion()
      #    # check browser
    $rootScope.msieBrowser = ()->
      ua = window.navigator.userAgent
      msie = ua.indexOf('MSIE')
      if msie > 0 or !!navigator.userAgent.match(/Trident.*rv\:11\./)
        return true
      else
        console.info window.navigator.userAgent, 'otherbrowser', msie
        return false
#    # open window for IE
    $rootScope.openWindow = (url) ->
      win = window.open()
      win.document.write('sep=,\r\n', url)
      win.document.close()
      win.document.execCommand('SaveAs', true, 'abc' + ".xls")
      win.close()
#
#   $rootScope.firstLogin = true
  
    $rootScope.$on('companyChanged', ->
      DAServices.ClearData()
      localStorageService.remove("_ledgerData")
      localStorageService.remove("_selectedAccount")
    )
    # $rootScope.$on('company-changed', (event, changeData)->
    #   if changeData.type == "CHANGE"
    #     $state.go('company.content.manage')
    # )
    $rootScope.canChangeCompany = false
#    $rootScope.flatAccList = {
#      page: 1
#      count: 10
#      totalPages: 0
#      currentPage : 1
#    }

#    $rootScope.getFlatAccountList = (compUname) ->
#      reqParam = {
#        companyUniqueName: compUname
#        q: ''
#        page: $rootScope.flatAccList.page
#        count: $rootScope.flatAccList.count
#      }
#      groupService.getFlatAccList(reqParam).then($rootScope.getFlatAccountListListSuccess, $rootScope.getFlatAccountListFailure)
#
#    $rootScope.getFlatAccountListListSuccess = (res) ->
#      $rootScope.fltAccntListPaginated = res.body.results
#      $rootScope.flatAccList.limit = 5
#
#    $rootScope.getFlatAccountListFailure = (res) ->
#      toastr.error(res.data.message)

#    # search flat accounts list
#    $rootScope.searchAccounts = (str) ->
#      reqParam = {}
#      reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
#      if str.length > 2
#        reqParam.q = str
#        groupService.getFlatAccList(reqParam).then($rootScope.getFlatAccountListListSuccess, $rootScope.getFlatAccountListFailure)
#      else
#        reqParam.q = ''
#        reqParam.count = 5
#        groupService.getFlatAccList(reqParam).then($rootScope.getFlatAccountListListSuccess, $rootScope.getFlatAccountListFailure)

#    # set financial year
#    $rootScope.setActiveFinancialYear = (FY) ->
#      if FY != undefined
#        activeYear = {}
#        activeYear.start = moment(FY.financialYearStarts,"DD/MM/YYYY").year()
#        activeYear.ends = moment(FY.financialYearEnds,"DD/MM/YYYY").year()
#        if activeYear.start == activeYear.ends then (activeYear.year = activeYear.start) else (activeYear.year = activeYear.start + '-' + activeYear.ends)
#        $rootScope.fy = FY
#        $rootScope.activeYear = activeYear
#        $rootScope.currentFinancialYear =  activeYear.year
#      localStorageService.set('activeFY',FY)

]

giddh.webApp.config ($sceProvider) ->
  $sceProvider.enabled(false)

giddh.webApp.config ($httpProvider) ->
  $httpProvider.interceptors.push('appInterceptor')

giddh.webApp.factory 'appInterceptor', ['$q', '$location', '$log', 'toastr', '$timeout', '$rootScope' 
  ($q, $location, $log, toastr, $timeout, $rootScope) ->
    request: (request) ->
      $rootScope.superLoader = true
      return request
    response: (response) ->
      $rootScope.superLoader = false
      return response
    responseError: (responseError) ->
      $rootScope.superLoader = false
      if responseError.status is 500 and responseError.data isnt undefined
        if _.isObject(responseError.data)
          $q.reject responseError
        else
          #check if responseError.data contains error regarding Auth-Key
          isError = responseError.data.indexOf("`value` required in setHeader")
          isAuthKeyError = responseError.data.indexOf("Auth-Key")
          #if Auth-Key Error found, redirect to login
          if isAuthKeyError != -1
            toastr.error('Your Session has Expired, Please Login Again.')
            $timeout ( ->
              window.location.assign('/login')
            ), 2000
      else if responseError.status is 401
        if _.isObject(responseError.data) and responseError.data.code is "INVALID_AUTH_KEY"
          toastr.error('Your Session has Expired, Please Login Again.')
          $timeout ( ->
            window.location.assign('/login')
          ), 2000
        else
          $q.reject responseError
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
