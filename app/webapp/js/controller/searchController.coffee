"use strict"
searchController = ($scope, $rootScope, localStorageService, toastr, groupService, $filter, reportService) ->

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
  $scope.grp = {}
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
    obj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: data.group.uniqueName
      fromDate: $filter('date')(data.fromDate, "dd-MM-yyyy")
      toDate: $filter('date')(data.toDate, "dd-MM-yyyy")
    }
    groupService.getClosingBal(obj)
      .then(
        (res)->
          # $scope.waitForResponse = true
          console.log res.body
          $scope.searchResData = groupService.flattenSearchGroupsAndAccounts(res.body)
          _.extend($scope.searchResDataOrig, $scope.searchResData)
          $scope.srchDataFound = true
          console.log $scope.searchResData
        ,(error)->
          $scope.srchDataFound = false
          # $scope.waitForResponse = true
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
    # show reset data button
    $scope.inSrchmode = true

    # for each object filter data
    _.each(srchQData, (query)->
      console.log "query:", query, 
      # logic to search data
      $scope.searchResData = _.reject($scope.searchResData, (account)->
          switch query.queryDiffer
            when 'Greater'
              if query.queryType is 'closingBalance' or query.queryType is 'openingBalance'
                return not(account[query.queryType].amount > Number(query.amount) and account[query.queryType].type is query.balType)
              else
                return not(account[query.queryType] > Number(query.amount))
            when 'Less'
              if query.queryType is 'closingBalance' or query.queryType is 'openingBalance'
                return not(account[query.queryType].amount < Number(query.amount) and account[query.queryType].type is query.balType)
              else
                return not(account[query.queryType] < Number(query.amount))
            when 'Equals'
              if query.queryType is 'closingBalance' or query.queryType is 'openingBalance'
                return not(account[query.queryType].amount is Number(query.amount) and account[query.queryType].type is query.balType)
              else
                return not(account[query.queryType] is Number(query.amount))
            else
              toastr.warning("something went wrong reload page", "Warning")
        )
        # end reject
      )
      # end each



  $scope.resetData =()->
    $scope.srchDataSet = []
    $scope.srchDataSet = [new angular.srchDataSet()]
    $scope.inSrchmode = false
    _.extend($scope.searchResData, $scope.searchResDataOrig)



  # init some func when page load
  $scope.getGrpsforSearch()

#init angular app
giddh.webApp.controller 'searchController', searchController

# class method
class angular.srchDataSet
  constructor: ()->
    @queryType= ""
    @balType= "CREDIT"
    @queryDiffer= ""
    @amount = ""
