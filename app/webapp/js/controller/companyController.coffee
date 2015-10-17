"use strict"
companyController = ($scope, $rootScope, $timeout, $modal, $log, companyServices, currencyService, locationService, $confirm, localStorageService, toastr) ->
  #make sure managecompanylist page not load
  $rootScope.mngCompDataFound = false
  #make sure manage company detail not load
  $rootScope.cmpViewShow = false
  $rootScope.selectedCompany = {}

  #contains company list
  $scope.companyList = []
  $scope.companyDetails = {}
  $scope.currencyList = []
  $scope.currencySelected = undefined;
  $scope.shareRequest = {role: 'view_only', user: null}

  #dialog for first time user
  $scope.openFirstTimeUserModal = () ->
    modalInstance = $modal.open(
      templateUrl: '/public/webapp/views/createCompanyModal.html',
      size: "sm",
      backdrop: 'static',
      scope: $scope
    )
    modalInstance.result.then($scope.onCompanyCreateModalCloseSuccess, $scope.onCompanyCreateModalCloseFailure)

  $scope.onCompanyCreateModalCloseSuccess = (data) ->
    cData = {}
    cData.name = data.name
    cData.city = data.city
    $scope.createCompany(cData)

  $scope.onCompanyCreateModalCloseFailure = () ->
    $scope.checkCmpCretedOrNot()

  #check if user is admin
  $scope.ifHavePermission = (data) ->
    $scope.canManageUser = false
    angular.forEach data.role.permissions, (value, key) ->
      if value.code is "MNG_USR"
        $scope.canManageUser = true

  #for make sure
  $scope.checkCmpCretedOrNot = ->
    if $scope.companyList.length <= 0
      $scope.openFirstTimeUserModal()

  #get only city for create company
  $scope.getOnlyCity = (val) ->
    locationService.searchOnlyCity(val).then($scope.getOnlyCitySuccess, $scope.getOnlyCityFailure)

  #get only city success
  $scope.getOnlyCitySuccess = (data) ->
    filterThis = data.results.filter (i) -> i.types[0] is "locality"
    filterThis.map((item) ->
      item.address_components[0].long_name
    )

  #get only city failure
  $scope.getOnlyCityFailure = (response) ->
    toastr.error(response.data.message, "Error")

  #creating company
  $scope.createCompany = (cdata) ->
    companyServices.create(cdata).then($scope.onCreateCompanySuccess, $scope.onCreateCompanyFailure)

  #create company success
  $scope.onCreateCompanySuccess = (response) ->
    toastr.success("Company create successfully", "Success")
    $rootScope.mngCompDataFound = true
    $scope.companyList.push(response.body)

  #create company failure
  $scope.onCreateCompanyFailure = (response) ->
    toastr.error(response.data.message, "Error")

  #Get company list
  $scope.getCompanyList = ->
    companyServices.getAll().then($scope.getCompanyListSuccess, $scope.getCompanyListFailure)

  #Get company list
  $scope.getCompanyListSuccess = (response) ->
    $scope.companyList = response.body
    if _.isEmpty($scope.companyList)
      $scope.openFirstTimeUserModal()
    else
      $rootScope.mngCompDataFound = true
      $scope.goToCompany($scope.companyList[0], 0)

  #get company list failure
  $scope.getCompanyListFailure = (response)->
    toastr.error(response.data.message, "Error")
  
  $scope.getCompany = (uniqueName)->
    companyServices.get(uniqueName).then((->), (->))

  #delete company
  $scope.deleteCompany = (uniqueName, index, name) ->
    $confirm.openModal(
      title: 'Are you sure you want to delete? ' + name,
      ok: 'Yes',
      cancel: 'No'
    ).then ->
      companyServices.delete(uniqueName).then($scope.delCompanySuccess, $scope.delCompanyFailure)

  #delete company success
  $scope.delCompanySuccess = (response) ->
    toastr.success("Company deleted successfully", "Success")
    $scope.getCompanyList()

  #delete company failure
  $scope.delCompanyFailure = (response) ->
    toastr.error(response.data.message, "Error")

  #making a detail company view
  $scope.goToCompany = (data, index) ->
    $scope.ifHavePermission(data)
    $rootScope.cmpViewShow = true
    $scope.selectedCmpLi = index
    angular.extend($scope.selectedCompany, data)
    if $scope.canManageUser is true
      $scope.getSharedUserList($scope.selectedCompany.uniqueName)
      $scope.getRolesList()

  #update company details
  $scope.updateCompanyInfo = (data) ->
    companyServices.update(data).then($scope.updtCompanySuccess, $scope.updtCompanyFailure)

  #update company success
  $scope.updtCompanySuccess = (response)->
    toastr.success("Company updated successfully", "Success")
    $scope.getCompanyList()

  #update company failure
  $scope.updtCompanyFailure = (response)->
    toastr.error(response.data.message, "Error")

  #to inject form again on scope do not remove very imp function
  $scope.setFormScope = (scope) ->
    @formScope = scope

  $scope.getCountry = (val) ->
    locationService.searchCountry(val).then($scope.onGetCountrySuccess, $scope.onGetCountryFailure)

  $scope.onGetCountrySuccess = (data) ->
    filterThis = data.results.filter (i) -> i.types[0] is "country"
    filterThis.map((item) ->
      item.address_components[0].long_name
    )

  $scope.onGetCountryFailure = (data) ->
    console.log "in get country failure"

  $scope.getState = (val) ->
    locationService.searchState(val, $rootScope.selectedCompany.country).then($scope.onGetStateSuccess, $scope.onGetStateFailure)

  $scope.onGetStateSuccess = (data) ->
    filterThis = data.results.filter (i) -> i.types[0] is "administrative_area_level_1"
    filterThis.map((item) ->
      item.address_components[0].long_name
    )

  $scope.onGetStateFailure = (data) ->
    console.log "in get state failure"

  $scope.getCity = (val) ->
    locationService.searchCity(val, $rootScope.selectedCompany.state).then($scope.onGetCitySuccess, $scope.onGetCityFailure)

  $scope.onGetCitySuccess = (data) ->
    filterThis = data.results.filter (i) -> i.types[0] is "locality"
    filterThis.map((item) ->
      item.address_components[0].long_name
    )

  $scope.onGetCityFailure = (data) ->
    console.log "in get city failure"

  $scope.getCurrencyList = ->
    lsKeys = localStorageService.keys()
    if _.contains(lsKeys, "_currencyList")
      $scope.currencyList = localStorageService.get("_currencyList")
    else
      currencyService.getList($scope.getCurrencyListSuccess, $scope.getCurrencyListFailure)

  $scope.getCurrencyListFailure = (response)->
    toastr.error(response.data.message, "Error")

  #Get company list
  $scope.getCurrencyListSuccess = (response) ->
    $scope.currencyList = _.map(response.body,(item) ->
      item.code
    )
    localStorageService.set("_currencyList", $scope.currencyList)

  #update user role
  $scope.updateUserRole = (role, userEmail) ->
    sData = {role: role, user: userEmail}
    companyServices.share($scope.selectedCompany.uniqueName, sData).then($scope.onShareCompanySuccess, $scope.onShareCompanyFailure)

  #share and manage permission in manage company
  $scope.shareCompanyWithUser = () ->
    companyServices.share($scope.selectedCompany.uniqueName, $scope.shareRequest).then($scope.onShareCompanySuccess, $scope.onShareCompanyFailure)

  $scope.onShareCompanySuccess = (response) ->
    $scope.shareRequest = {}
    toastr.success(response.body, response.status)
    $scope.getSharedUserList($scope.selectedCompany.uniqueName)


  $scope.onShareCompanyFailure = (response) ->
    toastr.error(response.data.message, response.data.status)

  #get roles and set it in local storage
  $scope.getRolesList = () ->
    cUname = $scope.selectedCompany.uniqueName
    companyServices.getRoles(cUname).then($scope.getRolesSuccess, $scope.getRolesFailure)

  $scope.getRolesSuccess = (response) ->
    $scope.rolesList = response.body

  $scope.getRolesFailure = (response) ->
    toastr.error(response.data.message, response.data.status)

  #get shared user list
  $scope.getSharedUserList = (uniqueName) ->
    companyServices.shredList(uniqueName).then($scope.getSharedUserListSuccess, $scope.getSharedUserListFailure)

  $scope.getSharedUserListSuccess = (response) ->
    $scope.sharedUsersList = response.body

  $scope.getSharedUserListFailure = (response) ->
    toastr.error(response.data.message, response.data.status)

  #delete shared user
  $scope.unSharedUser = (uNqame, id) ->
    data = {user: uNqame}
    companyServices.unSharedComp($scope.selectedCompany.uniqueName, data).then($scope.unSharedCompSuccess, $scope.unSharedCompFailure)

  $scope.unSharedCompSuccess = (response) ->
    toastr.success("Company unshared successfully", "Success")
    $scope.getSharedUserList($scope.selectedCompany.uniqueName)

  $scope.unSharedCompFailure = (response) ->
    toastr.error(response.data.message, response.data.status)

  #fire function after page fully loaded
  $rootScope.$on '$viewContentLoaded', ->
    $scope.getCompanyList()
    $scope.getCurrencyList()
  
#init angular app
angular.module('giddhWebApp').controller 'companyController', companyController
