'use strict'

proformaController = ($scope, $rootScope, invoiceService, $timeout, toastr, $filter) ->
  $rootScope.cmpViewShow = true
  $scope.showSubMenus = false
  $scope.format = "dd-MM-yyyy"
  $scope.today = new Date()
  d = moment(new Date()).subtract(1, 'month')
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
  $scope.count = {}
  $scope.count.set = [10,15,30,35,40,45,50]
  $scope.count.val = $scope.count.set[0]
  ## Get all Proforma ##
  $scope.getAllProforma = () ->
  	@success = (res) ->
      $scope.proformaList = res.body
      if res.body.results.length < 1
        $scope.showFilters = true

  	@failure = (res) ->
      toastr.error(res.data.message)

    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    reqParam.date1 = $filter('date')($scope.filters.fromDate, 'dd-MM-yyyy')
    reqParam.date2 = $filter('date')($scope.filters.toDate, 'dd-MM-yyyy')
    reqParam.count = $scope.count.val
    reqParam.page = $scope.count.page
    invoiceService.getAllProforma(reqParam).then(@success, @failure)

  ## proforma filters ##
  $scope.balanceStatuses = ['All', 'paid','unpaid', 'partial-paid', 'hold', 'partial']
  $scope.filters = {
      "balanceStatus":$scope.balanceStatuses[0]
      "accountUniqueName": ''
      "balanceDue":null
      "proformaNumber":""
      "balanceEqual": false
      "balanceMoreThan": false
      "balanceLessThan": false
      "dueDate": $filter('date')($scope.today, 'dd-MM-yyyy')
      "fromDate":$filter('date')(d._d, 'dd-MM-yyyy')
      "toDate":$filter('date')($scope.today, 'dd-MM-yyyy')
      "dueDateEqual": true
      "dueDateAfter": false
      "dueDateBefore": true
      "companyName":""
      "groupUniqueName":""
      "total" : null
      "totalMoreThan":false
      "totalLessThan":false
      "totalEqual": true
    }

  pc.filterModel = () ->
  	@model = {
      "balanceStatus":$scope.balanceStatuses[0]
      "accountUniqueName": ''
      "balanceDue":null
      "proformaNumber":""
      "balanceEqual": false
      "balanceMoreThan": false
      "balanceLessThan": false
      "dueDate": $filter('date')($scope.today, 'dd-MM-yyyy')
      "fromDate":$filter('date')(d._d, 'dd-MM-yyyy')
      "toDate":$filter('date')($scope.today, 'dd-MM-yyyy')
      "dueDateEqual": true
      "dueDateAfter": false
      "dueDateBefore": true
      "companyName":""
      "groupUniqueName":""
      "total" : null
      "totalMoreThan":false
      "totalLessThan":false
      "totalEqual": true
    }	

  pc.getAllProformaByFilter = (data) ->
    @success = (res) ->
        $scope.proformaList = res.body
        $scope.filters.balanceStatus = pc.prevBalanceStatus
    @failure = (res) ->
        $scope.filters.balanceStatus = pc.prevBalanceStatus
        toastr.error(res.data.message)
    invoiceService.getAllProformaByFilter($rootScope.selectedCompany.uniqueName, data).then(@success, @failure)

  $scope.resetFilters = () ->
  	$scope.filters = new pc.filterModel()

  $scope.applyFilters = () ->
    $scope.filters.page = $scope.proformaList.page
    $scope.filters.count = $scope.count.val
    pc.prevBalanceStatus = $scope.filters.balanceStatus
    if $scope.filters.accountUniqueName != undefined && $scope.filters.accountUniqueName != ''
      $scope.filters.accountUniqueName = $scope.filters.accountUniqueName.name
    if $scope.filters.groupUniqueName != undefined && $scope.filters.groupUniqueName != ''
      $scope.filters.groupUniqueName = $scope.filters.groupUniqueName.name
    if $scope.filters.balanceStatus.length > 0
        if $scope.filters.balanceStatus == 'All'
          $scope.filters.balanceStatus = []
        else
          $scope.filters.balanceStatus = [$scope.filters.balanceStatus]

    if $scope.filters.balanceText != undefined
      if $scope.filters.balanceText == "Equal To"
        $scope.filters.balanceEqual = true
        $scope.filters.balanceMoreThan = false
        $scope.filters.balanceLessThan = false
      else if $scope.filters.balanceText == "Less Than"
        $scope.filters.balanceEqual = false
        $scope.filters.balanceMoreThan = false
        $scope.filters.balanceLessThan = true
      else if $scope.filters.balanceText == "Greater Than"
        $scope.filters.balanceEqual = false
        $scope.filters.balanceMoreThan = true
        $scope.filters.balanceLessThan = false
      else if $scope.filters.balanceText == "Greater Than and Equal To"
        $scope.filters.balanceEqual = true
        $scope.filters.balanceMoreThan = true
        $scope.filters.balanceLessThan = false
      else if $scope.filters.balanceText == "Less Than and Equal To"
        $scope.filters.balanceEqual = true
        $scope.filters.balanceMoreThan = false
        $scope.filters.balanceLessThan = true
    $scope.filters.fromDate = $filter('date')($scope.filters.fromDate, 'dd-MM-yyyy')
    $scope.filters.toDate = $filter('date')($scope.filters.toDate, 'dd-MM-yyyy')
    $scope.filters.dueDate = $filter('date')($scope.filters.dueDate, 'dd-MM-yyyy')
    pc.getAllProformaByFilter($scope.filters)

  $scope.deleteProforma = (num, index) ->
    @success = (res) ->
      $scope.proformaList.results.splice(index, 1)
      toastr.success(res.body)
    @failure = (res) ->
      toastr.error(res.data.message)
    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    reqParam.proforma = num
    invoiceService.deleteProforma(reqParam).then(@success, @failure)


giddh.webApp.controller 'proformaController', proformaController