"use strict"

companyController = ($scope, $rootScope, $timeout, $modal, $log, companyControllerServices, $http) ->

	#blank Obj for modal
	$rootScope.company = {}

	#make sure managecompanylist page not load
	$rootScope.mngCompDataFound = false

	#make sure manage company detail not load
	$rootScope.cmpViewShow = false

	#contains company list
	$scope.companyList =[]

	#for get company basic info contains
	$scope.companyDetails = {}
	#for update company basic info contains
	$scope.companyBasicInfo = {}

	#for make sure
	$scope.checkCmpCretedOrNot = ->
		console.log $scope.companyList.length
		if $scope.companyList.length <= 0
			console.log "in if"
			$rootScope.openFirstTimeUserModal()

	#dialog for first time user
	$rootScope.openFirstTimeUserModal = () ->
	  modalInstance = $modal.open(
	    templateUrl: '/public/webapp/views/createCompanyModal.html',
	    size: "sm",
	    backdrop: 'static',
	    scope : $scope
	  )
	  console.log 'modal opened', $scope

	  modalInstance.result.then ((data) ->
	    console.log data, "modal close"
	    cData = {}
	    cData.name = data.name.replace(/[\s]/g, '')
	    cData.city = data.city
	    console.log cData 
	    $scope.createCompany(cData)

	    #reset form obj and reset form
	    $scope.company = {}
	  ), ->
	    console.log 'Modal dismissed at: ' + new Date
	    #check if popup is closed without make company
	    $scope.checkCmpCretedOrNot()
	    

	#creating company
	$scope.createCompany = (cdata) ->
		console.log "inc createCompany", cdata
		companyControllerServices.createCompany(cdata, onCreateCompanySuccess, onCreateCompanyFailure)

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
			companyControllerServices.getCompList(getCompanyListSuc, getCompanyListFail)
		catch e
			throw new Error(e.message);

	#delete company
	$scope.deleteCompany = (id, index) ->
		console.log id, index

	#making a detail company view
	$scope.goToCompany = (data) ->
		console.log data
		$rootScope.cmpViewShow = true
		$rootScope.companyDetailsName = data.name
		$scope.companyDetails = data

	#form submit for changeBasicInfo
	$scope.updateBasicInfo = () ->
		if @formScope.cmpnyBascFrm.$valid
			console.log @formScope.cmpnyBascFrm
			console.log "hurray dude form is valid"
			console.log $scope.companyBasicInfo
	
	#to inject form again on scope
	$scope.setFormScope = (scope) ->
  	@formScope = scope
	

	#fire function after page fully loaded
	$rootScope.$on '$viewContentLoaded', ->
		console.log "companyController viewContentLoaded"
		$scope.getCompanyList()

#init angular app
angular.module('giddhWebApp').controller 'companyController', companyController




