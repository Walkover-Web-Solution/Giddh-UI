'use strict'

describe 'ledgerController', ->
  beforeEach module('giddhWebApp')

  describe 'local variables', ->
    beforeEach inject ($rootScope, $controller, localStorageService) ->
      @scope = $rootScope.$new()
      @rootScope = $rootScope
      @localStorageService = localStorageService
      spyOn(@localStorageService, 'get').andReturn({name: "walkover"} )
      @ledgerController = $controller('ledgerController',
        {$scope: @scope, $rootScope: @rootScope, localStorageService: @localStorageService} )

    it 'should check scope variables set by default', ->
      expect(@scope.ledgerdata).toBeUndefined()
      expect(@scope.accntTitle).toBeUndefined()
      expect(@scope.selectedGroupUname).toBeUndefined()
      expect(@scope.selectedLedgerAccount).toBeUndefined()
      expect(@scope.selectedLedgerGroup).toBeUndefined()
      expect(@scope.ledgerOnlyDebitData).toEqual([])
      expect(@scope.ledgerOnlyCreditData).toEqual([])
      expect(@rootScope.selectedCompany).toEqual({name: "walkover"} )
      expect(@rootScope.showImportListData).toBeFalsy()
      expect(@rootScope.unableToShowBrdcrmb).toBeFalsy()
      expect(@rootScope.importList).toEqual([])
      expect(@scope.creditTotal).toBeUndefined()
      expect(@scope.debitTotal).toBeUndefined()
      expect(@scope.creditBalanceAmount).toBeUndefined()
      expect(@scope.debitBalanceAmount).toBeUndefined()
      expect(@scope.quantity).toBe(50)
      expect(@rootScope.cmpViewShow).toBeTruthy()
      expect(@rootScope.lItem).toEqual([])
      expect(@scope.ledgerEmailData).toEqual({})
      expect(@scope.today).toBeDefined()
      expect(@scope.fromDate.date).toBeDefined()
      expect(@scope.toDate.date).toBeDefined()
      expect(@scope.fromDatePickerIsOpen).toBeFalsy()
      expect(@scope.fromDatePickerIsOpen).toBeFalsy
      expect(@scope.dateOptions).toEqual({'year-format': "'yy'", 'starting-day': 1, 'showWeeks': false, 'show-button-bar': false, 'year-range': 1, 'todayBtn': false} )
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
        {
          name: "Debit Note"
          shortCode: "debit note"
        }
        {
          name: "Credit Note"
          shortCode: "credit note"
        }
      ]
      expect(@scope.voucherTypeList).toEqual(vouchDat)

  describe 'controller methods', ->
    beforeEach inject ($rootScope, $controller, localStorageService, toastr, ledgerService, $q, modalService, DAServices, permissionService, accountService, Upload, groupService) ->
      @scope = $rootScope.$new()
      @rootScope = $rootScope
      @localStorageService = localStorageService
      @ledgerService = ledgerService
      @DAServices = DAServices
      @toastr = toastr
      @accountService = accountService
      @permissionService = permissionService
      @modalService = modalService
      @groupService = groupService
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
          groupService: @groupService
        }
      )

    describe '#trashEntry', ->
      it 'should call ledgerService trashTransaction method with object', ->
        @rootScope.selectedCompany = {
          uniqueName: "12345"
        }
        @rootScope.selAcntUname = "abc"
        item = {
          sharedData:
            transactionId: "abc123"
        }
        unqNamesObj = {
          compUname: @rootScope.selectedCompany.uniqueName
          acntUname: @rootScope.selAcntUname
          trId: item.sharedData.transactionId
        }
        deferred = @q.defer()
        spyOn(@ledgerService, 'trashTransaction').andReturn(deferred.promise)
        @scope.trashEntry(item)
        expect(@ledgerService.trashTransaction).toHaveBeenCalledWith(unqNamesObj)

    describe 'trashEntrySuccess', ->
      it 'should remove values from eLedgerData variables and call some functions', ->
        res = 
          status: "success"
          body:
            transactionId: "abc123"

        @scope.eLedgerDrData = [
          {
            sharedData:
              transactionId: "abc123"
              entryDate: "09-10-2010"
          }
          {
            sharedData:
              transactionId: "def"
              entryDate: "09-10-2010"
          }
        ]
        @scope.eLedgerCrData = [
          {
            sharedData:
              transactionId: "abc123"
              entryDate: "09-10-2010"
          }
          {
            sharedData:
              transactionId: "def"
              entryDate: "09-10-2010"
          }
        ]
        result = [
          {
            sharedData:
              transactionId: "def"
              entryDate: "09-10-2010"
          }
        ]
        spyOn(@toastr, "success")
        spyOn(@scope, "removeClassInAllEle")
        spyOn(@scope, "removeLedgerDialog")
        spyOn(@scope, "calculateELedger")
        @scope.trashEntrySuccess(res)
        expect(@toastr.success).toHaveBeenCalledWith("Entry deleted successfully", "Success")
        expect(@scope.eLedgerDrData).toEqual(result)
        expect(@scope.eLedgerCrData).toEqual(result)
        expect(@scope.removeClassInAllEle).toHaveBeenCalledWith("eLedgEntryForm", "open")
        expect(@scope.removeClassInAllEle).toHaveBeenCalledWith("eLedgEntryForm", "highlightRow")
        expect(@scope.removeLedgerDialog).toHaveBeenCalledWith(".eLedgerPopDiv")
        expect(@scope.calculateELedger).toHaveBeenCalled()
    
    describe '#trashEntryFailure', ->
      it 'should show error message with toastr', ->
        res =
          data:
            status: "Error"
            message: "message"
        spyOn(@toastr, "error")
        @scope.trashEntryFailure(res)
        expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)
    

    describe '#moveEntryInGiddh', ->
      it 'should add a entry to ledger, copy data to a variable, call ledgerService createEntry method', ->
        @rootScope.selectedCompany = {
          uniqueName: "giddh"
        }
        @scope.selectedGroupUname = "groupname"
        @rootScope.selAcntUname = "accountname"
        unqNamesObj = {
          compUname: @rootScope.selectedCompany.uniqueName
          acntUname: @rootScope.selAcntUname
        }
        deferred = @q.defer()
        spyOn(@ledgerService, "createEntry").andReturn(deferred.promise)
        data = {
          sharedData:
            multiEntry: false
            voucher:
              shortcode: "12345"
          transactions: [
            {
              particular: "particular"
            }
          ]
        }
        edata = {
          multiEntry: false
          voucher:
            shortcode: "12345"
          transactions: [
            {
              particular: "particular"
            }
          ]
        }
        @scope.moveEntryInGiddh(data)
        expect(@ledgerService.createEntry).toHaveBeenCalledWith(unqNamesObj, edata)
    
    describe 'moveEntryInGiddhSuccess', ->
      it 'should call some functions and show message with toastr', ->
        res = 
          status: "success"
          body:
            transactionId: "abc123"
        spyOn(@toastr, "success")
        spyOn(@scope, "removeClassInAllEle")
        spyOn(@scope, "removeLedgerDialog")
        spyOn(@scope, "reloadLedger")
        @scope.moveEntryInGiddhSuccess(res)
        expect(@toastr.success).toHaveBeenCalledWith("Entry created successfully", "Success")
        expect(@scope.removeClassInAllEle).toHaveBeenCalledWith("eLedgEntryForm", "open")
        expect(@scope.removeClassInAllEle).toHaveBeenCalledWith("eLedgEntryForm", "highlightRow")
        expect(@scope.removeLedgerDialog).toHaveBeenCalledWith(".eLedgerPopDiv")
        expect(@scope.reloadLedger).toHaveBeenCalled()

    describe '#getOtherTransactionsFailure', ->
      it 'should show error message with toastr', ->
        res =
          data:
            status: "Error"
            message: "message"
        spyOn(@toastr, "error")
        @scope.getOtherTransactionsFailure(res)
        expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

    describe '#getOtherTransactionsSuccess', ->
      it 'should make eLedgerDataFound to false and do nothing', ->
        gData = undefined
        acData = undefined
        res =
          status: "success"
          body: []

        @scope.getOtherTransactionsSuccess(res, gData, acData)
        expect(@scope.eLedgerDataFound).toBeFalsy()
        expect(@scope.eLedgerCrData).toEqual([])
        expect(@scope.eLedgerDrData).toEqual([])

      it 'should call calculateELedger function and make data from core object and push into eLedgerCrData and eLedgerDrData and make a variable true', ->
        gData = undefined
        acData = undefined
        res =
          status: "success"
          body: [
            {
              date: "01-12-2015"
              transactionId: "123"
              transactions: [
                {
                  amount: 130
                  type: "credit"
                  remarks:
                    description: "make"
                }
              ]
            }
            {
              date: "01-12-2015"
              transactionId: "123"
              transactions: [
                {
                  amount: 130
                  type: "debit"
                  remarks:
                    description: "make"
                }
              ]
            }
          ]
        convResCr = [
          {
            sharedData:
              date: '01-12-2015'
              transactionId: '123'
              multiEntry: false
              total: 0
              voucherType: 'rcpt'
              entryDate: '01-12-2015'
              description: 'make'
            transactions: [
              {
                amount: "130.00"
                type: "credit"
                remarks:
                  description: "make"
              }
            ]
          }
        ]
        convResDr = [
          {
            sharedData:
              date: '01-12-2015'
              transactionId: '123'
              multiEntry: false
              total: 0
              voucherType: 'pay'
              entryDate: '01-12-2015'
              description: 'make'
            transactions: [
              {
                amount: "130.00"
                type: "debit"
                remarks:
                  description: "make"
              }
            ]
          }
        ]
        spyOn(@scope, "calculateELedger")
        @scope.getOtherTransactionsSuccess(res, gData, acData)
        expect(@scope.eLedgerDataFound).toBeTruthy()
        expect(@scope.eLedgerCrData).toEqual(convResCr)
        expect(@scope.eLedgerDrData).toEqual(convResDr)
        expect(@scope.calculateELedger).toHaveBeenCalled()
    
    describe '#calculateELedger', ->
      it 'should do some math and calculate data and assign values in some variables', ->
        @scope.eLedgerDrData = [
          {
            transactions: [
              {
                amount: "130.00"
              }
            ]
          }
          {
            transactions: [
              {
                amount: "20.00"
              }
            ]
          }
        ]
        @scope.eLedgerCrData = [
          {
            transactions: [
              {
                amount: "200.00"
              }
            ]
          }
          {
            transactions: [
              {
                amount: "100.00"
              }
            ]
          }
        ]
        @scope.calculateELedger()
        expect(@scope.eCrTotal).toBe(300) 
        expect(@scope.eDrTotal).toBe(300)
        expect(@scope.eCrBalAmnt).toBe(0)
        expect(@scope.eDrBalAmnt).toBe(150)
        expect(@scope.eLedgType).toEqual('CREDIT')
        
      

    describe '#reloadLedger', ->
      it 'should call load ledger from scope variables and go in if condition', ->
        @scope.selectedLedgerGroup = {}
        @scope.selectedLedgerAccount = {}
        spyOn(@scope, 'loadLedger')
        @scope.reloadLedger()
        expect(@scope.loadLedger).toHaveBeenCalledWith(@scope.selectedLedgerGroup, @scope.selectedLedgerAccount)

      it 'should call loadLedger from localStorageService data', ->
        @scope.selectedLedgerGroup = undefined
        data =
          ledgerData:
            groupName: "CPU"
            groupUniqueName: "cpu"
            open: true
        spyOn(@localStorageService, "get").andReturn(data.ledgerData)
        spyOn(@scope, 'loadLedger')
        @scope.reloadLedger()
        expect(@scope.loadLedger).toHaveBeenCalled() 

      it 'should not call load ledger and goes in else else condition and show message with toastr', ->
        @scope.selectedLedgerGroup = undefined
        spyOn(@localStorageService, "get").andReturn(null)
        spyOn(@scope, 'loadLedger')
        spyOn(@toastr, "warning")
        @scope.reloadLedger()
        expect(@scope.loadLedger).not.toHaveBeenCalled()
        expect(@localStorageService.get).toHaveBeenCalledWith("_ledgerData")
        expect(@toastr.warning).toHaveBeenCalledWith("Something went wrong, Please reload page", "Warning")

    describe '#showLedgerBreadCrumbs', ->
      it 'should set data in ledgerBreadCrumbList', ->
        data = {}
        @scope.showLedgerBreadCrumbs(data)
        expect(@scope.ledgerBreadCrumbList).toEqual({} )

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
      acData = {
        mergedAccounts: ""
        name: "abcdef"
        uniqueName: "a333r3dge"
        parentGroups: [
          {name: "test", uniqueName: "jalgjlakjlgn"}
          {name: "Capital", uniqueName: "capital"}
        ]
      }
      gData = {
        accountDetails: [
          mergedAccounts: ""
          name: "abcdef"
          parentGroups: [
            {name: "test", uniqueName: "jalgjlakjlgn"}
            {name: "Capital", uniqueName: "capital"}
          ]
          uniqueName: "a333r3dge"
        ]
        groupName: "test"
        groupSynonyms: null
        groupUniqueName: "jalgjlakjlgn"
        open: true
      }
      matchData = {
        parentGroups:[
          {name: "test", uniqueName: "jalgjlakjlgn"}
          {name: "Capital", uniqueName: "capital"}
        ]
      }
      it 'should call accountService get method and if success then it will call getAcDtlDataSuccess with data and set unableToShowBrdcrmb variable falsy', ->
        @scope.toDate = {
          date: "14-11-2015"
        }
        @scope.fromDate = {
          date: "14-11-2015"
        }
        @rootScope.selectedCompany = {
          uniqueName: "giddh"
        }
        unqObj = {
          compUname : @rootScope.selectedCompany.uniqueName
          acntUname : acData.uniqueName
        }
        @rootScope.flatGroupsList = []
        # @rootScope.flatGroupsList = undefined
        # @rootScope.flatGroupsList = null
        deferred = @q.defer()
        spyOn(@accountService, 'get').andReturn(deferred.promise)
        spyOn(@scope, "getAcDtlDataSuccess")
        spyOn(@scope, "showLedgerBreadCrumbs")
        spyOn(@groupService, "matchAndReturnObj").andReturn(matchData)
        @scope.loadLedger(gData, acData)
        expect(@scope.unableToShowBrdcrmb).toBeTruthy()
        expect(@accountService.get).toHaveBeenCalledWith(unqObj)
        expect(@groupService.matchAndReturnObj).not.toHaveBeenCalled()
      it 'should call accountService get method and if success then it will call getAcDtlDataSuccess with data and set unableToShowBrdcrmb variable falsy and call groupService method matchAndReturnObj and call showLedgerBreadCrumbs with matchData object', ->
        @scope.toDate = {
          date: "14-11-2015"
        }
        @scope.fromDate = {
          date: "14-11-2015"
        }
        @rootScope.selectedCompany = {
          uniqueName: "giddh"
        }
        unqObj = {
          compUname : @rootScope.selectedCompany.uniqueName
          acntUname : acData.uniqueName
        }
        @rootScope.flatGroupsList = [
          {hey: "ddue"}
        ]
        deferred = @q.defer()
        spyOn(@accountService, 'get').andReturn(deferred.promise)
        spyOn(@scope, "getAcDtlDataSuccess")
        spyOn(@scope, "showLedgerBreadCrumbs")
        spyOn(@groupService, "matchAndReturnObj").andReturn(matchData)
        @scope.loadLedger(gData, acData)
        expect(@scope.unableToShowBrdcrmb).toBeFalsy()
        expect(@accountService.get).toHaveBeenCalledWith(unqObj)
        expect(@groupService.matchAndReturnObj).toHaveBeenCalledWith(gData, @rootScope.flatGroupsList)
        expect(@scope.showLedgerBreadCrumbs).toHaveBeenCalledWith(matchData.parentGroups)

    describe '#getAcDtlDataFailure', ->
      it 'should show error message with toastr', ->
        res =
          data:
            status: "Error"
            message: "message"
        spyOn(@toastr, "error")
        @scope.loadLedgerFailure(res)
        expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

    describe '#getAcDtlDataSuccess', ->
      it 'should assigne values in variables and call ledgerService getLedger method and not call ledgerService getOtherTransactions method', ->
        @rootScope.selectedCompany = {
          uniqueName: "giddh"
        }
        
        acData = {
          mergedAccounts: ""
          name: "abcdef"
          uniqueName: "a333r3dge"
          parentGroups: [
            {name: "test", uniqueName: "jalgjlakjlgn"}
            {name: "Capital", uniqueName: "capital"}
          ]
        }
        gData = {
          accountDetails: [
            mergedAccounts: ""
            name: "abcdef"
            parentGroups: [
              {name: "test", uniqueName: "jalgjlakjlgn"}
              {name: "Capital", uniqueName: "capital"}
            ]
            uniqueName: "a333r3dge"
          ]
          groupName: "test"
          groupSynonyms: null
          groupUniqueName: "jalgjlakjlgn"
          open: true
        }
        @rootScope.selAcntUname = acData.uniqueName
        @scope.fromDate.date = "14-11-2015"
        @scope.toDate.date = "14-12-2015"
        unqNamesObj = {
          compUname: @rootScope.selectedCompany.uniqueName
          acntUname: @rootScope.selAcntUname
          fromDate: @scope.fromDate.date
          toDate: @scope.toDate.date
        }
        res = {
          status: "success"
          body: {
            address: null
            city: null
            companyName: null
            country: null
            createdAt: "01-02-2016 13:54:50"
            description: null
            email: null
            mergedAccounts: ""
            mobileNo: null
            name: "abcdef"
            openingBalance: 0
            openingBalanceDate: "01-02-2016"
            openingBalanceType: "CREDIT"
            pincode: null
            role: {
              name: "Super Admin"
              uniqueName: "super_admin"
            }
            state: null
            uniqueName: "a333r3dge"
            updatedAt: "01-02-2016 13:54:50"
            yodleeAdded: false
          }
        }
        spyOn(@scope, "hasAddAndUpdatePermission")
        deferred = @q.defer()
        spyOn(@ledgerService, 'getOtherTransactions').andReturn(deferred.promise)
        deferred = @q.defer()
        spyOn(@ledgerService, 'getLedger').andReturn(deferred.promise)
        @scope.getAcDtlDataSuccess(res, gData, acData)
        expect(@ledgerService.getLedger).toHaveBeenCalledWith(unqNamesObj)
        expect(@ledgerService.getOtherTransactions).not.toHaveBeenCalled()

      it 'should assigne values in variables and call ledgerService getLedger method and  call ledgerService getOtherTransactions method', ->
        @rootScope.selectedCompany = {
          uniqueName: "giddh"
        }
        acData = {
          mergedAccounts: ""
          name: "abcdef"
          uniqueName: "a333r3dge"
          parentGroups: [
            {name: "test", uniqueName: "jalgjlakjlgn"}
            {name: "Capital", uniqueName: "capital"}
          ]
        }
        gData = {
          accountDetails: [
            mergedAccounts: ""
            name: "abcdef"
            parentGroups: [
              {name: "test", uniqueName: "jalgjlakjlgn"}
              {name: "Capital", uniqueName: "capital"}
            ]
            uniqueName: "a333r3dge"
          ]
          groupName: "test"
          groupSynonyms: null
          groupUniqueName: "jalgjlakjlgn"
          open: true
        }
        @rootScope.selAcntUname = acData.uniqueName
        @scope.fromDate.date = "14-11-2015"
        @scope.toDate.date = "14-12-2015"
        unqNamesObj = {
          compUname: @rootScope.selectedCompany.uniqueName
          acntUname: @rootScope.selAcntUname
          fromDate: @scope.fromDate.date
          toDate: @scope.toDate.date
        }
        res = {
          status: "success"
          body: {
            address: null
            city: null
            companyName: null
            country: null
            createdAt: "01-02-2016 13:54:50"
            description: null
            email: null
            mergedAccounts: ""
            mobileNo: null
            name: "abcdef"
            openingBalance: 0
            openingBalanceDate: "01-02-2016"
            openingBalanceType: "CREDIT"
            pincode: null
            role: {
              name: "Super Admin"
              uniqueName: "super_admin"
            }
            state: null
            uniqueName: "a333r3dge"
            updatedAt: "01-02-2016 13:54:50"
            yodleeAdded: true
          }
        }
        spyOn(@scope, "hasAddAndUpdatePermission")
        deferred = @q.defer()
        spyOn(@ledgerService, 'getOtherTransactions').andReturn(deferred.promise)
        deferred = @q.defer()
        spyOn(@ledgerService, 'getLedger').andReturn(deferred.promise)
        @scope.getAcDtlDataSuccess(res, gData, acData)
        expect(@ledgerService.getLedger).toHaveBeenCalledWith(unqNamesObj)
        expect(@ledgerService.getOtherTransactions).toHaveBeenCalled()

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
        expect(@scope.ledgerData).toEqual(_.omit(res.body, 'ledgers') )
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
        spyOn(@rootScope, "$emit")
        @scope.addNewAccount()
        expect(@rootScope.$emit).toHaveBeenCalledWith('callManageGroups')
     

    describe '#addNewEntry', ->
      it 'should add a entry to ledger, copy data to a variable, call ledgerService createEntry method', ->
        @rootScope.selectedCompany = {
          uniqueName: "giddh"
        }
        @scope.selectedGroupUname = "groupname"
        @rootScope.selAcntUname = "accountname"
        udata = {
          compUname: @rootScope.selectedCompany.uniqueName
          acntUname: @rootScope.selAcntUname
        }
        deferred = @q.defer()
        spyOn(@ledgerService, "createEntry").andReturn(deferred.promise)
        data = {
          sharedData: {voucher: {shortcode: "12345"} }
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
        spyOn(@scope, "reloadLedger")
        spyOn(@toastr, "success")
        @scope.addEntrySuccess({} )
        expect(@rootScope.lItem).toEqual([])
        expect(@toastr.success).toHaveBeenCalledWith("Entry created successfully", "Success")
        expect(@scope.removeLedgerDialog).toHaveBeenCalled()
        expect(@scope.removeClassInAllEle).toHaveBeenCalledWith("ledgEntryForm", "newMultiEntryRow")
        expect(@scope.reloadLedger).toHaveBeenCalled()
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
        @rootScope.selectedCompany = {
          uniqueName: "giddh"
        }
        @scope.selectedGroupUname = "groupname"
        @rootScope.selAcntUname = "accountname"
        data = {
          sharedData: {
            uniqueName: "uniqueName"
            voucher: {shortCode: "12345"}
          }
          transactions: [{particular: "particular"} ]
        }
        @scope.ledgerOnlyDebitData = [data]
        eData = {
          uniqueName: "uniqueName"
          voucher: {shortCode: "12345"}
          voucherType: "12345"
          transactions: [{particular: "particular"} ]
        }
        udata = {
          compUname: @rootScope.selectedCompany.uniqueName
          acntUname: @rootScope.selAcntUname
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
        @rootScope.selectedCompany = {
          uniqueName: "giddh"
        }
        @scope.selectedGroupUname = "somename"
        @rootScope.selAcntUname = "somename"
        item = {sharedData: {name: "name", uniqueName: "somename"} }

        udata = {
          compUname: @rootScope.selectedCompany.uniqueName
          acntUname: @rootScope.selAcntUname
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
        sharedData: {
          uniqueName: "somename"
          entryDate: "01-12-2015"
        }
        transactions: [ {type: "CREDIT", amount: 20} ]
      }
      it 'should check array length and set value in local variable, then it should check if entryDate isnot blank and amount is not blank then it should call sameMethodForDrCr function with two parameters and it should check if uniqueName is undefined then it will add one more key {addType} in object after all this it will perform some underscore action {omit, last and extend}', ->
        @scope.ledgerOnlyCreditData = [
          {
            sharedData: {
              uniqueName: "somename1"
              entryDate: "01-12-2015"
            }
            transactions: [ {type: "CREDIT", amount: 30} ]
          }
          {
            sharedData: {
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
            sharedData: {
              uniqueName: ""
              entryDate: ""
            }
            transactions: [ {type: "", amount: ""} ]
          }
          {
            sharedData: {
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
        sharedData: {
          uniqueName: "somename"
          entryDate: "01-12-2015"
        }
        transactions: [ {type: "DEBIT", amount: 20} ]
      }
      it 'should check array length and set value in local variable, then it should check if entryDate isnot blank and amount is not blank then it should call sameMethodForDrCr function with two parameters and it should check if uniqueName is undefined then it will add one more key {addType} in object after all this it will perform some underscore action {omit, last and extend}', ->
        @scope.ledgerOnlyDebitData = [
          {
            sharedData: {
              uniqueName: "somename1"
              entryDate: "01-12-2015"
            }
            transactions: [ {type: "DEBIT", amount: 30} ]
          }
          {
            sharedData: {
              uniqueName: "somename2"
              entryDate: "02-12-2015"
            }
            transactions: [ {type: "DEBIT", amount: 20} ]
          }
        ]
        spyOn(@scope, "sameMethodForDrCr")
        @scope.addEntryInDebit(data)
        expect(@scope.sameMethodForDrCr).toHaveBeenCalledWith(1, ".drLedgerEntryForm")

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
      data = {
        ledgerData:
          groupName: "CPU"
          groupUniqueName: "cpu"
          open: true
        selectedAccount:
          address: "null"
          companyName: "null"
          description: "null"
          mobileNo: "123433"
          name: "mother board"
      }
      it 'if condition work and it should call da service LedgerGet method and after fetch data it will call loadLedger function with data', ->
        spyOn(@DAServices, 'LedgerGet').andReturn(data)
        spyOn(@scope, "loadLedger")
        @rootScope.$broadcast('$viewContentLoaded')
        expect(@DAServices.LedgerGet).toHaveBeenCalled()
        expect(@scope.loadLedger).toHaveBeenCalledWith(data.ledgerData, data.selectedAccount)
      it 'should go in else if condition and check if data is in localStorageService and then call loadLedger function with data', ->
        spyOn(@scope, "loadLedger")
        spyOn(@DAServices, 'LedgerGet').andReturn({} )
        spyOn(@localStorageService, 'get').andReturn(data.ledgerData)
        @rootScope.$broadcast('$viewContentLoaded')
        expect(@DAServices.LedgerGet).toHaveBeenCalled()
        expect(@scope.loadLedger).toHaveBeenCalledWith(data.ledgerData, data.ledgerData)

    describe '#hasAddAndUpdatePermission', ->
      it 'should return true if user has add and update permission on account', ->
        account = {parentGroups: [{role: {permissions: [{"code": "UPDT"}, {"code": "ADD"} ]} } ]}
        spyOn(@permissionService, 'hasPermissionOn').andReturn(true)
        result = @scope.hasAddAndUpdatePermission(account)
        expect(result).toBeTruthy()
        expect(@permissionService.hasPermissionOn).toHaveBeenCalledWith(account, "ADD")
        expect(@permissionService.hasPermissionOn).toHaveBeenCalledWith(account, "UPDT")

      it 'should return false if user has only add permission on account not update', ->
        account = {parentGroups: [{role: {permissions: [{"code": "ADD"} ]} } ]}
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
        @rootScope.selectedCompany = {
          uniqueName: "giddh"
        }
        @scope.selectedGroupUname = "somename"
        @rootScope.selAcntUname = "somename"
        udata = {
          compUname: @rootScope.selectedCompany.uniqueName
          selGrpUname: @scope.selectedGroupUname
          acntUname: @rootScope.selAcntUname
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
      xit 'check if browser is not ie', ->
        spyOn(window, "open")
        spyOn(@scope, "msieBrowser").andReturn(false)
        @scope.exportLedgerSuccess(res)
        expect(window.open).toHaveBeenCalled()
      xit 'should check if browser is ie then call ie specific function', ->
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
        @rootScope.selectedCompany = {
          uniqueName: "giddh"
        }
        @scope.selectedGroupUname = "somename"
        @rootScope.selAcntUname = "somename"
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
        } ]
        errFiles = []
        deferred = @q.defer()
        spyOn(@Upload, "upload").andReturn(deferred.promise)
        @scope.importLedger(files, errFiles)
        expect(@Upload.upload).toHaveBeenCalled()
        expect(@scope.impLedgBar).toBeFalsy()
        expect(@scope.impLedgFiles).toBe(files)
        expect(@scope.impLedgErrFiles).toBe(errFiles)
        expect(angular.forEach).toBeDefined()

    describe '#showImportList', ->
      it 'should open madal and call accountService ledgerImportList method', ->
        @rootScope.selectedCompany = {
          uniqueName: "giddh"
        }
        @scope.selectedGroupUname = "somename"
        @rootScope.selAcntUname = "somename"
        data = {
          compUname: @rootScope.selectedCompany.uniqueName
          selGrpUname: @scope.selectedGroupUname
          acntUname: @rootScope.selAcntUname
        }
        spyOn(@modalService, "openImportListModal")
        deferred = @q.defer()
        spyOn(@accountService, "ledgerImportList").andReturn(deferred.promise)
        @scope.showImportList()
        expect(@modalService.openImportListModal).toHaveBeenCalled()
        expect(@accountService.ledgerImportList).toHaveBeenCalledWith(data)

    describe '#ledgerImportListSuccess', ->
      it 'should call calculate ledger function with data and set a variable true and push value in ledgerdata', ->
        spyOn(@scope, "calculateLedger")
        res = {
          status: "success"
          body: {
            key: "value"
            ledgers: []
          }
        }
        @scope.ledgerImportListSuccess(res)
        expect(@rootScope.importList).toEqual(res.body)
        expect(@rootScope.showImportListData).toBeTruthy()

    describe '#ledgerImportListFailure', ->
      it 'should show error message with toastr', ->
        res =
          data:
            status: "Error"
            message: "message"
        spyOn(@toastr, "error")
        @scope.ledgerImportListFailure(res)
        expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

    describe '#sendLedgEmail', ->
      data =
        email: "abc@gmail.com"
      it 'should check if date is format is proper or not', ->
        @scope.toDate = 
          date: "04-10-2009"
        @scope.fromDate = 
          date: null
        spyOn(@toastr, "error")
        @scope.sendLedgEmail(data)
        expect(@toastr.error).toHaveBeenCalledWith("Date should be in proper format", "Error")
      it 'should set variables and return false in case of not valid string and not call accountService emailLedger method', ->
        spyOn(@toastr, "warning")
        deferred = @q.defer()
        spyOn(@accountService, "emailLedger").andReturn(deferred.promise)
        @scope.sendLedgEmail("abc@x y z.in, abc@e")
        expect(@toastr.warning).toHaveBeenCalledWith("Enter valid Email ID", "Warning")
        expect(@accountService.emailLedger).not.toHaveBeenCalled()

      it 'should call accountService emailLedger method with desired variables', ->
        @rootScope.selectedCompany =
          uniqueName: "somename"
        @rootScope.selAcntUname = "somename"
        @scope.toDate = 
          date: "12-02-2016"
        @scope.fromDate = 
          date: "12-01-2016"
        spyOn(@toastr, "warning")
        deferred = @q.defer()
        spyOn(@accountService, "emailLedger").andReturn(deferred.promise)
        unqNamesObj = {
          compUname: @rootScope.selectedCompany.uniqueName
          acntUname: @rootScope.selAcntUname
          toDate: @scope.toDate.date
          fromDate: @scope.fromDate.date
        }
        sendData = {
          recipients: ["abc@xyz.in", "abc@ebc.com"]
        }
        @scope.sendLedgEmail("abc@x y z.in, abc@ebc.com")
        expect(@toastr.warning).not.toHaveBeenCalled()
        expect(@accountService.emailLedger).toHaveBeenCalledWith(unqNamesObj, sendData)

    describe '#validateEmail', ->
      it 'should validate string and return true if string is valid email id', ->
        result =  @scope.validateEmail("abc@xyz.com")
        expect(result).toBeTruthy()
      it 'should return false if string is not valid email id', ->
        result =  @scope.validateEmail("abc@x")
        expect(result).toBeFalsy()

    describe '#emailLedgerSuccess', ->
      it 'should make variable empty and show message with toastr success method', ->
        res = {
          body: "Email sent to xyz@gmail.com"
          status: "success"
        }
        spyOn(@toastr, "success")
        @scope.emailLedgerSuccess(res)
        expect(@toastr.success).toHaveBeenCalledWith(res.body, res.status)
        expect(@scope.ledgerEmailData).toEqual({})

    describe '#emailLedgerFailure', ->
      it 'should show error message with toastr', ->
        res =
          data:
            status: "Error"
            message: "message"
        spyOn(@toastr, "error")
        @scope.emailLedgerFailure(res)
        expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)
