# 'use strict'

# describe 'invoiceController', ->
#   beforeEach module('giddhWebApp')

#   describe 'local variables', ->
#     beforeEach inject ($rootScope, $controller, localStorageService) ->
#       @scope = $rootScope.$new()
#       @rootScope = $rootScope
#       @localStorageService = localStorageService
#       spyOn(@localStorageService, 'get').andReturn({})
#       @invoiceController = $controller('invoiceController',
#         {$scope: @scope, $rootScope: @rootScope, localStorageService: @localStorageService} )

#     it 'should check scope variables set by default', ->
#       expect(@scope.selectedCompany).toEqual({})
#       expect(@localStorageService.get).toHaveBeenCalledWith("_selectedCompany")
#       expect(@scope.withSampleData).toBeTruthy()
#       expect(@scope.logoUpldComplt).toBeFalsy()
#       expect(@scope.showAccountList).toBeFalsy()
#       expect(@scope.invoiceLoadDone).toBeFalsy()
#       expect(@scope.noDataDR).toBeFalsy()
#       expect(@scope.radioChecked).toBeFalsy()
#       expect(@scope.genPrevMode).toBeFalsy()
#       expect(@scope.genMode).toBeFalsy()
#       expect(@scope.prevInProg).toBeFalsy()
#       expect(@scope.InvEmailData).toEqual({})
#       expect(@scope.nameForAction).toEqual([])
#       expect(@scope.onlyDrData).toEqual([])
#       expect(@scope.entriesForInvoice).toEqual([])
#       expect(@scope.today).toBeDefined()
#       expect(@scope.dateData.fromDate).toBeDefined()
#       expect(@scope.dateData.toDate).toBeDefined()
#       expect(@scope.fromDatePickerIsOpen).toBeFalsy()
#       expect(@scope.toDatePickerIsOpen).toBeFalsy()
#       expect(@scope.dateOptions).toEqual({'year-format': "'yy'", 'starting-day': 1, 'showWeeks': false, 'show-button-bar': false, 'year-range': 1, 'todayBtn': false} )
#       expect(@scope.format).toBe("dd-MM-yyyy")

#       defaultInvoiceData=
#         logo: 
#           path: '/public/website/images/logo.png'
#         invoiceDetails:
#           invoiceNumber: '##########'
#           invoiceDate: '11-12-2016'
#         company:
#           name: 'Walkover Web Solutions Pvt. ltd.'
#           data: '405-406 Capt. C.S. Naidu Arcade,10/2 Old Palasiya,Indore Madhya Pradesh,CIN: 02830948209eeri,Email: account@giddh.com'
#         companyIdentities: 
#           data: 'tin:67890, cin:12345'
#         entries: [
#           {
#             "transactions": [
#               {
#                 "amount": 54500,
#                 "accountName": "John",
#                 "accountUniqueName": "john",
#                 "description": "Purchase of Macbook"
#               }
#             ],
#             "uniqueName": "d7t1462171597019"
#           }
#           {
#             "transactions": [
#               {
#                 "amount": 23700,
#                 "accountName": "John",
#                 "accountUniqueName": "john",
#                 "description": "Purchase of Ipad"
#               }
#             ],
#             "uniqueName": "d7t1462171597030"
#           }
#           {
#             "transactions": [
#               {
#                 "amount": 25300,
#                 "accountName": "John",
#                 "accountUniqueName": "john",
#                 "description": "Purchase of Iphone"
#               }
#             ],
#             "uniqueName": "d7t1462171597023"
#           }
#         ]
#         terms: [
#           "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
#           "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
#           "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
#         ]
#         grandTotal: 118507.50
#         subTotal: 103500
#         taxTotal: 0
#         taxes:[
#           {
#             "hasError": false,
#             "amount": 15007.50,
#             "accountName": "vat@14.5",
#             "taxRate": 14,
#             "visibleTaxRate": 14,
#             "errorMessage": "",
#             "accountUniqueName": "vat14.5"
#           }
#         ]
#         signature:
#           name: 'Walkover Web Solutions Pvt. ltd.'
#           data: 'Authorised Signatory'
#         account:
#           name: 'Career Point Ltd.'
#           data: 'CP Tower Road No. 1,Indraprashta Industrial Kota,PAN: 1862842,Email: info@career.com'
      
#       expect(@scope.tempDataDef).toEqual(defaultInvoiceData)
      
#       # expect(@scope.voucherTypeList).toEqual(vouchDat)

#   describe 'controller methods', ->
#     beforeEach inject ($rootScope, $controller, localStorageService, toastr, ledgerService, $q, modalService, DAServices, permissionService, accountService, Upload, groupService, companyServices, $uibModal) ->
#       @scope = $rootScope.$new()
#       @rootScope = $rootScope
#       @localStorageService = localStorageService
#       @ledgerService = ledgerService
#       @DAServices = DAServices
#       @toastr = toastr
#       @companyServices = companyServices
#       @accountService = accountService
#       @permissionService = permissionService
#       @modalService = modalService
#       @groupService = groupService
#       @Upload = Upload
#       @q = $q
#       @uibModal = $uibModal
#       @invoiceController = $controller('invoiceController',
#         {
#           $scope: @scope,
#           $rootScope: @rootScope,
#           localStorageService: @localStorageService
#           ledgerService: @ledgerService
#           accountService: @accountService
#           DAServices: @DAServices
#           modalService: @modalService
#           Upload: @Upload
#           permissionService: @permissionService
#           groupService: @groupService
#           companyServices: @companyServices
#           $uibModal: @uibModal
#         }
#       )

#     describe '#closePop', ->
#       it 'should make changes in some variables', ->
#         @scope.closePop()
#         expect(@scope.withSampleData).toBeTruthy()
#         expect(@scope.genMode).toBeFalsy()
#         expect(@scope.genPrevMode).toBeFalsy()
#         expect(@scope.prevInProg).toBeTruthy()

#     describe '#getAllGroupsWithAcnt', ->
#       it 'should show error message with toastr', ->
#         @rootScope.selectedCompany = {}
#         spyOn(@toastr, "error")
#         @scope.getAllGroupsWithAcnt()
#         expect(@toastr.error).toHaveBeenCalledWith("Select company first.", "Error")

#       it 'should call groupService getGroupsWithAccountsCropped method with uniqueName', ->
#         @rootScope.selectedCompany = {
#           uniqueName: "12345"
#         }
#         deferred = @q.defer()
#         spyOn(@groupService, 'getGroupsWithAccountsCropped').andReturn(deferred.promise)
#         @scope.getAllGroupsWithAcnt()
#         expect(@groupService.getGroupsWithAccountsCropped).toHaveBeenCalledWith(@rootScope.selectedCompany.uniqueName)
    
#     describe '#makeAccountsList', ->
#       it 'should call groupService matchAndReturnGroupObj', ->
#         item=
#           name: "Current Assets"
#           uniqueName:"current_assets"
#         res=
#           "status": "success",
#           "body": [
#             {
#               "name": "Capital",
#               "uniqueName": "capital",
#               "synonyms": null,
#               "accounts": [],
#               "groups": [],
#               "category": "liabilities"
#             }
#             {
#               "name": "Current Assets",
#               "uniqueName": "current_assets",
#               "synonyms": null,
#               "accounts": [],
#               "groups": [
#                 {
#                   "name": "Sundry Debtors",
#                   "uniqueName": "sundry_debtors",
#                   "synonyms": null,
#                   "accounts": [
#                     {
#                       "name": "faltu group",
#                       "uniqueName": "dfsfdf",
#                       "mergedAccounts": ""
#                     },
#                     {
#                       "name": "chirag",
#                       "uniqueName": "chirag_new",
#                       "mergedAccounts": ""
#                     },
#                     {
#                       "name": "nidhi",
#                       "uniqueName": "aba",
#                       "mergedAccounts": ""
#                     },
#                     {
#                       "name": "def",
#                       "uniqueName": "def",
#                       "mergedAccounts": ""
#                     }
#                   ],
#                   "groups": [],
#                   "category": "assets"
#                 }
#               ],
#               "category": "assets"
#             }
#           ]
          
#         getPgrps=
#           "name": "Current Assets",
#           "uniqueName": "current_assets",
#           "synonyms": null,
#           "accounts": [],
#           "groups": [
#             {
#               "name": "Sundry Debtors",
#               "uniqueName": "sundry_debtors",
#               "synonyms": null,
#               "accounts": [
#                 {
#                   "name": "faltu group",
#                   "uniqueName": "dfsfdf",
#                   "mergedAccounts": ""
#                 },
#                 {
#                   "name": "chirag",
#                   "uniqueName": "chirag_new",
#                   "mergedAccounts": ""
#                 },
#                 {
#                   "name": "nidhi",
#                   "uniqueName": "aba",
#                   "mergedAccounts": ""
#                 },
#                 {
#                   "name": "def",
#                   "uniqueName": "def",
#                   "mergedAccounts": ""
#                 }
#               ],
#               "groups": [],
#               "category": "assets"
#             }
#           ],
#           "category": "assets"
        
#         @rootScope.$stateParams=
#           invId: "def"
          
#         spyOn(@groupService, "matchAndReturnGroupObj").andReturn(getPgrps)
#         spyOn(@groupService, "flattenGroup").andReturn([])
#         spyOn(@groupService, "flattenGroupsWithAccounts").andReturn([])
#         spyOn(@scope, "toggleAcMenus")

#         @scope.makeAccountsList(res)
        
#         expect(@groupService.matchAndReturnGroupObj).toHaveBeenCalledWith(item, res.body)
#         expect(@groupService.flattenGroup).toHaveBeenCalledWith([getPgrps], [])
#         expect(@groupService.flattenGroupsWithAccounts).toHaveBeenCalledWith([])
#         expect(@rootScope.flatGroupsList).toEqual([])
#         expect(@scope.flatAccntWGroupsList).toEqual([])
#         expect(@scope.canChangeCompany).toBeTruthy()
#         expect(@scope.showAccountList).toBeTruthy()
#         expect(@scope.toggleAcMenus).toHaveBeenCalledWith(true)

#     describe '#makeAccountsListFailure', ->
#       it 'should show error message with toastr', ->
#         res =
#           data:
#             status: "error"
#             message: "message"
#         spyOn(@toastr, "error")
#         @scope.makeAccountsListFailure(res)
#         expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)
    

#     describe '#toggleAcMenus', ->
#       varx = [{
#           open: false,
#           name: "group1"
#           uniqueName: "g1"
#           accounts: []
#         }
#         {
#           open: false,
#           name: "group1"
#           uniqueName: "g1"
#           accounts: []
#       }]
#       it 'should check if flatAccntWGroupsList is empty then do nothing', ->
#         @scope.flatAccntWGroupsList = {}
#         @scope.toggleAcMenus(true)
#         expect(angular.forEach).toBeDefined()
#         expect(@scope.showSubMenus).not.toBeTruthy()
#       it 'should expand menus', ->
#         @scope.flatAccntWGroupsList = varx
#         @scope.toggleAcMenus(true)
#         expect(angular.forEach).toBeDefined()
#         expect(@scope.showSubMenus).toBeTruthy()
#       it 'should collapse all menus', ->
#         @scope.flatAccntWGroupsList = varx
#         @scope.toggleAcMenus(false)
#         expect(angular.forEach).toBeDefined()
#         expect(@scope.showSubMenus).toBeFalsy()

#     describe '#checkLength', ->
#       it 'should checkLength of value if value is blank or undefined it will call toggleAcMenus function with false', ->
#         spyOn(@scope, "toggleAcMenus")
#         @scope.checkLength("")
#         expect(@scope.toggleAcMenus).toHaveBeenCalledWith(false)
#       it 'should checkLength of value if value length is greater than or equals to four it will call toggleAcMenus with true function', ->
#         spyOn(@scope, "toggleAcMenus")
#         @scope.checkLength("abcd")
#         expect(@scope.toggleAcMenus).toHaveBeenCalledWith(true)
#       it 'should checkLength of value if value length is less than or to four it will call toggleAcMenus with false function', ->
#         spyOn(@scope, "toggleAcMenus")
#         @scope.checkLength("abc")
#         expect(@scope.toggleAcMenus).toHaveBeenCalledWith(false)

#     describe '#loadInvoice', ->
#       it 'should set value in a variable and call DAServices ledgerset method and set value in localStorageService and call getTemplates function', ->
#         data = {}
#         acData = {uniqueName: "name"}
#         spyOn(@DAServices, "LedgerSet")
#         spyOn(@localStorageService, "set")
#         spyOn(@scope, "getTemplates")
#         @scope.loadInvoice(data, acData)
        
#         expect(@DAServices.LedgerSet).toHaveBeenCalledWith(data, acData)
#         expect(@localStorageService.set).toHaveBeenCalledWith("_ledgerData", data)
#         expect(@localStorageService.set).toHaveBeenCalledWith("_selectedAccount", acData)
#         expect(@scope.getTemplates).toHaveBeenCalled()

#     describe '#getTemplates', ->
#       it 'should call companyServices getTemplates method with uniqueName', ->
#         @rootScope.selectedCompany=
#           uniqueName: "12345"
#         deferred = @q.defer()
#         spyOn(@companyServices, 'getInvTemplates').andReturn(deferred.promise)
#         @scope.getTemplates()
#         expect(@companyServices.getInvTemplates).toHaveBeenCalledWith(@rootScope.selectedCompany.uniqueName)

#     describe '#getTemplatesSuccess', ->
#       it 'should show error message with toastr', ->
#         res =
#           status: "success"
#           body:
#             templates: []
#             templateData: {}
#         @scope.getTemplatesSuccess(res)
#         expect(@scope.invoiceLoadDone).toBeTruthy()
#         expect(@scope.templateList).toEqual([])
#         expect(@scope.templateData).toEqual({})

#     describe '#getTemplatesFailure', ->
#       it 'should show error message with toastr', ->
#         res =
#           data:
#             status: "error"
#             message: "message"
#         spyOn(@toastr, "error")
#         @scope.getTemplatesFailure(res)
#         expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)


#     describe '#setDefTemp', ->
#       it 'should call companyServices setDefltInvTemplt method with uniqueName', ->
#         data=
#           isDefault: true
#           uniqueName: "abc"

#         @rootScope.selectedCompany=
#           uniqueName: "12345"

#         obj = 
#           uniqueName: @rootScope.selectedCompany.uniqueName
#           tempUname: data.uniqueName

#         deferred = @q.defer()
#         spyOn(@companyServices, 'setDefltInvTemplt').andReturn(deferred.promise)

#         @scope.setDefTemp(data)
#         expect(@companyServices.setDefltInvTemplt).toHaveBeenCalledWith(obj)

#       it 'should not call companyServices setDefltInvTemplt method, it should show warning message with toastr and set variable false', ->
#         data=
#           isDefault: false
#           uniqueName: "abc"

#         @rootScope.selectedCompany=
#           uniqueName: "12345"

#         obj = 
#           uniqueName: @rootScope.selectedCompany.uniqueName
#           tempUname: data.uniqueName

#         deferred = @q.defer()
#         spyOn(@companyServices, 'setDefltInvTemplt').andReturn(deferred.promise)
#         spyOn(@toastr, "warning")

#         @scope.setDefTemp(data)
#         expect(@companyServices.setDefltInvTemplt).not.toHaveBeenCalledWith(obj)
#         expect(@toastr.warning).toHaveBeenCalledWith("You have to select atleast one template", "Warning")
#         expect(data.isDefault).toBeTruthy()

#     describe '#switchTempData', ->
#       it 'should go in if condition make variable false and set data in scope variable, and call convertIntoOur function', ->

#         spyOn(@scope, "convertIntoOur")
#         @scope.defTempData = {}
#         @scope.templateData = {name:"abc"}
#         @scope.tempDataDef = {name:"xyz"}
#         @scope.withSampleData = true
#         @scope.switchTempData()

#         expect(@scope.withSampleData).toBeFalsy()
#         expect(@scope.defTempData).toEqual({name:"abc"})
#         expect(@scope.convertIntoOur).toHaveBeenCalledWith()

#       it 'should go in else conditon and make variable true and set data in scope variable, and call convertIntoOur function', ->

#         spyOn(@scope, "convertIntoOur")
#         @scope.defTempData = {}
#         @scope.templateData = {name:"abc"}
#         @scope.tempDataDef = {name:"xyz"}
#         @scope.withSampleData = false
#         @scope.switchTempData()

#         expect(@scope.withSampleData).toBeTruthy()
#         expect(@scope.defTempData).toEqual({name:"xyz"})
#         expect(@scope.convertIntoOur).toHaveBeenCalled()

#     describe '#viewInvTemplate', ->
#       it 'should set some variables and check conditon and call a function and then open modal', ->
#         data=
#           name:"abc"
#         mode = "edit"
#         template=
#           isDefault: true
#           name: "Alpha"
#           uniqueName: "alpha"
#           sections: {}

#         modalData = {
#           templateUrl: '/public/webapp/views/prevInvoiceTemp.html',
#           size: "a4",
#           backdrop: 'static',
#           scope: @scope
#         }
#         deferred = @q.defer()
#         spyOn(@uibModal, 'open').andReturn({result: deferred.promise})
#         spyOn(@scope, "convertIntoOur")

#         @scope.viewInvTemplate(template, mode, data)

#         expect(@uibModal.open).toHaveBeenCalledWith(modalData)
#         expect(@scope.defTempData).toEqual(data)
#         expect(@scope.convertIntoOur).toHaveBeenCalled()
#         expect(@scope.editMode).toBeTruthy()
#         expect(@scope.tempSet).toEqual({})
#         expect(@scope.logoWrapShow).toBeFalsy()
#         expect(@scope.logoUpldComplt).toBeFalsy()
#         expect(@scope.genPrevMode).toBeFalsy()

#     describe '#uploadLogo', ->
#       it 'should call Upload service with file and make a variable truthy', ->
#         @rootScope.selectedCompany=
#           uniqueName: "12345"
#         files = [{ 
#           fieldname: 'file',
#           originalname: 'logo.png',
#           encoding: '7bit',
#           mimetype: 'image',
#           destination: './uploads/',
#           filename: 'logo.png',
#           path: 'uploads/logo.png',
#           size: 12034 
#         }]
        
#         deferred = @q.defer()
#         spyOn(@Upload, "upload").andReturn(deferred.promise)

#         @scope.uploadLogo(files)
#         expect(@scope.logoUpldComplt).toBeTruthy()
#         expect(@Upload.upload).toHaveBeenCalled()
#         expect(angular.forEach).toBeDefined()

#     describe '#resetLogo', ->
#       it 'should make a variable falsy',->
#         @scope.resetLogo()
#         expect(@scope.logoUpldComplt).toBeFalsy()

#     describe '#showUploadWrap', ->
#       it 'should make a variable falsy',->
#         @scope.showUploadWrap()
#         expect(@scope.logoWrapShow).toBeTruthy()

#     describe '#convertIntoOur', ->
#       it 'should convert things according to our conditions by using some regex',->
#         @scope.defTempData=
#           company:
#             "data": "405-406 Capt. C.S. Naidu Arcade,10/2 Old Palasiya,Indore Madhya Pradesh,CIN: 02830948209,Email: account@giddh.com"
          
#           companyIdentities:
#             "data": "Tin No: 1978273,PAN: 2o009390,Dude"
#           terms: [
#             "Bank Details ICICI- Ac/no 1228309",
#             "In case there are some changes to be made  kindly update it on the panel and mail us at accounts@giddh.com"
#           ]

#         result=
#           company:
#             "data": "405-406 Capt. C.S. Naidu Arcade\n10/2 Old Palasiya\nIndore Madhya Pradesh\nCIN: 02830948209\nEmail: account@giddh.com"
#           companyIdentities:
#             "data": "Tin No: 1978273\nPAN: 2o009390\nDude"
#           termsStr: "Bank Details ICICI- Ac/no 1228309\nIn case there are some changes to be made  kindly update it on the panel and mail us at accounts@giddh.com"
        
#         @scope.convertIntoOur()
#         expect(@scope.defTempData.company.data).toEqual(result.company.data)
#         expect(@scope.defTempData.companyIdentities.data).toEqual(result.companyIdentities.data)
#         expect(@scope.defTempData.termsStr).toEqual(result.termsStr)

#     describe '#saveTemp', ->
#       xit '',->


#     describe '#saveTempSuccess', ->
#       it 'should make variable falsy and set data in a variable and call toastr success method',->
#         res=
#           status: "success"
#           body:
#             logo: "123"
#             company:
#               "data": ""
#             companyIdentities:
#               "data": ""
#             terms: []
        
#         abc=
#           company:
#             "data": ""
#           companyIdentities:
#             "data": ""
#           terms: []
#         @scope.modalInstance = {}
#         @scope.modalInstance = @uibModal.open(templateUrl: '/')
#         @scope.templateData = {}
#         spyOn(@toastr, "success")
#         spyOn(@scope.modalInstance, "close")
#         @scope.saveTempSuccess(res)
#         expect(@scope.updatingTempData).toBeFalsy()
#         expect(@scope.templateData).toEqual(abc)
#         expect(@toastr.success).toHaveBeenCalledWith("Template updated successfully", "Success")
#         expect(@scope.modalInstance.close).toHaveBeenCalled()

#     describe '#saveTempFailure', ->
#       it 'should show error message with toastr', ->
#         res =
#           data:
#             status: "error"
#             message: "message"
#         spyOn(@toastr, "error")
#         @scope.saveTempFailure(res)
#         expect(@scope.updatingTempData).toBeFalsy()
#         expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#     describe '#genInvoiceSuccess', ->
#       it 'should make variable falsy and empty a array var and call modal close and show message with toastr success',->
#         res=
#           status: "success"
#           body: "Invoice generated successfully with invoice number: #####"
#         @scope.entriesForInvoice=[
#           {
#             id: "12345"
#           }
#         ]
#         @scope.onlyDrData= [
#           {
#             id: "12311"
#           }
#           {
#             id: "12335"
#           }
#           {
#             id: "12345"
#           }
#         ]
#         @scope.modalInstance = {}
#         @scope.modalInstance = @uibModal.open(templateUrl: '/')
#         spyOn(@toastr, "success")
#         spyOn(@scope.modalInstance, "close")

#         @scope.genInvoiceSuccess(res)

#         expect(@scope.updatingTempData).toBeFalsy()
        
#         expect(@toastr.success).toHaveBeenCalledWith(res.body, "Success")
#         expect(@scope.modalInstance.close).toHaveBeenCalled()
#         expect(@scope.entriesForInvoice).toEqual([])

#     describe '#genInvoiceFailure', ->
#       it 'should show error message with toastr and make a variable falsy and go in else condition', ->
#         res=
#           data:
#             code: "other"
#             message: "some message"
#             status: "error"

#         spyOn(@toastr, "error")
#         @scope.genInvoiceFailure(res)
#         expect(@scope.updatingTempData).toBeFalsy()
#         expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#       it 'should go in if condition', ->
#         res=
#           data:
#             code: "INVALID_TAX"
#             message: "some message"
#             status: "error"
#         obj=
#           title: 'Something wrong with your invoice data',
#           body: res.data.message+'\\n Do you still want to generate invoice with incorrect data.',
#           ok: 'Generate Anyway',
#           cancel: 'Cancel'

#         deferred = @q.defer()
#         spyOn(@modalService, 'openConfirmModal').andReturn(deferred.promise)
#         @scope.genInvoiceFailure(res)
#         expect(@scope.updatingTempData).toBeFalsy()
#         expect(@modalService.openConfirmModal).toHaveBeenCalledWith(obj)

#     describe '#getLedgerEntries', ->
#       it 'should call ledgerService getLedger method with uniqueName', ->

#         @rootScope.selectedCompany=
#           uniqueName: "12345"
#         @rootScope.$stateParams=
#           invId: "def"
#         @scope.dateData=
#           fromDate: "01-02-2016"
#           toDate: "01-04-2016"

#         obj = {
#           compUname: @rootScope.selectedCompany.uniqueName
#           acntUname: @rootScope.$stateParams.invId
#           fromDate: @scope.dateData.fromDate
#           toDate: @scope.dateData.toDate
#         }

#         deferred = @q.defer()
#         spyOn(@ledgerService, 'getLedger').andReturn(deferred.promise)

#         @scope.getLedgerEntries()
#         expect(@ledgerService.getLedger).toHaveBeenCalledWith(obj)
        
#     describe '#getLedgerEntriesSuccess', ->
#       it 'should set a variable true and push value in onlyDrData', ->
#         res = {
#           status: "success"
#           body: {
#             ledgers: []
#           }
#         }
#         @scope.getLedgerEntriesSuccess(res)
#         expect(@scope.onlyDrData).toEqual(_.omit(res.body, 'ledgers') )
#         expect(@scope.noDataDR).toBeTruthy()

#     describe '#getLedgerEntriesFailure', ->
#       it 'should show error message with toastr', ->
#         res =
#           data:
#             status: "error"
#             message: "message"
#         spyOn(@toastr, "error")
#         @scope.getLedgerEntriesFailure(res)
#         expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#     describe '#summationForInvoice', ->
#       xit 'should',->

#     describe '#prevAndGenInv', ->
#       it 'should call accountService prevInvoice method with obj and data',->
#         @scope.entriesForInvoice=[
#           {
#             id: "123"
#             sharedData:
#               uniqueName: "123"
#           }
#           {
#             id: "1234"
#             sharedData:
#               uniqueName: "1234"
#           }
#           {
#             id: "123"
#             sharedData:
#               uniqueName: "123"
#           }
#         ]
#         @rootScope.selectedCompany=
#           uniqueName: "12345"
#         @rootScope.$stateParams=
#           invId: "def"
#         obj = {
#           compUname: @rootScope.selectedCompany.uniqueName
#           acntUname: @rootScope.$stateParams.invId
#         }
#         result=
#           uniqueNames: ["123", "1234"]

#         deferred = @q.defer()
#         spyOn(@accountService, 'prevInvoice').andReturn(deferred.promise)
#         @scope.prevAndGenInv()
#         expect(@accountService.prevInvoice).toHaveBeenCalledWith(obj, result)
#         expect(@scope.genMode).toBeTruthy()
#         expect(@scope.prevInProg).toBeTruthy()


#     describe '#prevAndGenInvSuccess', ->
#       it 'should call viewInvTemplate function and make a variable falsy',->
#         res=
#           body:
#             template: {}
#             templateData: {}
#         spyOn(@scope, "viewInvTemplate")
#         @scope.prevAndGenInvSuccess(res)
#         expect(@scope.prevInProg).toBeFalsy()
#         expect(@scope.viewInvTemplate).toHaveBeenCalledWith(res.body.template, 'edit', res.body)

#     describe '#prevAndGenInvFailure', ->
#       it 'should show error message with toastr', ->
#         res =
#           data:
#             status: "error"
#             message: "message"
#         spyOn(@toastr, "error")
#         @scope.prevAndGenInvFailure(res)
#         expect(@scope.prevInProg).toBeFalsy()
#         expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)


#     describe '#getInvList', ->
#       it 'should call accountService getInvList method with obj',->
#         @rootScope.selectedCompany=
#           uniqueName: "12345"
#         @rootScope.$stateParams=
#           invId: "def"
#         @scope.dateData=
#           fromDate: "01-02-2016"
#           toDate: "01-04-2016"
#         obj = {
#           compUname: @rootScope.selectedCompany.uniqueName
#           acntUname: @rootScope.$stateParams.invId
#           fromDate: @scope.dateData.fromDate
#           toDate: @scope.dateData.toDate
#         }
#         deferred = @q.defer()
#         spyOn(@accountService, 'getInvList').andReturn(deferred.promise)
#         @scope.getInvList()
#         expect(@accountService.getInvList).toHaveBeenCalledWith(obj)


#     describe '#getInvListSuccess', ->
#       it 'should set value in a variable and  make a variable falsy',->
#         res=
#           body:[
#             {
#               item: "one"
#             }
#             {
#               item: "two"
#             }
#           ]
#         @scope.getInvListSuccess(res)
#         expect(@scope.noDataGenInv).toBeFalsy()
#         expect(@scope.genInvList).toEqual(res.body)

#       it 'should set value in a variable and  make a variable truthy',->
#         res=
#           body:[]
#         @scope.getInvListSuccess(res)
#         expect(@scope.noDataGenInv).toBeTruthy()
#         expect(@scope.genInvList).toEqual(res.body)

#     describe '#getInvListFailure', ->
#       it 'should show error message with toastr', ->
#         res =
#           data:
#             status: "error"
#             message: "message"
#         spyOn(@toastr, "error")
#         @scope.getInvListFailure(res)
#         expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#     describe '#summationForDownload', ->
#       it 'should make a variable truthy and push value in a array',->
#         entry=
#           invoiceNumber: "1234"
#         @scope.summationForDownload(entry)
#         expect(@scope.radioChecked).toBeTruthy()
#         expect(@scope.nameForAction).toEqual(["1234"])

#     describe '#sendInvEmail', ->
#       xit 'should call accountService mailInvoice method with some rough filters',->
#         @rootScope.validateEmail=()->
#           return true
#         emailData = "abc@xyz.com, xzy@abc.in"
#         @scope.nameForAction= ["1234"]
#         @rootScope.selectedCompany=
#           uniqueName: "12345"
#         @rootScope.$stateParams=
#           invId: "def"
#         obj=
#           compUname: @rootScope.selectedCompany.uniqueName
#           acntUname: @rootScope.$stateParams.invId
#         data=
#           emailId: ["abc@xyz.com", "xzy@abc.in"]
#           invoiceNumber: @scope.nameForAction

#         deferred = @q.defer()
#         spyOn(@accountService, 'mailInvoice').andReturn(deferred.promise)
#         spyOn(@rootScope, "validateEmail")
#         @scope.sendInvEmail(emailData)
#         expect(@accountService.downloadInvoice).toHaveBeenCalledWith(obj, data)
#         expect(@rootScope.validateEmail).toHaveBeenCalled()

#     describe '#sendInvEmailSuccess', ->
#       it 'should show message with toastr and blank a obj',->
#         res=
#           status: "success"
#           body: "hey"
#         @scope.InvEmailData=
#           inv: "1234" 
#         spyOn(@toastr, "success")
#         @scope.sendInvEmailSuccess(res)
#         expect(@scope.InvEmailData).toEqual({})
#         expect(@toastr.success).toHaveBeenCalledWith("Email sent successfully", "Success")

#     describe '#multiActionWithInv', ->
#       it 'should check if array length is 0 then call toastr warning method and andReturn falsy',->
#         @scope.nameForAction=[]
#         spyOn(@toastr, "warning")
#         @scope.multiActionWithInv("edit")
#         expect(@toastr.warning).toHaveBeenCalledWith("Something went wrong", "Warning")
      
#       it 'should check type and call companyServices delInv method with obj', ->
#         @scope.nameForAction= ["1234", "2345"]
#         @rootScope.selectedCompany=
#           uniqueName: "12345"
#         @rootScope.$stateParams=
#           invId: "def"
#         obj = {
#           compUname: @rootScope.selectedCompany.uniqueName
#           acntUname: @rootScope.$stateParams.invId
#           invoiceUniqueID: @scope.nameForAction[0]
#         }
#         deferred = @q.defer()
#         spyOn(@companyServices, 'delInv').andReturn(deferred.promise)
#         @scope.multiActionWithInv("delete")
#         expect(@companyServices.delInv).toHaveBeenCalledWith(obj)

#       it 'should check type and call accountService downloadInvoice method with obj', ->
#         @scope.nameForAction= ["1234", "2345"]
#         @rootScope.selectedCompany=
#           uniqueName: "12345"
#         @rootScope.$stateParams=
#           invId: "def"
#         obj=
#           compUname: @rootScope.selectedCompany.uniqueName
#           acntUname: @rootScope.$stateParams.invId
#         data=
#           invoiceNumber: @scope.nameForAction
#           template: ""
#         deferred = @q.defer()
#         spyOn(@accountService, 'downloadInvoice').andReturn(deferred.promise)
#         @scope.multiActionWithInv("download")
#         expect(@accountService.downloadInvoice).toHaveBeenCalledWith(obj, data)

#     describe '#multiActionWithInvFailure', ->
#       it 'should show error message with toastr', ->
#         res =
#           data:
#             status: "error"
#             message: "message"
#         spyOn(@toastr, "error")
#         @scope.multiActionWithInvFailure(res)
#         expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#     describe '#delInvSuccess', ->
#       it 'should call toastr success method, make variable falsy blank a array and call getInvList function',->
#         res=
#           status: "success"
#           body: ""

#         @scope.nameForAction = ["1234"]
#         spyOn(@scope, "getInvList")
#         spyOn(@toastr, "success")
#         @scope.delInvSuccess(res)
#         expect(@toastr.success).toHaveBeenCalledWith("Invoice deleted successfully", "Success")
#         expect(@scope.radioChecked).toBeFalsy()
#         expect(@scope.nameForAction).toEqual([])
#         expect(@scope.getInvList).toHaveBeenCalled()

#     describe '#downInvSuccess', ->
#       xit '',->

#     describe '#prevGenerateInv', ->
#       it 'should call accountService prevOfGenInvoice method with obj',->
#         item=
#           invoiceNumber: "1234"
#         @rootScope.selectedCompany=
#           uniqueName: "12345"
#         @rootScope.$stateParams=
#           invId: "def"
#         obj=
#           compUname: @rootScope.selectedCompany.uniqueName
#           acntUname: @rootScope.$stateParams.invId
#           invoiceUniqueID: item.invoiceNumber
#         deferred = @q.defer()
#         spyOn(@accountService, 'prevOfGenInvoice').andReturn(deferred.promise)
#         @scope.prevGenerateInv(item)
#         expect(@accountService.prevOfGenInvoice).toHaveBeenCalledWith(obj)
#         expect(@scope.nameForAction).toEqual([item.invoiceNumber])

#     describe '#prevGenerateInvSuccess', ->
#       it 'should make variable truthy, call viewInvTemplate function and assign value in a variable',->
#         @scope.tempType=
#           uniqueName: "123"
#         res=
#           body:
#             templateData: {}
#             template:
#               uniqueName: "alpha"
#         spyOn(@scope, "viewInvTemplate")
#         @scope.prevGenerateInvSuccess(res)
#         expect(@scope.genPrevMode).toBeTruthy()
#         expect(@scope.viewInvTemplate).toHaveBeenCalledWith(res.body.template, 'genprev', res.body)
#         expect(@scope.tempType.uniqueName).toEqual(res.body.template.uniqueName)

#     describe '#prevGenerateInvFailure', ->
#       it 'should show error message with toastr', ->
#         res =
#           data:
#             status: "error"
#             message: "message"
#         spyOn(@toastr, "error")
#         @scope.prevGenerateInvFailure(res)
#         expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#     describe '#setDiffView', ->
#       it 'should check and assign value in variable',->
#         @scope.templateList=[
#           {
#             uniqueName: "alpha"
#             sections:
#               logo: true
#           }
#           {
#             uniqueName: "beta"
#             sections:
#               logo: false
#           }
#         ]
#         result=
#           sections:
#             logo: true

#         @scope.tempType=
#           uniqueName: "alpha"
#         @scope.setDiffView()
#         expect(@scope.tempSet).toEqual(result.sections)

#     describe '#downInv', ->
#       it 'should call accountService downloadInvoice method with obj and data',->
#         @scope.tempType=
#           uniqueName: "alpha"
#         @scope.nameForAction= ["1234", "2345"]
#         @rootScope.selectedCompany=
#           uniqueName: "12345"
#         @rootScope.$stateParams=
#           invId: "def"
#         obj=
#           compUname: @rootScope.selectedCompany.uniqueName
#           acntUname: @rootScope.$stateParams.invId
#         data=
#           invoiceNumber: @scope.nameForAction
#           template: @scope.tempType.uniqueName
#         deferred = @q.defer()
#         spyOn(@accountService, 'downloadInvoice').andReturn(deferred.promise)
#         @scope.downInv()
#         expect(@accountService.downloadInvoice).toHaveBeenCalledWith(obj, data)

    



















