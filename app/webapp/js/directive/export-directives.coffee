angular.module('exportDirectives', [])
.directive('exportPdfaccountwise', [
  '$rootScope'
  '$compile'
  '$filter'
  ($rootScope, $compile, $filter) ->
    {
      restrict: 'A'
      link: (scope, elem, attr) ->
  
        elem.on 'click', (e) ->
          
          pdf = new jsPDF('p','pt')
          groups = []
          accounts = []
          childGroups = []
          rawData = scope.data.groupDetails
          companyDetails = $rootScope.selectedCompany

          rawData = scope.data.groupDetails

          _.each rawData, (obj) ->
            group = {}
            group.Name = obj.groupName
            #group.openingBalance = obj.forwardedBalance.amount
            group.Credit = obj.creditTotal
            group.Debit = obj.debitTotal
            group.ClosingBalance = obj.closingBalance.amount
            #group.accounts = obj.accounts
            #group.childGroups = obj.childGroups
            groups.push group


          sortChildren = (parent) ->
            #push account to accounts if accounts.length > 0
            _.each parent, (obj) ->
              if obj.accounts.length > 0
                _.each obj.accounts, (acc) ->
                  account = {}
                  account.name = acc.name
                  account.openingBalance = acc.openingBalance.amount + $filter('recType')(acc.openingBalance.type, acc.openingBalance.amount)
                  account.openingBalanceType = acc.openingBalance.type + $filter('recType')(acc.closingBalance.type, acc.openingBalance.amount)
                  account.credit = acc.creditTotal
                  account.debit = acc.debitTotal
                  account.closingBalance = acc.closingBalance.amount
                  account.closingBalanceType = acc.closingBalance.type
                  accounts.push account

            #push childgroup to childGroups if childGroups.length > 0
            _.each parent, (obj) ->
              if obj.childGroups.length > 0
                _.each obj.childGroups, (chld) ->
                  childGroup = {}
                  childGroup.name = chld.groupName
                  childGroup.credit = chld.creditTotal
                  childGroup.debit = chld.debitTotal
                  childGroup.closingBalance = chld.closingBalance.amount
                  childGroups.push childGroup

                  if chld.accounts.length > 0
                    _.each chld.accounts, (acc) ->
                      account = {}
                      account.name = acc.name
                      account.openingBalance = acc.openingBalance.amount + $filter('recType')(acc.openingBalance.type, acc.openingBalance.amount)
                      account.openingBalanceType = acc.openingBalance.type
                      account.credit = acc.creditTotal
                      account.debit = acc.debitTotal
                      account.closingBalance = acc.closingBalance.amount + $filter('recType')(acc.closingBalance.type, acc.closingBalance.amount)
                      account.closingBalanceType = acc.closingBalance.type
                      accounts.push account

                  if chld.childGroups.length > 0
                    _.each chld.childGroups, (obj) ->
                      group = {}
                      group.Name = obj.groupName
                      #group.openingBalance = obj.forwardedBalance.amount
                      group.Credit = obj.creditTotal
                      group.Debit = obj.debitTotal
                      group.Closing - Balance = obj.closingBalance.amount
                      group.accounts = obj.accounts
                      group.childGroups = obj.childGroups
                      groups.push group
                    sortChildren(chld.childGroups)

          sortChildren(rawData)

          columns = [
            {
              title:'Particular'
              dataKey:'name'
            }
            {
              title: 'Opening Balance'
              dataKey: 'openingBalance'
            }
            {
              title: 'Debit'
              dataKey: 'debit'
            }
            {
              title: 'Credit'
              dataKey: 'credit'
            }
            {
              title: 'Closing Balance'
              dataKey: 'closingBalance'
            }
          ]

          rows = accounts

          pdf.autoTable(columns,rows,
              theme: "plain"
              margin: {
                  top: 110
                },
              beforePageContent: () ->
                pdf.setFontSize(16)
                pdf.text(40,50,companyDetails.name)
                pdf.setFontSize(10)
                pdf.text(40,65,companyDetails.address)
                pdf.text(40,80,companyDetails.city + '-' + companyDetails.pincode)
                pdf.text(40,95, "Trial Balance: " + $filter('date')(scope.fromDate.date,'dd/MM/yyyy') + '-' + $filter('date')(scope.toDate.date,'dd/MM/yyyy'))
            )

          # write footer
          OBT = scope.data.forwardedBalance.amount.toString()
          DBT = scope.data.debitTotal.toString()
          CDT = scope.data.creditTotal.toString()
          CBT = scope.data.closingBalance.amount.toString()
          footerX = 45
          lastY = pdf.autoTableEndPosY()
          pageWidth = pdf.internal.pageSize.width - 40
          pdf.setFontSize(8)
          pdf.line(40, lastY, pageWidth, lastY)
          pdf.text(footerX,lastY+20,"Total")
          pdf.text(footerX+210, lastY+20, OBT)
          pdf.text(footerX+302, lastY+20, DBT)
          pdf.text(footerX+365, lastY+20, CDT)
          pdf.text(footerX+430, lastY+20, CBT)

          pdf.save('TrialBalance-AccountWise.pdf')
    }
])
.directive('exportPdfgroupwise', [
  '$rootScope'
  '$compile'
  '$filter'
  ($rootScope, $compile, $filter) ->
    {
      restrict: 'A'
      link: (scope, elem, attr) ->
  
        elem.on 'click', (e) ->
          pdf = new jsPDF('p','pt')
          groups = []
          rawData = scope.data.groupDetails
          companyDetails = $rootScope.selectedCompany

          _.each rawData, (obj) ->
            group = {}
            group.name = obj.groupName
            group.openingBalance = obj.forwardedBalance.amount + $filter('recType')(obj.forwardedBalance.type, obj.forwardedBalance.amount)
            #group.openingBalanceType = obj.forwardedBalance.type
            group.debit = obj.debitTotal
            group.credit = obj.creditTotal
            group.closingBalance = obj.closingBalance.amount + $filter('recType')(obj.closingBalance.type, obj.closingBalance.amount)
            #group.closingBalanceType = obj.closingBalance.type
            groups.push(group)

          columns = [
            {
              title:'Particular'
              dataKey:'name'
            }
            {
              title: 'Opening Balance'
              dataKey: 'openingBalance'
            }
            {
              title: 'Debit'
              dataKey: 'debit'
            }
            {
              title: 'Credit'
              dataKey: 'credit'
            }
            {
              title: 'Closing Balance'
              dataKey: 'closingBalance'
            }
          ]

          rows = groups
          pdf.autoTable(columns,rows,
              theme: "plain"
              margin: {
                  top: 110
                },
              beforePageContent: () ->
                pdf.setFontSize(16)
                pdf.text(40,50,companyDetails.name)
                pdf.setFontSize(10)
                pdf.text(40,65,companyDetails.address)
                pdf.text(40,80, companyDetails.city + ' - '+companyDetails.pincode)
                pdf.text(40,95, "Trial Balance: " + $filter('date')(scope.fromDate.date,'dd/MM/yyyy') + '-' + $filter('date')(scope.toDate.date,'dd/MM/yyyy'))
            )

          # write footer
          OBT = scope.data.forwardedBalance.amount.toString()
          DBT = scope.data.debitTotal.toString()
          CDT = scope.data.creditTotal.toString()
          CBT = scope.data.closingBalance.amount.toString()
          footerX = 45
          lastY = pdf.autoTableEndPosY()
          pageWidth = pdf.internal.pageSize.width - 40
          pdf.setFontSize(10)
          pdf.line(40, lastY, pageWidth, lastY)
          pdf.text(footerX,lastY+20,"Total")
          pdf.text(footerX+150, lastY+20, OBT)
          pdf.text(footerX+260, lastY+20, DBT)
          pdf.text(footerX+335, lastY+20, CDT)
          pdf.text(footerX+415, lastY+20, CBT)

          pdf.save('TrialBalance-GroupWise.pdf')
    }
])
.directive('exportPdfcondensed', [
  '$rootScope'
  '$compile'
  '$filter'
  ($rootScope, $compile, $filter) ->
    {
      restrict: 'A'
      link: (scope, elem, attr) ->
        pdf = new jsPDF()
        # initial coordinates
        companyDetails = $rootScope.selectedCompany 
        colX = 10
        colY = 50

        # assign object values
        setObjVal = (obj) ->
          val = {}
          val.name = $filter('truncate')(obj.Name.toString(),true,25,"...")
          val.ob = obj.OpeningBalance.toString()
          val.dr = obj.Debit.toString()
          val.cr = obj.Credit.toString()
          val. cl = obj.ClosingBalance.toString()
          val


        # write text to pdf with arguments
        writeText = (obj) ->
          pageHeight = pdf.internal.pageSize.height
          val = setObjVal(obj)
          pdf.text(colX, colY, val.name) 
          pdf.text(70, colY, val.ob)
          pdf.text(105, colY, val.dr)
          pdf.text(140, colY, val.cr)
          pdf.text(170, colY, val.cl)
          y = colY % pageHeight
          if colY > 247
            pdf.addPage()
            colY = 20
          else
          colY += 5
        # create pdf 
        createPDF = (dataArray) ->
          pageHeight = pdf.internal.pageSize.height
          # Loop over data array and write values 
          _.each dataArray, (dataObj) ->
            #assign accounts and childgroups
            accounts = dataObj.accounts
            childgroups = dataObj.childGroups
            pdf.setFontSize(10)           
            #write dataObj values
            writeText(dataObj)

            if dataObj.accounts.length > 0
              #loop over accounts and write values
              colX += 5
              _.each accounts, (acc) ->
                writeText(acc)
              colX -= 5
            if childgroups.length > 0
              #loop over childgroups and write values
              colX += 5
              _.each childgroups, (childGrp) ->
                writeText(childGrp)

                if childGrp.subAccounts.length > 0
                  colX += 5
                  _.each childGrp.accounts, (acc) ->
                    writeText(acc)
                  colX -= 5
                    
                if childGrp.subGroups.length > 0
                  colX += 5
                  createPDF(childGrp.subGroups)
                  colX -= 5
              colX -= 5
        # on element click  
        elem.on 'click', (e) ->
        
          rawData = scope.data.groupDetails
          groupData = []
          companyDetails = $rootScope.selectedCompany 
          sortData = (parent, groups) ->
            _.each parent, (obj) ->
              group = group or
                accounts: []
                childGroups: []
              group.Name = obj.groupName.toUpperCase()
              group.OpeningBalance = obj.forwardedBalance.amount + $filter('recType')(obj.forwardedBalance.type, obj.forwardedBalance.amount)
              group.Credit = obj.creditTotal
              group.Debit = obj.debitTotal
              group.ClosingBalance = obj.closingBalance.amount + $filter('recType')(obj.closingBalance.type, obj.closingBalance.amount)
              group.ClosingBalanceType = obj.closingBalance.type
              if obj.accounts.length > 0
                #group.accounts = obj.accounts
                _.each obj.accounts, (acc) ->
                  account = {}
                  account.Name = acc.name.toLowerCase()
                  account.Credit = acc.creditTotal
                  account.Debit = acc.debitTotal
                  account.ClosingBalance = acc.closingBalance.amount + $filter('recType')(acc.closingBalance.type, acc.closingBalance.amount)
                  account.ClosingBalanceType = acc.closingBalance.type
                  account.OpeningBalance = acc.openingBalance.amount + $filter('recType')(acc.openingBalance.type, acc.openingBalance.amount)
                  group.accounts.push account

              if obj.childGroups.length > 0
                #group.childGroups = obj.childGroups
                _.each obj.childGroups, (grp) ->
                  childGroup = childGroup or
                    subGroups: []
                    subAccounts: []
                  childGroup.Name = grp.groupName.toUpperCase()
                  childGroup.Credit = grp.creditTotal
                  childGroup.Debit = grp.debitTotal
                  childGroup.ClosingBalance = grp.closingBalance.amount + $filter('recType')(grp.closingBalance.type, grp.closingBalance.amount)
                  childGroup.DlosingBalanceType = grp.closingBalance.type
                  childGroup.OpeningBalance = grp.forwardedBalance.amount + $filter('recType')(grp.forwardedBalance.type, grp.forwardedBalance.amount)
                  group.childGroups.push childGroup

                  if grp.accounts.length > 0
                    _.each grp.accounts, (acc) ->
                      childGroup.subAccounts = childGroup.subAccounts or
                        []
                      account = {}
                      account.Name = acc.name.toLowerCase()
                      account.Credit = acc.creditTotal
                      account.Debit = acc.debitTotal
                      account.ClosingBalance = acc.closingBalance.amount + $filter('recType')(acc.closingBalance.type, acc.closingBalance.amount)
                      account.ClosingBalanceType = acc.closingBalance.type
                      account.OpeningBalance = acc.openingBalance.amount + $filter('recType')(acc.openingBalance.type, acc.openingBalance.amount)
                      childGroup.subAccounts.push account

                  if grp.childGroups.length > 0
                    sortData(grp.childGroups, childGroup.subGroups)

              groups.push group
          sortData(rawData, groupData)

          #write header
          pdf.setFontSize(16)
          pdf.text(10,20,companyDetails.name)
          pdf.setFontSize(10)
          pdf.text(10,25,companyDetails.address)
          pdf.text(10,30,companyDetails.city + '-' + companyDetails.pincode)
          pdf.text(10,35, "Trial Balance: " + $filter('date')(scope.fromDate.date,'dd/MM/yyyy') + '-' + $filter('date')(scope.toDate.date,'dd/MM/yyyy'))
          pdf.line(10,38,200,38)

          #write table header
          pdf.setFontSize(9)
          pdf.text(10, 43, 'PARTICULAR')
          pdf.text(70,43, 'OPENING BALANCE')
          pdf.text(105, 43, 'DEBIT')
          pdf.text(140, 43, 'CREDIT')
          pdf.text(170, 43, 'CLOSING BALANCE')
          pdf.line(10, 45,200,45)

          createPDF(groupData)
          
          # write table footer
          pdf.line(10, colY, 200, colY)
          pdf.text(10, colY + 5, "TOTAL")
          pdf.text(70, colY + 5, scope.data.forwardedBalance.amount.toString())
          pdf.text(105, colY + 5, scope.data.debitTotal.toString())
          pdf.text(140, colY + 5, scope.data.creditTotal.toString())
          pdf.text(170, colY + 5, scope.data.closingBalance.amount.toString())

          # save to pdf
          pdf.save('TrialBalance-Condensed.pdf')
    }
])
.directive('clearTbsearch', [
  '$rootScope'
  '$compile'
  '$filter'
  '$timeout'
  ($rootScope, $compile, $filter, $timeout) ->
    {
      restrict: 'A'
      link: (scope, elem, attr) ->
        elem.on 'keydown',()->
          
          clear = () ->
            elem[0].value = ''
            elem.val().length = 0
            scope.showClearSearch = false
            scope.keyWord = null

          $timeout (->
            
            if elem.val().length > 1
              scope.showClearSearch = true
            else
              scope.showClearSearch = false

          ), 10

          elem.next('.close-icon').on 'click', ()->
            $timeout (->
              clear()

            ), 10

    }
])
.directive('accordionControls',[
  '$rootScope'
  '$compile'
  '$filter'
  '$timeout'
  ($rootScope, $compile, $filter, $timeout) ->
    {
      restrict: 'A'
      link: (scope, elem, attr) ->
        action = attr.action
        elem.on 'click', () ->
          if action == 'expandAll'
            scope.accordion.expandAll()
          else if action == 'closeAll'
            scope.accordion.collapseAll()
    }
])
.directive('clearSearch',[
  '$rootScope'
  '$compile'
  '$filter'
  '$timeout'
  ($rootScope, $compile, $filter, $timeout) ->
    {
      restrict: 'A'
      link: (scope, elem, attr) ->

        scope.isNotEmpty = false
        model = attr.ngModel
        initModel = model
        remove = $compile("<i class='glyphicon glyphicon-remove clear' ng-show='isNotEmpty'></i>")(scope)

        elem.after(remove)

        elem.on 'keydown', (e) ->
          $timeout (->
            if elem.val().length > 1
              scope.isNotEmpty = true
            else
              scope.isNotEmpty = false
          ), 10

        $('.clear').on 'click', () ->
          $timeout ( ->
            elem[0].value = ''
            scope.acntSrch = null
            scope.isNotEmpty = false
            
          ), 10  
    }
])
.directive('resetChart',[
  '$rootScope'
  '$compile'
  '$filter'
  '$timeout'
  ($rootScope, $compile, $filter, $timeout) ->
    {
      restrict: 'A'
      link: (scope, elem, attr) ->

    }
])
