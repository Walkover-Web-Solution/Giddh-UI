"use strict"
invoiceController = ($scope, $rootScope, $filter, $uibModal, $timeout, toastr, localStorageService, groupService, DAServices,  Upload, ledgerService) ->

  $rootScope.selectedCompany = {}
  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
  # invoice setting
  $scope.withSampleData = true
  $scope.logoUpldComplt = false
  $scope.showAccountList = true
  $scope.invoiceLoadDone = true
  # default Template data
  $scope.tempDataDef=
    sectionContent:
      one:
        imgPath: "/public/website/images/logo.png"
        logoUploaded: true
      two:
        date: "11-12-2016"
        invNo: "00123"
      
      three:
        firmName: "Walkover Web Solutions Pvt. ltd."
        data: "405-406 Capt. C.S. Naidu Arcade\n10/2 Old Palasiya\nIndore Madhya Pradesh\nCIN: 02830948209eeri\nEmail: account@giddh.com"
      
      four:
        firmName: "Career Point Ltd."
        data: "CP Tower Road No. 1\nIndraprashta Industrial Kota\nPAN: 1862842\nEmail: info@career.com"
      
      five:
        data: undefined
      
      six:
        data: "TIN: 14242422\nPAN: kaljfljie"
      
      seven:
        firmName: "Walkover Web Solutions Pvt. ltd."
        data: "Authorise Signatory"
      
      eight:
        data: [
          "Lorem ipsum dolor sit amet, consectetur adipisicing elit",
          "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
          "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
        ]
  # invoice setting end

  # datepicker setting end
  $scope.dateData = {
    fromDate: new Date(moment().subtract(3, 'month').utc())
    toDate: new Date()
  }
  $scope.dateOptions = {
    'year-format': "'yy'",
    'starting-day': 1,
    'showWeeks': false,
    'show-button-bar': false,
    'year-range': 1,
    'todayBtn': false
  }
  $scope.format = "dd-MM-yyyy"
  $scope.today = new Date()
  $scope.fromDatePickerIsOpen = false
  $scope.toDatePickerIsOpen = false
  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true
  # end of date picker
  $scope.showInvLoader= true

  # end of page load varialbles

  $scope.getAllGroupsWithAcnt=()->
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      # with accounts, group data
      groupService.getGroupsWithAccountsCropped($rootScope.selectedCompany.uniqueName).then($scope.makeAccountsList, $scope.makeAccountsListFailure)
      # without accounts only groups conditionally
      cData = localStorageService.get("_selectedCompany")
      if cData.sharedEntity is 'accounts'
        console.info "sharedEntity:"+ cData.sharedEntity
      else
        groupService.getGroupsWithoutAccountsCropped($rootScope.selectedCompany.uniqueName).then($scope.getGroupListSuccess, $scope.getGroupListFailure)

  $scope.makeAccountsList = (res) ->
    # flatten all groups with accounts and only accounts flatten
    item = {
      name: "Current Assets"
      uniqueName:"current_assets"
    }
    result = groupService.matchAndReturnGroupObj(item, res.body)
    $rootScope.flatGroupsList = groupService.flattenGroup([result], [])
    $scope.flatAccntWGroupsList = groupService.flattenGroupsWithAccounts($rootScope.flatGroupsList)

    # b = groupService.flattenAccount(a)
    # $rootScope.makeAccountFlatten(b)
    # $scope.flattenGroupList = groupService.makeGroupListFlatwithLessDtl($rootScope.flatGroupsList)
    $rootScope.canChangeCompany = true
    $scope.showAccountList = true
    console.log $scope

  $scope.makeAccountsListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)


  #Expand or  Collapse all account menus
  $scope.toggleAcMenus = (state) ->
    if !_.isEmpty($scope.flatAccntWGroupsList)
      _.each($scope.flatAccntWGroupsList, (e) ->
        e.open = state
        $scope.showSubMenus = state
      )

  # trigger expand or collapse func
  $scope.checkLength = (val)->
    if val is '' || _.isUndefined(val)
      $scope.toggleAcMenus(false)
    else if val.length >= 4
      $scope.toggleAcMenus(true)
    else
      $scope.toggleAcMenus(false)
  # end acCntrl

  $scope.loadInvoice = (data, acData) ->
    $scope.selectedAccountUniqueName = acData.uniqueName
    DAServices.LedgerSet(data, acData)
    localStorageService.set("_ledgerData", data)
    localStorageService.set("_selectedAccount", acData)
    # show invoice page
    $scope.invoiceLoadDone = true
    $scope.getTemplates()


  $scope.getTemplates = ()->
    res =
      body:
        templates:[ 
          {
            uniqueName: "alpha"
            name: "Alpha"
            isDefault: true
            sections:
              one: true
              two: true
              three: true
              four: true
              five: true
              six: true
              seven: true
              eight: true
          }
          {
            uniqueName: "winterfall"
            name: "Winter Fall"
            isDefault: false
            sections:
              one: false
              two: false
              three: true
              four: true
              five: true
              six: true
              seven: true
              eight: false
          }
        ]            
        templateData:
          sectionContent:
            one:
              imgPath: "/public/website/images/logo.png"
              logoUploaded: true
            two:
              date: ""
              invNo: ""
            three:
              firmName: "Walkover Technologies"
              data: "505 Capt. C.S. Naidu Arcade\n10/2 Old Palasiya\nIndore Madhya Pradesh\nCIN: 02830948209eeri\nEmail: account@giddh.com"
            four:
              firmName: ""
              data: ""
            five:
              data: undefined
            six:
              data: "TIN: 14242422\nPAN: kaljfljie"
            seven:
              firmName: "Walkover Technologies Pvt. ltd."
              data: "Authorised Signatory"
            eight:
              # comma separated values in array
              data: []

        
      
    $scope.templateList = res.body.templates
    $scope.templateData = res.body.templateData

  # switch sample data with original data
  $scope.switchTempData=()->
    console.log "switch"
    if $scope.withSampleData
      $scope.withSampleData = false
      _.extend($scope.defTempData , $scope.templateData)
    else
      $scope.withSampleData = true
      _.extend($scope.defTempData , $scope.tempDataDef)

  # view template with sample data
  $scope.viewInvTemplate =(template, mode) ->
    # set mode
    $scope.editMode = if mode is 'edit' then true else false
    $scope.tempSet = template
    $scope.defTempData = {}
    if $scope.editMode
      _.extend($scope.defTempData , $scope.templateData)
    else
      _.extend($scope.defTempData , $scope.tempDataDef)


    # open dialog
    modalInstance = $uibModal.open(
      templateUrl: '/public/webapp/views/prevInvoiceTemp.html'
      size: "liq100"
      backdrop: 'static'
      scope: $scope
    )
    modalInstance.result.then($scope.viewInvTemplateOpen, $scope.viewInvTemplateClose)

  $scope.viewInvTemplateOpen = (res) ->
    console.log "opened", res
  
  $scope.viewInvTemplateClose = () ->
    console.log "close"

  # set as default
  $scope.setAsDefaultTemplate = (data) ->
    console.log data, "setAsDefaultTemplate"

  # add New term
  $scope.addNewTerm=(term)->
    console.log term
    # $scope.defTempData.sectionContent.eight.data.push(term)

  # upload logo
  $scope.uploadLogo=(files)->
    console.log files,  "uploadLogo"
    $scope.logoUpldComplt = true
    angular.forEach files, (file) ->
      file.upload = Upload.upload(
        url: '/upload/' + $rootScope.selectedCompany.uniqueName + '/logo'
        file: file
      )
      file.upload.then ((res) ->
        $timeout ->
          console.log res, "success"
          toastr.success("Logo Uploaded Successfully", res.data.status)
      ), ((res) ->
        console.log res, "error"
        toastr.warning("Something went wrong", "warning")
      ), (evt) ->
        console.log "file upload progress" ,Math.min(100, parseInt(100.0 * evt.loaded / evt.total))

  # reset Logo
  $scope.resetLogo=()->
    $scope.logoUpldComplt = false

  # save template data
  $scope.saveTemp=()->
    console.log $scope.defTempData


  # $scope.openWin=()->
  #   myWindow=window.open('','','width=595,height=742')
  #   myWindow.document.write()
  #   myWindow.focus()
  #   print(myWindow)

  # init func on dom ready
  # $scope.getAllGroupsWithAcnt()
  $scope.getTemplates()

  

  # invoice setting end

  # get ledger entries to generate invoice
  $scope.getLedgerEntries=()->
    $scope.showInvLoader= true
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $rootScope.$stateParams.invId
      fromDate: $filter('date')($scope.dateData.fromDate, "dd-MM-yyyy")
      toDate: $filter('date')($scope.dateData.toDate, "dd-MM-yyyy")
    }
    ledgerService.getLedger(unqNamesObj).then($scope.getLedgerEntriesSuccess, $scope.getLedgerEntriesFailure)

  $scope.getLedgerEntriesSuccess=(res)->
    console.log "getLedgerEntriesSuccess:" ,res
    $scope.onlyCrData = []
    $scope.onlyDrData = []
    _.each(res.body.ledgers, (ledger) ->
      if ledger.transactions.length > 1
        ledger.multiEntry = true
      else
        ledger.multiEntry = false
      sharedData = _.omit(ledger, 'transactions')
      _.each(ledger.transactions, (transaction, index) ->
        transaction.amount = parseFloat(transaction.amount).toFixed(2)
        newEntry = {sharedData: sharedData}
        newEntry.id = sharedData.uniqueName + "_" + index
        if transaction.type is "DEBIT"
          newEntry.transactions = [transaction]
          $scope.onlyDrData.push(newEntry)

        if transaction.type is "CREDIT"
          newEntry.transactions = [transaction]
          $scope.onlyCrData.push(newEntry)
      )
    )
    console.log $scope.onlyCrData
    console.log $scope.onlyDrData
    $scope.showInvLoader= false

  $scope.getLedgerEntriesFailure=(res)->
    console.log "getLedgerEntriesFailure: ", res

  $scope.entriesForInvoice = []

  $scope.summationForInvoice=(ths, entry, index)->
    console.log ths, entry, index
    if entry.sharedData.multiEntry
      if ths
        # create logic to select all multi Entries
        _.each($scope.onlyCrData, (item)->
          if item.sharedData.uniqueName is entry.sharedData.uniqueName
            item.sharedData.itemCheck = true
            $scope.entriesForInvoice.push(item)
            console.log item
        )
      else
        $scope.entriesForInvoice = _.reject($scope.entriesForInvoice, (item) ->
          entry.id is item.id
        )
    else
      if ths
        $scope.entriesForInvoice.push(entry)
      else
        $scope.entriesForInvoice = _.reject($scope.entriesForInvoice, (item) ->
          entry.id is item.id
        )

    console.log $scope.entriesForInvoice.length

  # end get ledger entries to generate invoice
























#init angular app
giddh.webApp.controller 'invoiceController', invoiceController