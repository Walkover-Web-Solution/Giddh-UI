"use strict"

companyController = ($scope, $rootScope, $timeout, $modal, $log, companyServices, currencyService, locationService) ->

  #blank Obj for modal
  $rootScope.company = {}
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
    console.log(response)
    toastr[response.status](response.message)

  #Get company list
  getCompanyListSuc = (response) ->
    if response.status is "error"
      $rootScope.openFirstTimeUserModal()
    else
      $rootScope.mngCompDataFound = true
      angular.extend($scope.companyList, response.body)

  #Get company list
  $scope.getCompanyList = ->
    try
      companyServices.getAll().then(getCompanyListSuc, getCompanyListFail)
    catch e
      throw new Error(e.message)

  $scope.getCompany = (uniqueName)->
    companyServices.get(uniqueName).then((->), (->))

  #delete company
  $scope.deleteCompany = (id, index) ->
    console.log(id, index, "in deleteCompany")

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

  $scope.getLocation = (val) ->
    promise = locationService.search(val)
    promise.then(onGetLocationSuccess, onGetLocationFailure)

  onGetLocationSuccess = (data) ->
    data.results.map((item) ->
      item.formatted_address
    )

  onGetLocationFailure = (data) ->
    console.lon "in get location failure", data

  $scope.getCurrencyList = ->
    currencyService.getList(getCurrencyListSuc, getCurrencyListFail)

  getCurrencyListFail = (response)->
    console.log "companyList failure", response
    toastr[response.status](response.message)

  #Get company list
  getCurrencyListSuc = (response) ->
    console.log "companyList successfully", response.body
    response.body

#init angular app
angular.module('giddhWebApp').controller 'companyController', companyController
