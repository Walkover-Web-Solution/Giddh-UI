'use strict'

describe 'reportsController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($rootScope, $controller, toastr, groupService, $q, localStorageService, reportService) ->
    @scope = $rootScope.$new()
    @rootScope = $rootScope
    @toastr = toastr
    @reportService = reportService
    @groupService = groupService
    @q = $q
    @localStorageService = localStorageService
    @reportsController = $controller('reportsController',
      {
        $scope: @scope,
        groupService: @groupService,
        reportService: @reportService
      })

  describe '#getAccountsGroupsList', ->
    it 'should show a toastr informing user to select company first when no company selected', ->
      spyOn(@toastr, 'error')
      spyOn(@localStorageService, 'get').andReturn({})
      @scope.getAccountsGroupsList()
      expect(@toastr.error).toHaveBeenCalledWith('Select company first.', 'Error')
      expect(@scope.showAccountList).toBeFalsy()

    it 'should call groups from route after getting company unique name', ->
      spyOn(@localStorageService, 'get').andReturn({"data": "Got it", "uniqueName": "soniravi"})
      deferred = @q.defer()
      spyOn(@groupService, 'getGroupsWithAccountsInDetail').andReturn(deferred.promise)
      @scope.getAccountsGroupsList()
      expect(@groupService.getGroupsWithAccountsInDetail).toHaveBeenCalledWith("soniravi")
      expect(@scope.showAccountList).toBeFalsy()

  describe '#getGroupsFailure', ->
    it 'should set group list', ->
      @rootScope.makeAccountFlatten = (data) ->

      result = ["body": [{
        "name": "group1",
        "uniqueName": "g1",
        "accounts": [{"name": "a1"}]
      },
        {"name": "group2", "uniqueName": "g2", "accounts": []},
        {"name": "group3", "uniqueName": "g3", "accounts": []}]]
      spyOn(@groupService, 'flattenGroup').andReturn({"name": "group2", "uniqueName": "g2", "groups": []})
      spyOn(@groupService, 'flattenGroupsWithAccounts').andReturn([{
        "groupName": "group1",
        "groupUniqueName": "g1",
        "accountDetails": [{"name": "a1"}]
      }])
      spyOn(@rootScope, 'makeAccountFlatten')
      @scope.getGroupsSuccess(result)
      expect(@groupService.flattenGroup).toHaveBeenCalledWith(result.body, [])
      expect(@groupService.flattenGroupsWithAccounts).toHaveBeenCalledWith(@scope.flattenGroupList)
      expect(@scope.groupList).toBe(result.body)
      expect(@scope.flattenGroupList).toEqual({"name": "group2", "uniqueName": "g2", "groups": []})
      expect(@scope.flatAccntWGroupsList).toEqual([{
        "groupName": "group1",
        "groupUniqueName": "g1",
        "accountDetails": [{"name": "a1"}]
      }])

  describe '#getGroupListFailure', ->
    it 'should show a toastr for error', ->
      res =
        data:
          status: "Error"
          message: "Unable to get group details."
      spyOn(@toastr, "error")
      @scope.getGroupsFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#generateGraph', ->
    xit 'should call getGraphData with reqParam and graphParam', ->
      @scope.selected.groups.length = 1
      @scope.selected.accounts.length = 1
      expect(@scope.chartDataAvailable).toBeTruthy()
      @rootScope.selectedCompany = {
        uniqueName: 'companyUniqueName'
       } 

      reqParam = {
        'cUname': @rootScope.selectedCompany.uniqueName
        'fromDate': '15/01/2015'
        'toDate': '12/12/2015'
        'interval': 1
      }
      graphParam = {
        'groups' : ['group1', 'group2']
        'accounts' : ['account1', 'account2']
      }

      spyOn(@reportService,"historicData")
      @scope.generateGraph()
      expect(@reportService.historicData).toHaveBeenCalledWith(reqParam, graphParam)
