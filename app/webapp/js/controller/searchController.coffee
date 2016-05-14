"use strict"
searchController = ($scope, $rootScope, localStorageService, toastr, groupService, $filter, reportService, $uibModal) ->

  $scope.today = new Date()
  $scope.dateOptions = {
    'year-format': "'yy'",
    'starting-day': 1,
    'showWeeks': false,
    'show-button-bar': false,
    'year-range': 1,
    'todayBtn': false,
    'container': "body"
    'minViewMode': 0
  }
  $scope.format = "dd-MM-yyyy"
  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
  $scope.noData = false
  $scope.searchLoader = false
  $scope.searchFormData = {
    fromDate: new Date(moment().subtract(1, 'month').utc())
    toDate: new Date()
  }
  $scope.searchResData = {}
  $scope.searchResDataOrig = {}
  # search query parameters
  $scope.queryType = [
    {name:"Closing", uniqueName: "closingBalance"}
    {name:"Opening", uniqueName: "openingBalance"}
    {name:"Cr. total", uniqueName: "creditTotal"}
    {name:"Dr. total", uniqueName: "debitTotal"}
  ]
  $scope.queryDiffer = [
    "Less"
    "Greater"
    "Equals"
  ]
  $scope.balType = [
    {name:"CR", uniqueName: "CREDIT"}
    {name:"DR", uniqueName: "DEBIT"}
  ]
  $scope.srchDataSet=[new angular.srchDataSet()]

  $scope.sortType     = 'name'
  $scope.sortReverse  = false  

  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true


  # get groups list
  $scope.getGrpsforSearch = ()->
    $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      groupService.getGroupsWithAccountsInDetail($rootScope.selectedCompany.uniqueName).then($scope.getGrpsforSearchSuccess, $scope.getGrpsforSearchFailure)

  $scope.getGrpsforSearchSuccess = (res) ->
    $scope.groupList = res.body
    $scope.flattenGroupList = groupService.flattenGroup($scope.groupList, [])
    $scope.searchLoader = true


  $scope.getGrpsforSearchFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  # get selected group closing balance
  $scope.getClosingBalance = (data) ->
    $scope.resetQuery()
    $scope.searchDtCntLdr = true
    obj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: data.group.uniqueName
      fromDate: $filter('date')(data.fromDate, "dd-MM-yyyy")
      toDate: $filter('date')(data.toDate, "dd-MM-yyyy")
    }
    groupService.getClosingBal(obj)
      .then(
        (res)->
          $scope.searchResData = groupService.flattenSearchGroupsAndAccounts(res.body)
          _.extend($scope.searchResDataOrig, $scope.searchResData)
          $scope.srchDataFound = true
          $scope.searchDtCntLdr = false
        ,(error)->
          $scope.srchDataFound = false
          $scope.searchDtCntLdr = false
      )

  # push new value
  $scope.addSearchRow =()->
    if $scope.srchDataSet.length < 4 
      $scope.srchDataSet.push(new angular.srchDataSet())
    else
      toastr.warning("Cannot add more parameters", "Warning")

  $scope.removeSearchRow = () ->
    $scope.srchDataSet.splice(-1,1)

  $scope.searchQuery = (srchQData)->
    _.extend($scope.searchResData, $scope.searchResDataOrig)
    # show reset data button
    $scope.inSrchmode = true
    # for each object filter data
    _.each(srchQData, (query)->
      $scope.searchResData = _.filter($scope.searchResData, (account)->
          amount = Number(query.amount)
          switch query.queryDiffer
            when 'Greater'
              if amount is 0
                return account[query.queryType] > amount
              else
                if query.queryType is 'openingBalance'
                  return account.openingBalance > amount and account.openBalType is query.balType
                if query.queryType is 'closingBalance'
                  return account.closingBalance > amount and account.closeBalType is query.balType
                else
                  return account[query.queryType] > amount
            when 'Less'
              if amount is 0
                return account[query.queryType] < amount
              else
                if query.queryType is 'openingBalance'
                  return account.openingBalance < amount and account.openBalType is query.balType
                if query.queryType is 'closingBalance'
                  return account.closingBalance < amount and account.closeBalType is query.balType
                else
                  return account[query.queryType] < amount
            when 'Equals'
              if amount is 0
                return account[query.queryType] is amount
              else
                if query.queryType is 'openingBalance'
                  return account.openingBalance is amount and account.openBalType is query.balType
                if query.queryType is 'closingBalance'
                  return account.closingBalance is amount and account.closeBalType is query.balType
                else
                  return account[query.queryType] is amount
            else
              toastr.warning("something went wrong reload page", "Warning")
        )
        # end reject
      )
      # end each

      

  $scope.resetQuery =()->
    $scope.srchDataSet = []
    $scope.srchDataSet = [new angular.srchDataSet()]
    $scope.inSrchmode = false
    _.extend($scope.searchResData, $scope.searchResDataOrig)


  # download CSV
  $scope.getCSVHeader=()->
    return  [
      "Name"
      "Opening Bal."
      "Opening Bal. Type"
      "Closing Bal."
      "Closing Bal. Type"
      "CR Total"
      "DR Total"
      "UniqueName"
    ]

  $scope.order = [
    "name"
    "closingBalance"
    "closeBalType"
    "openingBalance"
    "openBalType"
    "creditTotal"
    "debitTotal"
    "uniqueName"
  ]

  # init some func when page load
  $scope.getGrpsforSearch()

  #send as email/sms
  $scope.accountName = '%s_AccountName'
  $scope.msgBody = {
    header: {
      email: 'Send Email'
      sms: 'Send Sms'
      set: ''
    }
    btn : {
      email: 'Send Email'
      sms: 'Send Sms'
      set: ''
    }
    type: ''
    msg: ''
    subject: ''
  }

  $scope.dataVariables = [
    {
      name: 'Opening Balance'
      value: '%s_OB'
    }
    {
      name: 'Closing Balance'
      value: '%s_CB'
    }
    {
      name: 'Credit Total'
      value: '%s_CT'
    }
    {
      name: 'Debit Total'
      value: '%s_DT'
    }
    {
      name: 'From Date'
      value: '%s_FD'
    }
    {
      name: 'To Date'
      value: '%s_TD'
    }
    {
      name: 'Magic Link'
      value: '%s_magicLink'
    }
    {
      name: 'Account Name'
      value: '%s_accountName'
    }
  ]

  $scope.openEmailDialog = () ->
    $scope.msgBody.subject = ''
    $scope.msgBody.msg = ''
    $scope.msgBody.type = 'Email'
    $scope.msgBody.btn.set = $scope.msgBody.btn.email
    $scope.msgBody.header.set = $scope.msgBody.header.email
    modalInstance = $uibModal.open(
        templateUrl: '/public/webapp/views/bulkMail.html' 
        size: "md"
        backdrop: 'static'
        scope: $scope
      )

  $scope.openSmsDialog = () ->
    $scope.msgBody.msg = ''
    $scope.msgBody.type = 'sms'
    $scope.msgBody.btn.set = $scope.msgBody.btn.sms
    $scope.msgBody.header.set = $scope.msgBody.header.sms
    modalInstance = $uibModal.open(
        templateUrl: '/public/webapp/views/bulkMail.html' 
        size: "md"
        backdrop: 'static'
        scope: $scope
      )

  $scope.addValueToMsg = (val) ->
    $scope.msgBody.msg += " " + val.value.toString() + " "
    

#init angular app
giddh.webApp.controller 'searchController', searchController

# class method
class angular.srchDataSet
  constructor: ()->
    @queryType= ""
    @balType= "CREDIT"
    @queryDiffer= ""
    @amount = ""
