"use strict"

homeController = ($scope, $rootScope, $timeout, $modal, $log, createCompanyService) ->

	$scope.title = "Sarfaraz"

	#blank Obj for modal
	$rootScope.company = {}

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
		createCompanyService.createCompany(cdata, $scope.onCreateCompanySuccess, $scope.onCreateCompanyFailure)

	#create company success
	$scope.onCreateCompanySuccess = (response) ->
		console.log response, "in create company success"
		if response.status is "success"
			toastr[response.status]("Company create successfully")
			$rootScope.mngCompDataFound = true
			$scope.companyList.push(response.body)
		else
			toastr[response.status](response.message)

	#create company failure
	$scope.onCreateCompanyFailure = (response) ->
		console.log response, "in onCreateCompanyFailure"


	$scope.listCompanyGet = ->
		console.log "in listCompany"


#init angular app
angular.module('giddhWebApp').controller 'homeController', homeController




