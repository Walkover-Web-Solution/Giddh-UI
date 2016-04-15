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
  $scope.searchResult = []
  # search query parameters
  $scope.queryType = [
    "Closing"
    "Opening"
    "Cr. total"
    "Dr. total"
  ]
  $scope.queryDiffer = [
    "Less"
    "Greater"
    "Equals"
  ]
  $scope.balType = [
    "CR"
    "DR"
  ]
  $scope.srchDataSet=[
    {
      queryType: ""
      balType: "CR"
      queryDiffer: ""
    }
  ]
    

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
    console.log "getClosingBalance: ", data
    obj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: data.group.uniqueName
      fromDate: $filter('date')(data.fromDate, "dd-MM-yyyy")
      toDate: $filter('date')(data.toDate, "dd-MM-yyyy")
    }
    groupService.getClosingBal(obj)
      .then(
        (res)->
          angular.copy(res.body, $scope.searchResult)
          # $scope.searchResult = res.body
          console.log "res:", res
        ,(error)->
          console.log "error:", error
      )

  # push new value
  $scope.addSearchRow =()->
    if $scope.srchDataSet.length < 2 
      num = $scope.srchDataSet.length-1
      abc = {
        queryType: ""
        balType: "CR"
        queryDiffer: ""
      }
      $scope.srchDataSet.push(abc)
      # $scope.secondRow_+num = true
    else
      console.log "cannot add more query"
      toastr.warning("Cannot add more parameters", "Warning")


  $scope.searchQuery = (data)->
    console.log "searchQuery:", data


  # init some func when page load
  $scope.getGrpsforSearch()




#init angular app
giddh.webApp.controller 'searchController', searchController
