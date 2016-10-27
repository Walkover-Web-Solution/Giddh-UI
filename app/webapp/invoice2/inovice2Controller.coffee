'use strict'

invoice2controller = ($scope, $rootScope, invoiceService, toastr) ->
  $rootScope.cmpViewShow = true
  $scope.checked = false;
  $scope.size = '105px';
  $scope.invoices = []
  $scope.ledgers = []
  $scope.selectedTab = 0
  $scope.sendForGenerate = []

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
    $scope.selectedTab = value

  $scope.commonGoButtonClick = () ->
    if $scope.selectedTab == 0
      $scope.getAllInvoices()
    else if $scope.selectedTab == 1
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
    console.log(_.flatten($scope.invoices))

  $scope.getInvoicesFailure = (res) ->
    console.log("failure ", res)

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
    console.log("ledger to add", value)
    if value == true
      $scope.sendForGenerate.push(ledger)
    else if value == false
      index = $scope.sendForGenerate.indexOf(ledger)
      $scope.sendForGenerate.splice(index, 1)


  $scope.generateBulkInvoice = () ->
    console.log($scope.sendForGenerate)
    selected = []
    _.each($scope.sendForGenerate, (item) ->
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
        pushthis.accountUnqiueName = invoice.accUniqueName
        unqNameArr.push(invoice.uniqueName)
      )
      pushthis.entries = unqNameArr
      final.push(pushthis)
    )
    console.log("inside generate invoice function", final)

giddh.webApp.controller 'invoice2Controller', invoice2controller