# 'use strict'

# describe 'reportsController', ->
#   beforeEach module('giddhWebApp')

#   beforeEach inject ($rootScope, $controller, toastr, groupService, $q, localStorageService, reportService) ->
#     @scope = $rootScope.$new()
#     @rootScope = $rootScope
#     @toastr = toastr
#     @reportService = reportService
#     @groupService = groupService
#     @q = $q
#     @localStorageService = localStorageService
#     @reportsController = $controller('reportsController',
#       {
#         $scope: @scope,
#         groupService: @groupService,
#         reportService: @reportService
#       })

#   describe 'local variables', ->
#     beforeEach inject ($rootScope, $controller,localStorageService) ->
#       @scope = $rootScope.$new()
#       @rootScope = $rootScope
#       @localStorageService = localStorageService
#       @reportsController = $controller('reportsController',
#         {
#           $scope: @scope,
#           $rootScope: @rootScope
#         })

#     it 'should check scope variables set by default', ->
#       expect(@scope.today).toBeDefined()
#       expect(@scope.fromDate).toBeDefined()
#       expect(@scope.toDate).toBeDefined()
#       expect(@scope.fromPLDate).toBeDefined()
#       expect(@scope.toPLDate).toBeDefined()
#       expect(@scope.fromNWDate).toBeDefined()
#       expect(@scope.toNWDate).toBeDefined()
#       expect(@scope.fromDatePickerIsOpen).toBeFalsy()
#       expect(@scope.toDatePickerIsOpen).toBeFalsy()
#       expect(@scope.GroupsAndAccounts).toEqual([])
#       expect(@scope.selected).toBeDefined()
#       expect(@scope.dateOptions).toBeDefined()
#       expect(@scope.format).toBeDefined()
#       expect(@scope.chartDataAvailable).toBeTruthy()
#       expect(@scope.showFilters).toBeFalsy()
#       expect(@scope.series).toBeDefined()
#       expect(@scope.chartData).toBeDefined()
#       expect(@scope.labels).toBeDefined()
#       expect(@scope.plSeries).toBeDefined()
#       expect(@scope.plChartData).toBeDefined()
#       expect(@scope.plLabels).toBeDefined()
#       expect(@scope.nwSeries).toBeDefined()
#       expect(@scope.nwChartData).toBeDefined()
#       expect(@scope.nwLabels).toBeDefined()
#       expect(@scope.chartOptions).toBeDefined()
#       expect(@scope.chartTypes).toBeDefined()
#       expect(@scope.chartType).toBeDefined()
#       expect(@scope.listBeforeLimit).toBeDefined()
#       expect(@scope.noData).toBeFalsy()
#       expect(@scope.intervalVals).toBeDefined()
#       expect(@scope.chartParams).toBeDefined()
#       expect(@scope.showHistoryFilters).toBeTruthy()
#       expect(@scope.showPLGraphFilters).toBeFalsy()
#       expect(@scope.showNWfilters).toBeFalsy()



#   describe '#getAccountsGroupsList', ->
#     it 'should show a toastr informing user to select company first when no company selected', ->
#       spyOn(@toastr, 'error')
#       spyOn(@localStorageService, 'get').andReturn({})
#       @scope.getAccountsGroupsList()
#       expect(@toastr.error).toHaveBeenCalledWith('Select company first.', 'Error')
#       expect(@scope.showAccountList).toBeFalsy()

#     it 'should call groups from route after getting company unique name', ->
#       spyOn(@localStorageService, 'get').andReturn({"data": "Got it", "uniqueName": "soniravi"})
#       deferred = @q.defer()
#       spyOn(@groupService, 'getGroupsWithAccountsInDetail').andReturn(deferred.promise)
#       @scope.getAccountsGroupsList()
#       expect(@groupService.getGroupsWithAccountsInDetail).toHaveBeenCalledWith("soniravi")
#       expect(@scope.showAccountList).toBeFalsy()

#   describe '#getGroupsSuccess', ->
#     it 'should set group list', ->
#       @rootScope.makeAccountFlatten = (data) ->

#       result = ["body": [{
#         "name": "group1",
#         "uniqueName": "g1",
#         "accounts": [{"name": "a1"}]
#       },
#         {"name": "group2", "uniqueName": "g2", "accounts": []},
#         {"name": "group3", "uniqueName": "g3", "accounts": []}]]
#       spyOn(@groupService, 'flattenGroup').andReturn({"name": "group2", "uniqueName": "g2", "groups": []})
#       spyOn(@groupService, 'flattenGroupsWithAccounts').andReturn([{
#         "groupName": "group1",
#         "groupUniqueName": "g1",
#         "accountDetails": [{"name": "a1"}]
#       }])
#       spyOn(@rootScope, 'makeAccountFlatten')
#       @scope.getGroupsSuccess(result)
#       expect(@groupService.flattenGroup).toHaveBeenCalledWith(result.body, [])
#       expect(@groupService.flattenGroupsWithAccounts).toHaveBeenCalledWith(@scope.flattenGroupList)
#       expect(@scope.groupList).toBe(result.body)
#       expect(@scope.flattenGroupList).toEqual({"name": "group2", "uniqueName": "g2", "groups": []})
#       expect(@scope.flatAccntWGroupsList).toEqual([{
#         "groupName": "group1",
#         "groupUniqueName": "g1",
#         "accountDetails": [{"name": "a1"}]
#       }])

#   describe '#getGroupsFailure', ->
#     it 'should show a toastr for error', ->
#       res =
#         data:
#           status: "Error"
#           message: "Unable to get group details."
#       spyOn(@toastr, "error")
#       @scope.getGroupsFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#sortGroupsAndAccounts' , ->
#     it 'should return', ->
#       dataArray = [
#         {
#           accountDetails :[]
#           beforeFilter: []
#           groupName: 'group name'
#           groupSynonyms: null
#           groupUniqueName: 'group unique name'
#           open : false
#         },
#         {
#           accountDetails :[]
#           beforeFilter: []
#           groupName: 'group name'
#           groupSynonyms: null
#           groupUniqueName: 'group unique name'
#           open : false
#         }
#       ]
#       @scope.sortGroupsAndAccounts(dataArray)
#       groups = [
#         {
#           name: 'group name'
#           uniqueName: 'group unique name'
#         },
#         {
#           name: 'group name'
#           uniqueName: 'group unique name'
#         }
#       ]
#       accounts = []
#       expect(@scope.groups).toEqual(groups)
#       expect(@scope.accounts).toEqual(accounts)

#   describe '#createArrayWithUniqueName' , ->
#     it 'should take array and return final array with uniqueNames', ->
#       dataArray = [
#         {
#           name: 'group name'
#           uniqueName: 'group unique name'
#         },
#         {
#           name: 'group name'
#           uniqueName: 'group unique name'
#         }
#       ]
#       finalArray = [
#         'group unique name'
#         'group unique name'
#       ]
#       final = @scope.createArrayWithUniqueName(dataArray)
#       expect(final).toEqual(finalArray)

#   describe '#formatGraphData', ->
#     it 'should set chartDataAvailable and showFilters as true' ,->
#       graphdata = [
#         groups: [
#           {
#             category :''
#             intervalBalances: []
#             name: ''
#             uniqueName: ''
#           }
#         ]
#         accounts: [
#           {
#             category :''
#             intervalBalances: []
#             name: ''
#             uniqueName: ''
#           }
#         ]
#       ]
#       @spyOn(@scope, 'formatGraphData')
#       @scope.formatGraphData(graphdata)
#       expect(@scope.chartDataAvailable).toBeTruthy()
#       # expect(@scope.showFilters).toBeTruthy()

#   describe '#filterGraph', ->
#     it 'should take argument and filter graphdata based on argument', ->
#       arg = {
#         type: 'cb'
#         val: false
#       }
#       @spyOn(@scope, 'filterGraph')
#       @scope.filterGraph(arg)
#       expect(@scope.filterGraph).toHaveBeenCalledWith(arg)

#   describe '#getGraphData' , ->
#     it 'should call method historicData of reportService with objects reqParam and graphParam', ->
#       reqParam = {
#         'cUname': ''
#         'fromDate': ''
#         'toDate': ''
#         'interval': ''
#       }
#       graphParam = {
#         'groups' : ''
#         'accounts' : ''
#       }
#       deferred = @q.defer()
#       spyOn(@reportService, 'historicData').andReturn(deferred.promise)
#       @scope.getGraphData(reqParam, graphParam)
#       expect(@reportService.historicData).toHaveBeenCalledWith(reqParam, graphParam)

#   describe '#getGraphDataSuccess', ->
#     it 'should set graphdata to equal body of response', ->
#       res = {
#         body : {
#           accounts: [
#             {
#               category :''
#               intervalBalances: []
#               name: ''
#               uniqueName: ''
#             }
#           ]
#           groups: [
#             {
#               category :''
#               intervalBalances: []
#               name: ''
#               uniqueName: ''
#             }
#           ]
#         }
#         status: 'Success'
#       }  
#       @scope.getGraphDataSuccess(res)
#       expect(@scope.graphData).toEqual(res.body)
#       @scope.graphData = res.body
#       @spyOn(@scope, 'formatGraphData')
#       @scope.formatGraphData(@scope.graphData)
#       expect(@scope.formatGraphData).toHaveBeenCalledWith(@scope.graphData)

#   describe '#getGraphDataFailure' , ->
#     it 'should set chartDataAvailable equal to true', ->
#       res = {
#         data:{
#           message: ''
#         }
#       }
#       @scope.getGraphDataFailure(res)
#       expect(@scope.chartDataAvailable).toBeTruthy()

#     it 'should show a toastr for error', ->
#       res = {
#         data: {
#           "message": "Unable to get group details."
#           "status": "Error"
#         }
#       }
#       spyOn(@toastr, 'error')
#       @scope.getGraphDataFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#generateGraph' , ->
#     it 'should set chartDataAvailable and showFilters to false' ,->
#       reqParam = {
#         'cUname': ''
#         'fromDate': ''
#         'toDate': ''
#         'interval': ''
#       }
#       graphParam = {
#         'groups' : ''
#         'accounts' : ''
#       }
#       @scope.selected.groups.length = 1
#       @scope.selected.accounts.length = 1

#       @spyOn(@scope,'generateGraph')
#       @scope.generateGraph()
#       expect(@scope.showFilters).toBeFalsy()

#   describe '#showPLFilter', ->
#     it 'should set variable values', ->
#       @scope.showPLFilter()
#       expect(@scope.showPLGraphFilters).toBeTruthy()
#       expect(@scope.showNWfilters).toBeFalsy()
#       expect(@scope.showHistoryFilters).toBeFalsy()

#   describe '#showHistoryFilter', ->
#     it 'should set variable values', ->
#       @scope.showHistoryFilter()
#       expect(@scope.showPLGraphFilters).toBeFalsy()
#       expect(@scope.showNWfilters).toBeFalsy()
#       expect(@scope.showHistoryFilters).toBeTruthy()

#   describe '#showNWfilter', ->
#     it 'should set variable values', ->
#       @scope.showNWfilter()
#       expect(@scope.showPLGraphFilters).toBeFalsy()
#       expect(@scope.showNWfilters).toBeTruthy()
#       expect(@scope.showHistoryFilters).toBeFalsy()

#   describe '#getPLgraphData', ->
#     it 'should call method plGraphData of reportService with reqParam', ->
#       reqParam = {
#         'cUname': ''
#         'fromDate': ''
#         'toDate': ''
#         'interval': ''
#       }
#       deferred = @q.defer()
#       spyOn(@reportService, 'plGraphData').andReturn(deferred.promise)
#       @scope.getPLgraphData(reqParam)
#       expect(@reportService.plGraphData).toHaveBeenCalledWith(reqParam)

#   describe '#getPLgraphDataSuccess', ->
#     it 'should set plGraphData equal to body of response', ->
#       res = {
#         body: {

#         }
#       }
#       @scope.getPLgraphDataSuccess(res)
#       expect(@scope.plGraphData).toEqual(res.body)

#     it 'should call formatPLgraphData with plGraphData', ->
#       res = {
#         body: {

#         }
#       }
#       @scope.plGraphData = res.body
#       @spyOn(@scope, 'formatPLgraphData')
#       @scope.formatPLgraphData(@scope.plGraphData)
#       expect(@scope.formatPLgraphData).toHaveBeenCalledWith(@scope.plGraphData)

#   describe '#getPLgraphDataFailure', ->
#     it 'should set chartDataAvailable to true', ->
#       res = {
#         data: ''
#         message: ''
#       }
#       @scope.getPLgraphDataFailure(res)
#       expect(@scope.chartDataAvailable).toBeTruthy()

#     it 'should show error with toastr', ->
#       res =
#         data:
#           status: "Error"
#           message: "Unable to get group details."
#       spyOn(@toastr, "error")
#       @scope.getPLgraphDataFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message)      

#   describe '#generatePLgraph', ->
#     it 'should call getPLgraphData with reqParam', ->
#       reqParam = {
#         'cUname': ''
#         'fromDate': ''
#         'toDate': ''
#         'interval': ''
#       }
#       @spyOn(@scope, 'getPLgraphData')
#       @scope.getPLgraphData(reqParam)
#       expect(@scope.getPLgraphData).toHaveBeenCalledWith(reqParam)
#       #expect(@scope.getPLgraphData).toBeFalsy()
  
#   describe '#formatPLgraphData', ->
#     it 'should be called with plData and set chartDataAvailable to true', ->
#       plData = {
#         periodBalances: []
#       }
#       @spyOn(@scope, 'formatPLgraphData')
#       @scope.formatPLgraphData(plData)
#       expect(@scope.formatPLgraphData).toHaveBeenCalledWith(plData)
#       expect(@scope.chartDataAvailable).toBeTruthy()

#   describe '#getNWgraphData', ->
#     it 'should call method nwGraphData of reportService with reqParam', ->
#       reqParam = {
#         'cUname': ''
#         'fromDate': ''
#         'toDate': ''
#         'interval': ''
#       }
#       deferred = @q.defer()
#       spyOn(@reportService, 'nwGraphData').andReturn(deferred.promise)
#       @scope.getNWgraphData(reqParam)
#       expect(@reportService.nwGraphData).toHaveBeenCalledWith(reqParam)

#   describe '#getNWgraphDataSuccess', ->
#     it  'should set nwGraphData equalt to body of response', ->
#       res = {
#         body: {

#         }
#       }
#       @scope.getNWgraphDataSuccess(res)
#       expect(@scope.nwGraphData).toEqual(res.body)

#     it 'should call formatNWgraphData with nwGraphData', ->
#       res = {
#         body: {

#         }
#       }
#       @scope.nwGraphData = res.body
#       @spyOn(@scope, 'formatNWgraphData')
#       @scope.formatNWgraphData(@scope.nwGraphData)
#       expect(@scope.formatNWgraphData).toHaveBeenCalledWith(@scope.nwGraphData)

#   describe 'getNWgraphDataFailure', ->
#     it 'should set chartDataAvailable to true', ->
#       res = {
#         data: ''
#         message: ''
#       }
#       @scope.getNWgraphDataFailure(res)
#       expect(@scope.chartDataAvailable).toBeTruthy()

#     it 'should show error with toastr', ->
#       res =
#         data:
#           status: "Error"
#           message: "Unable to get group details."
#       spyOn(@toastr, "error")
#       @scope.getNWgraphDataFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message)     

#   describe 'generateNWgraph' ,->
#     it 'should call getNWgraphData with reqParam', ->
#       reqParam = {
#         'cUname': ''
#         'fromDate': ''
#         'toDate': ''
#         'interval': ''
#       }
#       @spyOn(@scope, 'generateNWgraph')
#       @scope.generateNWgraph(reqParam)
#       expect(@scope.generateNWgraph).toHaveBeenCalledWith(reqParam)

#   describe 'formatNWgraphData', ->
#    it 'should be called with nwData and set chartDataAvailable to true', ->
#       nwData = {
#         periodBalances: []
#       }
#       @spyOn(@scope, 'formatNWgraphData')
#       @scope.formatNWgraphData(nwData)
#       expect(@scope.formatNWgraphData).toHaveBeenCalledWith(nwData)
#       expect(@scope.chartDataAvailable).toBeTruthy()