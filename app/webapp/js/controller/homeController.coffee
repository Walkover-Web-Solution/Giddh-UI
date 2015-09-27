"use strict"

homeController = ($scope, $rootScope, $timeout, $modal, $log, companyServices, $http) ->

  #blank Obj for modal
  $rootScope.company = {}

  #make sure managecompanylist page not load
  $rootScope.mngCompDataFound = false

  #make sure manage company detail not load
  $scope.cmpViewShow = false

  #contains company list
  $scope.companyList = []

  #for get company basic info contains
  $scope.companyDetails = {}
  #for update company basic info contains
  $scope.companyBasicInfo = {}

  #dialog for first time user
  $rootScope.openFirstTimeUserModal = () ->
    modalInstance = $modal.open(
      templateUrl: '/public/webapp/views/createCompanyModal.html',
      size: "sm",
      scope: $scope
    )

    modalInstance.result.then ((data) ->
      $scope.createCompany(data)
    ), ->
      console.log 'Modal dismissed at: ' + new Date

  #creating company
  $scope.createCompany = (cdata) ->
    companyServices.create(cdata, onCreateCompanySuccess, onCreateCompanyFailure)

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
      angular.extend($scope.companyList, response.body)

  #Get company list
  $scope.getCompanyList = ->
    try
      companyServices.getAll().then(getCompanyListSuc, getCompanyListFail)
    catch e
      throw new Error(e.message)

  #delete company
  $scope.deleteCompany = (id, index) ->

    #making a detail company view
  $scope.goToCompany = (data) ->
    $rootScope.cmpViewShow = true
    $rootScope.companyDetailsName = data.name
    $scope.companyDetails = data

  #form submit for changeBasicInfo
  $scope.updateBasicInfo = () ->
    if @formScope.cmpnyBascFrm.$valid
      console.log $scope.companyBasicInfo

  $scope.setFormScope = (scope) ->
    @formScope = scope

  #fire function after page fully loaded
  $rootScope.$on '$viewContentLoaded', ->
    $scope.getCompanyList()

#init angular app
angular.module('giddhWebApp').controller 'homeController', homeController