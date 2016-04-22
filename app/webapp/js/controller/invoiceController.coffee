"use strict"
invoiceController = ($scope, $rootScope, $filter, toastr,  localStorageService, groupService, DAServices, $uibModal) ->

  $rootScope.selectedCompany = {}
  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")

  console.log "Hey invoiceController", $rootScope

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
            isDefault: false
            sections:[
              {
                name: "one"
                visible: true
              }
              {
                name: "two"
                visible: true
              }
              {
                name: "three"
                visible: true
              }
              {
                name: "four"
                visible: true
              }
              {
                name: "five"
                visible: true
              }
              {
                name: "six"
                visible: true
              }
              {
                name: "seven"
                visible: true
              }
              {
                name: "eight"
                visible: true
              }
            ]
          }
          {
            uniqueName: "winterfall"
            name: "Winter Fall"
            isDefault: false
            sections:[
              {
                name: "one"
                visible: false
              }
              {
                name: "two"
                visible: false
              }
              {
                name: "three"
                visible: true
              }
              {
                name: "four"
                visible: true
              }
              {
                name: "five"
                visible: true
              }
              {
                name: "six"
                visible: true
              }
              {
                name: "seven"
                visible: true
              }
              {
                name: "eight"
                visible: false
              }
            ]
          }
        ]            
        templateData:
          sectionContent:[
            {
              name: "one"
              imgPath: "/public/website/images/logo.png"
            }
            {
              name: "two"
              data:
                date: "11-12-2016"
                invNo: "00123"
            }
            {
              name: "three"
              data:
                firmName: "Walkover Web Solutions Pvt. ltd."
                otherDetails: "405-406 Capt. C.S. Naidu Arcade\n10/2 Old Palasiya\nIndore Madhya Pradesh\nCIN: 02830948209eeri\nEmail: account@giddh.com"
            }
            {
              name: "four"
              data:
                firmName: "Career Point Ltd."
                otherDetails: "CP Tower Road No. 1\nIndraprashta Industrial Kota\nPAN: 1862842\nEmail: info@career.com"
            }
            {
              name: "five"
              data: ""
            }
            {
              name: "six"
              data: "TIN: 14242422\nPAN: kaljfljie"
            }
            {
              name: "seven"
              data:
                firmName: "Walkover Web Solutions Pvt. ltd."
                otherDetails: "Authorise Signatory"
            }
            {
              name: "eight"
              data: [
                {
                  term: "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
                }
                {
                  term: "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
                }
                {
                  term: "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
                }
              ]
            }
          ]
        
      
    $scope.templateList = res.body.templates
    $scope.templateData = res.body.templateData

    console.log $scope.templateList
    console.log $scope.templateData


  $scope.viewInvTemplate =(mode) ->
    # set mode
    $scope.editMode = if mode is 'edit' then true else false
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

  $scope.openWin=()->
    myWindow=window.open('','','width=595,height=742')
    myWindow.document.write()
    myWindow.focus()
    print(myWindow)

  # init func on dom ready
  # $scope.getAllGroupsWithAcnt()
  $scope.showAccountList = true
  $scope.invoiceLoadDone = true
  $scope.getTemplates()

  # what i get
  
  # what i send
  data = {
    templateData:{
      sectionContent:[
        {
          name: "one"
          data: "405 Cs naidu arcade near great"
        }
      ]
    }
    template:{
      uniqueName: "winterfall"
      name: "Winter Fall"
      isDefault: false
      sections:[
        {
          name: "one"
          visible: false
        }
        {
          name: "two"
          visible: false
        }
      ]
    }
  }


#init angular app
giddh.webApp.controller 'invoiceController', invoiceController