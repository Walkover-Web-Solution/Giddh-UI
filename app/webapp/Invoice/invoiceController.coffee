"use strict"
invoiceController = ($scope, $rootScope, $filter, $uibModal, $timeout, toastr, localStorageService, groupService, DAServices, $state,  Upload, ledgerService, companyServices, accountService, modalService, $location) ->

  $rootScope.selectedCompany = {}
  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
  # invoice setting
  $scope.withSampleData = true
  $scope.logoUpldComplt = false
  $scope.showAccountList = false
  $scope.invoiceLoadDone = false
  $scope.entryListUpdated = false
  $scope.noDataDR = false
  $scope.radioChecked = false
  $scope.genPrevMode = false
  $scope.genMode = false
  $scope.prevInProg = false
  $scope.InvEmailData = {}
  $scope.nameForAction = []
  $scope.onlyDrData = []
  $scope.entriesForInvoice = []
  $scope.flatAccntWGroupsList = []
  $scope.subgroupsList = []
  $scope.search = {}
  $scope.search.acnt = ''
  $scope.selectedAccountCategory = ''
  $scope.editGenInvoice = false
  $scope.invoiceSettings = {}
  $scope.invoiceSettings.emailAddress = ""
  $scope.gwaList = {
    page: 1
    count: 5000
    totalPages: 0
    currentPage : 1
    limit: 5
  }
  # default Template data
  $scope.tempDataDef=
    logo: 
      path: '/public/website/images/logo.png'
    invoiceDetails:
      invoiceNumber: '##########'
      invoiceDate: '11-12-2016'
    company:
      name: 'Walkover Web Solutions Pvt. ltd.'
      data: ['405-406 Capt. C.S. Naidu Arcade','10/2 Old Palasiya','Indore Madhya Pradesh','CIN: 02830948209eeri','Email: account@giddh.com']
    companyIdentities: 
      data: 'tin:67890,cin:12345'
    entries: [
      {
        "transactions": [
          {
            "amount": 54500,
            "accountName": "John",
            "accountUniqueName": "john",
            "description": "Purchase of Macbook"
          }
        ],
        "uniqueName": "d7t1462171597019"
      }
      {
        "transactions": [
          {
            "amount": 23700,
            "accountName": "John",
            "accountUniqueName": "john",
            "description": "Purchase of Ipad"
          }
        ],
        "uniqueName": "d7t1462171597030"
      }
      {
        "transactions": [
          {
            "amount": 25300,
            "accountName": "John",
            "accountUniqueName": "john",
            "description": "Purchase of Iphone"
          }
        ],
        "uniqueName": "d7t1462171597023"
      }
    ]
    terms: [
      "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
      "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
      "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
    ]
    grandTotal: 118507.50
    subTotal: 103500
    taxTotal: 0
    taxes:[
      {
        "hasError": false,
        "amount": 15007.50,
        "accountName": "vat@14.5",
        "taxRate": 14,
        "visibleTaxRate": 14,
        "errorMessage": "",
        "accountUniqueName": "vat14.5"
      }
    ]
    signature:
      name: 'Walkover Web Solutions Pvt. ltd.'
      data: 'Authorised Signatory'
    account:
      name: 'Career Point Ltd.'
      data: 'CP Tower Road No. 1,Indraprashta Industrial Kota,PAN: 1862842,Email: info@career.com'
      attentionTo:'Mr. Agrawal'
  # invoice setting end

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
  

  # end of page load varialbles

  # close popup
  $scope.closePop=()->
    $scope.withSampleData = true
    $scope.genMode = false
    $scope.genPrevMode = false
    $scope.prevInProg= true

  $scope.getAllGroupsWithAcnt=()->
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      # with accounts, group data
      $scope.getFlattenGrpWithAccList($rootScope.selectedCompany.uniqueName)
#      $scope.getSubgroupsWithAccounts($rootScope.selectedCompany.uniqueName,'sundry_debtors')
      $scope.getMultipleSubgroupsWithAccounts($rootScope.selectedCompany.uniqueName,['sundry_debtors','revenue_from_operations'])
      groupService.getGroupsWithAccountsCropped($rootScope.selectedCompany.uniqueName).then($scope.makeAccountsList, $scope.makeAccountsListFailure)

  $scope.makeAccountsList = (res) ->
    # flatten all groups with accounts and only accounts flatten
    item = {
      name: "Current Assets"
      uniqueName:"current_assets"
    }
    result = groupService.matchAndReturnGroupObj(item, res.body)
    $rootScope.flatGroupsList = groupService.flattenGroup([result], [])
    #$scope.flatAccntWGroupsList = groupService.flattenGroupsWithAccounts($rootScope.flatGroupsList)
    $rootScope.canChangeCompany = true
    #$scope.showAccountList = true
    if not(_.isEmpty($rootScope.$stateParams.invId))
      $scope.toggleAcMenus(true)

  $scope.makeAccountsListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  
  # search flat accounts list
  $scope.searchAccounts = (str) ->
    console.log("inside search accounts")
#    reqParam = {}
#    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
#    if str.length > 2
#      $scope.hideAccLoadMore = true
#      reqParam.q = str
#      reqParam.count = 5000
#    else
#      $scope.hideAccLoadMore = false
#      reqParam.q = ''
#      reqParam.count = 5000
#    groupService.getFlatAccList(reqParam).then($scope.getFlatAccountListListSuccess, $scope.getFlatAccountListFailure)

  #----------- Get multiple subgroups with accounts -----------#
  $scope.getMultipleSubgroupsWithAccounts = (compUname, groupUnames) ->
    reqParam = {
      companyUniqueName: compUname
    }
    data = {uniqueNames:groupUnames}
    groupService.getMultipleSubGroups(reqParam,data).then($scope.getMSubgroupsSuccess,$scope.getMSubgroupsFailure)

  $scope.getMSubgroupsSuccess = (res) ->
    $scope.flatAccntWGroupsList = []
#    $scope.flatAccntWGroupsList.push(res.body)
    $scope.filterSundryDebtors(res.body)
    _.extend($scope.subgroupsList,$scope.flatAccntWGroupsList)
    $scope.gwaList.limit = 5

  $scope.getMSubgroupsFailure = (res) ->
    toastr.error(res.data.message)

  #----------- Get subgroups with accounts -----------#
  $scope.getSubgroupsWithAccounts = (compUname, groupUname) ->
    reqParam = {
      companyUniqueName: compUname
      groupUniqueName: groupUname
    }
    groupService.getSubgroupsWithAccounts(reqParam).then($scope.getSubgroupsSuccess,$scope.getSubgroupsFailure)

  $scope.getSubgroupsSuccess = (res) ->
#    console.log(res)
    $scope.flatAccntWGroupsList = []
    $scope.flatAccntWGroupsList.push(res.body)
    $scope.filterSundryDebtors(res.body.groups)
    _.extend($scope.subgroupsList,$scope.flatAccntWGroupsList)
    $scope.gwaList.limit = 5

  $scope.getSubgroupsFailure = (res) ->
    console.log(res)

  #-------- fetch groups with accounts list-------
  $scope.getFlattenGrpWithAccList = (compUname) ->
    reqParam = {
      companyUniqueName: compUname
      q: ''
      page: $scope.gwaList.page
      count: $scope.gwaList.count
    }
    groupService.getFlattenGroupAccList(reqParam).then($scope.getFlattenGrpWithAccListSuccess, $scope.getFlattenGrpWithAccListFailure)

  $scope.getFlattenGrpWithAccListSuccess = (res) ->
    $scope.gwaList.totalPages = res.body.totalPages
#    $scope.flatAccntWGroupsList = []
#    $scope.filterSundryDebtors(res.body.results)
#    $scope.showAccountList = true
    $scope.gwaList.limit = 5  

  $scope.getFlattenGrpWithAccListFailure = (res) ->
    toastr.error(res.data.message)

  $scope.loadMoreGrpWithAcc = (compUname) ->
    $scope.gwaList.limit += 5

  $scope.loadMoreGrpWithAccSuccess = (res) ->
    $scope.gwaList.currentPage += 1
    list = res.body.results
    if res.body.totalPages >= $scope.gwaList.currentPage
      $scope.flatAccntWGroupsList = _.union($scope.flatAccntWGroupsList, list)
    else
      $scope.hideLoadMore = true

  $scope.loadMoreGrpWithAccFailure = (res) ->
    toastr.error(res.data.message)

  $scope.searchGrpWithAccounts = (str) ->
#    $scope.flatAccntWGroupsList = []
#    if _.isEmpty(str)
#      _.extend($scope.flatAccntWGroupsList,$scope.subgroupsList)
#    else
#      _.each($scope.subgroupsList,(group) ->
#        if group.name.toLowerCase().match(str) || group.uniqueName.match(str)
#          $scope.flatAccntWGroupsList.push(group)
#        else
#          if group.accounts.length > 0
#            _.each(group.accounts, (account) ->
#              if account.name.toLowerCase().match(str) || account.uniqueName.match(str)
#                $scope.flatAccntWGroupsList.push(group)
#            )
#      )
    if str.length < 1
      $scope.gwaList.limit = 5

  $scope.isGrpMatch = (g, q) ->
    p = RegExp(q,"i")
    if (g.name.match(p) || g.uniqueName.match(p))
      return true
    return false

  $scope.loadMoreGrpWithAcc = () ->
    $scope.gwaList.limit += 5

  $scope.filterSundryDebtors = (grpList) ->
#    $scope.flatAccntWGroupsList = _.flatten(grpList)
    _.each grpList, (grp) ->
#      if grp.groupUniqueName == 'sundry_debtors'
        grp.open = false

        if grp.accounts.length > 0
          _.each grp.accounts, (acc) ->
            if acc.uniqueName == $rootScope.$stateParams.invId
              $scope.selectedAccountCategory = grp.category

        $scope.flatAccntWGroupsList.push(grp)
        if grp.groups.length > 0
          $scope.filterSundryDebtors(grp.groups)
    $scope.showAccountList = true
#    console.log($scope.flatAccntWGroupsList)



  $scope.loadMoreGrpWithAccFailure = (res) ->
    toastr.error(res.data.message)


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
    $scope.selectedAccountCategory = data.category
    localStorageService.set("_ledgerData", data)
    localStorageService.set("_selectedAccount", acData)
    $rootScope.$stateParams.invId = acData.uniqueName
    $scope.entriesForInvoice = []
    # call invoice load func
    $scope.getTemplates()
    $scope.invoiceLoadDone = true


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

  # upload logo
  $scope.uploadLogo=(files,type)->
    $scope.logoUpldComplt = true
    $scope.signatureUpldComplt = true
    angular.forEach files, (file) ->
      file.fType = type
#      console.log file
      file.upload = Upload.upload(
        url: '/upload/' + $rootScope.selectedCompany.uniqueName + '/logo'
        # file: file
        # fType: type
        data : {
          file: file
          fType: type
        }
      )
      file.upload.then ((res) ->
        $timeout ->
          # $scope.logoWrapShow = false
          $scope.defTempData.signature.path = res.data.body.path
          toastr.success("Logo Uploaded Successfully", res.data.status)
      ), ((res) ->
#        console.log res, "error"
        $scope.logoUpldComplt = false
        $scope.signatureUpldComplt = false
        toastr.warning("Something went wrong", "warning")
      ), (evt) ->
        console.log "file upload progress" ,Math.min(100, parseInt(100.0 * evt.loaded / evt.total))

  # reset Logo
  $scope.resetLogo=()->
    $scope.logoUpldComplt = false
    $scope.logoWrapShow = true

  $scope.showUploadWrap=()->
    $scope.logoWrapShow = true

  # reset Signature
  $scope.resetSignature=()->
    $scope.signatureUpldComplt = false
    $scope.signatureWrapShow = true

  $scope.showUploadSignatureWrap=()->
    $scope.signatureWrapShow = true

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


  # save template data
  $scope.saveTemp=(stype, force)->
    $scope.genMode = false
    $scope.updatingTempData = true
    dData = {}
    data = {}
    angular.copy($scope.defTempData, data)

    # company setting
    if not(_.isEmpty(data.company.data))
      data.company.data = data.company.data.split('\n')
      #data.company.data.replace(RegExp('\n', 'g'), ',')
    if not(_.isEmpty(data.account.data))
      data.account.data = data.account.data.split('\n')

    # companyIdentities setting
    if not(_.isEmpty(data.companyIdentities.data))
      data.companyIdentities.data = data.companyIdentities.data.replace(RegExp('\n', 'g'), ',')
      # data.companyIdentities.data = data.companyIdentities.data.replace(RegExp(' ', 'g'), '')

    # terms setting
    if not(_.isEmpty(data.termsStr))
      data.terms = data.termsStr.split('\n')
    else
      data.terms = []

#    if data.invoiceDetails.dueDate != ""
#      data.invoiceDetails.dueDate = moment(data.invoiceDetails.dueDate).format('DD-MM-YYYY')
#    else
#      data.invoiceDetails.dueDate = null

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

      if moment(data.invoiceDetails.invoiceDate, "DD-MM-YYYY", true).isValid()
        if $scope.defTempData.account.data.length > 0 
          accountService.genInvoice(obj, dData).then($scope.genInvoiceSuccess, $scope.genInvoiceFailure)
        else
          toastr.error("Buyer's address can not be left blank.")
          $scope.updatingTempData = false
          $scope.genMode = true
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
    _.each($scope.entriesForInvoice, (entry)->
      $scope.onlyDrData = _.reject($scope.onlyDrData, (item) ->
        item.id is entry.id
      )
    )
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
    $scope.entriesForInvoice = []
    $scope.prevInProg = false
    obj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $rootScope.$stateParams.invId
      fromDate: $filter('date')($scope.dateData.fromDate, "dd-MM-yyyy")
      toDate: $filter('date')($scope.dateData.toDate, "dd-MM-yyyy")
    }
    ledgerService.getLedger(obj).then($scope.getLedgerEntriesSuccess, $scope.getLedgerEntriesFailure)
    $scope.entryListUpdated = false

  $scope.getLedgerEntriesSuccess = (res)->
    $scope.onlyDrData = []
    _.each(res.body.ledgers, (ledger) ->
      if ledger.transactions.length > 1
        ledger.multiEntry = true
      else
        ledger.multiEntry = false
      sharedData = _.omit(ledger, 'transactions')
      sharedData.itemCheck = false
      _.each(ledger.transactions, (transaction, index) ->
        transaction.amount = parseFloat(transaction.amount).toFixed(2)
        newEntry = {sharedData: sharedData}
        newEntry.id = sharedData.uniqueName + "_" + index
        if $scope.selectedAccountCategory.toLowerCase() != 'income' && transaction.type is "DEBIT"
          newEntry.transactions = [transaction]
          $scope.onlyDrData.push(newEntry)
        if $scope.selectedAccountCategory.toLowerCase() == 'income' && transaction.type is "CREDIT"
          newEntry.transactions = [transaction]
          $scope.onlyDrData.push(newEntry)
      )
    )
    $scope.onlyDrData = _.reject($scope.onlyDrData, (item) ->
      item.sharedData.invoiceGenerated is true
    )
    if $scope.onlyDrData.length is 0
      $scope.noDataDR = true
    else
      $scope.noDataDR = false
    $scope.entryListUpdated = true
    
  $scope.getLedgerEntriesFailure=(res)->
    toastr.error(res.data.message, res.data.status)
    $scope.entryListUpdated = true

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

    if $scope.entriesForInvoice.length > 0
      $scope.prevInProg= true
    else
      $scope.prevInProg= false

    entry.sharedData.itemCheck = ths

  $scope.prevAndGenInv=()->
    $scope.genMode = true
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
    $scope.viewInvTemplate(res.body.template, 'edit', res.body)
    

  $scope.prevAndGenInvFailure=(res)->
    $scope.prevInProg = false
    $scope.entriesForInvoice = []
    toastr.error(res.data.message, res.data.status)
    $scope.resetAllCheckBoxes()

  $scope.resetAllCheckBoxes = () ->
    _.each $scope.onlyDrData, (dr) ->
      dr.sharedData.itemCheck = false


  # get generated invoices list
  $scope.getInvList=()->
    obj =
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $rootScope.$stateParams.invId
      fromDate: $filter('date')($scope.dateData.fromDate, "dd-MM-yyyy")
      toDate: $filter('date')($scope.dateData.toDate, "dd-MM-yyyy")
    accountService.getInvList(obj).then($scope.getInvListSuccess, $scope.getInvListFailure)

  $scope.getInvListSuccess=(res)->
    $scope.genInvList = []
    _.extend($scope.genInvList , res.body)
    if $scope.genInvList.length is 0
      $scope.noDataGenInv = true
    else
      $scope.noDataGenInv = false
    

  $scope.getInvListFailure=(res)->
    toastr.error(res.data.message, res.data.status)

  $scope.summationForDownload=(entry)->
    $scope.radioChecked = true
    $scope.nameForAction = []
    $scope.nameForAction.push(entry.invoiceNumber)

  # mail Invoice
  $scope.sendInvEmail=(emailData)->
    obj =
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $rootScope.$stateParams.invId
    sendData=
      emailId: []
      invoiceNumber: $scope.nameForAction
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
    accountService.mailInvoice(obj, sendData).then($scope.sendInvEmailSuccess, $scope.multiActionWithInvFailure)

  $scope.sendInvEmailSuccess=(res)->
    toastr.success("Email sent successfully", "Success")
    $scope.InvEmailData = {}

  # delete invoice
  $scope.multiActionWithInv=(type)->
    if $scope.nameForAction.length is 0
      toastr.warning("Something went wrong", "Warning")
      return false

    obj =
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $rootScope.$stateParams.invId

    if type is 'delete'
      obj.invoiceUniqueID= $scope.nameForAction[0]
      companyServices.delInv(obj).then($scope.delInvSuccess, $scope.multiActionWithInvFailure)

    if type is 'download'
      data=
        invoiceNumber: $scope.nameForAction
        template: ""
      accountService.downloadInvoice(obj, data).then($scope.downInvSuccess, $scope.multiActionWithInvFailure)

  # common failure message
  $scope.multiActionWithInvFailure=(res)->
    toastr.error(res.data.message, res.data.status)

  $scope.delInvSuccess=(res)->
    toastr.success("Invoice deleted successfully", "Success")
    $scope.radioChecked = false
    $scope.nameForAction = []
    $scope.getInvList()

  $scope.downInvSuccess=(res)->
    dataUri = 'data:application/pdf;base64,' + res.body
    a = document.createElement('a')
    a.download = $scope.nameForAction[0]+".pdf"
    a.href = dataUri
    a.click()
    #close dialog box
    # if $scope.genPrevMode
    #   $scope.modalInstance.close()
    # $scope.genPrevMode = false

    # $scope.isSafari = Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0
    # if $scope.msieBrowser()
    #   #$scope.openWindow("data:application/pdf;base64, " + res.body)
    #   window.navigator.msSaveBlob(file, 'abc.pdf')
    # else if $scope.isSafari       
    #   modalInstance = $uibModal.open(
    #     template: '<div>
    #         <div class="modal-header">
    #           <h3 class="modal-title">Download File</h3>
    #         </div>
    #         <div class="modal-body">
    #           <p class="mrB">To download your file Click on button</p>
    #           <button onClick="window.open(\'data:application/pdf;base64, '+res.body+'\')" class="btn btn-primary">Download</button>
    #         </div>
    #         <div class="modal-footer">
    #           <button class="btn btn-default" ng-click="$dismiss()">Cancel</button>
    #         </div>
    #     </div>'
    #     size: "sm"
    #     backdrop: 'static'
    #     scope: $scope
    #   )
    # else
      # passthis = "data:application/pdf;base64, " + res.body 
      # window.open(passthis)
    # a = document.createElement("a")
    # document.body.appendChild(a)
    # a.style = "display:none"
    # a.href = fileURL
    # a.download = $scope.nameForAction[0]+".pdf"
    # a.click()


  # preview of generated invoice
  $scope.prevGenerateInv=(item)->
    $scope.nameForAction = []
    $scope.nameForAction.push(item.invoiceNumber)
    obj =
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $rootScope.$stateParams.invId
      invoiceUniqueID: item.invoiceNumber
    accountService.prevOfGenInvoice(obj).then($scope.prevGenerateInvSuccess, $scope.prevGenerateInvFailure)

  $scope.prevGenerateInvSuccess=(res)->
    $scope.genPrevMode = true
    $scope.viewInvTemplate( res.body.template, 'genprev', res.body)
    $scope.tempType=
      uniqueName: res.body.template.uniqueName

  $scope.prevGenerateInvFailure=(res)->
    toastr.error(res.data.message, res.data.status)

  $scope.setDiffView=()->
    even = _.find($scope.templateList, (item)->
      item.uniqueName is $scope.tempType.uniqueName
    )
    $scope.tempSet = even.sections
    $scope.defTempData.signatureType = $scope.tempSet.signatureType

  $scope.downInv=()->
    obj =
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $rootScope.$stateParams.invId
    data=
      invoiceNumber: $scope.nameForAction
      template: $scope.tempType.uniqueName
    accountService.downloadInvoice(obj, data).then($scope.downInvSuccess, $scope.multiActionWithInvFailure)

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

  $scope.saveInvoiceSettings = (action) ->
    if action == 'delete'
      $scope.invoiceSettings.emailAddress = ""
    if _.isEmpty($scope.invoiceSettings.emailAddress)
      $scope.invoiceSettings.emailAddress = null
    obj = {
      companyUniqueName : $rootScope.selectedCompany.uniqueName
    }
    companyServices.saveInvoiceSetting(obj.companyUniqueName,$scope.invoiceSettings).then((res) ->
        $scope.saveInvoiceSettingsSuccess(res, action)
      , $scope.saveInvoiceSettingsFailure)

  $scope.saveInvoiceSettingsSuccess = (res,action) ->
    if action == 'delete'
      toastr.error("Email deleted successfully.")
      $scope.invoiceSettings.isEmailVerified = false
    else
      toastr.success(res.body)

  $scope.saveInvoiceSettingsFailure = (res) ->
    toastr.error(res.data.message)
  
  # state change
  $scope.$on('$stateChangeStart', (event, toState, toParams, fromState, fromParams)->
    # close accounts dropdown and false var if going upwords
    if toState.name is "invoice.accounts"
      $scope.toggleAcMenus(false)
      $scope.invoiceLoadDone = false
  )

  $timeout(->
    $rootScope.basicInfo = localStorageService.get("_userDetails")
    if !_.isEmpty($rootScope.selectedCompany)
      $rootScope.cmpViewShow = true
  ,1000)

  # init func on dom ready
  $timeout(->
    $scope.getTemplates()
    # get accounts
    $scope.getAllGroupsWithAcnt()

    # group list through api
    $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)

  ,10)

  $scope.redirectToState = (state) ->
    $state.go(state)

  $scope.$on 'company-changed', (event,changeData) ->
    $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
#    $scope.getMultipleSubgroupsWithAccounts($rootScope.selectedCompany.uniqueName,['sundry_debtors','revenue_from_operations'])
    # when company is changed, redirect to manage company page
    if changeData.type == 'CHANGE'
      $scope.redirectToState('company.content.manage')

giddh.webApp.controller 'invoiceController', invoiceController