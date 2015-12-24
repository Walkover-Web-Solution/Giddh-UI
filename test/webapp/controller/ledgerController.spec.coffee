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
      expect(@scope.ledgerdata).toBeUndefined()
      expect(@scope.accntTitle).toBeUndefined()
      expect(@scope.selectedAccountUniqueName).toBeUndefined()
      expect(@scope.selectedGroupUname).toBeUndefined()
      expect(@scope.selectedLedgerAccount).toBeUndefined()
      expect(@scope.ledgerOnlyDebitData).toEqual([])
      expect(@scope.ledgerOnlyCreditData).toEqual([])
      expect(@scope.selectedCompany).toEqual({name: "walkover"})
      expect(@scope.creditTotal).toBeUndefined()
      expect(@scope.debitTotal).toBeUndefined()
      expect(@scope.creditBalanceAmount).toBeUndefined()
      expect(@scope.debitBalanceAmount).toBeUndefined()
      expect(@scope.quantity).toBe(50)
      expect(@rootScope.cmpViewShow).toBeTruthy()
      expect(@rootScope.lItem).toEqual([])
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
      vouchDat = [
        {
          name: "Sales"
          shortCode: "sal"
        }
        {
          name: "Purchases"
          shortCode: "pur"
        }
        {
          name: "Receipt"
          shortCode: "rcpt"
        }
        {
          name: "Payment"
          shortCode: "pay"
        }
        {
          name: "Journal"
          shortCode: "jr"
        }
        {
          name: "Contra"
          shortCode: "cntr"
        }
      ]
      expect(@scope.voucherTypeList).toEqual(vouchDat)

  describe 'controller methods', ->
    beforeEach inject ($rootScope, $controller, localStorageService, toastr, ledgerService, $q, modalService, DAServices, permissionService, accountService, Upload) ->
      @scope = $rootScope.$new()
      @rootScope = $rootScope
      @localStorageService = localStorageService
      @ledgerService = ledgerService
      @DAServices = DAServices
      @toastr = toastr
      @accountService = accountService
      @permissionService = permissionService
      @modalService = modalService
      @Upload = Upload
      @q = $q
      @ledgerController = $controller('ledgerController',
        {
          $scope: @scope,
          $rootScope: @rootScope,
          localStorageService: @localStorageService
          ledgerService: @ledgerService
          accountService: @accountService
          DAServices: @DAServices
          modalService: @modalService
          Upload: @Upload
          permissionService: @permissionService
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
        @scope.selectedCompany = {
          uniqueName: "giddh"
        }
        @scope.selectedGroupUname = "somename"
        @scope.selectedAccountUniqueName = "somename"
        data = {groupUniqueName: "somename"}
        acData = {
          name: "name"
          uniqueName: "somename"
          parentGroups: [
            {name: "name0", uniqueName: "somename0"}
            {name: "name1", uniqueName: "somename1"}
            {name: "name2", uniqueName: "somename2"}
          ]
        }
        udata = {
          compUname: @scope.selectedCompany.uniqueName
          selGrpUname: @scope.selectedGroupUname
          acntUname: @scope.selectedAccountUniqueName
          fromDate: @scope.toDate.date
          toDate: @scope.fromDate.date
        }
        deferred = @q.defer()
        spyOn(@ledgerService, "getLedger").andReturn(deferred.promise)
        spyOn(@scope, "hasAddAndUpdatePermission").andReturn(true)
        spyOn(@scope, "showLedgerBreadCrumbs")

        @scope.loadLedger(data, acData)
        expect(@scope.showLedgerBox).toBeFalsy()
        expect(@scope.showLedgerLoader).toBeTruthy()
        expect(@scope.selectedLedgerAccount).toBe(acData)
        expect(@scope.selectedLedgerGroup).toBe(data)
        expect(@scope.accntTitle).toEqual(acData.name)
        expect(@scope.selectedAccountUniqueName).toEqual(acData.uniqueName)
        expect(@scope.selectedGroupUname).toEqual(data.groupUniqueName)

        expect(@scope.hasAddAndUpdatePermission).toHaveBeenCalledWith(acData)
        expect(@ledgerService.getLedger).toHaveBeenCalledWith(udata)
        expect(@scope.showLedgerBreadCrumbs).toHaveBeenCalledWith(acData.parentGroups.reverse())

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
        expect(@scope.ledgerData).toEqual(_.omit(res.body, 'ledgers'))
        expect(@scope.showLedgerBox).toBeTruthy()
        expect(@scope.showLedgerLoader).toBeFalsy()
        expect(@scope.calculateLedger).toHaveBeenCalledWith(@scope.ledgerData, "server")

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
          sharedData: {voucher: {shortcode: "12345"}}
          transactions: [
            {
              particular: "particular"
            }
          ]
        }
        edata = {
          voucher: {shortcode: "12345"}
          transactions: [
            {
              particular: "particular"
            }
          ]
        }
        @scope.addNewEntry(data)
        expect(@ledgerService.createEntry).toHaveBeenCalledWith(udata, edata)

    describe '#addEntrySuccess', ->
      it 'should show success message, call removeLedgerDialog function, and push data to main object and push data according to type in ledger Object, and call calculateLedger function', ->
        spyOn(@scope, "removeLedgerDialog")
        spyOn(@scope, "removeClassInAllEle")
        spyOn(@scope, "$broadcast")
        spyOn(@toastr, "success")
        @scope.addEntrySuccess({})
        expect(@rootScope.lItem).toEqual([])
        expect(@toastr.success).toHaveBeenCalledWith("Entry created successfully", "Success")
        expect(@scope.removeLedgerDialog).toHaveBeenCalled()
        expect(@scope.removeClassInAllEle).toHaveBeenCalledWith("ledgEntryForm", "newMultiEntryRow")
        expect(@scope.$broadcast).toHaveBeenCalledWith('$reloadLedger')
        expect(@rootScope.lItem).toEqual([])

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
          sharedData: {
            uniqueName: "uniqueName"
            voucher: {shortCode: "12345"}
          }
          transactions: [{particular: "particular"}]
        }
        @scope.ledgerOnlyDebitData = [data]
        eData = {
          uniqueName: "uniqueName"
          voucher: {shortCode: "12345"}
          voucherType: "12345"
          transactions: [{particular: "particular"}]
        }
        udata = {
          compUname: @scope.selectedCompany.uniqueName
          selGrpUname: @scope.selectedGroupUname
          acntUname: @scope.selectedAccountUniqueName
          entUname: data.sharedData.uniqueName
        }
        deferred = @q.defer()
        spyOn(@ledgerService, "updateEntry").andReturn(deferred.promise)

        @scope.updateEntry(data)
        expect(@ledgerService.updateEntry).toHaveBeenCalledWith(udata, eData)

    describe '#updateEntrySuccess', ->
      it 'should show success message, call removeLedgerDialog function, and change data to main object, and call calculateLedger function', ->
        debitLedger = {
          sharedData: {uniqueName: "some-debit-entry"}
          transactions: [ {type: "DEBIT"} ]
        }
        creditLedger = {
          sharedData: {uniqueName: "some-credit-entry"}
          transactions: [ {type: "CREDIT"} ]
        }
        res = { body: debitLedger }
        @scope.ledgerOnlyDebitData = [debitLedger]
        @scope.ledgerOnlyCreditData = [creditLedger]
        @scope.ledgerData = [creditLedger, creditLedger]

        spyOn(@scope, "removeLedgerDialog")
        spyOn(@scope, "removeClassInAllEle")
        spyOn(@scope, "calculateLedger")
        spyOn(@toastr, "success")

        @scope.updateEntrySuccess(res)
        expect(@rootScope.lItem).toEqual([])
        expect(@toastr.success).toHaveBeenCalledWith("Entry updated successfully", "Success")
        expect(@scope.removeLedgerDialog).toHaveBeenCalled()
        expect(@scope.removeClassInAllEle).toHaveBeenCalledWith("ledgEntryForm", "newMultiEntryRow")
        expect(@scope.removeClassInAllEle).toHaveBeenCalledWith("ledgEntryForm", "highlightRow")
        expect(@scope.removeClassInAllEle).toHaveBeenCalledWith("ledgEntryForm", "open")
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

    describe '#deleteEntry', ->
      it 'should call ledgerService deleteEntry method with object', ->
        deferred = @q.defer()
        spyOn(@ledgerService, "deleteEntry").andReturn(deferred.promise)
        @scope.selectedCompany = {
          uniqueName: "giddh"
        }
        @scope.selectedGroupUname = "somename"
        @scope.selectedAccountUniqueName = "somename"
        item = {sharedData: {name: "name", uniqueName: "somename"}}

        udata = {
          compUname: @scope.selectedCompany.uniqueName
          selGrpUname: @scope.selectedGroupUname
          acntUname: @scope.selectedAccountUniqueName
          entUname: item.sharedData.uniqueName
        }
        @scope.deleteEntry(item)
        expect(@ledgerService.deleteEntry).toHaveBeenCalledWith(udata)

    describe '#deleteEntrySuccess', ->
      it 'should check ledger array length and remove data from its position by index and show success message through toastr and call calculateLedger function with two para', ->
        res = {
          status: "success"
          body: "Entry deleted successfully"
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
        expect(@toastr.success).toHaveBeenCalledWith(res.body, res.status)
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

    describe '#addEntryInCredit', ->
      data = {
        sharedData:{
          uniqueName: "somename"
          entryDate: "01-12-2015"
        }
        transactions: [ {type: "CREDIT", amount: 20} ]
      }
      it 'should check array length and set value in local variable, then it should check if entryDate isnot blank and amount is not blank then it should call sameMethodForDrCr function with two parameters and it should check if uniqueName is undefined then it will add one more key {addType} in object after all this it will perform some underscore action {omit, last and extend}', ->
        @scope.ledgerOnlyCreditData = [
          {
            sharedData:{
              uniqueName: "somename1"
              entryDate: "01-12-2015"
            }
            transactions: [ {type: "CREDIT", amount: 30} ]
          }
          {
            sharedData:{
              uniqueName: "somename2"
              entryDate: "02-12-2015"
            }
            transactions: [ {type: "CREDIT", amount: 20} ]
          }
        ]
        spyOn(@scope, "sameMethodForDrCr")
        @scope.addEntryInCredit(data)
        expect(@scope.sameMethodForDrCr).toHaveBeenCalledWith(1, ".crLedgerEntryForm")

      it 'timeout test', ->
        @scope.ledgerOnlyCreditData = [
          {
            sharedData:{
              uniqueName: ""
              entryDate: ""
            }
            transactions: [ {type: "", amount: ""} ]
          }
          {
            sharedData:{
              uniqueName: ""
              entryDate: ""
            }
            transactions: [ {type: "", amount: ""} ]
          }
        ]
        spyOn(@scope, "sameMethodForDrCr")
        runs ->
          expect(@scope.sameMethodForDrCr).not.toHaveBeenCalledWith(1, ".crLedgerEntryForm")
        waitsFor (->
          @scope.addEntryInCredit(data)
        ), 200
        runs ->
          expect(@scope.sameMethodForDrCr).toHaveBeenCalledWith(1, ".crLedgerEntryForm")
    
    describe '#addEntryInDebit', ->
      data = {
        sharedData:{
          uniqueName: "somename"
          entryDate: "01-12-2015"
        }
        transactions: [ {type: "DEBIT", amount: 20} ]
      }
      it 'should check array length and set value in local variable, then it should check if entryDate isnot blank and amount is not blank then it should call sameMethodForDrCr function with two parameters and it should check if uniqueName is undefined then it will add one more key {addType} in object after all this it will perform some underscore action {omit, last and extend}', ->
        @scope.ledgerOnlyDebitData = [
          {
            sharedData:{
              uniqueName: "somename1"
              entryDate: "01-12-2015"
            }
            transactions: [ {type: "DEBIT", amount: 30} ]
          }
          {
            sharedData:{
              uniqueName: "somename2"
              entryDate: "02-12-2015"
            }
            transactions: [ {type: "DEBIT", amount: 20} ]
          }
        ]
        spyOn(@scope, "sameMethodForDrCr")
        @scope.addEntryInDebit(data)
        expect(@scope.sameMethodForDrCr).toHaveBeenCalledWith(1, ".drLedgerEntryForm")

    describe '#sameMethodForDrCr', ->
      xit 'should call removeLedgerDialog function and removeClassInAllEle with parameters', ->
        spyOn(@scope, "removeLedgerDialog")
        spyOn(@scope, "removeClassInAllEle")
        
        loadFixtures('myfixture.html');
        node=document.getElementById('my-fixture')
        @scope.sameMethodForDrCr(1, ".drLedgerEntryForm")

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
        }
        @scope.ledgerOnlyDebitData = [
          {
            uniqueName: "somename",
            transactions: [ {type: "DEBIT", amount: 100} ]
          }
          {
            uniqueName: "somename2",
            transactions: [ {type: "DEBIT", amount: 50} ]
          }
        ]
        @scope.ledgerOnlyCreditData = [
          {
            uniqueName: "somename1",
            transactions: [ {type: "CREDIT", amount: 30} ]
          }

          {
            uniqueName: "somename3",
            transactions: [ {type: "CREDIT", amount: 20} ]
          }
        ]
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
        }
        @scope.ledgerOnlyDebitData = [
          {
            uniqueName: "somename",
            transactions: [ {type: "DEBIT", amount: 100} ]
          }
          {
            uniqueName: "somename2",
            transactions: [ {type: "DEBIT", amount: 50} ]
          }
        ]
        @scope.ledgerOnlyCreditData = [
          {
            uniqueName: "somename1",
            transactions: [ {type: "CREDIT", amount: 30} ]
          }

          {
            uniqueName: "somename3",
            transactions: [ {type: "CREDIT", amount: 20} ]
          }
        ]
        @scope.calculateLedger(data, "server")
        expect(@scope.ledgBalType).toBe ('DEBIT')
        expect(@scope.creditBalanceAmount).toBe (208)
        expect(@scope.debitTotal).toBe(258)
        expect(@scope.creditTotal).toBe(258)


      it 'should calculate data and set some variables to according in this CREDIT/DEBIT are same', ->
        data = {
          balance: {
            amount: 0
            type: "CREDIT"
          }
          creditTotal: 100
          debitTotal: 100
          forwardedBalance: {
            amount: 0
            description: "BF_BALANCE"
            type: "DEBIT"
          }
        }
        @scope.ledgerOnlyDebitData = [
          {
            uniqueName: "somename",
            transactions: [ {type: "DEBIT", amount: 100} ]
          }
        ]
        @scope.ledgerOnlyCreditData = [
          {
            uniqueName: "somename1",
            transactions: [ {type: "CREDIT", amount: 50} ]
          }

          {
            uniqueName: "somename3",
            transactions: [ {type: "CREDIT", amount: 50} ]
          }
        ]
        @scope.calculateLedger(data, "server")
        expect(@scope.ledgBalType).toBe (undefined)
        expect(@scope.creditBalanceAmount).toBe(0)
        expect(@scope.debitBalanceAmount).toBe(0)
        expect(@scope.debitTotal).toBe(100)
        expect(@scope.creditTotal).toBe(100)

    describe '#viewContentLoaded event', ->
      xit 'should set date and call da service ledgerget method and call localStorageService and call loadLedger', ->
        spyOn(@DAServices, 'LedgerGet')
        @rootScope.$broadcast('$viewContentLoaded')
        expect(@DAServices.LedgerGet).toHaveBeenCalled()

    describe '#hasAddAndUpdatePermission', ->
      it 'should return true if user has add and update permission on account', ->
        account = {parentGroups: [{role: {permissions: [{"code": "UPDT"}, {"code": "ADD"}]}}]}
        spyOn(@permissionService, 'hasPermissionOn').andReturn(true)
        result = @scope.hasAddAndUpdatePermission(account)
        expect(result).toBeTruthy()
        expect(@permissionService.hasPermissionOn).toHaveBeenCalledWith(account, "ADD")
        expect(@permissionService.hasPermissionOn).toHaveBeenCalledWith(account, "UPDT")

      it 'should return false if user has only add permission on account not update', ->
        account = {parentGroups: [{role: {permissions: [{"code": "ADD"}]}}]}
        spyOn(@permissionService, 'hasPermissionOn').andReturn(false)
        result = @scope.hasAddAndUpdatePermission(account)
        expect(result).toBeFalsy()
        expect(@permissionService.hasPermissionOn).not.toHaveBeenCalledWith(account, "ADD")
        expect(@permissionService.hasPermissionOn).toHaveBeenCalledWith(account, "UPDT")

    describe '#exportLedger', ->
      it 'should call account service exportLedger method with unqObj', ->
        @scope.toDate = {
          date: "14-11-2015"
        }
        @scope.fromDate = {
          date: "14-11-2015"
        }
        @scope.selectedCompany = {
          uniqueName: "giddh"
        }
        @scope.selectedGroupUname = "somename"
        @scope.selectedAccountUniqueName = "somename"
        udata = {
          compUname: @scope.selectedCompany.uniqueName
          selGrpUname: @scope.selectedGroupUname
          acntUname: @scope.selectedAccountUniqueName
          fromDate: @scope.toDate.date
          toDate: @scope.fromDate.date
        }
        deferred = @q.defer()
        spyOn(@accountService, "exportLedger").andReturn(deferred.promise)
        @scope.exportLedger()
        expect(@accountService.exportLedger).toHaveBeenCalledWith(udata)

    describe '#exportLedgerSuccess', ->
      res =
        body:
          status: "Success"
          filePath: "abc/example.com"
      it 'check if browser is not ie', ->
        spyOn(window, "open")
        spyOn(@scope, "msieBrowser").andReturn(false)
        @scope.exportLedgerSuccess(res)
        expect(window.open).toHaveBeenCalled()
      it 'should check if browser is ie then call ie specific function', ->
        spyOn(@scope, "openWindow")
        spyOn(@scope, "msieBrowser").andReturn(true)
        @scope.exportLedgerSuccess(res)
        expect(@scope.openWindow).toHaveBeenCalledWith(res.body.filePath)
        

    describe '#exportLedgerFailure', ->
      it 'should show error message with toastr', ->
        res =
          data:
            status: "Error"
            message: "message"
        spyOn(@toastr, "error")
        @scope.exportLedgerFailure(res)
        expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

    describe '#importLedger', ->
    it 'should make variable false set values in a scope variable, then call upload service with upload method', ->
      @scope.selectedCompany = {
        uniqueName: "giddh"
      }
      @scope.selectedGroupUname = "somename"
      @scope.selectedAccountUniqueName = "somename"
      result = ''
      files = [{ 
        fieldname: 'file',
        originalname: 'master-small.xml',
        encoding: '7bit',
        mimetype: 'text/xml',
        destination: './uploads/',
        filename: '1449894122205.xml',
        path: 'uploads/1449894122205.xml',
        size: 1288072 
      }]
      errFiles = []
      deferred = @q.defer()
      spyOn(@Upload, "upload").andReturn(deferred.promise)
      @scope.importLedger(files, errFiles)
      expect(@Upload.upload).toHaveBeenCalled()
      expect(@scope.impLedgBar).toBeFalsy()
      expect(@scope.impLedgFiles).toBe(files)
      expect(@scope.impLedgErrFiles).toBe(errFiles)
      expect(angular.forEach).toBeDefined()



