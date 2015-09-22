"use strict"

homeController = ($scope, $rootScope, $timeout, $modal, $log, homeControllerServices, $http) ->

	#blank Obj for modal
	$rootScope.company = {}

	$scope.companyList =[]

	#dialog for first time user
	$rootScope.openFirstTimeUserModal = () ->
	  modalInstance = $modal.open(
	    templateUrl: '/public/webapp/views/createCompanyModal.html',
	    size: "sm",
	    scope : $scope
	  )
	  console.log 'modal opened', $scope

	  modalInstance.result.then ((data) ->
	    console.log data, "modal close"
	    $scope.createCompany(data)
	  ), ->
	    console.log 'Modal dismissed at: ' + new Date

	#creating company
	$scope.createCompany = (cdata) ->
		console.log "inc createCompany", cdata
		homeControllerServices.createCompany(cdata, onCreateCompanySuccess, onCreateCompanyFailure)

	#create company success
	onCreateCompanySuccess = (response) ->
		console.log response, "in create company success"
		if response.status is "success"
			toastr[response.status]("Company create successfully")
			$rootScope.mngCompDataFound = true
			$scope.companyList.push(response.body)
		else
			toastr[response.status](response.message)

	#create company failure
	onCreateCompanyFailure = (response) ->
		console.log response, "in onCreateCompanyFailure"


	#get company list failure
	getCompanyListFail = (response)->
		console.log "companyList failure", response
		toastr[response.status](response.message)

	#Get company list
	getCompanyListSuc = (response) ->
		console.log "companyList successfully", response
		if response.status is "error"
			$rootScope.openFirstTimeUserModal()
		else
			$rootScope.mngCompDataFound = true
			angular.extend($scope.companyList, response.body)

	#Get company list
	$scope.getCompanyList = ->
		try
			homeControllerServices.getCompList(getCompanyListSuc, getCompanyListFail)
		catch e
			throw new Error(e.message);

	#delete company
	$scope.deleteCompany = (id, index) ->
		console.log id, index

	#making a detail company view
	$scope.goToCompany = (data) ->
		console.log data
		$scope.cmpViewShow = true
		$scope.companyBasicInfo = data

	#form submit for changeBasicInfo
	$scope.updateBasicInfo = () ->
		console.log 'in updateBasicInfo', $scope.companyBasicInfo
		console.log @formScope.cmpnyBascFrm, "hurray"
		
	$scope.setFormScope = (scope) ->
  	@formScope = scope
	

	#fire function after page fully loaded
	$rootScope.$on '$viewContentLoaded', ->
		console.log "homeController viewContentLoaded"
		$scope.getCompanyList()

#init angular app
angular.module('giddhWebApp').controller 'homeController', homeController




