'use strict'

invoice2controller = ($scope, $rootScope, invoiceService, toastr) ->
  $rootScope.cmpViewShow = true
  $scope.checked = false;
  $scope.size = '105px';
  $scope.invoices = []
  $scope.ledgers = []
  selectedTab = 0
  sendForGenerate = []

  $scope.inCaseOfFailedInvoice = []

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

  $scope.setTab = (value) ->
    selectedTab = value

  $scope.commonGoButtonClick = () ->
    if selectedTab == 0
      $scope.getAllInvoices()
    else if selectedTab == 1
      $scope.getAllTransaction()

  $scope.getAllInvoices = () ->
    infoToSend = {
      "companyUniqueName": $rootScope.selectedCompany.uniqueName
      "fromDate": moment($scope.dateData.fromDate).format('DD-MM-YYYY')
      "toDate": moment($scope.dateData.toDate).format('DD-MM-YYYY')
    }
    invoiceService.getInvoices(infoToSend).then($scope.getInvoicesSuccess, $scope.getInvoicesFailure)

  $scope.getInvoicesSuccess = (res) ->
    $scope.invoices = _.flatten(res.body.results)

  $scope.getInvoicesFailure = (res) ->
    toastr.error(res.data.message)

  $scope.getAllTransaction = () ->
    infoToSend = {
      "companyUniqueName": $rootScope.selectedCompany.uniqueName
      "fromDate": moment($scope.dateData.fromDate).format('DD-MM-YYYY')
      "toDate": moment($scope.dateData.toDate).format('DD-MM-YYYY')
    }
    invoiceService.getAllLedgers(infoToSend, {}).then($scope.getAllTransactionSuccess, $scope.getAllTransactionFailure)

  $scope.getAllTransactionSuccess = (res) ->
    $scope.ledgers = res.body

  $scope.getAllTransactionFailure = (res) ->
    toastr.error(res.data.message)

  $scope.addThis = (ledger, value) ->
    if value == true
      sendForGenerate.push(ledger)
    else if value == false
      index = sendForGenerate.indexOf(ledger)
      sendForGenerate.splice(index, 1)


  $scope.generateBulkInvoice = (condition) ->
    selected = []
    _.each(sendForGenerate, (item) ->
      obj = {}
      obj.accUniqueName = item.account.uniqueName
      obj.uniqueName = item.uniqueName
      selected.push(obj)
    )
    generateInvoice = _.groupBy(selected, 'accUniqueName')
    final = []
    _.each(generateInvoice, (inv) ->
      pushthis = {
        accountUniqueName: ""
        entries: []
      }
      unqNameArr = []
      _.each(inv, (invoice) ->
        pushthis.accountUniqueName = invoice.accUniqueName
        unqNameArr.push(invoice.uniqueName)
      )
      pushthis.entries = unqNameArr
      final.push(pushthis)
    )
    infoToSend = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      combined: condition
    }
    invoiceService.generateBulkInvoice(infoToSend, final).then($scope.generateBulkInvoiceSuccess, $scope.generateBulkInvoiceFailure)

  $scope.generateBulkInvoiceSuccess = (res) ->
    console.log("success", res)
    toastr.success("Invoice generated successfully.")
    $scope.inCaseOfFailedInvoice = res.body
    _.each(sendForGenerate, (removeThis) ->
      index = $scope.ledgers.indexOf(removeThis)
      $scope.ledgers.splice(index, 1)
    )
    $scope.getAllTransaction()

  $scope.generateBulkInvoiceFailure = (res) ->
    toastr.error(res.data.message)

giddh.webApp.controller 'invoice2Controller', invoice2controller