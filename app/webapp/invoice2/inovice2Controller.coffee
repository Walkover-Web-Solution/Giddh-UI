'use strict'

invoice2controller = ($scope, $rootScope, invoiceService) ->
  $rootScope.cmpViewShow = true
  $scope.checked = false;
  $scope.size = '100px';
  $scope.invoices = []

  # datepicker setting end
  $scope.dateData = {
    fromDate: new Date(moment().subtract(1, 'month').utc())
    toDate: new Date()
  }
  $scope.dateOptions = {
    'year-format': "'yy'",
    'starting-day': 1,
    'showWeeks': false,
    'show-button-bar': false,
    'year-range': 1,
    'todayBtn': false
  }
  $scope.format = "dd-MM-yyyy"
  $scope.today = new Date()
  $scope.fromDatePickerIsOpen = false
  $scope.toDatePickerIsOpen = false

  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true
  # end of date picker

  $scope.toggle = () ->
    $scope.checked = !$scope.checked


  $scope.getAllInvoices = () ->
    infoToSend = {
      "companyUniqueName": $rootScope.selectedCompany.uniqueName
      "fromDate": moment($scope.dateData.fromDate).format('DD-MM-YYYY')
      "toDate": moment($scope.dateData.toDate).format('DD-MM-YYYY')
    }
    invoiceService.getInvoices(infoToSend).then($scope.getInvoicesSuccess, $scope.getInvoicesFailure)

  $scope.getInvoicesSuccess = (res) ->
    $scope.invoices = _.flatten(res.body.results)
    console.log(_.flatten($scope.invoices))

  $scope.getInvoicesFailure = (res) ->
    console.log("failure ", res)

giddh.webApp.controller 'invoice2Controller', invoice2controller