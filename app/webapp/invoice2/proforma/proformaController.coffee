'use strict'

proformaController = ($scope, $rootScope, localStorageService,invoiceService,settingsService ,$timeout, toastr, $filter, $uibModal,accountService, groupService, $state) ->
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
  pc = @
  $scope.count = {}
  $scope.count.set = [10,15,30,35,40,45,50]
  $scope.count.val = $scope.count.set[0]
  $scope.editStatus = false

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
  $scope.balanceStatusOptions = ['paid','unpaid', 'hold', 'cancel']
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
      "dueDate": $filter('date')($scope.today, 'dd-MM-yyyy')
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
    }
    groupService.getFlattenGroupAccList(reqParam).then(pc.getFlattenGrpWithAccListSuccess, pc.getFlattenGrpWithAccListFailure)

  pc.getFlattenGrpWithAccListSuccess = (res) ->
    $scope.flatGrpList = res.body.results
    index = 0
    _.each $scope.flatGrpList, (grp, idx) ->
      if grp.groupUniqueName == "sundry_debtors"
        index = idx
    $scope.newAccountModel.group = $scope.flatGrpList[index]

  pc.getFlattenGrpWithAccListFailure = (res) ->
    toastr.error(res.data.message)

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

  pc.getTemplates = () ->
    @success = (res) ->
      _.each res.body, (temp) ->
        if temp.type == "proforma"
          $scope.pTemplateList.push(temp)

    @failure = (res) ->
      console.log res

    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    invoiceService.getTemplates(reqParam).then(@success, @failure)  

  $timeout ( ->
    pc.getTemplates()
  ),1000

  $scope.fetchTemplateData = (template) ->
    @success = (res) ->
      console.log res
      #$scope.templateHtml = res.body.html
    @failure = (res) ->
      console.log res
    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    reqParam.templateUniqueName = template.uniqueName
    settingsService.getTemplate(reqParam).then(@success, @failure)


  $scope.htmlData = {
    sections : [{
      styles:{
        'height':'200px'
        'width':'300px'
        'background':'#fff'
        'clear':'both'
      }
      elements:[
        {
          type: 'p'
          value: 'Date:'
          editable: false
          linebreak: false
          styles:{}
          elements:[
            {
              type: 'strong'
              value: '$invoiceDate'

              editable: true
              linebreak: false
              styles:{
                'font-weight':'bold'
              },
              elements: []
            }
          ]
        }
      ]
    }]
    variables: []
  }




giddh.webApp.controller 'proformaController', proformaController