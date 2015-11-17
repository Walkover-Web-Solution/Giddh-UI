'use strict'

describe 'ledgerController', ->
  beforeEach module('giddhWebApp')

  describe 'local variables', ->
    beforeEach inject ($rootScope, $controller, localStorageService) ->
      @scope = $rootScope.$new()
      @rootScope = $rootScope
      @localStorageService = localStorageService
      spyOn(@localStorageService, 'get').andReturn({name: "walkover"})

      @ledgerController = $controller('ledgerController',
        {$scope: @scope, $rootScope: @rootScope, localStorageService: @localStorageService})

    it 'should check scope variables set by default', ->
      expect(@scope.selectedCompany).toEqual({name: "walkover"})
      expect(@scope.accntTitle).toBeUndefined()
      expect(@scope.showLedgerBox).toBeFalsy()
      expect(@scope.selectedAccountUniqueName).toBeUndefined()
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
      expect(@scope.dateOptions).toEqual({'year-format': "'yy'", 'starting-day': 1, 'showWeeks': false, 'show-button-bar': false, 'year-range': 1, 'todayBtn': false})
      expect(@scope.format).toBe("dd-MM-yyyy")
      expect(@scope.ftypeAdd).toBe("add")
      expect(@scope.ftypeUpdate).toBe("update")
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
        @scope.selectedAccountUniqueName = "somename"
        data = {groupUniqueName: "somename"}
        acData = {name: "name", uniqueName: "somename"}

        udata = {
          compUname: @scope.selectedCompany.uniqueName
          selGrpUname: @scope.selectedGroupUname
          acntUname: @scope.selectedAccountUniqueName
          fromDate: @scope.toDate.date
          toDate: @scope.fromDate.date
        }
        @scope.loadLedger(data, acData)
        expect(@scope.showLedgerBox).toBeFalsy()
        expect(@scope.selectedLedgerAccount).toBe(acData)
        expect(@scope.selectedLedgerGroup).toBe(data)
        expect(@scope.accntTitle).toEqual(acData.name)
        expect(@scope.selectedAccountUniqueName).toEqual(acData.uniqueName)
        expect(@scope.selectedGroupUname).toEqual(data.groupUniqueName)

        expect(@ledgerService.getLedger).toHaveBeenCalledWith(udata)

    describe '#loadLedgerSuccess', ->
      it 'should call calculate ledger function with data and set a variable true and push value in ledgerdata', ->
        spyOn(@scope, "calculateLedger")
        res = {
          status: "success"
          body: {
            key: "value"
            ledgers: []
          }
        }
        @scope.loadLedgerSuccess(res)
        expect(@scope.ledgerData).toBe(res.body)
        expect(@scope.showLedgerBox).toBeTruthy()
        expect(@scope.calculateLedger).toHaveBeenCalledWith(@scope.ledgerData, "server")

    describe '#debitOnly', ->
      it 'should check ledger transactions type', ->
        data = {
          voucher: {shortcode: "12345"}
          transactions: [
            {
              particular: "particular"
              type: "DEBIT"
            }
          ]
        }
        @scope.debitOnly(data)
        expect("DEBIT").toBe(data.transactions[0].type)

    describe '#creditOnly', ->
      it 'should check ledger transactions type', ->
        data = {
          voucher: {shortcode: "12345"}
          transactions: [
            {
              particular: "particular"
              type: "CREDIT"
            }
          ]
        }
        @scope.debitOnly(data)
        expect("CREDIT").toBe(data.transactions[0].type)

    describe '#loadLedgerFailure', ->
      it 'should show error message with toastr', ->
        res =
          data:
            status: "Error"
            message: "message"
        spyOn(@toastr, "error")
        @scope.loadLedgerFailure(res)
        expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

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
        @scope.selectedAccountUniqueName = "somename"
        item = {name: "name", uniqueName: "somename"}

        udata = {
          compUname: @scope.selectedCompany.uniqueName
          selGrpUname: @scope.selectedGroupUname
          acntUname: @scope.selectedAccountUniqueName
          entUname: item.uniqueName
        }
        @scope.deleteEntry(item)
        expect(@ledgerService.deleteEntry).toHaveBeenCalledWith(udata)

    describe '#deleteEntrySuccess', ->
      it 'should check ledger array length and remove data from its position by index and show success message through toastr and call calculateLedger function with two para', ->
        res = {
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
        @scope.deleteEntrySuccess(item, res)
        expect(@toastr.success).toHaveBeenCalledWith(res.message, res.status)
        expect(@scope.removeLedgerDialog).toHaveBeenCalled()
        expect(@scope.calculateLedger).toHaveBeenCalledWith(@scope.ledgerData, "deleted")

    describe '#deleteEntryFailure', ->
      it 'should show error message with toastr', ->
        res =
          data:
            status: "Error"
            message: "message"
        spyOn(@toastr, "error")
        @scope.deleteEntryFailure(res)
        expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

    describe '#addNewEntry', ->
      it 'should add a entry to ledger, copy data to a variable, call ledgerService createEntry method', ->
        @scope.selectedCompany = {
          uniqueName: "giddh"
        }
        @scope.selectedGroupUname = "groupname"
        @scope.selectedAccountUniqueName = "accountname"
        udata = {
          compUname: @scope.selectedCompany.uniqueName
          selGrpUname: @scope.selectedGroupUname
          acntUname: @scope.selectedAccountUniqueName
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
        res = {
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
        tType = res.body.transactions[0].type
        count = 0
        rpl = 0
        spyOn(@scope, "removeLedgerDialog")
        spyOn(@scope, "calculateLedger")
        spyOn(@toastr, "success")
        @scope.addEntrySuccess(res)
        expect(@toastr.success).toHaveBeenCalledWith(res.message, res.status)
        expect(@scope.removeLedgerDialog).toHaveBeenCalled()
        expect(tType).toBe(res.body.transactions[0].type)
        expect(count).toBe (0)
        expect(rpl).toBe (0)
        expect(@scope.ledgerData.ledgers[rpl]).toBe(res.body)
        expect(@scope.calculateLedger).toHaveBeenCalledWith(@scope.ledgerData, "add")

    describe '#addEntryFailure', ->
      it 'should show error message with toastr', ->
        res =
          data:
            status: "Error"
            message: "message"
        spyOn(@toastr, "error")
        @scope.addEntryFailure(res)
        expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

    describe '#updateEntry', ->
      it 'should update a entry to ledger, copy data to a variable, call ledgerService createEntry method', ->
        @scope.selectedCompany = {
          uniqueName: "giddh"
        }
        @scope.selectedGroupUname = "groupname"
        @scope.selectedAccountUniqueName = "accountname"
        data = {
          uniqueName: "uniqueName"
          voucher: {shortcode: "12345"}
          transactions: [
            {
              particular: "particular"
            }
          ]
        }
        udata = {
          compUname: @scope.selectedCompany.uniqueName
          selGrpUname: @scope.selectedGroupUname
          acntUname: @scope.selectedAccountUniqueName
          entUname: data.uniqueName
        }
        deferred = @q.defer()
        spyOn(@ledgerService, "updateEntry").andReturn(deferred.promise)
        edata = {}

        @scope.updateEntry(data)
        expect(@ledgerService.updateEntry).toHaveBeenCalledWith(udata, data)

    describe '#updateEntrySuccess', ->
      it 'should show success message, call removeLedgerDialog function, and change data to main object, and call calculateLedger function', ->
        res = {
          status: "Success"
          message: "Entry updated successfully"
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
        tType = res.body.transactions[0].type
        count = 0
        rpl = 0
        spyOn(@scope, "removeLedgerDialog")
        spyOn(@scope, "calculateLedger")
        spyOn(@toastr, "success")
        @scope.updateEntrySuccess(res)
        expect(@toastr.success).toHaveBeenCalledWith(res.message, res.status)
        expect(@scope.removeLedgerDialog).toHaveBeenCalled()
        expect(count).toBe (0)
        expect(rpl).toBe (0)
        expect(@scope.ledgerData.ledgers[rpl]).toBe(res.body)
        expect(@scope.calculateLedger).toHaveBeenCalledWith(@scope.ledgerData, "update")

    describe '#updateEntryFailure', ->
      it 'should show error message with toastr', ->
        res =
          data:
            status: "Error"
            message: "message"
        spyOn(@toastr, "error")
        @scope.updateEntryFailure(res)
        expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

    describe '#calculateLedger', ->
      it 'should calculate data and set some variables to according in this credit is greater', ->
        data = {
          balance: {
            amount: 8
            type: "DEBIT"
          }
          creditTotal: 158
          debitTotal: 158
          forwardedBalance: {
            amount: 108
            description: "BF_BALANCE"
            type: "CREDIT"
          }
          ledgers: [
            {
              uniqueName: "somename",
              transactions: [
                {type: "DEBIT", amount: 100}
              ]
            }
            {
              uniqueName: "somename1",
              transactions: [
                {type: "CREDIT", amount: 30}
              ]
            }
            {
              uniqueName: "somename2",
              transactions: [
                {type: "DEBIT", amount: 50}
              ]
            }
            {
              uniqueName: "somename3",
              transactions: [
                {type: "CREDIT", amount: 20}
              ]
            }
          ]
        }
        @scope.calculateLedger(data, "server")
        expect(@scope.ledgBalType).toBe ('CREDIT')
        expect(@scope.debitBalanceAmount).toBe (8)
        expect(@scope.debitTotal).toBe(158)
        expect(@scope.creditTotal).toBe(158)

      it 'should calculate data and set some variables to according in this DEBIT is greater', ->
        data = {
          balance: {
            amount: 208
            type: "CREDIT"
          }
          creditTotal: 258
          debitTotal: 258
          forwardedBalance: {
            amount: 108
            description: "BF_BALANCE"
            type: "DEBIT"
          }
          ledgers: [
            {
              uniqueName: "somename",
              transactions: [
                {type: "DEBIT", amount: 100}
              ]
            }
            {
              uniqueName: "somename1",
              transactions: [
                {type: "CREDIT", amount: 30}
              ]
            }
            {
              uniqueName: "somename2",
              transactions: [
                {type: "DEBIT", amount: 50}
              ]
            }
            {
              uniqueName: "somename3",
              transactions: [
                {type: "CREDIT", amount: 20}
              ]
            }
          ]
        }
        @scope.calculateLedger(data, "server")
        expect(@scope.ledgBalType).toBe ('DEBIT')
        expect(@scope.creditBalanceAmount).toBe (208)
        expect(@scope.debitTotal).toBe(258)
        expect(@scope.creditTotal).toBe(258)