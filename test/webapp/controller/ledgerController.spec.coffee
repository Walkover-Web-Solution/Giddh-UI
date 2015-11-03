'use strict'

describe 'ledgerController', ->
  beforeEach module('giddhWebApp')

  describe 'local variables', ->
    beforeEach inject ($rootScope, $controller, localStorageService) ->
      @scope = $rootScope.$new()
      @rootScope = $rootScope
      @localStorageService = localStorageService
      spyOn(@localStorageService, 'keys').andReturn(["_selectedCompany"])
      spyOn(@localStorageService, 'get').andReturn({name: "walkover"})

      @ledgerController = $controller('ledgerController',
        {$scope: @scope, $rootScope: @rootScope, localStorageService: @localStorageService})

    it 'should check scope variables set by default', ->
      expect(@scope.selectedCompany).toEqual({name: "walkover"})
      expect(@scope.accntTitle).toBeUndefined()
      expect(@scope.showLedgerBox).toBeFalsy()
      expect(@scope.selectedAccountUname).toBeUndefined()
      expect(@scope.selectedGroupUname).toBeUndefined()
      expect(@scope.selectedLedgerAccount).toBeUndefined()
      expect(@scope.creditTotal).toBeUndefined()
      expect(@scope.debitTotal).toBeUndefined()
      expect(@scope.creditBalanceAmount).toBeUndefined()
      expect(@scope.debitBalanceAmount).toBeUndefined()
      expect(@scope.quantity).toBe(50)
      expect(@scope.today).toBeDefined()
      expect(@scope.fromDate.date).toBeDefined()
      expect(@scope.toDate.date).toBeDefined()
      expect(@scope.fromDatePickerIsOpen).toBeFalsy()
      expect(@scope.fromDatePickerIsOpen).toBeFalsy
      expect(@scope.dateOptions).toEqual({ 'year-format': "'yy'", 'starting-day': 1, 'showWeeks': false, 'show-button-bar': false, 'year-range': 1, 'todayBtn': false})
      expect(@scope.format).toBe("dd-MM-yyyy")
      expect(@scope.ftypeAdd).toBe("add")
      expect(@scope.ftypeUpdate).toBe("update")
      expect(@localStorageService.keys).toHaveBeenCalled()
      expect(@localStorageService.get).toHaveBeenCalledWith("_selectedCompany")

  describe 'controller methods', ->
    beforeEach inject ($rootScope, $controller, localStorageService, toastr, ledgerService, $q, modalService, DAServices) ->
      @scope = $rootScope.$new()
      @rootScope = $rootScope
      @localStorageService = localStorageService
      @ledgerService = ledgerService
      @DAServices = DAServices
      @toastr = toastr
      @modalService = modalService
      @q = $q
      @ledgerController = $controller('ledgerController',
        {
          $scope: @scope,
          $rootScope: @rootScope,
          localStorageService: @localStorageService
          ledgerService: @ledgerService
          DAServices: @DAServices
          modalService: @modalService
        })

    describe '#reloadLedger', ->
      it 'should not call load ledger', ->
        @scope.selectedLedgerGroup = undefined
        spyOn(@scope, 'loadLedger')
        @scope.reloadLedger()
        expect(@scope.loadLedger).not.toHaveBeenCalled()
        
      it 'should call load ledger by date filter', ->
        @scope.selectedLedgerGroup = {}
        @scope.selectedLedgerAccount = {}
        spyOn(@scope, 'loadLedger')
        @scope.reloadLedger()
        expect(@scope.loadLedger).toHaveBeenCalledWith(@scope.selectedLedgerGroup, @scope.selectedLedgerAccount)

    describe '#loadLedger', ->
      it 'should show alert if date format is wrong', ->
        @scope.toDate = {
          date: null
        }
        @scope.fromDate = {
          date: null
        }
        data = {}
        acData = {}
        spyOn(@toastr, 'error')
        @scope.loadLedger(data, acData)
        expect(@toastr.error).toHaveBeenCalledWith('Date should be in proper format', 'Error')

      it 'should call service and set some variables value', ->
        @scope.toDate = {
          date: "14-11-2015"
        }
        @scope.fromDate = {
          date: "14-11-2015"
        }
        deferred = @q.defer()
        spyOn(@ledgerService, "getLedger").andReturn(deferred.promise)
        @scope.selectedCompany = {
          uniqueName: "giddh"
        }
        @scope.selectedGroupUname = "somename"
        @scope.selectedAccountUname = "somename"
        data = {groupUniqueName: "somename"}
        acData = {name: "name", uniqueName: "somename"}

        udata = {
          compUname: @scope.selectedCompany.uniqueName
          selGrpUname: @scope.selectedGroupUname
          acntUname: @scope.selectedAccountUname
          fromDate: @scope.toDate.date
          toDate: @scope.fromDate.date
        }
        @scope.loadLedger(data, acData)
        expect(@scope.showLedgerBox).toBeFalsy()
        expect(@scope.selectedLedgerAccount).toBe(acData)
        expect(@scope.selectedLedgerGroup).toBe(data)
        expect(@scope.accntTitle).toEqual(acData.name)
        expect(@scope.selectedAccountUname).toEqual(acData.uniqueName)
        expect(@scope.selectedGroupUname).toEqual(data.groupUniqueName)
        
        expect(@ledgerService.getLedger).toHaveBeenCalledWith(udata)

    describe '#loadLedgerSuccess', ->
      it 'should call calculate ledger function with data and set a variable true and push value in ledgerdata', ->
        spyOn(@scope, "calculateLedger")
        response = {
          status: "success"
          body: {
            key: "value"
            ledgers: []
          }
        }
        @scope.loadLedgerSuccess(response)
        expect(@scope.ledgerData).toBe(response.body)
        expect(@scope.showLedgerBox).toBeTruthy()
        expect(@scope.calculateLedger).toHaveBeenCalledWith(@scope.ledgerData, "server")

    describe '#addNewAccount', ->
      it 'should check if selectedCompany is empty then it will show alert', ->
        @scope.selectedCompany = {}
        spyOn(@toastr, "error")
        @scope.addNewAccount()
        expect(@toastr.error).toHaveBeenCalledWith("Select company first.", "Error")
      it 'should call modalService and not show error', ->
        @scope.selectedCompany = {
          uniqueName: "giddh"
        }
        spyOn(@modalService, "openManageGroupsModal")
        @scope.addNewAccount()
        expect(@modalService.openManageGroupsModal).toHaveBeenCalled()
    
    describe '#deleteEntry', ->
      it 'should call ledgerService deleteEntry method with object', ->
        deferred = @q.defer()
        spyOn(@ledgerService, "deleteEntry").andReturn(deferred.promise)
        @scope.selectedCompany = {
          uniqueName: "giddh"
        }
        @scope.selectedGroupUname = "somename"
        @scope.selectedAccountUname = "somename"
        item = {name: "name", uniqueName: "somename"}

        udata = {
          compUname: @scope.selectedCompany.uniqueName
          selGrpUname: @scope.selectedGroupUname
          acntUname: @scope.selectedAccountUname
          entUname: item.uniqueName
        }
        @scope.deleteEntry(item)
        expect(@ledgerService.deleteEntry).toHaveBeenCalledWith(udata)

    describe '#deleteEntrySuccess', ->
      it 'should check ledger array length and remove data from its position by index and show success message through toastr and call calculateLedger function with two para', ->
        response = {
          status: "success"
          message: "Entry deleted successfully"
        }
        item = {name: "name", uniqueName: "somename"}
        @scope.ledgerData = {
          key: "value"
          ledgers: [
            {uniqueName: "somename"}
            {uniqueName: "somename1"}
            {uniqueName: "somename2"}
          ]
        }
        spyOn(@toastr, "success")
        spyOn(@scope, "calculateLedger")
        spyOn(@scope, "removeLedgerDialog")
        @scope.deleteEntrySuccess(item, response)
        expect(@toastr.success).toHaveBeenCalledWith(response.message, response.status)
        expect(@scope.removeLedgerDialog).toHaveBeenCalled()
        expect(@scope.calculateLedger).toHaveBeenCalledWith(@scope.ledgerData, "deleted")
      
    describe '#addNewEtry', ->
      it 'should add a entry to ledger, copy data to a variable, call ledgerService createEntry method', ->
        @scope.selectedCompany = {
          uniqueName: "giddh"
        }
        @scope.selectedGroupUname = "groupname"
        @scope.selectedAccountUname = "accountname"
        udata = {
          compUname: @scope.selectedCompany.uniqueName
          selGrpUname: @scope.selectedGroupUname
          acntUname: @scope.selectedAccountUname
        }
        deferred = @q.defer()
        spyOn(@ledgerService, "createEntry").andReturn(deferred.promise)
        data = {
          voucher: {shortcode: "12345"}
          transactions: [
            {
              particular: "particular"
            }
          ]
        }
        edata = {}
        
        @scope.addNewEntry(data)
        expect(@ledgerService.createEntry).toHaveBeenCalledWith(udata, data)

    describe '#addEntrySuccess', ->
      it 'should show success message, call removeLedgerDialog function, and push data to main object and push data according to type in ledger Object, and call calculateLedger function', ->
        response = {
          status: "Success"
          message: "Entry created successfully"
          body: {
            transactions: [
              {type: "DEBIT"}
            ]
          }
        }
        @scope.ledgerData = {
          key: "value"
          ledgers: [
            {
              uniqueName: "somename", 
              transactions: [
                {type: "DEBIT"}
              ]
            }
          ]
        }
        tType = response.body.transactions[0].type
        count = 0
        rpl = 0
        spyOn(@scope, "removeLedgerDialog")
        spyOn(@scope, "calculateLedger")
        spyOn(@toastr, "success")
        @scope.addEntrySuccess(response)
        expect(@toastr.success).toHaveBeenCalledWith(response.message, response.status)
        expect(@scope.removeLedgerDialog).toHaveBeenCalled()
        expect(tType).toBe(response.body.transactions[0].type)
        expect(count).toBe (0)
        expect(rpl).toBe (0)
        expect(@scope.ledgerData.ledgers[rpl]).toBe(response.body)
        
      
        
      


          
        











