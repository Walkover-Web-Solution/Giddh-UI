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
          total = {
            ob: 0
            cb: 0
            cr: 0
            dr: 0
          }
          rawData = scope.exportData
          companyDetails = $rootScope.selectedCompany

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
                  account.openingBalanceType = acc.openingBalance.type
                  account.credit = acc.creditTotal
                  account.debit = acc.debitTotal
                  account.closingBalance = acc.closingBalance.amount + $filter('recType')(acc.closingBalance.type, acc.openingBalance.amount)
                  account.closingBalanceType = acc.closingBalance.type
                  if acc.isVisible
                    total.ob += acc.openingBalance.amount
                    total.cb += acc.closingBalance.amount
                    total.cr += acc.creditTotal
                    total.dr += acc.debitTotal
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
                      if acc.isVisible
                        total.ob += acc.openingBalance.amount
                        total.cb += acc.closingBalance.amount
                        total.cr += acc.creditTotal
                        total.dr += acc.debitTotal
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
          total.ob = $filter('number')(total.ob, 2)
          total.cb = $filter('number')(total.cb, 2)
          total.dr = $filter('number')(total.dr, 2)
          total.cr = $filter('number')(total.cr, 2)
          OBT = total.ob.toString()
          DBT = total.dr.toString()
          CDT = total.cr.toString()
          CBT = total.cb.toString()
          footerX = 40
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
          rawData = scope.exportData
          companyDetails = $rootScope.selectedCompany
          total = {
            ob: 0
            cb: 0
            cr: 0
            dr: 0
          }

          _.each rawData, (obj) ->
            group = {}
            group.name = obj.groupName
            group.openingBalance = obj.forwardedBalance.amount + $filter('recType')(obj.forwardedBalance.type, obj.forwardedBalance.amount)
            #group.openingBalanceType = obj.forwardedBalance.type
            group.debit = obj.debitTotal
            group.credit = obj.creditTotal
            group.closingBalance = obj.closingBalance.amount + $filter('recType')(obj.closingBalance.type, obj.closingBalance.amount)
            #group.closingBalanceType = obj.closingBalance.type
            if obj.isVisible
              if obj.forwardedBalance.type == "DEBIT"
                total.ob = total.ob + obj.forwardedBalance.amount
              else
                total.ob = total.ob - obj.forwardedBalance.amount
              if obj.closingBalance.type == "DEBIT"
                total.cb = total.cb + obj.closingBalance.amount
              else
                total.cb = total.cb - obj.closingBalance.amount
#              total.ob += obj.forwardedBalance.amount
#              total.cb += obj.closingBalance.amount
              total.cr += obj.creditTotal
              total.dr += obj.debitTotal
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
          total.ob = $filter('number')(total.ob, 2)
          total.cb = $filter('number')(total.cb, 2)
          total.dr = $filter('number')(total.dr, 2)
          total.cr = $filter('number')(total.cr, 2)
          if total.ob < 0
            total.ob = total.ob * -1
            total.ob = total.ob + " Cr"
          else
            total.ob = total.ob + " Dr"
          if total.cb < 0
            total.cb = total.cb * -1
            total.cb = total.cb + " Cr"
          else
            total.cb = total.cb + " Dr"
          OBT = total.ob.toString()
          DBT = total.dr.toString()
          CDT = total.cr.toString()
          CBT = total.cb.toString()
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

        pdf = new jsPDF
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
          val.cl = obj.ClosingBalance.toString()
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
                console.log childGrp
                writeText(childGrp)

                if childGrp.subAccounts.length > 0
                  colX += 5
                  _.each childGrp.subAccounts, (acc) ->
                    writeText(acc)
                  colX -= 5
                    
                if childGrp.subGroups.length > 0
                  colX += 5
                  createPDF(childGrp.subGroups)
                  colX -= 5
              colX -= 5

        # on element click  
        elem.on 'click', (e) ->
          colX = 10
          colY = 50
          if !_.isUndefined(pdf)
            pdf = undefined
            pdf = new jsPDF()
          else
            pdf = new jsPDF
          rawData = scope.exportData
          groupData = []
          total = {
              ob: 0
              cb: 0
              cr: 0
              dr: 0
          }
          companyDetails = $rootScope.selectedCompany 

          sortData = (parent, groups) ->
            _.each parent, (obj) ->
              if obj.isVisible
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
                    if acc.isVisible
                      account = {}
                      account.Name = acc.name.toLowerCase()
                      account.Credit = acc.creditTotal
                      account.Debit = acc.debitTotal
                      account.ClosingBalance = acc.closingBalance.amount + $filter('recType')(acc.closingBalance.type, acc.closingBalance.amount)
                      account.ClosingBalanceType = acc.closingBalance.type
                      account.OpeningBalance = acc.openingBalance.amount + $filter('recType')(acc.openingBalance.type, acc.openingBalance.amount)
                      group.accounts.push account
                      total.ob += acc.openingBalance.amount
                      total.cb += acc.closingBalance.amount
                      total.cr += acc.creditTotal
                      total.dr += acc.debitTotal

                if obj.childGroups.length > 0
                  #group.childGroups = obj.childGroups
                  _.each obj.childGroups, (grp) ->
                    if grp.isVisible
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
                          if acc.isVisible
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
                            if acc.openingBalance.type == "DEBIT"
                              total.ob = total.ob + acc.openingBalance.amount
                            else
                              total.ob = total.ob - acc.openingBalance.amount
                            if acc.closingBalance.type == "DEBIT"
                              total.cb = total.cb + acc.closingBalance.amount
                            else
                              total.cb = total.cb - acc.closingBalance.amount
#                            total.ob += acc.openingBalance.amount
#                            total.cb += acc.closingBalance.amount
                            total.cr += acc.creditTotal
                            total.dr += acc.debitTotal

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

          
          total.ob = $filter('number')(total.ob, 2)
          total.cb = $filter('number')(total.cb, 2)
          total.dr = $filter('number')(total.dr, 2)
          total.cr = $filter('number')(total.cr, 2)
          if total.ob < 0
            total.ob = total.ob * -1
            total.ob = total.ob + " Cr"
          else
            total.ob = total.ob + " Dr"
          if total.cb < 0
            total.cb = total.cb * -1
            total.cb = total.cb + " Cr"
          else
            total.cb = total.cb + " Dr"
          # write table footer
          pdf.line(10, colY, 200, colY)
          pdf.text(10, colY + 5, "TOTAL")
          pdf.text(70, colY + 5, total.ob.toString())
          pdf.text(105, colY + 5, total.dr.toString())
          pdf.text(140, colY + 5, total.cr.toString())
          pdf.text(170, colY + 5, total.cb.toString())

          # save to pdf
          pdf.save('TrialBalance-Condensed.pdf')
    }
])
.directive('exportPlpdf', [
  '$rootScope'
  '$compile'
  '$filter'
  ($rootScope, $compile, $filter) ->
    {
      restrict: 'A'
      link: (scope, elem, attr) ->
  
        elem.on 'click', (e) ->
          pdf = new jsPDF('p','pt')
          plData = scope.plData
          incomeTotal = plData.incomeTotal.toString()
          expenseTotal = plData.expenseTotal.toString()
          pl = $filter('number')(plData.closingBalance, 3)
          companyDetails = $rootScope.selectedCompany
          colX = 20
          colY = 40
          pWidth = pdf.internal.pageSize.width
          pHeight = pdf.internal.pageSize.height
          col = pWidth/4
          col2 =  col + 40
          col3 = 2 * col + 10
          col4 = 3 * col + 40 
          pageEnd = 0
          #write header
          pdf.setFontSize(14)
          pdf.setFontStyle('bold')
          pdf.text(colX,colY, companyDetails.name)
          colY += 15
          pdf.setFontSize(10)
          pdf.text(colX, colY, companyDetails.address)
          colY+= 15
          pdf.text(colX,colY,companyDetails.city + '-' + companyDetails.pincode)
          colY+= 15
          pdf.text(colX,colY, "Profit and Loss: " + $filter('date')(scope.fromDate.date,'dd/MM/yyyy') + '-' + $filter('date')(scope.toDate.date,'dd/MM/yyyy'))
          colY+= 15
          pdf.line(colX,colY,pWidth-20,colY)
          colY += 20

          #write table header
          pdf.setFontStyle('normal')
          pdf.setFontSize(12)
          pdf.text(colX, colY,'INCOME')
          pdf.text(col3, colY, 'EXPENSES')
          colY += 10
          pdf.line(colX, colY, pWidth-20, colY)
          colY+= 20
          #write table 
          tableStartY = colY
          _.each plData.incArr, (inc) ->
            if colY > pHeight - 80
              pdf.addPage()
            name = inc.groupName.toString()
            amount = $filter('number')(inc.closingBalance.amount, 3)
            amount = amount.toString()
            pdf.setFontSize(10)
            pdf.setFontStyle('normal')
            pdf.text(colX, colY, name)
            pdf.text(col2,colY, amount)
            colY += 15
            if inc.childGroups.length > 0
              colX += 20
              _.each inc.childGroups, (cInc) ->
                if colY > pHeight - 80
                  pdf.addPage()
                cName = cInc.groupName.toString()
                cAmount = $filter('number')(cInc.closingBalance.amount, 3) 
                cAmount = cAmount.toString()
                pdf.text(colX, colY, cName)
                pdf.text(col2 + 10, colY, cAmount)
                colY += 15
              colX -= 20

          colY = tableStartY
          _.each plData.expArr, (exp) ->
            if colY > pHeight - 80
              pdf.addPage()
            name = exp.groupName.toString()
            amount = $filter('number')(exp.closingBalance.amount, 3)
            amount = amount.toString()
            pdf.setFontSize(10)
            pdf.text(col3, colY, name)
            pdf.text(col4,colY, amount)
            colY += 15
            if exp.childGroups.length > 0
              col3 += 20
              _.each exp.childGroups, (cExp) ->
                if colY > pHeight - 80
                  pdf.addPage()
                cName = cExp.groupName.toString()
                cAmount = $filter('number')(cExp.closingBalance.amount, 3)
                cAmount = cAmount.toString()
                pdf.text(col3, colY, cName)
                pdf.text(col4 + 10, colY, cAmount)
                colY += 15
              col3 -= 20
          pageEnd = colY
          pdf.line(pWidth/2, tableStartY - 20 , pWidth/2, pageEnd + 10)
          pdf.line(20, pageEnd+10, pWidth-20, pageEnd+10)
          pdf.setFontSize(12)
          pageEnd += 30

          if plData.closingBalance >= 0
            pdf.text(20, pageEnd, 'Profit')
            pdf.text(col2, pageEnd, pl.toString())
          else
            pdf.text(col3, pageEnd, 'Loss')
            pdf.text(col4, pageEnd, pl.toString())
          pageEnd += 10

          pdf.line(20, pageEnd, pWidth-20, pageEnd)
          pageEnd +=20
          pdf.text(20, pageEnd, 'TOTAL')
          pdf.text(col2, pageEnd, incomeTotal)
          pdf.text(col3, pageEnd, 'TOTAL')
          pdf.text(col4, pageEnd, expenseTotal)

          pdf.save('Profit-and-Loss.pdf')
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

.directive 'selectOnClick', [
  '$window'
  ($window) ->
    # Linker function
    (scope, element, attrs) ->
      element.bind 'click', ->
        if !$window.getSelection().toString()
          @setSelectionRange 0, @value.length
]

.directive 'ignoreMouseWheel',[
  '$rootScope'
  ($rootScope) ->
    {
      restrict: 'A'
      link: (scope, element, attrs) ->
        element.bind 'mousewheel', (event) ->
          element.blur()
    }
]


# .directive( 'ignoreMouseWheel', function( $rootScope ) {
#   return {
#     restrict: 'A',
#     link: function( scope, element, attrs ){
#       element.bind('mousewheel', function ( event ) {
#         element.blur();
#       } );
#     }
#   }
# } );

# module.directive('selectOnClick', ['$window', function ($window) {
#   // Linker function
#   return function (scope, element, attrs) {
#     element.bind('click', function () {
#       if (!$window.getSelection().toString()) {
#         this.setSelectionRange(0, this.value.length)
#       }
#     });
#   };
# }]);

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

.filter('grpsrch', ->
  (input, search) ->
    if !_.isUndefined(search)
      srch = search.toLowerCase()
    initial = input

    checkIndex = (src, str) ->
      if src.indexOf(str) != -1
        true
      else 
        false      

    performSearch  = (input) ->
      _.each input, (grp) ->
        grpName = grp.name.toLowerCase()
        grpUnq = grp.uniqueName.toLowerCase()
        if !checkIndex(grpName, srch) && !checkIndex(grpUnq, srch)
          grp.isVisible = false
          if grp.groups.length > 0
            _.each grp.groups, (sub) ->
              subName = sub.name.toLowerCase()
              subUnq = sub.uniqueName.toLowerCase()

              if !checkIndex(subName, srch) && !checkIndex(subUnq, srch)
                sub.isVisible = false
                if sub.groups.length
                  _.each sub.groups, (child) ->
                    childName = child.name.toLowerCase()
                    childUnq = child.uniqueName.toLowerCase()
                    if !checkIndex(childName, srch) && !checkIndex(childUnq, srch)
                      child.isVisible = false
                      if child.groups.length > 0
                        _.each child.groups, (subChild) ->
                          subChildName = subChild.name.toLowerCase()
                          subChildUnq = subChild.uniqueName.toLowerCase()
                          if !checkIndex(subChildName, srch) && !checkIndex(subChildUnq, srch)
                            subChild.isVisible = false
                            if subChild.groups.length > 0
                              _.each child.groups, (subChild2) ->
                                subChild2Name = subChild2.name.toLowerCase()
                                subChild2Unq = subChild2.uniqueName.toLowerCase()
                                if !checkIndex(subChild2Name, srch) && !checkIndex(subChild2Unq, srch)
                                  subChild2.isVisible = false
                                  if subChild2.groups.length > 0
                                    performSearch(subChild.groups)
                                else
                                  grp.isVisible = true
                                  child.isVisible = true
                                  sub.isVisible = true 
                                  subChild.isVisible = true
                                  subChild2.isVisible = true
                          else
                            grp.isVisible = true
                            child.isVisible = true
                            sub.isVisible = true 
                            subChild.isVisible = true
                    else if checkIndex(childName, srch) || checkIndex(childUnq, srch)
                      grp.isVisible = true
                      child.isVisible = true
                      sub.isVisible = true
              else if checkIndex(subName, srch) || checkIndex(subUnq, srch)
                grp.isVisible = true
                sub.isVisible = true
        else if checkIndex(grpName, srch) || checkIndex(grpUnq, srch)
          grp.isVisible = true

    resetSearch = (input) ->
      _.each input, (grp) ->
        grp.isVisible = true
        if grp.groups.length > 0
          _.each grp.groups, (sub)->
            sub.isVisible = true
            if sub.groups.length > 0
              resetSearch(sub.groups)

    if !_.isUndefined(srch)
      performSearch(input)
      if srch.length < 2
        resetSearch(input)
    input

               
)

.filter('tbsearch', ->
  (input, search) ->
    
    if !_.isUndefined(search)
      srch = search.toLowerCase()
    initial = input

    checkIndex = (src, str) ->
      if src.indexOf(str) != -1
        true
      else 
        false      

    performSearch  = (input) ->
      _.each input, (grp) ->
        grpName = grp.groupName.toLowerCase()
        grpUnq = grp.uniqueName.toLowerCase()

        if !checkIndex(grpName, srch) && !checkIndex(grpName, srch)
          grp.isVisible = false
          if grp.childGroups.length > 0
            _.each grp.childGroups, (child) ->
              childName = child.groupName.toLowerCase()
              childUnq = child.groupName.toLowerCase()

              if !checkIndex(childName, srch) && !checkIndex(childUnq, srch)
                child.isVisible = false
                if child.childGroups.length > 0
                  _.each child.childGroups, (nChild1) ->
                    nchild1Name = nChild1.groupName.toLowerCase()
                    nChild1Unq = nChild1.uniqueName.toLowerCase()
                    if !checkIndex(nchild1Name, srch) && !checkIndex(nChild1Unq, srch)
                      nChild1.isVisible = false
                      if nChild1.childGroups.length > 0
                        _.each nChild1.childGroups, (nChild2) ->
                          nChild2Name = nChild2.groupName.toLowerCase()
                          nChild2Unq = nChild2.uniqueName.toLowerCase()
                          if !checkIndex(nChild2Name, srch) && !checkIndex(nChild2Unq, srch)
                            nChild2.isVisible = false
                            if nChild2.childGroups.length > 0
                              _.each nChild2.childGroups, (nChild3) ->
                                nChild3Name = nChild3.groupName.toLowerCase()
                                nChild3Unq = nChild2.uniqueName.toLowerCase()
                                if !checkIndex(nChild3Name, srch) && !checkIndex(nChild3Unq, srch)
                                  nChild3.isVisible = false
                                  if nChild3.childGroups.length > 0
                                    performSearch(nChild3.childGroups) 
                                  if nChild3.accounts.length > 0

                                    _.each nChild3.accounts, (acc) ->
                                      accName = acc.name.toLowerCase()
                                      accUnq = acc.uniqueName.toLowerCase()
                                      if !checkIndex(accName, srch) && !checkIndex(accUnq, srch)
                                        acc.isVisible = false
                                      else if checkIndex(accName, srch) || checkIndex(accUnq, srch)
                                        nChild3.isVisible = true
                                        nChild2.isVisible = true
                                        nChild1.isVisible = true
                                        child.isVisible = true
                                        grp.isVisible = true
                                        acc.isVisible = true
                                else if checkIndex(nChild3Name, srch) || checkIndex(nChild3Unq, srch)
                                  nChild3.isVisible = true
                                  nChild2.isVisible = true
                                  nChild1.isVisible = true
                                  child.isVisible = true
                                  grp.isVisible = true
                            if nChild2.accounts.length > 0
                              _.each nChild2.accounts, (acc) ->
                                accName = acc.name.toLowerCase()
                                accUnq = acc.uniqueName.toLowerCase()
                                if !checkIndex(accName, srch) && !checkIndex(accUnq, srch)
                                  acc.isVisible = false
                                else if checkIndex(accName, srch) || checkIndex(accUnq, srch)
                                  nChild2.isVisible = true
                                  nChild1.isVisible = true
                                  child.isVisible = true
                                  grp.isVisible = true
                                  acc.isVisible = true
                          else if checkIndex(nChild2Name, srch) || checkIndex(nChild2Unq, srch)
                            nChild2.isVisible = true
                            nChild1.isVisible = true
                            child.isVisible = true
                            grp.isVisible = true
                      if nChild1.accounts.length > 0
                        _.each nChild1.accounts, (acc) ->
                          accName = acc.name.toLowerCase()
                          accUnq = acc.uniqueName.toLowerCase()
                          if !checkIndex(accName, srch) && !checkIndex(accUnq, srch)
                            acc.isVisible = false
                          else if checkIndex(accName, srch) || checkIndex(accUnq, srch)
                            nChild1.isVisible = true
                            child.isVisible = true
                            grp.isVisible = true
                            acc.isVisible = true
                    else if checkIndex(nchild1Name, srch) || checkIndex(nChild1Unq, srch)
                      nChild1.isVisible = true
                      child.isVisible = true
                      grp.isVisible = true

                if child.accounts.length > 0
                  _.each child.accounts, (acc) ->
                    accName = acc.name.toLowerCase()
                    accUnq = acc.uniqueName.toLowerCase()

                    if !checkIndex(accName, srch) && !checkIndex(accUnq, srch)
                      acc.isVisible = false
                    else if checkIndex(accName, srch) || checkIndex(accUnq, srch)
                      child.isVisible = true
                      grp.isVisible = true
                      acc.isVisible = true 

              else if checkIndex(childName, srch) || checkIndex(childUnq, srch)
                grp.isVisible = true
                child.isVisible = true

          if grp.accounts.length > 0
            _.each grp.accounts, (acc) ->
              accName = acc.name.toLowerCase()
              accUnq = acc.uniqueName.toLowerCase()

              if !checkIndex(accName, srch) && !checkIndex(accUnq, srch)
                acc.isVisible = false
              else if checkIndex(accName, srch) || checkIndex(accUnq, srch)
                grp.isVisible = true
                acc.isVisible = true



        else if checkIndex(grpName, srch) || checkIndex(grpName, srch)
          grp.isVisible = true


    resetSearch = (input) ->
      _.each input, (grp) ->
        grp.isVisible = true
        if grp.childGroups.length > 0
          _.each grp.childGroups, (sub)->
            sub.isVisible = true
            if sub.childGroups.length > 0
              resetSearch(sub.childGroups)
            if sub.accounts.length > 0
              _.each sub.accounts, (acc) ->
                acc.isVisible = true
        if grp.accounts.length > 0
          _.each grp.accounts, (acc) ->
            acc.isVisible = true
    
    if !_.isUndefined(srch)
      performSearch(input)
      if srch.length < 2
        resetSearch(input)
    input                
      
)