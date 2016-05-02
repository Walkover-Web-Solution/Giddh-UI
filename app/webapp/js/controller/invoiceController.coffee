"use strict"
invoiceController = ($scope, $rootScope, $filter, $uibModal, $timeout, toastr, localStorageService, groupService, DAServices,  Upload, ledgerService, companyServices, accountService, modalService) ->

  $rootScope.selectedCompany = {}
  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
  # invoice setting
  $scope.withSampleData = true
  $scope.logoUpldComplt = false
  $scope.showAccountList = false
  $scope.invoiceLoadDone = false
  $scope.noDataDR = false
  # default Template data
  $scope.tempDataDef=
    logo: 
      path: '/public/website/images/logo.png'
    invoiceDetails:
      invoiceNumber: '##########'
      invoiceDate: '11-12-2016'
    company:
      name: 'Walkover Web Solutions Pvt. ltd.'
      data: '405-406 Capt. C.S. Naidu Arcade,10/2 Old Palasiya,Indore Madhya Pradesh,CIN: 02830948209eeri,Email: account@giddh.com'
    companyIdentities: 
      data: 'tin:67890, cin:12345'
    entries: null
    terms: [
      "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
      "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
      "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
    ]
    signature:
      name: 'Walkover Web Solutions Pvt. ltd.'
      data: 'Authorised Signatory'
    account:
      name: 'Career Point Ltd.'
      data: 'CP Tower Road No. 1,Indraprashta Industrial Kota,PAN: 1862842,Email: info@career.com'
  # invoice setting end

  # datepicker setting end
  $scope.dateData = {
    fromDate: new Date(moment().subtract(3, 'month').utc())
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
  $scope.onlyDrData = []
  $scope.entriesForInvoice = []

  # end of page load varialbles

  $scope.getAllGroupsWithAcnt=()->
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      # with accounts, group data
      groupService.getGroupsWithAccountsCropped($rootScope.selectedCompany.uniqueName).then($scope.makeAccountsList, $scope.makeAccountsListFailure)
      # without accounts only groups conditionally
      cData = localStorageService.get("_selectedCompany")
      if cData.sharedEntity is 'accounts'
        console.info "sharedEntity:"+ cData.sharedEntity
      else
        groupService.getGroupsWithoutAccountsCropped($rootScope.selectedCompany.uniqueName).then($scope.getGroupListSuccess, $scope.getGroupListFailure)

  $scope.makeAccountsList = (res) ->
    # flatten all groups with accounts and only accounts flatten
    item = {
      name: "Current Assets"
      uniqueName:"current_assets"
    }
    result = groupService.matchAndReturnGroupObj(item, res.body)
    $rootScope.flatGroupsList = groupService.flattenGroup([result], [])
    $scope.flatAccntWGroupsList = groupService.flattenGroupsWithAccounts($rootScope.flatGroupsList)
    $rootScope.canChangeCompany = true
    $scope.showAccountList = true
    if not(_.isEmpty($rootScope.$stateParams.invId))
      $scope.toggleAcMenus(true)

  $scope.makeAccountsListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)


  #Expand or  Collapse all account menus
  $scope.toggleAcMenus = (state) ->
    if !_.isEmpty($scope.flatAccntWGroupsList)
      _.each($scope.flatAccntWGroupsList, (e) ->
        e.open = state
        $scope.showSubMenus = state
      )

  # trigger expand or collapse func
  $scope.checkLength = (val)->
    if val is '' || _.isUndefined(val)
      $scope.toggleAcMenus(false)
    else if val.length >= 4
      $scope.toggleAcMenus(true)
    else
      $scope.toggleAcMenus(false)
  # end acCntrl

  $scope.loadInvoice = (data, acData) ->
    DAServices.LedgerSet(data, acData)
    localStorageService.set("_ledgerData", data)
    localStorageService.set("_selectedAccount", acData)
    # call invoice load func
    $scope.getTemplates()


  $scope.getTemplates = ()->
    companyServices.getInvTemplates($rootScope.selectedCompany.uniqueName).then($scope.getTemplatesSuccess, $scope.getTemplatesFailure)

  $scope.getTemplatesSuccess=(res)->
    console.log "getTemplatesSuccess:", res
    $scope.invoiceLoadDone = true
    $scope.templateList = res.body.templates
    $scope.templateData = res.body.templateData

  $scope.getTemplatesFailure = (res) ->
    $scope.invoiceLoadDone = true
    toastr.error(res.data.message, res.data.status)

  # set as default
  $scope.setDefTemp = (data) ->
    if data.isDefault
      obj = 
        uniqueName: $rootScope.selectedCompany.uniqueName
        tempUname: data.uniqueName
      companyServices.setDefltInvTemplt(obj).then(
        (res)->
          $scope.templateList = res.body.templates
          $scope.templateData = res.body.templateData
          toastr.success("Template changed successfully", "Success")
        , (res)->
          data.isDefault = false
          toastr.error(res.data.message, res.data.status)
      )
    else
      toastr.warning("You have to select atleast one template", "Warning")
      data.isDefault = true

  # switch sample data with original data
  $scope.switchTempData=()->
    if $scope.withSampleData
      $scope.withSampleData = false
      _.extend($scope.defTempData , $scope.templateData)
    else
      $scope.withSampleData = true
      _.extend($scope.defTempData , $scope.tempDataDef)
    $scope.convertIntoOur()

  # view template with sample data
  $scope.viewInvTemplate =(template, mode, data) ->
    $scope.logoWrapShow = false
    $scope.logoUpldComplt = false
    $scope.tempSet = {}
    $scope.defTempData = {}
    # set mode
    $scope.editMode = if mode is 'edit' then true else false
    $scope.tempSet = template.sections
    
    _.extend($scope.defTempData , data)
    $scope.convertIntoOur()

    # open dialog
    $scope.modalInstance = $uibModal.open(
      templateUrl: '/public/webapp/views/prevInvoiceTemp.html'
      size: "a4"
      backdrop: 'static'
      scope: $scope
    )
    if not(_.isUndefined($scope.defTempData.grandTotal))
      $scope.numbDigit = window.num2Words.inWords($scope.defTempData.grandTotal)
      console.log $scope.numbDigit
    

  # upload logo
  $scope.uploadLogo=(files)->
    $scope.logoUpldComplt = true
    angular.forEach files, (file) ->
      file.upload = Upload.upload(
        url: '/upload/' + $rootScope.selectedCompany.uniqueName + '/logo'
        file: file
      )
      file.upload.then ((res) ->
        $timeout ->
          toastr.success("Logo Uploaded Successfully", res.data.status)
      ), ((res) ->
        console.log res, "error"
        toastr.warning("Something went wrong", "warning")
      ), (evt) ->
        console.log "file upload progress" ,Math.min(100, parseInt(100.0 * evt.loaded / evt.total))

  # reset Logo
  $scope.resetLogo=()->
    $scope.logoUpldComplt = false

  $scope.showUploadWrap=()->
    $scope.logoWrapShow = true

  # convert data for UI usage
  $scope.convertIntoOur=()->
    # company setting
    if not(_.isEmpty($scope.defTempData.company.data))
      $scope.defTempData.company.data = $scope.defTempData.company.data.replace(RegExp(',', 'g'), '\n')
    
    # companyIdentities setting
    if not(_.isEmpty($scope.defTempData.companyIdentities.data))
      $scope.defTempData.companyIdentities.data = $scope.defTempData.companyIdentities.data.replace(RegExp(',', 'g'), '\n')

    # terms setting
    if $scope.defTempData.terms.length > 0
      str = $scope.defTempData.terms.toString()
      $scope.defTempData.termsStr = str.replace(RegExp(',', 'g'), '\n')


  # save template data
  $scope.saveTemp=(stype, force)->
    $scope.updatingTempData = true
    dData = {}
    data = {}
    angular.copy($scope.defTempData, data)

    # company setting
    if not(_.isEmpty(data.company.data))
      data.company.data = data.company.data.replace(RegExp('\n', 'g'), ',')
    
    # companyIdentities setting
    if not(_.isEmpty(data.companyIdentities.data))
      data.companyIdentities.data = data.companyIdentities.data.replace(RegExp('\n', 'g'), ',')

    # terms setting
    if not(_.isEmpty(data.termsStr))
      data.terms = data.termsStr.split('\n')
    else
      data.terms = []

    if stype is 'save'
      companyServices.updtInvTempData($rootScope.selectedCompany.uniqueName, data).then($scope.saveTempSuccess, $scope.saveTempFailure)

    else if stype is 'generate'
      _.omit(data, 'termsStr')
      obj=
        compUname: $rootScope.selectedCompany.uniqueName
        acntUname: $rootScope.$stateParams.invId
      dData=
        uniqueNames: data.ledgerUniqueNames
        validateTax: true
        invoice: _.omit(data, 'ledgerUniqueNames')
      if force
        dData.validateTax = false

      accountService.genInvoice(obj, dData).then($scope.genInvoiceSuccess, $scope.genInvoiceFailure)

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
    _.each($scope.entriesForInvoice, (entry)->
      $scope.onlyDrData = _.reject($scope.onlyDrData, (item) ->
        item.id is entry.id
      )
    )
    $scope.entriesForInvoice = []

    
    # $scope.getLedgerEntries()

  $scope.genInvoiceFailure = (res) ->
    console.log "genInvoiceFailure", res
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

  

  # init func on dom ready
  
  # get accounts
  $scope.getAllGroupsWithAcnt()

  # get inv templates 
  if not(_.isEmpty($rootScope.$stateParams.invId))
    ledgerObj = DAServices.LedgerGet()
    if !_.isEmpty(ledgerObj.ledgerData)
      $scope.loadInvoice(ledgerObj.ledgerData, ledgerObj.selectedAccount)
    else
      if !_.isNull(localStorageService.get("_ledgerData"))
        lgD = localStorageService.get("_ledgerData")
        acD = localStorageService.get("_selectedAccount")
        $scope.loadInvoice(lgD, acD)

  

  # invoice setting end

  # get ledger entries to generate invoice
  $scope.getLedgerEntries=()->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $rootScope.$stateParams.invId
      fromDate: $filter('date')($scope.dateData.fromDate, "dd-MM-yyyy")
      toDate: $filter('date')($scope.dateData.toDate, "dd-MM-yyyy")
    }
    ledgerService.getLedger(unqNamesObj).then($scope.getLedgerEntriesSuccess, $scope.getLedgerEntriesFailure)

  $scope.getLedgerEntriesSuccess=(res)->
    $scope.onlyDrData = []
    _.each(res.body.ledgers, (ledger) ->
      if ledger.transactions.length > 1
        ledger.multiEntry = true
      else
        ledger.multiEntry = false
      sharedData = _.omit(ledger, 'transactions')
      _.each(ledger.transactions, (transaction, index) ->
        transaction.amount = parseFloat(transaction.amount).toFixed(2)
        newEntry = {sharedData: sharedData}
        newEntry.id = sharedData.uniqueName + "_" + index
        if transaction.type is "DEBIT"
          newEntry.transactions = [transaction]
          $scope.onlyDrData.push(newEntry)
      )
    )
    if $scope.onlyDrData.length is 0
      $scope.noDataDR = true
    else
      $scope.noDataDR = false
    $scope.onlyDrData = _.reject($scope.onlyDrData, (item) ->
      item.sharedData.invoiceGenerated is true
    )
    
  $scope.getLedgerEntriesFailure=(res)->
    console.log "getLedgerEntriesFailure: ", res
    toastr.error(res.data.message, res.data.status)

  $scope.summationForInvoice=(ths, entry, index)->
    if entry.sharedData.multiEntry
      if ths
        # create logic to select all multi Entries
        _.each($scope.onlyDrData, (item)->
          if item.sharedData.uniqueName is entry.sharedData.uniqueName
            item.sharedData.itemCheck = true
            $scope.entriesForInvoice.push(item)
        )
      else
        $scope.entriesForInvoice = _.filter($scope.entriesForInvoice, (item) ->
          not(entry.sharedData.uniqueName is item.sharedData.uniqueName)
        )
    else
      if ths
        $scope.entriesForInvoice.push(entry)
      else
        $scope.entriesForInvoice = _.reject($scope.entriesForInvoice, (item) ->
          entry.id is item.id
        )

    console.log $scope.entriesForInvoice

  $scope.prevAndGenInv=()->
    $scope.prevInProg = true
    arr = []
    _.each($scope.entriesForInvoice, (entry)->
      arr.push(entry.sharedData.uniqueName)
    )
    data =
      uniqueNames: _.uniq(arr)

    obj =
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $rootScope.$stateParams.invId

    accountService.prevInvoice(obj, data).then($scope.prevAndGenInvSuccess, $scope.prevAndGenInvFailure)

  $scope.prevAndGenInvSuccess=(res)->
    $scope.prevInProg = false
    console.log "prevAndGenInvSuccess: ", res.body
    $scope.viewInvTemplate(res.body.template, 'edit', res.body)
    

  $scope.prevAndGenInvFailure=(res)->
    $scope.prevInProg = false
    toastr.error(res.data.message, res.data.status)


  # get generated invoices list
  $scope.getInvList=()->
    obj =
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $rootScope.$stateParams.invId
      fromDate: $filter('date')($scope.dateData.fromDate, "dd-MM-yyyy")
      toDate: $filter('date')($scope.dateData.toDate, "dd-MM-yyyy")
    accountService.getInvList(obj).then($scope.getInvListSuccess, $scope.getInvListFailure)

  $scope.getInvListSuccess=(res)->
    console.log "getInvListSuccess: ", res.body
    $scope.genInvList = []
    _.extend($scope.genInvList , res.body)
    if $scope.genInvList is 0
      $scope.noDataGenInv = true
    else
      $scope.noDataGenInv = false
    

  $scope.getInvListFailure=(res)->
    console.log "getInvListFailure: ", res
    toastr.error(res.data.message, res.data.status)


  # delete invoice
  $scope.delInv=(inv)->
    console.log "delInv", inv
    obj =
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $rootScope.$stateParams.invId
      invoiceUniqueID: inv.uniqueName
    accountService.delInv(obj).then($scope.delInvSuccess, $scope.delInvFailure)

  $scope.delInvSuccess=(res)->
    console.log "delInvSuccess: ", res

  $scope.delInvFailure=(res)->
    console.log "delInvFailure: ", res

  $scope.summationForDownload=(entry)->
    console.log entry




  # end get generated invoice list



  # state change
  $scope.$on('$stateChangeStart', (event, toState, toParams, fromState, fromParams)->
    # close accounts dropdown and false var if going upwords
    if toState.name is "invoice.accounts"
      $scope.toggleAcMenus(false)
      $scope.invoiceLoadDone = false
  )




#init angular app
giddh.webApp.controller 'invoiceController', invoiceController