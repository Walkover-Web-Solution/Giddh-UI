'use strict'

proformaController = ($scope, $rootScope, localStorageService,invoiceService,settingsService ,$timeout, toastr, $filter, $uibModal,accountService, groupService, $state, companyServices,FileSaver,modalService) ->
  if _.isUndefined($rootScope.selectedCompany)
    $rootScope.selectedCompany = localStorageService.get('_selectedCompany')
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
  $scope.pTemplateList = []
  $scope.sundryDebtors = []
  pc = @
  $scope.count = {}
  $scope.count.set = [10,15,30,35,40,45,50]
  $scope.count.val = $scope.count.set[0]
  $scope.editStatus = false
  $scope.subtotal = 0
  $scope.selectedTemplate = null
  $scope.editMode = false
  $scope.addressList = ''
  $scope.disableCreate = true
  $scope.enableCreate = true
  $scope.discount = {}
  $scope.discount.amount = 0
  $scope.discount.accounts = []
  $scope.discountTotal = 0
  ## Get all Proforma ##
  $scope.gettingProformaInProgress = false
  $scope.popOver = {
    content: 'Hello, World!',
    templateUrl: 'proformaDropdown.html',
    title: 'Title'
  }
  $scope.getAllProforma = () ->
    @success = (res) ->
      $scope.gettingProformaInProgress = false
      $scope.proformaList = res.body
      if res.body.results.length < 1
        $scope.showFilters = true

    @failure = (res) ->
      $scope.gettingProformaInProgress = false
      toastr.error(res.data.message)

    if $scope.gettingProformaInProgress
      return
    else
      $scope.gettingProformaInProgress = true
      reqParam = {}
      reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
      reqParam.date1 = $filter('date')($scope.filters.fromDate, 'dd-MM-yyyy')
      reqParam.date2 = $filter('date')($scope.filters.toDate, 'dd-MM-yyyy')
      reqParam.count = $scope.count.val
      reqParam.page = $scope.count.page
      invoiceService.getAllProforma(reqParam).then(@success, @failure)

  ## proforma filters ##
  $scope.balanceStatuses = ['All', 'paid','unpaid', 'partial-paid', 'hold', 'partial']
  $scope.balanceStatusOptions = ['paid','unpaid', 'hold', 'cancel']
  $scope.filters = {
      "balanceStatus":$scope.balanceStatuses[0]
      "accountUniqueName": ''
      "balanceDue":null
      "proformaNumber":""
      "balanceEqual": false
      "balanceMoreThan": false
      "balanceLessThan": false
      "dueDate": null
      "fromDate":$filter('date')(d._d, 'dd-MM-yyyy')
      "toDate":$filter('date')($scope.today, 'dd-MM-yyyy')
      "dueDateEqual": true
      "dueDateAfter": false
      "dueDateBefore": true
      "attentionTo":""
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
      "dueDate": null
      "fromDate":$filter('date')(d._d, 'dd-MM-yyyy')
      "toDate":$filter('date')($scope.today, 'dd-MM-yyyy')
      "dueDateEqual": true
      "dueDateAfter": false
      "dueDateBefore": true
      "attentionTo":""
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
    $scope.filters.page = $scope.proformaList.page || 1
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

  $scope.loadProforma = (proforma) ->
    $scope.editMode = false
    $scope.currentProforma = proforma
    @success = (res) ->
      # res.body.template.htmlData = JSON.parse(res.body.template.htmlData)
      # $scope.htmlData = res.body.template.htmlData
      pc.templateVariables = res.body.template.templateVariables
      pc.selectedAccountDetails = undefined
      selectedAccount = _.findWhere(pc.templateVariables, {key:"$accountUniqueName"})
      if selectedAccount
        account = {}
        account.uniqueName = selectedAccount.value
        $scope.setSelectedAccount(account)
      pc.htmlData = JSON.parse(res.body.template.htmlData)
      pc.sectionData = res.body.template.sections
      pc.checkEditableFields(pc.htmlData.sections)
      $scope.htmlData = pc.htmlData
      $scope.transactions = res.body.entries
      $scope.subtotal = res.body.subTotal
      $scope.taxTotal = res.body.taxTotal
      $scope.taxes = res.body.taxes
      $scope.discountTotal = res.body.discountTotal || 0
      if res.body.commonDiscount == null then res.body.commonDiscount = {} else res.body.commonDiscount = res.body.commonDiscount
      $scope.discount.amount = Math.abs(res.body.commonDiscount.amount) || null
      $scope.discount.account = res.body.commonDiscount.accountUniqueName || null
      #$scope.calcSubtotal()
      $timeout ( ->
        $scope.modalInstance = $uibModal.open(
          templateUrl: $rootScope.prefixThis+'/public/webapp/invoice2/proforma/prevProforma.html'
          size: "a4"
          backdrop: 'static'
          scope: $scope
        )
      ),500
      # console.log $scope.taxes, $scope.taxTotal
    @failure = (res) ->
      toastr.error(res.data.message)
    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    data = {}
    data.proforma = proforma.uniqueName
    invoiceService.getProforma(reqParam,data).then(@success, @failure)

  $scope.switchMode = () ->
    $$this = @
    $$this.getValues = (elements) ->
      _.each elements, (elem) ->
        if elem.type == 'Text' && elem.hasVar && elem.variable.isEditable
          if typeof(elem.variable.value) == "object"
            elem.variable.value = elem.variable.value
        else if elem.type == 'Element' && elem.children && elem.children.length > 0
          $$this.getValues(elem.children)
    if $scope.editMode
      _.each $scope.htmlData.sections, (sec) ->
        if sec.elements.length
          $$this.getValues(sec.elements)
      $scope.createProforma('update')
    $scope.editMode = true


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

  $scope.changeBalanceStatus = (proforma,index) ->
    $scope.selectedProforma = {}
    _.extend($scope.selectedProforma, proforma)
    $scope.selectedProformaIndex = index
    @success = (res) ->
      toastr.success("successfully updated")
      proforma.editStatus = !proforma.editStatus
      proforma = res.body
    @failure = (res) ->
      toastr.error(res.data.message)
    data = {}
    data.action = proforma.balanceStatus
    data.proformaUniqueName = proforma.uniqueName
    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    if proforma.balanceStatus == "paid"
      $scope.modalInstance = $uibModal.open(
        template: '<div>
            <div class="modal-header">
              <button type="button" class="close" data-dismiss="modal" ng-click="$dismiss()" aria-label="Close"><span
          aria-hidden="true">&times;</span></button>
            <h3 class="modal-title">Update Grand Total</h3>
            </div>
            <div class="modal-body">
              <input class="form-control" type="text" ng-model="selectedProforma.balance">
            </div>
            <div class="modal-footer">
              <button class="btn btn-default" ng-click="updateBalanceAmount(selectedProforma, selectedProformaIndex)">Paid</button>
            </div>
        </div>'
        size: "sm"
        backdrop: 'static'
        scope: $scope
      )
    else       
      invoiceService.updateBalanceStatus(reqParam, data).then(@success, @failure)

  $scope.updateBalanceAmount = (proforma,index) ->
    @success = (res) ->
      toastr.success("successfully updated")
      proforma.editStatus = !proforma.editStatus
      $scope.proformaList.results[index] = res.body
      $scope.modalInstance.close()
    @failure = (res) ->
      toastr.error(res.data.message)
    data = {}
    data.action = proforma.balanceStatus
    data.proformaUniqueName = proforma.uniqueName
    data.amount = proforma.balance
    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    invoiceService.updateBalanceStatus(reqParam, data).then(@success, @failure)

  $scope.gwaList = {
    page: 1
    count: 5000
    totalPages: 0
    currentPage : 1
    limit: 5
  }

  pc.getFlattenGrpWithAccList = (compUname) ->
    reqParam = {
      companyUniqueName: compUname
      q: ''
      page: $scope.gwaList.page
      count: $scope.gwaList.count
      showEmptyGroups: true
    }
    groupService.getFlattenGroupAccList(reqParam).then(pc.getFlattenGrpWithAccListSuccess, pc.getFlattenGrpWithAccListFailure)

  pc.getFlattenGrpWithAccListSuccess = (res) ->
    $scope.flatGrpList = res.body.results
    index = 0
    _.each $scope.flatGrpList, (grp, idx) ->
      if grp.groupUniqueName == $rootScope.groupName.sundryDebtors
        index = idx
    $scope.newAccountModel.group = $scope.flatGrpList[index]

  pc.getFlattenGrpWithAccListFailure = (res) ->
    toastr.error(res.data.message)


  $scope.$on("proformaSelect", () ->
    if !$scope.gettingProformaInProgress
      $scope.getAllProforma()
      $scope.gettingProformaInProgress
  )

  $scope.newAccountModel = {}  
  $scope.addNewAccount = (proforma, index) ->
    pc.selectedProforma = proforma
    pc.selectedProformaIndex = index
    $scope.newAccountModel.group = ''
    $scope.newAccountModel.account = proforma.accountName
    $scope.newAccountModel.accUnqName = ''
    pc.getFlattenGrpWithAccList($rootScope.selectedCompany.uniqueName)
    pc.AccmodalInstance = $uibModal.open(
      templateUrl: $rootScope.prefixThis+'/public/webapp/Ledger/createAccountQuick.html'
      size: "sm"
      backdrop: 'static'
      scope: $scope
    )
    #modalInstance.result.then($scope.addNewAccountCloseSuccess, $scope.addNewAccountCloseFailure)

  $scope.addNewAccountConfirm = () ->
    @success = (res) ->
      toastr.success('Account created successfully')
      $scope.proformaList.results[pc.selectedProformaIndex] = res.body
      pc.AccmodalInstance.close() 
    @failure = (res) ->
      toastr.error(res.data.message)

    $scope.newAccountModel.accUnqName = $scope.newAccountModel.accUnqName.replace(/ |,|\//g, '')
    $scope.newAccountModel.accUnqName = $scope.newAccountModel.accUnqName.toLowerCase()
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
    }
    data = {
      accountName: $scope.newAccountModel.account
      groupUniqueName: $scope.newAccountModel.group.groupUniqueName
      accountUniqueName: $scope.newAccountModel.accUnqName
      proformaUniqueName: pc.selectedProforma.uniqueName
    }
    if $scope.newAccountModel.group.groupUniqueName == '' || $scope.newAccountModel.group.groupUniqueName == undefined
      toastr.error('Please select a group.')
    else
      #accountService.createAc(unqNamesObj, newAccount).then(pc.addNewAccountConfirmSuccess, pc.addNewAccountConfirmFailure)
      invoiceService.linkProformaAccount(reqParam, data).then(@success, @failure) 

  pc.addNewAccountConfirmSuccess = (res) ->
    toastr.success('Account created successfully')
    #$rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
    pc.AccmodalInstance.close()

  pc.addNewAccountConfirmFailure = (res) ->
    toastr.error(res.data.message)

  $scope.genearateUniqueName = (unqName) ->
    unqName = unqName.replace(/ /g,'')
    unqName = unqName.toLowerCase()
    if unqName.length >= 1
      unq = ''
      text = ''
      chars = 'abcdefghijklmnopqrstuvwxyz0123456789'
      i = 0
      while i < 3
        text += chars.charAt(Math.floor(Math.random() * chars.length))
        i++ 
      unq = unqName + text
      $scope.newAccountModel.accUnqName = unq
    else
      $scope.newAccountModel.accUnqName = ''

  $scope.genUnq = (unqName) ->
    $timeout ( ->
      $scope.genearateUniqueName(unqName)
    ), 800

  $scope.create = {
    proformaTemplate : {}
  }

  $scope.getTemplates = () ->
    @success = (res) ->
      $scope.pTemplateList = []
      index = 0
      _.each res.body, (temp) ->
        if temp.type == "proforma"
          $scope.pTemplateList.push(temp)
      _.each $scope.pTemplateList, (temp, idx) ->
        if temp.isDefault
          index = idx
      $scope.create.proformaTemplate = $scope.pTemplateList[index]
      $scope.fetchTemplateData($scope.pTemplateList[index], 'create')
      $scope.transactions = []
      $scope.transactions.push(new pc.entryModel())
      $scope.taxes = []
      $scope.subtotal = 0
      pc.selectedAccountDetails = undefined
    @failure = (res) ->
      toastr.error(res.data.message)

    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    invoiceService.getTemplates(reqParam).then(@success, @failure)  

  # $timeout ( ->
  #   $scope.getTemplates()
  # ),1000

  # pc.parseData = (source, dest) ->
  #   _.each source.sections, (sec, sIdx) ->
  #     _.each dest.sections, (dec,dIdx) ->
  #       if sIdx == dIdx
  #         dec.styles.left = sec.leftOfBlock + '%'
  #         dec.styles.top = sec.topOfBlockt + '%'

  pc.checkEditableFields = (sections) ->
    $$this = @
    $$this.replaceEditables = (elements) ->
      _.each elements, (elem) ->
        if elem.type == 'Text' && elem.hasVar
          _.each pc.templateVariables, (temp) ->
            if elem.model == temp.key
              elem.variable = {}
              angular.copy(temp, elem.variable)
        else if elem.type == 'Element' && elem.children && elem.children.length > 0
          $$this.replaceEditables(elem.children)      

    templateVariables = []
    _.each sections, (sec,i) ->
      if sec.elements.length
        $$this.replaceEditables(sec.elements)
      _.each pc.sectionData, (data, j) ->
        if i==j
          sec.styles.left = data.leftOfBlock + '%'
          sec.styles.top = data.topOfBlock + '%'

  $scope.getDiscountAccounts = () ->
    $scope.discount.accounts = []
    _.each $rootScope.fltAccntListPaginated, (acc) ->
      isDiscount = false
      if acc.parentGroups.length > 0
        _.each acc.parentGroups, (pg) ->
          if pg.uniqueName == 'discount'
            isDiscount = true
      if isDiscount
        $scope.discount.accounts.push(acc)
    $scope.discount.accounts

  # $scope.getRevenueAccounts = () ->
  #   accounts = []
  #   _.each $rootScope.fltAccntListPaginated, (acc) ->
  #     isDiscount = false
  #     if acc.parentGroups.length > 0
  #       _.each acc.parentGroups, (pg) ->
  #         if pg.uniqueName == $rootScope.groupName.revenueFromOperations
  #           isDiscount = true
  #     if isDiscount
  #       accounts.push(acc)
  #   accounts

  $scope.revenueAccounts = []
  $scope.getRevenueAccounts = (query) ->
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      q: query
      page: 1
      count: 0
    }
    datatosend = {
      groupUniqueNames: [$rootScope.groupName.revenueFromOperations, 'discount']
    }
    return groupService.postFlatAccList(reqParam,datatosend).then(
      (res) ->
        $scope.revenueAccounts = res.body.results 
      (res) ->
        return []
    )

  $scope.fetchTemplateData = (template, operation) ->
    @success = (res) ->
      pc.templateVariables = res.body.templateVariables
      pc.htmlData = JSON.parse(res.body.htmlData)
      pc.sectionData = res.body.sections
      pc.checkEditableFields(pc.htmlData.sections)
      $scope.htmlData = pc.htmlData
      $scope.selectedTemplate = res.body.uniqueName
      $scope.discount = {} 
      #pc.getDiscountAccounts()
      #pc.parseData(res.body, $scope.htmlData)
    @failure = (res) ->
      toastr.error(res.data.message)
    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    reqParam.templateUniqueName = template.uniqueName
    reqParam.operation = operation
    settingsService.getTemplate(reqParam).then(@success, @failure)

  pc.buildFields = (sections) ->
    fields = []
    $$this = @
    $$this.getEditables = (elements) ->
      _.each elements, (elem) ->
        #if elem.type == 'Text' && elem.hasVar && elem.variable.isEditable
        if elem.type == 'Text' && elem.hasVar
          field = {}
          field.key = elem.variable.key
          field.value = elem.variable.value
          fields.push(field)
        else if elem.type == 'Element' && elem.children && elem.children.length > 0
          $$this.getEditables(elem.children)

    _.each sections, (sec) ->
      if sec.elements.length
        $$this.getEditables(sec.elements)
    fields

  # pc.processAccountDetails = () ->
  #   _.each $scope.transactions, (txn) ->
  #     if typeof(txn.accountUniqueName) == 'object'
  #       account = txn.accountUniqueName
  #       txn.accountName = account.name
  #       txn.accountUniqueName = account.uniqueName

  pc.removeBlankTrnsactions = (transactions) ->
    txns = []
    _.each transactions, (txn) ->
      if txn.accountUniqueName != ''
        txns.push(txn)
    _.each txns, (txn) ->
      if typeof(txn.accountUniqueName) == 'object'
        account = txn.accountUniqueName
        txn.accountName = account.name
        txn.accountUniqueName = account.uniqueName
    return txns

  $scope.createProforma = (action) ->
    $this = @
    $this.success = (res) ->
      if action == 'create'
        toastr.success("Proforma created successfully")
        $scope.fetchTemplateData($scope.create.proformaTemplate, 'create')
        $scope.transactions = []
        $scope.transactions.push(new pc.entryModel())
        $scope.subtotal = 0
        $scope.taxes = []
        $scope.discountTotal = 0
        $scope.taxTotal = 0
      else if action == 'update'
        toastr.success("Proforma updated successfully")
        $scope.transactions = res.body.entries
        $scope.editMode = !$scope.editMode
        $scope.getAllProforma()
    $this.failure = (res) ->
      toastr.error(res.data.message)
    reqBody = {}
    reqBody.templateUniqueName = $scope.selectedTemplate
    reqBody.fields = pc.buildFields($scope.htmlData.sections)
    #pc.processAccountDetails()
    txns = angular.copy($scope.transactions)
    reqBody.entries = pc.removeBlankTrnsactions(txns)
    _.each reqBody.entries,(entry) ->
      delete entry.appliedTaxes
    _.each reqBody.fields, (field) ->
      if field.key == "$accountName" && typeof(field.value) == "object"
        if field.value != null
          acUnq = {}
          acUnq.key = "$accountUniqueName"
          acUnq.value = field.value.uniqueName
          reqBody.fields.push(acUnq)
          field.value = field.value.name
        else
          toastr.error('Account Name cannot be blank')
      else if field.key == "$accountName" && typeof(field.value) == "string" && field.value != null && typeof(pc.selectedAccountDetails) == 'object'
        acUnq = {}
        acUnq.key = "$accountUniqueName"
        acUnq.value = pc.selectedAccountDetails.uniqueName
        reqBody.fields.push(acUnq)
    if $scope.discount.amount && $scope.discount.account
      reqBody.commonDiscount = {}
      reqBody.commonDiscount.amount = $scope.discount.amount
      if typeof $scope.discount.account == 'object' then (reqBody.commonDiscount.accountUniqueName = $scope.discount.account.uniqueName) else (reqBody.commonDiscount.accountUniqueName = $scope.discount.account)
    reqBody.updateAccountDetails = false
    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    if pc.selectedAccountDetails != undefined
      pc.checkAccountDetailsChange(reqBody)
    if !$scope.enableCreate
      modalService.openConfirmModal(
        title: 'Update Account Details',
        body: 'You have changed details for ' + pc.selectedAccountDetails.name + '. Do you want to update permanently?',
        ok: 'Yes',
        cancel: 'No').then(
          ()->
            reqBody.updateAccountDetails = true
            if action == 'create'
              invoiceService.createProforma(reqParam,reqBody).then($this.success,$this.failure)
            else if action == 'update'
              reqBody.proforma = $scope.currentProforma.uniqueName
              #reqBody.fields = null
              reqBody.fields = angular.extend(pc.templateVariables,reqBody.fields)
              reqBody.fields = _.uniq(reqBody.fields, (p)-> return p.key)
              invoiceService.updateProforma(reqParam,reqBody).then($this.success, $this.failure)

          () ->
            reqBody.updateAccountDetails = false
            if action == 'create'
              reqBody.fields = _.uniq(reqBody.fields, (p)-> return p.key)
              invoiceService.createProforma(reqParam,reqBody).then($this.success,$this.failure)
            else if action == 'update'
              reqBody.proforma = $scope.currentProforma.uniqueName
              #reqBody.fields = null
              reqBody.fields = angular.extend(pc.templateVariables,reqBody.fields)
              reqBody.fields = _.uniq(reqBody.fields, (p)-> return p.key)
              invoiceService.updateProforma(reqParam,reqBody).then($this.success, $this.failure)
        )
    else if action == 'create' && $scope.enableCreate
      reqBody.fields = angular.extend(pc.templateVariables,reqBody.fields)
      reqBody.fields = _.uniq(reqBody.fields, (p)-> return p.key)
      invoiceService.createProforma(reqParam,reqBody).then($this.success,$this.failure)
    else if action == 'update' && $scope.enableCreate
      reqBody.proforma = $scope.currentProforma.uniqueName
      #reqBody.fields = null
      reqBody.fields = angular.extend(pc.templateVariables,reqBody.fields)
      reqBody.fields = _.uniq(reqBody.fields, (p)-> return p.key)
      invoiceService.updateProforma(reqParam,reqBody).then($this.success, $this.failure)

  pc.entryModel = () ->
    @model = 
      {
        "description": "",
        "amount": 0,
        "accountUniqueName": "",
        "accountName":''
      }

  pc.getTaxList = () ->
    @success = (res) ->
      pc.taxList = res.body
    @failure = (res) ->
      toastr.error(res.data.message)

    companyServices.getTax($rootScope.selectedCompany.uniqueName).then(@success, @failure)
  
  pc.getTaxList()

  $scope.addParticular = (transactions) ->
    particular = new pc.entryModel()
    transactions.push(particular)

  $scope.removeParticular = (transactions, index, txn) ->
    transactions = transactions.splice(index, 1)
    $scope.calcSubtotal()
    return 0

  $scope.calcSubtotal = () ->
    $scope.subtotal = 0
    $scope.discountTotal = 0
    $scope.taxes = []
    prevTxn = null
    _.each $scope.transactions, (txn,idx) ->
      isDiscount = false
      if typeof(txn.accountUniqueName) == 'object'
        _.each txn.accountUniqueName.parentGroups, (pg) ->
          if pg.uniqueName == 'discount'
            isDiscount = true
      else if typeof(txn.accountUniqueName) == 'string'
        txn.appliedTaxes = pc.getTaxesFromAccountUniqueName(txn)
        isDiscount = pc.checkDiscountAccountFromParents(txn.accountUniqueName)
      if isDiscount
        $scope.discountTotal += Number(txn.amount)
        if $scope.subtotal > 0
          $scope.subtotal -= Math.abs(Number(txn.amount))
        if prevTxn
          #prevTxn.amount -= Number(txn.amount)
          pc.calcTax(prevTxn, prevTxn.amount, 'discount')
          prevTxn.amount -= Math.abs(Number(txn.amount))
          pc.calcTax(prevTxn, prevTxn.amount, 'txn')
      else
        $scope.subtotal += Number(txn.amount)
        prevTxn = angular.copy(txn)
        pc.calcTax(txn, prevTxn.amount, 'txn')

  pc.calcTax = (txn, amount, condition) ->
    if txn && txn.appliedTaxes && txn.appliedTaxes.length > 0
      _.each txn.appliedTaxes, (aTax) ->
        tax = _.findWhere(pc.taxList, {uniqueName:aTax})
        ctax = pc.calcTaxAmount(tax, txn,amount)
        if ctax
          existingTax = _.findWhere($scope.taxes, {name:ctax.name})
          if existingTax && condition == 'txn'
            existingTax.amount += Number(ctax.amount)
          else if existingTax && condition == 'discount'
            existingTax.amount -= Number(ctax.amount)
          else
            $scope.taxes.push(ctax)

  $scope.taxes = []
  pc.returnDateAsString = (date) ->
    date = date.split('-')
    date = date[1]+'-'+date[0]+'-'+date[2]
    return date

  pc.calcTaxAmount = (tax, txn, amount) ->
    proformaDate = _.findWhere(pc.templateVariables, {key:"$proformaDate"})
    proformaDate = pc.returnDateAsString(proformaDate.value)
    ctax = null
    _.each tax.taxDetail, (det) ->
      date = pc.returnDateAsString(det.date)
      pDate = Math.round(new Date(proformaDate).getTime()/1000)
      if pDate >= Math.round(new Date(date).getTime()/1000)
        ctax = {}
        ctax.amount = det.taxValue/100 * amount
        ctax.name = tax.name
    ctax
  
  pc.getTaxesFromAccountUniqueName = (txn) ->
    account = _.findWhere($rootScope.fltAccntListPaginated, {uniqueName:txn.accountUniqueName})
    return account.applicableTaxes

  pc.checkDiscountAccountFromParents = (accountUnq) ->
    isDiscout = false
    account = _.findWhere($rootScope.fltAccntListPaginated, {uniqueName:accountUnq})
    _.each account.parentGroups, (pg) ->
      if pg.uniqueName == 'discount'
        isDiscout = true
      else
        isDiscout = false
    isDiscout

  pc.isDiscountAccount = (account) ->
    isDiscount = false
    if account.parentGroups.length > 0
      _.each account.parentGroups, (pg) ->
        if pg.uniqueName == 'discount'
          isDiscount = true
    return isDiscount

  $scope.getTaxes = (account, txn, idx) ->
    if pc.isDiscountAccount(account) && idx == 0
      $scope.transactions = []
      $scope.transactions.push(new pc.entryModel())
      toastr.error('First account can not be discount account')
    else
      txn.appliedTaxes = account.applicableTaxes
      if txn.amount != null && txn.amount > 0
        $scope.calcSubtotal()

  $scope.addquickAccount = () ->
    $scope.newAccountModel.group = ''
    $scope.newAccountModel.account = ''
    $scope.newAccountModel.accUnqName = ''
    pc.getFlattenGrpWithAccList($rootScope.selectedCompany.uniqueName)
    pc.AccModalInstance = $uibModal.open(
      templateUrl: $rootScope.prefixThis+'/public/webapp/invoice2/addNewAccount.html'
      size: "sm"
      backdrop: 'static'
      scope: $scope
    )
    #modalInstance.result.then($scope.addNewAccountCloseSuccess, $scope.addNewAccountCloseFailure)

  $scope.addQuickAccountConfirm = () ->
    newAccount = {
      email:""
      mobileNo:""
      name:$scope.newAccountModel.account
      openingBalanceDate: $filter('date')($scope.today, "dd-MM-yyyy")
      uniqueName:$scope.newAccountModel.accUnqName
    }
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.newAccountModel.group.groupUniqueName
      acntUname: $scope.newAccountModel.accUnqName
    }
    if $scope.newAccountModel.group.groupUniqueName == '' || $scope.newAccountModel.group.groupUniqueName == undefined
      toastr.error('Please select a group.')
    else
      accountService.createAc(unqNamesObj, newAccount).then($scope.addQuickAccountConfirmSuccess, $scope.addQuickAccountConfirmFailure) 

  $scope.addQuickAccountConfirmSuccess = (res) ->
    toastr.success('Account created successfully')
    $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
    pc.AccModalInstance.close()

  $scope.addQuickAccountConfirmFailure = (res) ->
    toastr.error(res.data.message)

  $scope.sendMail = (addressList) ->
    @success = (res) ->
      toastr.success(res.body)
      $scope.showEmailBox = false

    @failure = (res) ->
      toastr.error(res.data.message)

    addresses = addressList.split(',')
    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    reqBody = {}
    reqBody.emailAddresses = addresses
    reqBody.proformaNumber = $scope.currentProforma.proformaNumber
    invoiceService.sendMail(reqParam,reqBody).then(@success, @failure)

  pc.b64toBlob = (b64Data, contentType, sliceSize) ->
    contentType = contentType or ''
    sliceSize = sliceSize or 512
    byteCharacters = atob(b64Data)
    byteArrays = []
    offset = 0
    while offset < byteCharacters.length
      slice = byteCharacters.slice(offset, offset + sliceSize)
      byteNumbers = new Array(slice.length)
      i = 0
      while i < slice.length
        byteNumbers[i] = slice.charCodeAt(i)
        i++
      byteArray = new Uint8Array(byteNumbers)
      byteArrays.push byteArray
      offset += sliceSize
    blob = new Blob(byteArrays, type: contentType)
    blob

  $scope.downloadProforma = (proforma) ->
    @success = (res) ->
      data = pc.b64toBlob(res.body, "application/pdf", 512)
      blobUrl = URL.createObjectURL(data)
      FileSaver.saveAs(data, proforma.proformaNumber+".pdf")
    @failure = (res) ->
      toastr.error(res.data.message)

    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    reqBody = {}
    reqBody.proformaNumber = proforma.proformaNumber
    invoiceService.downloadProforma(reqParam, reqBody).then(@success, @failure)

  $scope.setSelectedAccount = (account) ->
    @success = (res) ->
      pc.selectedAccountDetails = res.body
      pc.setSelectedAccountDetails(pc.selectedAccountDetails, account)
    @failure = (res) ->
      #console.log res
    reqParams = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: account.uniqueName
    }
    accountService.get(reqParams).then(@success, @failure)

  pc.setSelectedAccountDetails = (details, account) ->
    $$this = @
    $$this.getEditables = (elements) ->
      _.each elements, (elem) ->
        if elem.type == 'Text' && elem.hasVar && elem.variable.isEditable || elem.type == 'Text' && elem.hasVar && elem.variable.key == "$accountUniqueName"
          switch elem.variable.key
            when "$accountAddress"
              elem.variable.value = details.address 
            when "$accountCity"
              elem.variable.value = details.city 
            when "$accountEmail"
              elem.variable.value = details.email 
            when "$accountMobileNo"
              elem.variable.value = details.mobileNo 
            when "$accountState"
              elem.variable.value = details.state 
            when "$accountCountry"
              elem.variable.value = details.country 
            when "$accountPinCode"
              elem.variable.value = details.pincode 
            when "$accountAttentionTo"
              elem.variable.value = details.attentionTo
            when "$accountUniqueName"
              elem.variable.value = details.uniqueName

        else if elem.type == 'Element' && elem.children && elem.children.length > 0
          $$this.getEditables(elem.children)

    _.each $scope.htmlData.sections, (sec) ->
      if sec.elements.length
        $$this.getEditables(sec.elements)

  pc.checkAccountDetailsChange = (req) ->
    _.each req.fields, (field) ->
      switch field.key
        when "$accountName"
          if field.value != pc.selectedAccountDetails.name
            $scope.enableCreate = false
        when "$accountAddress"
          if field.value != pc.selectedAccountDetails.address
            $scope.enableCreate = false
        when "$accountCity"
          if field.value != pc.selectedAccountDetails.city
            $scope.enableCreate = false
        when "$accountEmail"
          if field.value != pc.selectedAccountDetails.email
            $scope.enableCreate = false
        when "$accountMobileNo"
          if field.value != pc.selectedAccountDetails.mobileNo
            $scope.enableCreate = false
        when "$accountState"
          if field.value != pc.selectedAccountDetails.state
            $scope.enableCreate = false
        when "$accountCountry"
          if field.value != pc.selectedAccountDetails.country
            $scope.enableCreate = false
        when "$accountPinCode"
          if field.value != pc.selectedAccountDetails.pincode
            $scope.enableCreate = false
        when "$accountAttentionTo"
          if field.value != pc.selectedAccountDetails.attentionTo
            $scope.enableCreate = false

  pc.createSundryDebtorsList = () ->
    _.each $rootScope.fltAccntListPaginated, (acc) ->
      isSd = false
      if acc.parentGroups.length > 0
        _.each acc.parentGroups, (pg) ->
          if pg.uniqueName == $rootScope.groupName.sundryDebtors
            isSd = true
      if isSd
        $scope.sundryDebtors.push(acc)

  $scope.updateProformaDate = (date) ->
    if date.length == 10
      _.each pc.templateVariables, (tp) ->
        if tp.key == "$proformaDate"
          tp.value = date
      $scope.calcSubtotal()

  $scope.taxTotal = 0
  $scope.$watch('taxes', (newVal, oldVal) ->
    if newVal != oldVal
      $scope.taxTotal = 0
      _.each newVal, (tax) ->
        $scope.taxTotal += tax.amount
  )
  $scope.$watch('subtotal', (newVal, oldVal) ->
    if newVal < 0
      toastr.warning("Subtotal cannot be negative, please adjust your discount amount.")
  )

  $rootScope.$on('account-list-updated', ()->
    pc.createSundryDebtorsList()
  )
giddh.webApp.controller 'proformaController', proformaController