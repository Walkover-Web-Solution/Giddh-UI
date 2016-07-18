"use strict"

mainController = ($scope, $state, $rootScope, $timeout, $http, $uibModal, localStorageService, toastr, locationService, modalService, roleServices, permissionService, companyServices, $window,groupService) ->
  $rootScope.showLedgerBox = true
  $rootScope.showLedgerLoader = false
  $rootScope.basicInfo = {}
  $rootScope.flatAccntListWithParents = []
  $rootScope.canManageComp = true
  $rootScope.canViewSpecificItems = false
  $rootScope.canUpdate = false
  $rootScope.canDelete = false
  $rootScope.canAdd = false
  $rootScope.canShare = false
  $rootScope.canManageCompany = false
  $rootScope.canVWDLT = false
  $rootScope.companyLoaded = true
  $rootScope.superLoader = false
  $rootScope.companyLoaded = true
  $rootScope.flatAccList = {
    page: 1
    count: 5000
    totalPages: 0
    currentPage : 1
    limit: 5
  }
  $rootScope.fltAccntListPaginated = []
#  $rootScope.fltAccountLIstFixed = []
  $rootScope.CompanyList = []
  $rootScope.companyIndex = 0
  $rootScope.selectedAccount ={}
  
  $scope.logout = ->
    $http.post('/logout').then ((res) ->
      # don't need to clear below
      # _userDetails, _currencyList
      localStorageService.clearAll()
      window.location = "/thanks"
    ), (res) ->

  # for ledger
  $rootScope.makeAccountFlatten = (data) ->
    $rootScope.flatAccntListWithParents = data
    obj = _.map(data, (item) ->
      obj = {}
      obj.name = item.name
      obj.uniqueName = item.uniqueName
      obj.mergedAccounts = item.mergedAccounts
      obj
    )
    $rootScope.fltAccntList = obj

  $rootScope.countryCodesList = locationService.getCountryCode()

  $scope.getRoles = () ->
    roleServices.getAll().then($scope.onGetRolesSuccess, $scope.onGetRolesFailure)

  $scope.onGetRolesSuccess = (res) ->
    localStorageService.set("_roles", res.body)

  $scope.onGetRolesFailure = (res) ->
    toastr.error("Something went wrong while fetching role", "Error")

  # switch user
  $scope.ucActive = false

  $scope.switchUser =() ->
    companyServices.switchUser($rootScope.selectedCompany.uniqueName).then($scope.switchUserSuccess, $scope.switchUserFailure)

  $scope.switchUserSuccess = (res) ->
    $scope.ucActive = res.body.active
    #console.log "switchUserSuccess:", res
    $state.reload()

  $scope.switchUserFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.checkPermissions = (entity) ->
    $rootScope.canUpdate = permissionService.hasPermissionOn(entity, "UPDT")
    $rootScope.canDelete = permissionService.hasPermissionOn(entity, "DLT")
    $rootScope.canAdd = permissionService.hasPermissionOn(entity, "ADD")
    $rootScope.canShare = permissionService.hasPermissionOn(entity, "SHR")
    $rootScope.canManageCompany = permissionService.hasPermissionOn(entity, "MNG_CMPNY")
    $rootScope.canVWDLT = permissionService.hasPermissionOn(entity, "VWDLT")

    

  $rootScope.setScrollToTop = (val, elem)->
    if val is '' || _.isUndefined(val)
      return false
    if val.length > 0
      cntBox = document.getElementById(elem)
      cntBox.scrollTop = 0

  $rootScope.validateEmail = (emailStr)->
    pattern = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    return pattern.test(emailStr)
  
  $scope.getRoles()
  $timeout(->
    $rootScope.basicInfo = localStorageService.get("_userDetails")
    if !_.isEmpty($rootScope.selectedCompany)
      $rootScope.cmpViewShow = true
  ,1000)

  $timeout (->
    cdt = localStorageService.get("_selectedCompany")
    if !_.isNull(cdt)
      $rootScope.setActiveFinancialYear(cdt.activeFinancialYear)
  ), 500
  
  #Get company list
  $rootScope.getCompanyList = ()->
    companyServices.getAll().then($scope.getCompanyListSuccess, $scope.getCompanyListFailure)

  #Get company list success
  $scope.getCompanyListSuccess = (res) ->    
    $scope.companyList = _.sortBy(res.body, 'shared')
    $rootScope.CompanyList = $scope.companyList
    if _.isEmpty($scope.companyList)
      #When no company is there
      $scope.companyList.count
    else
      # When there are companies
      $rootScope.mngCompDataFound = true
      cdt = localStorageService.get("_selectedCompany")
      if not _.isNull(cdt) && not _.isEmpty(cdt) && not _.isUndefined(cdt)
        cdt = _.findWhere($scope.companyList, {uniqueName: cdt.uniqueName})
        if _.isUndefined(cdt)
          $rootScope.setCompany($scope.companyList[0])
          $rootScope.companyIndex = 0
        else
          $rootScope.setCompany(cdt)
          $rootScope.companyIndex = cdt.index
      else
        $rootScope.setCompany($scope.companyList[0])
        $rootScope.companyIndex = 0

  #get company list failure
  $scope.getCompanyListFailure = (res)->
    $rootScope.CompanyList = []
    toastr.error(res.data.message, res.data.status)

  $rootScope.setCompany = (company) ->
    angular.extend($rootScope.selectedCompany, company)
    $rootScope.fltAccntListPaginated = []
    #$rootScope.selectedCompany = company
    localStorageService.set("_selectedCompany", $rootScope.selectedCompany)
    $rootScope.getFlatAccountList(company.uniqueName)


  $rootScope.getParticularAccount = (searchThis) ->
    accountList = []
    _.filter($rootScope.fltAccntListPaginated,(account) ->
      if(account.name.toLowerCase().match(searchThis.toLowerCase()) != null || account.uniqueName.match(searchThis) != null)
        accountList.push(account)
    )
    accountList

  $rootScope.removeAccountFromPaginatedList = (account) ->
    $rootScope.fltAccntListPaginated = _.without($rootScope.fltAccntListPaginated,account)

  $rootScope.getFlatAccountList = (compUname) ->
    reqParam = {
      companyUniqueName: compUname
      q: ''
      page: $scope.flatAccList.page
      count: $scope.flatAccList.count
    }
    groupService.getFlatAccList(reqParam).then($rootScope.getFlatAccountListListSuccess, $rootScope.getFlatAccountListFailure)

  $rootScope.getFlatAccountListListSuccess = (res) ->
    $rootScope.fltAccntListPaginated = res.body.results
#    $rootScope.fltAccountLIstFixed = $rootScope.fltAccntListPaginated
    $rootScope.flatAccList.limit = 5
    
  $rootScope.getFlatAccountListFailure = (res) ->
    toastr.error(res.data.message)

  # load-more function for accounts list on add and manage popup
  $rootScope.loadMoreAcc = (compUname) ->
    $rootScope.flatAccList.limit += 5

#  $rootScope.getCompanyList()

  $rootScope.$on 'callCheckPermissions', (event, data)->
    $scope.checkPermissions(data)
    # $rootScope.$emit('callCheckPermissions', data)

  $rootScope.$on 'companyLoaded', ()->
    console.log 'company changed'

giddh.webApp.controller 'mainController', mainController
