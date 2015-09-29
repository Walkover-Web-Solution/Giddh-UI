"use strict"

companyController = ($scope, $rootScope, $timeout, $modal, $log, companyServices, currencyService, locationService, $confirm) ->

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
    if response.status is "success"
      toastr[response.status]("Company create successfully")
      $rootScope.mngCompDataFound = true
      $scope.companyList.push(response.body)
    else
      toastr[response.status](response.message)

  #create company failure
  onCreateCompanyFailure = (response) ->

    #get company list failure
  getCompanyListFail = (response)->
    toastr[response.status](response.message)

  #Get company list
  getCompanyListSuc = (response) ->
    if response.status is "error"
      $rootScope.openFirstTimeUserModal()
    else
      $rootScope.mngCompDataFound = true
      $scope.companyList = response.body

  #Get company list
  $scope.getCompanyList = ->
    try
      companyServices.getAll().then(getCompanyListSuc, getCompanyListFail)
    catch e
      throw new Error(e.message)

  $scope.getCompany = (uniqueName)->
    companyServices.get(uniqueName).then((->), (->))

  #delete company
  $scope.deleteCompany = (uniqueName, index, name) ->
    $confirm(
      title: 'Are you sure you want to delete? '+ name, 
      ok: 'Yes', 
      cancel: 'No'
    ).then ->
      companyServices.delete(uniqueName).then(delCompanySuc, delCompanyFail)

  #delete company success
  delCompanySuc = (response) ->
    console.log response, "in deleteCompany success"
    if response.status is "success"
      toastr[response.status](response.body)
      $scope.getCompanyList()
    else  
      toastr[response.status](response.message)

  #delete company failure
  delCompanyFail = (response) ->
    console.log response, "deleteCompany failure"

    #making a detail company view
  $scope.goToCompany = (data) ->
    $rootScope.cmpViewShow = true
    $rootScope.companyDetailsName = data.name
    $scope.companyDetails = data

  #form submit for changeBasicInfo
  $scope.updateBasicInfo = () ->
    if @formScope.cmpnyBascFrm.$valid
      console.log $scope.companyBasicInfo

  #to inject form again on scope
  $scope.setFormScope = (scope) ->
    @formScope = scope

  #fire function after page fully loaded
  $rootScope.$on '$viewContentLoaded', ->
    $scope.getCompanyList()

  $scope.getCity = (val) ->
    console.log @formScope.cmpnyBascFrm.cState.$viewValue
    promise = locationService.searchCity(val, @formScope.cmpnyBascFrm.cState.$viewValue)
    promise.then(onGetCitySuccess, onGetCityFailure)

  onGetCitySuccess = (data) ->
    console.log data.results
    filterThis = data.results.filter (i) -> i.types[0] is "locality"
    filterThis.map((item) ->
      item.address_components[0].long_name
    )

  onGetCityFailure = (data) ->
    console.lon "in get city failure"

  $scope.getState = (val) ->
    promise = locationService.searchState(val, @formScope.cmpnyBascFrm.cCountry.$viewValue)
    promise.then(onGetStateSuccess, onGetStateFailure)

  onGetStateSuccess = (data) ->
    console.log data
    filterThis = data.results.filter (i) -> i.types[0] is "administrative_area_level_1"
    filterThis.map((item) ->
      item.address_components[0].long_name
    )

  onGetStateFailure = (data) ->
    console.lon "in get state failure"

  $scope.getCountry = (val) ->
    promise = locationService.searchCountry(val)
    promise.then(onGetCountrySuccess, onGetCountryFailure)

  onGetCountrySuccess = (data) ->
    console.log data.results
    filterThis = data.results.filter (i) -> i.types[0] is "country"
    filterThis.map((item) ->
      item.address_components[0].long_name
    )

  onGetCountryFailure = (data) ->
    console.lon "in get country failure"

  $scope.getCurrencyList = ->
    currencyService.getList(getCurrencyListSuccess, getCurrencyListFail)

  getCurrencyListFail = (response)->
    toastr[response.status](response.message)

  #Get company list
  getCurrencyListSuccess = (response) ->
    if(response.status is "error")
      toastr[response.status](response.message)
    else
      $scope.currencyList = response.body.map((item) ->
        item.code
      )

  $scope.getCurrencyList()

#init angular app
angular.module('giddhWebApp').controller 'companyController', companyController
