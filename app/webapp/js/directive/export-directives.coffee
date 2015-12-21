angular.module('exportDirectives', []).directive('exportPdfgroupwise', [
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
            group.openingBalance = obj.forwardedBalance.amount + $filter('recType')(obj.forwardedBalance.type)
            #group.openingBalanceType = obj.forwardedBalance.type
            group.credit = obj.creditTotal
            group.debit = obj.debitTotal
            group.closingBalance = obj.closingBalance.amount + $filter('recType')(obj.closingBalance.type)
            #group.closingBalanceType = obj.closingBalance.type
            groups.push group

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
              margin: {
                  top: 100
                },
              beforePageContent: () ->
                pdf.setFontSize(16)
                pdf.text(40,50,companyDetails.name)
                pdf.setFontSize(10)
                pdf.text(40,65,companyDetails.address)
                pdf.text(40,90, "Trial Balance: " + $filter('date')(scope.fromDate.date,'dd/MM/yyyy') + '-' + $filter('date')(scope.toDate.date,'dd/MM/yyyy'))
            )

          pdf.save('Trial Balance-Group Wise.pdf')
    }
]).directive('exportPdfaccountwise', [
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
                  account.openingBalance = acc.openingBalance.amount + $filter('recType')(acc.openingBalance.type)
                  account.openingBalanceType = acc.openingBalance.type + $filter('recType')(acc.closingBalance.type)
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
                      account.openingBalance = acc.openingBalance.amount + $filter('recType')(acc.openingBalance.type)
                      account.openingBalanceType = acc.openingBalance.type
                      account.credit = acc.creditTotal
                      account.debit = acc.debitTotal
                      account.closingBalance = acc.closingBalance.amount + $filter('recType')(acc.closingBalance.type)
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
              margin: {
                  top: 100
                },
              beforePageContent: () ->
                pdf.setFontSize(16)
                pdf.text(40,50,companyDetails.name)
                pdf.setFontSize(10)
                pdf.text(40,65,companyDetails.address)
                pdf.text(40,90, "Trial Balance: " + $filter('date')(scope.fromDate.date,'dd/MM/yyyy') + '-' + $filter('date')(scope.toDate.date,'dd/MM/yyyy'))
            )

          pdf.save('tb.pdf')
    }
]).directive('exportPdfgroupwise', [
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
            group.openingBalance = obj.forwardedBalance.amount + $filter('recType')(obj.forwardedBalance.type)
            #group.openingBalanceType = obj.forwardedBalance.type
            group.credit = obj.creditTotal
            group.debit = obj.debitTotal
            group.closingBalance = obj.closingBalance.amount + $filter('recType')(obj.closingBalance.type)
            #group.closingBalanceType = obj.closingBalance.type
            groups.push group

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
              margin: {
                  top: 100
                },
              beforePageContent: () ->
                pdf.setFontSize(16)
                pdf.text(40,50,companyDetails.name)
                pdf.setFontSize(10)
                pdf.text(40,65,companyDetails.address)
                pdf.text(40,90, "Trial Balance: " + $filter('date')(scope.fromDate.date,'dd/MM/yyyy') + '-' + $filter('date')(scope.toDate.date,'dd/MM/yyyy'))
            )

          pdf.save('Trial Balance-Account Wise.pdf')
    }
]).directive('exportPdfcondensed', [
  '$rootScope'
  '$compile'
  '$filter'
  ($rootScope, $compile, $filter) ->
    {
      restrict: 'A'
      link: (scope, elem, attr) ->
        pdf = new jsPDF()
        # initial coordinates
          
        colX = 10
        colY = 10

        # assign object values
        setObjVal = (obj) ->
          val = {}
          val.name = obj.Name.toString()
          val.ob = obj.OpeningBalance.toString()
          val.dr = obj.Debit.toString()
          val.cr = obj.Credit.toString()
          val. cl = obj.ClosingBalance.toString()
          val

          # write text to pdf with arguments
        writeText = (obj) ->
          val = obj
          pdf.text(colX, colY, val.name) 
          pdf.text(colX + 50, colY, val.ob)
          pdf.text(colX + 90, colY, val.dr)
          pdf.text(colX + 130, colY, val.cr)
          pdf.text(colX + 170, colY, val.cl)
          pdf.addPage()
        
        createPDF = (dataObj) ->
            _.each dataObj, (obj) ->
              pdf.setFontSize(10)

              grp = setObjVal(obj)

              writeText(grp)

              if obj.accounts.length > 0
                acc = setObjVal(obj.accounts)
                colX += 2
                coly += 5
                writeText(acc)

              if obj.childGroups.length > 0
                childGroups = obj.childGroups
                colX += 2
                _.each childGroups, (chldrn) ->
                  colY = colY + 5
                  chld = setObjVal(chldrn)
                  writeText(chld)
                  if chldrn.subAccounts.length > 0
                    subAccounts = chldrn.subAccounts
                    colX += 2
                    _.each subAccounts, (account) ->
                      colY += 5
                      acc = setObjVal(account)
                      writeText(acc)
                    colX -= 2 
                  if chldrn.subGroups.length > 0
                    console.log 'call recursive'



              colY = colY + 10
              colX = 10
              pageSize = pdf.internal.pageSize.height
              console.log pageSize
             #pdf.save('tb.pdf')


        elem.on 'click', (e) ->
         
          rawData = scope.data.groupDetails
          groupData = []
          companyDetails = $rootScope.selectedCompany 
          sortData = (parent, groups) ->
            _.each parent, (obj) ->
              group = group or
                accounts: []
                childGroups: []
              group.Name = obj.groupName
              group.OpeningBalance = obj.forwardedBalance.amount
              group.Credit = obj.creditTotal
              group.Debit = obj.debitTotal
              group.ClosingBalance = obj.closingBalance.amount
              group.ClosingBalanceType = obj.closingBalance.type
              if obj.accounts.length > 0
                #group.accounts = obj.accounts
                _.each obj.accounts, (acc) ->
                  account = {}
                  account.Name = acc.name
                  account.Credit = acc.creditTotal
                  account.Debit = acc.debitTotal
                  account.ClosingBalance = acc.closingBalance.amount
                  account.ClosingBalanceType = acc.closingBalance.type
                  account.OpeningBalance = acc.openingBalance.amount
                  group.accounts.push account

              if obj.childGroups.length > 0
                #group.childGroups = obj.childGroups
                _.each obj.childGroups, (grp) ->
                  childGroup = childGroup or
                    subGroups: []
                    subAccounts: []
                  childGroup.Name = grp.groupName
                  childGroup.Credit = grp.creditTotal
                  childGroup.Debit = grp.debitTotal
                  childGroup.ClosingBalance = grp.closingBalance.amount
                  childGroup.DlosingBalanceType = grp.closingBalance.type
                  childGroup.OpeningBalance = grp.forwardedBalance.amount
                  group.childGroups.push childGroup

                  if grp.accounts.length > 0
                    _.each grp.accounts, (acc) ->
                      childGroup.subAccounts = childGroup.subAccounts or
                        []
                      account = {}
                      account.Name = acc.name
                      account.Credit = acc.creditTotal
                      account.Debit = acc.debitTotal
                      account.ClosingBalance = acc.closingBalance.amount
                      account.ClosingBalanceType = acc.closingBalance.type
                      account.OpeningBalance = acc.openingBalance.amount
                      childGroup.subAccounts.push account

                  if grp.childGroups.length > 0
                    sortData(grp.childGroups, childGroup.subGroups)

              groups.push group
          sortData(rawData, groupData)

          createPDF(groupData)

    }
])