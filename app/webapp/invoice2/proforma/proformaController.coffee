'use strict'

proformaController = ($scope, $rootScope, invoiceService) ->
  $rootScope.cmpViewShow = true
  $scope.showSubMenus = false
  $scope.format = "dd-MM-yyyy"
  $scope.today = new Date()
  $scope.fromDatePickerIsOpen = false
  $scope.toDatePickerIsOpen = false
  $scope.dueDatePickerIsOpen = false
  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true
  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true
  $scope.dueDatePickerOpen = ->
    this.dueDatePickerIsOpen = true
  # end of date picker
  $scope.showFilters = false
  $scope.proformaList = []
  pc = @
  ## Get all Proforma ##
  $scope.getAllProforma = () ->
  	@success = (res) ->
  		$scope.proformaList = res.body.results
  	@failure = (res) ->
  		toastr.error(res.data.message)
  	invoiceService.getAllProforma($rootScope.selectedCompany.uniqueName).then(@success, @failure)


  ## proforma filters ##
  $scope.filters = {
	  "balanceStatus":"",
	  "accountUniqueName": "",
	  "balance":0,
	  "proformaNumber":"",
	  "balanceEqual": false,
	  "balanceMoreThan": false,
	  "balanceLessThanFalse": false,
	  "dueDate":"",
	  "dueDateEqual": false,
	  "dueDateAfter": false,
	  "dueDateBefore": false,
	  "companyName":"",
	  "groupUniqueName":""
	}

  pc.filterModel = () ->
  	@model = {
  	  "balanceStatus":"",
  	  "accountUniqueName": "",
  	  "balance":0,
  	  "proformaNumber":"",
  	  "balanceEqual": false,
  	  "balanceMoreThan": false,
  	  "balanceLessThanFalse": false,
  	  "dueDate":"",
  	  "dueDateEqual": false,
  	  "dueDateAfter": false,
  	  "dueDateBefore": false,
  	  "companyName":"",
  	  "groupUniqueName":""  
  	}	

  $scope.resetFilters = () ->
  	$scope.filters = new pc.filterModel()

  $scope.applyFilters = () ->
    if $scope.filters.balanceText != undefined
      if $scope.filters.balanceText == "Equal To"
        $scope.filters.balanceEqual = true
        $scope.filters.balanceMoreThan = false
        $scope.filters.balanceLessThan = false
      else if $scope.filters.balanceText == "Less Than"
        $scope.filters.balanceEqual = false
        $scope.filters.balanceMoreThan = false
        $scope.filters.balanceLessThanFalse = true
      else if $scope.filters.balanceText == "Greater Than"
        $scope.filters.balanceEqual = false
        $scope.filters.balanceMoreThan = true
        $scope.filters.balanceLessThanFalse = false
      else if $scope.filters.balanceText == "Greater Than and Equal To"
        $scope.filters.balanceEqual = true
        $scope.filters.balanceMoreThan = true
        $scope.filters.balanceLessThanFalse = false
      else if $scope.filters.balanceText == "Less Than and Equal To"
        $scope.filters.balanceEqual = false
        $scope.filters.balanceMoreThan = true
        $scope.filters.balanceLessThanFalse = true
    console.log $scope.filters

giddh.webApp.controller 'proformaController', proformaController