"use strict"
companyController = ($scope, $rootScope, $timeout, $modal, $log, companyServices, currencyService, locationService, $confirm, localStorageService, toastr) ->

  #blank Obj for modal
  $rootScope.company = {}

  #make sure managecompanylist page not load
  $rootScope.mngCompDataFound = false

  #make sure manage company detail not load
  $rootScope.cmpViewShow = false

  #contains company list
  $scope.companyList = []

  #for get company basic info contains
  $scope.companyDetails = {}
  #for update company basic info contains
  $scope.companyBasicInfo = {}

  $scope.currencyList = []
  $scope.currencySelected = undefined;



  #check if user is admin
  $scope.ifHavePermission = (data) ->
    angular.forEach data.permisions, (value, key) ->
      if value.code is "MNG_USR"
        $scope.isAdmin = true


  #for make sure
  $scope.checkCmpCretedOrNot = ->
    if $scope.companyList.length <= 0
      $rootScope.openFirstTimeUserModal()

  #dialog for first time user
  $rootScope.openFirstTimeUserModal = () ->
    modalInstance = $modal.open(
      templateUrl: '/public/webapp/views/createCompanyModal.html',
      size: "sm",
      backdrop: 'static',
      scope: $scope
    )

    modalInstance.result.then ((data) ->
      cData = {}
      cData.name = data.name.replace(/[\s]/g, '')
      cData.city = data.city
      $scope.createCompany(cData)
      $scope.company = {}
    ), ->
      $scope.checkCmpCretedOrNot()

  #creating company
  $scope.createCompany = (cdata) ->
    companyServices.create(cdata).then(onCreateCompanySuccess, onCreateCompanyFailure)

  #create company success
  onCreateCompanySuccess = (response) ->
    toastr.success("Company create successfully", "Success")
    $rootScope.mngCompDataFound = true
    $scope.companyList.push(response.body)

  #create company failure
  onCreateCompanyFailure = (response) ->
    toastr.error(response.data.message, "Error")

  #get company list failure
  getCompanyListFailure = (response)->
    toastr.error(response.data.message, "Error")

  #Get company list
  getCompanyListSuccess = (response) ->
    if response.status is "error"
      $rootScope.openFirstTimeUserModal()
    else
      $rootScope.mngCompDataFound = true
      $scope.companyList = response.body

  #Get company list
  $scope.getCompanyList = ->
    try
      companyServices.getAll().then(getCompanyListSuccess, getCompanyListFailure)
    catch e
      throw new Error(e.message)

  $scope.getCompany = (uniqueName)->
    companyServices.get(uniqueName).then((->), (->))

  #delete company
  $scope.deleteCompany = (uniqueName, index, name) ->
    $confirm(
      title: 'Are you sure you want to delete? ' + name,
      ok: 'Yes',
      cancel: 'No'
    ).then ->
      companyServices.delete(uniqueName).then(delCompanySuccess, delCompanyFailure)

  #delete company success
  delCompanySuccess = (response) ->
    toastr.success("Company deleted successfully", "Success")
    $scope.getCompanyList()

  #delete company failure
  delCompanyFailure = (response) ->
    toastr.error(response.data.message, "Error")

  #making a detail company view
  $scope.goToCompany = (data) ->
    $scope.ifHavePermission(data)
    $rootScope.cmpViewShow = true
    $rootScope.companyDetailsName = data.name
    angular.extend($scope.companyBasicInfo, data)

  #update company details
  $scope.updateCompanyInfo = () ->
    if @formScope.cmpnyBascFrm.$valid
      console.log $scope.companyBasicInfo
      companyServices.update($scope.companyBasicInfo).then(updtCompanySuc, updtCompanyFail)

  #update company success
  updtCompanySuc = (response)->
    toastr.success("Company updated successfully")

  #update company failure
  updtCompanyFail = (response)->
    toastr.error(response.data.message, "Error")

  #to inject form again on scope
  $scope.setFormScope = (scope) ->
    @formScope = scope

  

  $scope.getCity = (val) ->
    promise = locationService.searchCity(val, @formScope.cmpnyBascFrm.cState.$viewValue)
    promise.then(onGetCitySuccess, onGetCityFailure)

  onGetCitySuccess = (data) ->
    filterThis = data.results.filter (i) -> i.types[0] is "locality"
    filterThis.map((item) ->
      item.address_components[0].long_name
    )

  onGetCityFailure = (data) ->
    console.log "in get city failure"

  $scope.getState = (val) ->
    promise = locationService.searchState(val, @formScope.cmpnyBascFrm.cCountry.$viewValue)
    promise.then(onGetStateSuccess, onGetStateFailure)

  onGetStateSuccess = (data) ->
    filterThis = data.results.filter (i) -> i.types[0] is "administrative_area_level_1"
    filterThis.map((item) ->
      item.address_components[0].long_name
    )

  onGetStateFailure = (data) ->
    console.log "in get state failure"

  $scope.getCountry = (val) ->
    promise = locationService.searchCountry(val)
    promise.then(onGetCountrySuccess, onGetCountryFailure)
    

  onGetCountrySuccess = (data) ->
    filterThis = data.results.filter (i) -> i.types[0] is "country"
    filterThis.map((item) ->
      item.address_components[0].long_name
    )

  onGetCountryFailure = (data) ->
    console.log "in get country failure"

  $scope.getCurrencyList = ->
    lsKeys = localStorageService.keys()
    if _.contains(lsKeys, "_currencyList")
      $scope.currencyList = $rootScope.getItem("_currencyList")
    else
      currencyService.getList(getCurrencyListSuccess, getCurrencyListFail)
    

  getCurrencyListFail = (response)->
    toastr.error(response.data.message, "Error")

  #Get company list
  getCurrencyListSuccess = (response) ->
    if response.status is "error"
      toastr[response.status](response.message)
    else
      $scope.currencyList = response.body.map((item) ->
        item.code
      )
      localStorageService.set("_currencyList", $scope.currencyList)

  #fire function after page fully loaded
  $rootScope.$on '$viewContentLoaded', ->
    $scope.getCompanyList()
    $scope.getCurrencyList()

#init angular app
angular.module('giddhWebApp').controller 'companyController', companyController
