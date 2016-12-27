'use strict'

invoice2controller = ($scope, $rootScope, invoiceService, toastr, accountService, $uibModal, companyServices, $timeout, DAServices, modalService, $filter) ->
  ic = this
  $rootScope.cmpViewShow = true
  $scope.checked = false;
  $scope.size = '105px';
  $scope.invoices = []
  $scope.ledgers = []
  $scope.selectedTab = 0
  sendForGenerate = []
  $scope.filtersInvoice = {
    count: 12
  }
  $scope.filtersLedger = {
    count: 12
  }

  $scope.counts = {
    12
    25
    50
    100
  }
  $scope.flyDiv = false
  $scope.invoiceCurrentPage = 1
  $scope.ledgerCurrentPage = 1
  $scope.sortVar = 'entryDate'
  $scope.reverse = false
  $scope.sortVarInv = ''
  $scope.reverseInv = false
  $scope.hideFilters = false
  $scope.checkall = false

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
  $scope.showPreview = false
  $scope.canGenerateInvoice = false
  $scope.mainCheckbox = false

  $scope.range = (size, start, end) ->
    ret = []
    if size < end
      end = size
      if size < $scope.gap
        start = 0
      else
        start = size - ($scope.gap)
    i = start
    while i < end
      ret.push i
      i++
    ret

  $scope.sortInvoices = (varName, reverseCond) ->
    $scope.invoices.results = _.sortBy($scope.invoices.results, varName)
    if varName == "invoiceNumberM"
      letsC = _.groupBy($scope.invoices.results, varName)
      createA = []
      _.each(letsC, (item) ->
        pushThis = _.sortBy(item, "invoiceNumberP")
        createA.push(pushThis)
      )
      $scope.invoices.results = _.flatten(createA)
    if reverseCond
      $scope.invoices.results = $scope.invoices.results.reverse()


  $scope.prevPageInv = () ->
    $scope.invoiceCurrentPage = $scope.invoiceCurrentPage - 1

  $scope.nextPageInv = () ->
    $scope.invoiceCurrentPage = $scope.invoiceCurrentPage + 1

  $scope.prevPageLed = () ->
    $scope.ledgerCurrentPage = $scope.ledgerCurrentPage - 1

  $scope.nextPageLed = () ->
    $scope.ledgerCurrentPage = $scope.ledgerCurrentPage + 1

  $scope.setPage = ->
    $scope.currentPage = @n
    return

  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true
  # end of date picker


  $scope.performAction = (invoice) ->
    @success = (res) ->
      $scope.getAllInvoices()
    @failure = (res) ->
      toastr.error(res.data.message)
    if invoice.account.name == undefined || invoice.account.name == null
      return
    else
      if invoice.condition == "paid"
        $scope.modalInstance = $uibModal.open(
          templateUrl: '/public/webapp/invoice2/action/actionTransactions.html',
          size: "md",
          backdrop: 'static',
          scope: $scope,
          controller: 'actionTransactionController',
          resolve:{
            invoicePassed: invoice
          }
        )
      else if invoice.condition != ""
        infoToSend = {
          companyUniqueName: $rootScope.selectedCompany.uniqueName
          invoiceUniqueName: invoice.uniqueName
        }
        dataToSend = {
          action: invoice.condition
        }
        invoiceService.performAction(infoToSend, dataToSend).then(@success, @failure)


  $scope.selectAll = (checkOrNot) ->


  $scope.toggle = () ->
    $scope.checked = !$scope.checked

  $scope.setTab = (value) ->
    $scope.selectedTab = value
    $timeout ( ->
      $scope.commonGoButtonClick()
    ),2000
    if value == 2
      $scope.hideFilters = true
    else
      $scope.hideFilters = false

  $scope.commonGoButtonClick = () ->
    if $scope.selectedTab == 0
      $scope.getAllInvoices()
    else if $scope.selectedTab == 1
      $scope.ledgerCurrentPage = 1
      $scope.inCaseOfFailedInvoice = []
      sendForGenerate = []
      $scope.getAllTransaction()

  $scope.checkAccounts = () ->
    tempList = []
    _.each(sendForGenerate, (entry) ->
      tempList.push(entry.account.uniqueName)
    )
    uniqueList = _.uniq(tempList)
    if uniqueList.length > 1 || sendForGenerate.length == 0
      $scope.showPreview = false
    else
      $scope.showPreview = true

  $scope.prevAndGenInv=()->
    $scope.genMode = true
    $scope.prevInProg = true
    arr = []
    _.each(sendForGenerate, (entry)->
      arr.push(entry.uniqueName)
    )
    data =
      uniqueNames: _.uniq(arr)

    obj =
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: sendForGenerate[0].account.uniqueName

    accountService.prevInvoice(obj, data).then($scope.prevAndGenInvSuccess, $scope.prevAndGenInvFailure)

  $scope.prevAndGenInvSuccess=(res)->
    $scope.prevInProg = false
    $scope.viewInvTemplate(res.body.template, 'edit', res.body)


  $scope.prevAndGenInvFailure=(res)->
    $scope.prevInProg = false
    $scope.entriesForInvoice = []
    toastr.error(res.data.message, res.data.status)
#    $scope.resetAllCheckBoxes()

  $scope.getAllInvoices = () ->
    infoToSend = {
      "companyUniqueName": $rootScope.selectedCompany.uniqueName
      "fromDate": moment($scope.dateData.fromDate).format('DD-MM-YYYY')
      "toDate": moment($scope.dateData.toDate).format('DD-MM-YYYY')
      "count": $scope.filtersInvoice.count
      "page": $scope.invoiceCurrentPage
    }
    obj = {}
    if $scope.filtersInvoice.account != undefined
      obj.accountUniqueName = $scope.filtersInvoice.account.uniqueName
    obj.invoiceNumber = $scope.filtersInvoice.invoiceNumber
    if $scope.filtersInvoice.balanceDue != undefined
      obj.balanceDue = $scope.filtersInvoice.balanceDue
    if $scope.filtersInvoice.option != undefined
      if $scope.filtersInvoice.option == 'Greater than'
        obj.balanceMoreThan = true
      else if $scope.filtersInvoice.option == 'Less than'
        obj.balanceLessThan = true
      else if $scope.filtersInvoice.option == 'Equals'
        obj.balanceEqual = true
      else if $scope.filtersLedger.option == 'Greater than Equals'
        obj.balanceMoreThan = true
        obj.balanceEqual = true
      else if $scope.filtersLedger.option == 'Less than Equals'
        obj.balanceLessThan = true
        obj.balanceEqual = true
    invoiceService.getInvoices(infoToSend, obj).then($scope.getInvoicesSuccess, $scope.getInvoicesFailure)

  $scope.getInvoicesSuccess = (res) ->
    $scope.invoices = {}
    _.each(res.body.results, (invoice) ->
      dateDivi = invoice.invoiceDate.split('-')
#      console.log(invoice.invoiceDate, moment(new Date(dateDivi[2], dateDivi[1], dateDivi[0])).format('DD-MM-YYYY'))
      invoice.invoiceDateObj = new Date(dateDivi[2], dateDivi[1], dateDivi[0])
      temp = invoice.invoiceNumber.split("-")
      if temp[0] != "x"
        invoice.invoiceNumberM = Number(temp[0])
        invoice.invoiceNumberP = Number(temp[1])
      else
        invoice.invoiceNumberM = Number(temp[1])
        invoice.invoiceNumberP = Number(temp[2])
    )
    $scope.invoices = res.body
    if $scope.invoices.length == 0
      toastr.error("No invoices found.")

  $scope.getInvoicesFailure = (res) ->
    $scope.invoices = {}
    toastr.error(res.data.message)

  $scope.getAllTransaction = () ->
    $scope.searchInLedger = ""
    sendForGenerate = []
    infoToSend = {
      "companyUniqueName": $rootScope.selectedCompany.uniqueName
      "fromDate": moment($scope.dateData.fromDate).format('DD-MM-YYYY')
      "toDate": moment($scope.dateData.toDate).format('DD-MM-YYYY')
      "count": $scope.filtersLedger.count
      "page": $scope.ledgerCurrentPage
    }
    obj = {}
    if $scope.filtersLedger.account != undefined
      obj.accountUniqueName = $scope.filtersLedger.account.uniqueName
    if $scope.filtersLedger.entryTotal != undefined
      obj.entryTotal = $scope.filtersLedger.entryTotal
    if $scope.filtersLedger.option != undefined
      if $scope.filtersLedger.option == 'Greater than'
        obj.totalIsMore = true
      else if $scope.filtersLedger.option == 'Less than'
        obj.totalIsLess = true
      else if $scope.filtersLedger.option == 'Equals'
        obj.totalIsEqual = true
      else if $scope.filtersLedger.option == 'Greater than Equals'
        obj.totalIsMore = true
        obj.totalIsEqual = true
      else if $scope.filtersLedger.option == 'Less than Equals'
        obj.totalIsLess = true
        obj.totalIsEqual = true
    obj.description = $scope.filtersLedger.description

    invoiceService.getAllLedgers(infoToSend, obj).then($scope.getAllTransactionSuccess, $scope.getAllTransactionFailure)

  $scope.getAllTransactionSuccess = (res) ->
    $scope.ledgers = {}
    $scope.ledgers = res.body

  $scope.getAllTransactionFailure = (res) ->
    if res.data.code == 'NO_ENTRIES_FOUND'
      $scope.ledgers = {
        results: []
        totalPages: 1
      }
      $scope.buttonStatus()
    else
      toastr.error(res.data.message)

  $scope.addThis = (ledger, value) ->
    if value == true
      sendForGenerate.push(ledger)
    else if value == false
      index = sendForGenerate.indexOf(ledger)
      sendForGenerate.splice(index, 1)
    $scope.buttonStatus()


  $scope.buttonStatus = () ->
    if sendForGenerate.length > 0
      $scope.canGenerateInvoice = true
    else
      $scope.canGenerateInvoice = false
    $scope.checkAccounts()

  $scope.generateBulkInvoice = (condition) ->
    selected = []
    if sendForGenerate.length <= 0
      return
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
    $scope.checkall = false
    checkboxA = document.getElementsByName('checkall')
    checkboxA[0].checked = false
    if angular.isArray(res.body)
      $scope.inCaseOfFailedInvoice = res.body
      
      if $scope.inCaseOfFailedInvoice.length != sendForGenerate.length
        toastr.success("Invoice generated successfully.")

      if $scope.inCaseOfFailedInvoice.length > 0
        str = ""
        _.each($scope.inCaseOfFailedInvoice, (failedInv) ->
          str = str + failedInv.failedEntries[0] + " " + failedInv.reason + ","
        )
        toastr.error(str)
      _.each(sendForGenerate, (removeThis) ->
        dontremove = false
        if $scope.inCaseOfFailedInvoice.length > 0
          _.each($scope.inCaseOfFailedInvoice, (check) ->
            if check.failedEntries[0] == removeThis.uniqueName
              dontremove = true
          )
        if dontremove == false
          index = $scope.ledgers.results.indexOf(removeThis)
          $scope.ledgers.results.splice(index, 1)
      )
      sendForGenerate = []
#      $scope.getAllTransaction()
    else
      toastr.success("Invoice generated successfully.")
      $scope.canGenerateInvoice = false
      _.each(sendForGenerate, (removeThis) ->
        index = $scope.ledgers.results.indexOf(removeThis)
        $scope.ledgers.results.splice(index, 1)
      )
      sendForGenerate = []
      $scope.getAllTransaction()

    $scope.buttonStatus()

  $scope.generateBulkInvoiceFailure = (res) ->
    toastr.error(res.data.message)

  $scope.checkTransaction = (trns) ->
    sendThis = false
    _.each($scope.inCaseOfFailedInvoice, (inv) ->
      _.each(inv.failedEntries, (ent) ->
        if trns == ent
          sendThis = true
      )
    )
    sendThis


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
    $scope.selectedInvoiceDetails = {}
    # set mode
    $scope.editMode = if mode is 'edit' then true else false
    $scope.tempSet = template.sections

    _.extend($scope.defTempData , data)

    $scope.defTempData.signatureType = $scope.tempSet.signatureType

    showPopUp = $scope.convertIntoOur()
    angular.copy($scope.defTempData, $scope.selectedInvoiceDetails)

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

  $scope.deleteInvoice = (invoice) ->
    obj =
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: invoice.account.uniqueName
      invoiceUniqueID : invoice.invoiceNumber
    companyServices.delInv(obj).then($scope.delInvSuccess, $scope.multiActionWithInvFailure)

  $scope.delInvSuccess=(res)->
    toastr.success("Invoice deleted successfully", "Success")
    $scope.radioChecked = false
    $scope.selectedInvoice = {}
    $scope.getAllInvoices()

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
    $(document).trigger('click')
    return false

  $scope.updateGeneratedInvoice = () ->
    if $scope.editGenInvoice
      data_ = {}
      angular.copy($scope.defTempData, data_)

      matchThis = {}

      if not(_.isEmpty(data_.account.data))
        data_.account.data = data_.account.data.split('\n')
      else
        data_.account.data = []

      angular.copy(data_, matchThis)

      data = {}
      if data_.termsStr == undefined
        data_.termsStr = ""
      if not angular.isArray(data_.termsStr)
        data.terms = data_.termsStr.split('\n')
      else
        data.terms = data_.termsStr
      data.account = data_.account
      data.entries = data_.entries
      data.invoiceDetails = data_.invoiceDetails
      if data.invoiceDetails.dueDate != "" && data.invoiceDetails.dueDate != undefined
        data.invoiceDetails.dueDate = moment(data.invoiceDetails.dueDate).format('DD-MM-YYYY')
        if moment(data.invoiceDetails.dueDate, "DD-MM-YYYY", true).isValid()
          data.invoiceDetails.dueDate = data.invoiceDetails.dueDate
        else
          data.invoiceDetails.dueDate = null
      else
        data.invoiceDetails.dueDate = null
      obj = {
        compUname : $rootScope.selectedCompany.uniqueName
      }
      sendThis = {
        invoice: data
        updateAccountDetails: false
      }

      if $scope.selectedInvoiceDetails.account.name != matchThis.account.name || $scope.selectedInvoiceDetails.account.attentionTo != matchThis.account.attentionTo || $scope.selectedInvoiceDetails.account.data != matchThis.account.data || $scope.selectedInvoiceDetails.account.mobileNumber != matchThis.account.mobileNumber || $scope.selectedInvoiceDetails.account.email != matchThis.account.email
        modalService.openConfirmModal(
          title: 'Update'
          body: 'Would you also like to update account information in main account?',
          ok: 'Yes',
          cancel: 'No'
        ).then(
          (res) ->
            sendThis.updateAccountDetails = true
            accountService.updateInvoice(obj, sendThis).then($scope.updateGeneratedInvoiceSuccess, $scope.updateGeneratedInvoiceFailure)
          ,(res) ->
            sendThis.updateAccountDetails = false
            accountService.updateInvoice(obj, sendThis).then($scope.updateGeneratedInvoiceSuccess, $scope.updateGeneratedInvoiceFailure)
        )
      else
        accountService.updateInvoice(obj, sendThis).then($scope.updateGeneratedInvoiceSuccess, $scope.updateGeneratedInvoiceFailure)
    $scope.editGenInvoice = true

  $scope.updateGeneratedInvoiceSuccess = (res) ->
    toastr.success(res.body)
    $scope.editGenInvoice = false

  $scope.updateGeneratedInvoiceFailure = (res) ->
    toastr.error(res.data.message)


  # save template data
  $scope.saveTemp=(stype, force)->
    $scope.genMode = false
    $scope.updatingTempData = true
    dData = {}
    data = {}
    matchThis = {}
    angular.copy($scope.defTempData, data)
    # company setting
    if not(_.isEmpty(data.company.data))
      data.company.data = data.company.data.split('\n')
    #data.company.data.replace(RegExp('\n', 'g'), ',')
    if not(_.isEmpty(data.account.data))
      data.account.data = data.account.data.split('\n')

    angular.copy(data, matchThis)
    if matchThis.account.data != "" && matchThis.account.data != undefined
      matchThis.account.data = matchThis.account.data.join("\n")
#    $scope.selectedInvoiceDetails.account.data = $scope.selectedInvoiceDetails.account.data.join("\n")

    # companyIdentities setting
    if not(_.isEmpty(data.companyIdentities.data))
      data.companyIdentities.data = data.companyIdentities.data.replace(RegExp('\n', 'g'), ',')
    # data.companyIdentities.data = data.companyIdentities.data.replace(RegExp(' ', 'g'), '')

    # terms setting
    if not(_.isEmpty(data.termsStr))
      data.terms = data.termsStr.split('\n')
    else
      data.terms = []

    if data.invoiceDetails.dueDate != "" && data.invoiceDetails.dueDate != undefined
      data.invoiceDetails.dueDate = moment(data.invoiceDetails.dueDate).format('DD-MM-YYYY')
      if moment(data.invoiceDetails.dueDate, "DD-MM-YYYY", true).isValid()
        data.invoiceDetails.dueDate = data.invoiceDetails.dueDate
      else
        data.invoiceDetails.dueDate = null
    else
      data.invoiceDetails.dueDate = null

    if stype is 'save'
      companyServices.updtInvTempData($rootScope.selectedCompany.uniqueName, data).then($scope.saveTempSuccess, $scope.saveTempFailure)

    else if stype is 'generate'
      _.omit(data, 'termsStr')
      obj=
        compUname: $rootScope.selectedCompany.uniqueName
        acntUname: sendForGenerate[0].account.uniqueName
      dData=
        uniqueNames: data.ledgerUniqueNames
        validateTax: true
        invoice: _.omit(data, 'ledgerUniqueNames')
        updateAccountDetails: false
      if force
        dData.validateTax = false

      if moment(data.invoiceDetails.invoiceDate, "DD-MM-YYYY", true).isValid()
#        if $scope.defTempData.account.data.length == 0
#          $scope.defTempData.account.data = []
        if dData.invoice.account.data.length == 0
          dData.invoice.account.data = []
        if $scope.selectedInvoiceDetails.account.name != matchThis.account.name || $scope.selectedInvoiceDetails.account.attentionTo != matchThis.account.attentionTo || $scope.selectedInvoiceDetails.account.data != matchThis.account.data || $scope.selectedInvoiceDetails.account.mobileNumber != matchThis.account.mobileNumber || $scope.selectedInvoiceDetails.account.email != matchThis.account.email
          modalService.openConfirmModal(
            title: 'Update'
            body: 'Would you also like to update account information in main account?',
            ok: 'Yes',
            cancel: 'No'
          ).then(
            (res) ->
              dData.updateAccountDetails = true
              accountService.genInvoice(obj, dData).then($scope.genInvoiceSuccess, $scope.genInvoiceFailure)
            ,(res) ->
              dData.updateAccountDetails = false
              accountService.genInvoice(obj, dData).then($scope.genInvoiceSuccess, $scope.genInvoiceFailure)
          )
        else
          accountService.genInvoice(obj, dData).then($scope.genInvoiceSuccess, $scope.genInvoiceFailure)
#        else
#          toastr.error("Buyer's address can not be left blank.")
#          $scope.updatingTempData = false
#          $scope.genMode = true
      else
        toastr.warning("Enter proper date", "Warning")
        $scope.genMode = true
        $scope.updatingTempData = false
        return false

    else
      console.log "do nothing"


  $scope.saveTempSuccess=(res)->
    $scope.updatingTempData = false
    abc = _.omit(res.body, "logo")
    _.extend($scope.templateData , abc)
    toastr.success("Template updated successfully", "Success")
    $scope.modalInstance.close()

  $scope.saveTempFailure = (res) ->
    $scope.updatingTempData = false
    toastr.error(res.data.message, res.data.status)


  $scope.genInvoiceSuccess=(res)->
    $scope.updatingTempData = false
    toastr.success(res.body, "Success")
    $scope.modalInstance.close()
    _.each(sendForGenerate, (removeThis) ->
      index = $scope.ledgers.results.indexOf(removeThis)
      $scope.ledgers.results.splice(index, 1)
    )
    sendForGenerate = []
    $scope.buttonStatus()
    $scope.getAllTransaction()
    $scope.entriesForInvoice = []


  # $scope.getLedgerEntries()

  $scope.genInvoiceFailure = (res) ->
    if res.data.code is "INVALID_TAX"
      $scope.updatingTempData = false
      modalService.openConfirmModal(
        title: 'Something wrong with your invoice data',
        body: res.data.message+'\\n Do you still want to generate invoice with incorrect data.',
        ok: 'Generate Anyway',
        cancel: 'Cancel'
      ).then ->
        $scope.saveTemp('generate', true)
    else
      $scope.updatingTempData = false
      toastr.error(res.data.message, res.data.status)
      # if invoice date have any problem
      # if res.data.code is 'ENTRIES_AFTER_INOICEDATE'
      #   $scope.genMode = true
      # else if res.data.code is 'INVALID_INVOICE_DATE'
      #   $scope.genMode = true
      $scope.genMode = true

#  # get inv templates
#  if not(_.isEmpty(sendForGenerate[0].account.uniqueName))
#    ledgerObj = DAServices.LedgerGet()
#    if !_.isEmpty(ledgerObj.ledgerData)
#      $scope.loadInvoice(ledgerObj.ledgerData, ledgerObj.selectedAccount)
#    else
#      if !_.isNull(localStorageService.get("_ledgerData"))
#        lgD = localStorageService.get("_ledgerData")
#        acD = localStorageService.get("_selectedAccount")
#        $scope.loadInvoice(lgD, acD)

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
    if typeof($scope.defTempData.terms) == 'object' && not(_.isEmpty($scope.defTempData.terms))
      $scope.defTempData.termsStr = $scope.defTempData.terms.join("\n")
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

  $scope.selectAllLedger = (condition) ->
    _.each $scope.ledgers.results, (ledger) ->
      ledger.checked = condition
      $scope.addThis(ledger, condition)

  $timeout ( ->
    $scope.getTemplates()
  ),2000

  $scope.broadcastToProforma = () ->
    $scope.$broadcast("proformaSelect","")


giddh.webApp.controller 'invoice2Controller', invoice2controller