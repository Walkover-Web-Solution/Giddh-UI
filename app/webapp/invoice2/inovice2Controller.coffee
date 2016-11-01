'use strict'

invoice2controller = ($scope, $rootScope, invoiceService, toastr, accountService, $uibModal, companyServices, $timeout) ->
  $rootScope.cmpViewShow = true
  $scope.checked = false;
  $scope.size = '105px';
  $scope.invoices = []
  $scope.ledgers = []
  selectedTab = 0
  sendForGenerate = []
  $scope.filtersInvoice = {}
  $scope.flyDiv = false

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
    if $scope.invoices.length == 0
      toastr.error("No invoices found.")

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


  $scope.getTemplates = ()->
    companyServices.getInvTemplates($rootScope.selectedCompany.uniqueName).then($scope.getTemplatesSuccess, $scope.getTemplatesFailure)

  $scope.getTemplatesSuccess=(res)->
    $scope.templateList = res.body.templates
    $scope.templateData = res.body.templateData
    $scope.invoiceSettings.emailAddress = $scope.templateData.email
    $scope.invoiceSettings.isEmailVerified = $scope.templateData.emailVerified

  $scope.getTemplatesFailure = (res) ->
#    $scope.invoiceLoadDone = true
    toastr.error(res.data.message, res.data.status)

  # preview of generated invoice
  $scope.prevGenerateInv=(item)->
    $scope.selectedInvoice = item
    obj =
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: item.account.uniqueName
      invoiceUniqueID: item.invoiceNumber
    accountService.prevOfGenInvoice(obj).then($scope.prevGenerateInvSuccess, $scope.prevGenerateInvFailure)

  $scope.prevGenerateInvSuccess=(res)->
    $scope.genPrevMode = true
    $scope.viewInvTemplate( res.body.template, 'genprev', res.body)
    $scope.tempType=
      uniqueName: res.body.template.uniqueName

  $scope.prevGenerateInvFailure=(res)->
    toastr.error(res.data.message, res.data.status)

  # view template with sample data
  $scope.viewInvTemplate =(template, mode, data) ->
    showPopUp = true
    $scope.templateClass = template.uniqueName
    data.signatureType = template.sections.signatureType
    if mode isnt 'genprev'
      $scope.genPrevMode = false
    $scope.logoWrapShow = false
    $scope.logoUpldComplt = false
    $scope.signatureWrapShow = false
    $scope.signatureUpldComplt = false
    $scope.tempSet = {}
    $scope.defTempData = {}
    # set mode
    $scope.editMode = if mode is 'edit' then true else false
    $scope.tempSet = template.sections

    _.extend($scope.defTempData , data)
    $scope.defTempData.signatureType = $scope.tempSet.signatureType
    showPopUp = $scope.convertIntoOur()

    # open dialog
    if(showPopUp)
      $scope.modalInstance = $uibModal.open(
        templateUrl: $rootScope.prefixThis+'/public/webapp/Invoice/prevInvoiceTemp.html'
        size: "a4"
        backdrop: 'static'
        scope: $scope
      )
      $scope.modalInstance.result.then($scope.showInvoiceSuccess,$scope.showInvoiceFailure)

  $scope.showInvoiceSuccess = () ->
    console.log("invoice opened")

  $scope.showInvoiceFailure = () ->
    $scope.editGenInvoice = false

  $scope.downInv=()->
    obj =
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $scope.selectedInvoice.account.uniqueName
    data=
      invoiceNumber: [$scope.selectedInvoice.invoiceNumber]
      template: $scope.tempType.uniqueName
    accountService.downloadInvoice(obj, data).then($scope.downInvSuccess, $scope.multiActionWithInvFailure)

  $scope.downInvSuccess=(res)->
    dataUri = 'data:application/pdf;base64,' + res.body
    a = document.createElement('a')
    a.download = $scope.selectedInvoice.invoiceNumber+".pdf"
    a.href = dataUri
    a.click()


  # mail Invoice
  $scope.sendInvEmail=(emailData)->
    obj =
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $scope.selectedInvoice.account.uniqueName
    sendData=
      emailId: []
      invoiceNumber: [$scope.selectedInvoice.invoiceNumber]
    data = angular.copy(emailData)
    data = data.replace(RegExp(' ', 'g'), '')
    cdata = data.split(',')
    _.each(cdata, (str) ->
      if $rootScope.validateEmail(str)
        sendData.emailId.push(str)
      else
        toastr.warning("Enter valid Email ID", "Warning")
        data = ''
        sendData.emailId = []
        return false
    )
    if data != ''
      accountService.mailInvoice(obj, sendData).then($scope.sendInvEmailSuccess, $scope.multiActionWithInvFailure)

  $scope.sendInvEmailSuccess=(res)->
    toastr.success("Email sent successfully", "Success")
    $scope.InvEmailData = {}


  $scope.updateGeneratedInvoice = () ->
    if $scope.editGenInvoice
      data_ = {}
      angular.copy($scope.defTempData, data_)
      data_.account.data = data_.account.data.split('\n')
      data = {}
      data.account = data_.account
      data.entries = data_.entries
      data.invoiceDetails = data_.invoiceDetails
      obj = {
        compUname : $rootScope.selectedCompany.uniqueName
      }
      accountService.updateInvoice(obj, data).then($scope.updateGeneratedInvoiceSuccess, $scope.updateGeneratedInvoiceFailure)
    $scope.editGenInvoice = true

  $scope.updateGeneratedInvoiceSuccess = (res) ->
    toastr.success(res.body)
    $scope.editGenInvoice = false

  $scope.updateGeneratedInvoiceFailure = (res) ->
    toastr.error(res.data.message)


  # Helper methods

  $scope.getTemplates = ()->
    companyServices.getInvTemplates($rootScope.selectedCompany.uniqueName).then($scope.getTemplatesSuccess, $scope.getTemplatesFailure)

  $scope.getTemplatesSuccess=(res)->
    $scope.templateList = res.body.templates
    $scope.templateData = res.body.templateData

  $scope.getTemplatesFailure = (res) ->
#    $scope.invoiceLoadDone = true
    toastr.error(res.data.message, res.data.status)

  $scope.setDiffView=()->
    even = _.find($scope.templateList, (item)->
      item.uniqueName is $scope.tempType.uniqueName
    )
    $scope.tempSet = even.sections
    $scope.defTempData.signatureType = $scope.tempSet.signatureType

  # convert data for UI usage
  $scope.convertIntoOur=()->
    showPopUp = true
    # company setting
    if(_.isNull($scope.defTempData.company))
      toastr.error("Selected company is not available, please contact to support.","Error")
      showPopUp = false
    else if typeof($scope.defTempData.company.data) == 'object' && not(_.isEmpty($scope.defTempData.company.data))
      $scope.defTempData.company.data = $scope.defTempData.company.data.join("\n")

    if(_.isNull($scope.defTempData.account))
#      toastr.error("Selected company is not available, please contact to support.","Error")
      showPopUp = true
    else if typeof($scope.defTempData.account.data) == 'object' && not(_.isEmpty($scope.defTempData.account.data))
      $scope.defTempData.account.data = $scope.defTempData.account.data.join("\n")

    # companyIdentities setting
    if(_.isNull($scope.defTempData.companyIdentities))
      toastr.error("Selected company is not available, please contact to support.","Error")
      showPopUp = false
    else if not(_.isEmpty($scope.defTempData.companyIdentities.data))
      $scope.defTempData.companyIdentities.data = $scope.defTempData.companyIdentities.data.replace(RegExp(',', 'g'), '\n')

    # terms setting
    if $scope.defTempData.terms.length > 0
      str = $scope.defTempData.terms.toString()
      $scope.defTempData.termsStr = str.replace(RegExp(',', 'g'), '\n')
    showPopUp

  # switch sample data with original data
  $scope.switchTempData=()->
    if $scope.withSampleData
      $scope.withSampleData = false
      _.extend($scope.defTempData , $scope.templateData)
    else
      $scope.withSampleData = true
      _.extend($scope.defTempData , $scope.tempDataDef)
    $scope.convertIntoOur()


  $scope.multiActionWithInvFailure=(res)->
    toastr.error(res.data.message, res.data.status)
  # Helper methods ends here

  $timeout ( ->
    $scope.getTemplates()
  ),2000


giddh.webApp.controller 'invoice2Controller', invoice2controller