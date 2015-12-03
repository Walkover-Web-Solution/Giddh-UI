angular.module('twygmbh.auto-height', []).
directive 'autoHeight', ['$window', '$timeout', ($window, $timeout) ->
  link: ($scope, $element, $attrs) ->
    combineHeights = (collection) ->
      heights = 0
      heights += node.offsetHeight for node in collection
      heights

    siblings = ($elm) ->
      elm for elm in $elm.parent().children() when elm != $elm[0]

    angular.element($window).on 'resize', ->
      additionalHeight = $attrs.additionalHeight || 0
      parentHeight = $window.innerHeight - $element.parent()[0].getBoundingClientRect().top
      $element.css('height', (parentHeight - combineHeights(siblings($element)) - additionalHeight) + "px")

    $timeout ->
      angular.element($window).triggerHandler('resize')
    , 1000
]

angular.module('unique-name', []).
directive 'validUnique', (toastr)->
  {
  require: 'ngModel'
  link: (scope, element, attrs, modelCtrl) ->
    element.on 'keypress', (event) ->
      if event.which == 32
        toastr.warning("Space not allowed", "Warning")
        event.preventDefault()
      return
    modelCtrl.$parsers.push (inputValue) ->
      transformedInput = inputValue.toLowerCase().replace(RegExp(' ', 'g'), '')
      if transformedInput != inputValue
        modelCtrl.$setViewValue transformedInput
        modelCtrl.$render()
      transformedInput
    return
  }

angular.module('valid-number', []).
directive 'validNumber', ->
  {
  require: '?ngModel'
  link: (scope, element, attrs, ngModelCtrl) ->
    if !ngModelCtrl
      return
    ngModelCtrl.$parsers.push (val) ->
      if angular.isUndefined(val)
        val = ''
      if _.isNull(val)
        val = ''
      clean = val.replace(/[^0-9\.]/g, '')
      decimalCheck = clean.split('.')
      if !angular.isUndefined(decimalCheck[1])
        decimalCheck[1] = decimalCheck[1].slice(0, 2)
        clean = decimalCheck[0] + '.' + decimalCheck[1]
      if val != clean
        ngModelCtrl.$setViewValue clean
        ngModelCtrl.$render()
      clean
    element.on 'keypress', (event) ->
      if event.keyCode == 32
        event.preventDefault()
      return
    return

  }

# only for ledger
angular.module('valid-date', []).
directive 'validDate', (toastr, $filter) ->
  {
  require: '?ngModel'
  link: (scope, element, attrs, ngModelCtrl) ->
    if !ngModelCtrl
      return
    ngModelCtrl.$parsers.push (val) ->
      if angular.isUndefined(val)
        val = ''
      if _.isNull(val)
        val = ''
      clean = val.replace(/[^0-9\-]/g, '')
      hyphenCheck = clean.split('-')
      if !angular.isUndefined(hyphenCheck[2])
        clean = hyphenCheck[0] + '-' + hyphenCheck[1] + '-' + hyphenCheck[2]
      if val != clean
        ngModelCtrl.$setViewValue clean
        ngModelCtrl.$render()
      clean
    element.on 'keypress', (event) ->
      element.removeClass('error')
      if event.keyCode == 32
        event.preventDefault()
      return
    element.on 'focus', () ->
      if element.context.value is "" || element.context.value is undefined || element.context.value is null
        scope.item.sharedData.entryDate = $filter('date')(new Date(), "dd-MM-yyyy")

    element.on 'blur', () ->
      if moment(element.context.value, "DD-MM-YYYY").isAfter(new Date())
        element.addClass('error')
        toastr.error("You can\'t make a future entry", "Error")
      else if moment(element.context.value, "DD-MM-YYYY", true).isValid()
        element.removeClass('error')
      else
        toastr.error("Date is not valid.", "Error")
        element.addClass('error')
    return

  }

angular.module('ledger', [])
.directive 'ledgerPop', ['$compile', '$filter', '$document', '$parse', '$rootScope', '$timeout', ($compile, $filter, $document, $parse, $rootScope, $timeout) ->
  {
  restrict: 'A'
  replace: true
  transclude: true
  scope:
    index: '=index'
    item: '=itemdata'
    aclist: '=acntlist'
    ftype: '=ftype'
    formClass: '@formClass'
    updateLedger: '&'
    addLedger: '&'
    removeLedgdialog: '&'
    discardLedger: '&'
    removeClassInAllEle: '&'
    enterRowdebit: '&'
    enterRowcredit: '&'
    el:'&'
  controller: 'ledgerController'
  template: "<form novalidate tabindex='-1'>
      <div>
          <table class='table ldgrInnerTbl'>
            <tr>
              <td width='28%'>
                <input pos='1' type='text' class='nobdr ledgInpt'
                  tabindex='-1' required autocomplete='off'
                  name='entryDate_{{index}}'
                  ng-model='item.sharedData.entryDate' valid-date/>
              </td>
              <td width=44%'>
                <input pos='2' type='text'
                  tabindex='-1'  class='nobdr ledgInpt' required
                  name='trnsName_{{index}}'
                  ng-model='item.transactions[0].particular'
                  typeahead='obj as obj.name for obj in aclist | filter:$viewValue | limitTo:8'
                  class='form-control' autocomplete='off'
                  typeahead-no-results='noResults'
                  typeahead-on-select='addCrossFormField($item, $model, $label)'>
                <input type='hidden'
                  name='trnsUniq_{{index}}'
                  ng-model='item.transactions[0].particular.uniqueName'>
              </td>
              <td width='28%'>
                <input pos='3' type='text' class='alR nobdr ledgInpt'
                  tabindex='-1' required autocomplete='off'
                  name='amount_{{index}}'
                  ng-model='item.transactions[0].amount'
                  valid-number/>
              </td>
            </tr>
          </table>
        </div></form>"
  link: (scope, elem, attrs) ->
    scope.el = elem[0]

    fields = elem[0].getElementsByClassName('ledgInpt')
    i = 0
    while i < fields.length
      fields[i].addEventListener 'keydown', (e) ->
        scope.moveCursor(e, this)

      fields[i].addEventListener 'focus', (event) ->
        parentForm = angular.element(this).parents('form')
        if !parentForm.hasClass('open')
          $timeout ->
            scope.openDialog(scope.item, scope.index, scope.ftype, parentForm)
          , 300
      i++

    scope.moveForward = (e, ths)->
      target = ths.parentElement.nextElementSibling.firstElementChild
      target.focus()

    scope.moveBackward = (e, ths)->
      target = ths.parentElement.previousElementSibling.firstElementChild
      target.focus()

    scope.moveCursor = (e, ths) ->
      pos = ths.getAttribute("pos")
      keycode1 = if window.event then e.keyCode else e.which
      if pos is "1" or pos is "2"
        # tab without shift key
        if !e.shiftKey and (keycode1 is 0 or keycode1 is 9)
          e.preventDefault()
          scope.moveForward(e, ths)
        # tab with shift key
        if e.shiftKey and (keycode1 is 0 or keycode1 is 9)
          e.preventDefault()
          if pos is "2"
            scope.moveBackward(e, ths)
      else
        if e.shiftKey and (keycode1 is 0 or keycode1 is 9)
          e.preventDefault()
          scope.moveBackward(e, ths)
      
    scope.addCrossFormField = (i, d, c) ->
      # scope.item.transactions[0].particular.uniqueName = i.uName

    scope.closeEntry = ()->
      scope.removeLedgdialog()
      scope.resetEntry(scope.item, $rootScope.lItem)

    scope.closeAllEntry =()->
      $rootScope.lItem = []
      scope.removeLedgdialog()
      scope.removeClassInAllEle("ledgEntryForm", "highlightRow")
      scope.removeClassInAllEle("ledgEntryForm", "newMultiEntryRow")
      $rootScope.$broadcast('$reloadLedger')
      

    scope.resetEntry = (item, lItem) ->
      scope.removeClassInAllEle("ledgEntryForm", "newMultiEntryRow")
      if lItem.length > 1
        _.each(lItem, (entry) ->
          if entry.id is item.id
            angular.copy(entry, item)
        )
      else
        angular.copy(lItem[0], item)

      if _.isUndefined(scope.item.sharedData.uniqueName)
        item.sharedData.entryDate = undefined
      return false
      
    scope.setItemInLocalItemArr = (item) ->
      if $rootScope.lItem.length > 0
        found = undefined
        if $rootScope.lItem[0].sharedData.uniqueName is item.sharedData.uniqueName
          found = _.find($rootScope.lItem, (obj)->
              obj.id is item.id
            )
          if found is undefined
            $rootScope.lItem.push(angular.copy(item))
            found = undefined
        else
          $rootScope.lItem = []
          $rootScope.lItem.push(angular.copy(item))
      else
        $rootScope.lItem.push(angular.copy(item))

    scope.checkDateField = (item) ->
      if (item.sharedData.entryDate is "" || item.sharedData.entryDate is undefined || item.sharedData.entryDate is null)
        item.sharedData.entryDate = $filter('date')(new Date(), "dd-MM-yyyy")

    scope.highlightMultiEntry =(item)->
      scope.removeClassInAllEle("ledgEntryForm", "highlightRow")
      el = document.getElementsByClassName(item.sharedData.uniqueName)
      angular.element(el).addClass('highlightRow')

    scope.makeItHigh = () ->
      scope.forwardtoCntrlScope(angular.element(scope.el), scope.item)
      return false

    scope.openDialog = (item, indexs, ftype, parentForm) ->
      # $document.off 'click'
      scope.removeClassInAllEle("ledgEntryForm", "open")
      elem.addClass('open')
      scope.highlightMultiEntry(item)
      scope.checkDateField(item)
      rect = parentForm[0].getBoundingClientRect()
      childCount = parentForm[0].childElementCount
      popHtml = angular.element('
          <div class="popover fade bottom ledgerPopDiv" id="popid_{{index}}">
          <div class="arrow"></div>
          <h3 class="popover-title" ng-if="ftype == \'Update\'">Update entry</h3>
          <h3 class="popover-title" ng-if="ftype == \'Add\'">Add new entry</h3>
          <div class="popover-content">
            <div class="mrT">
              <div class="form-group">
                <button ng-disabled="{{formClass}}.$invalid || noResults" class="btn btn-sm btn-info mrR1" ng-click="enterRowdebit({entry: item}); makeItHigh()">Add in DR</button>
                <button ng-disabled="{{formClass}}.$invalid || noResults" class="btn btn-sm btn-primary" ng-click="enterRowcredit({entry: item}); makeItHigh()">Add in CR</button>
                <a class="pull-right" href="javascript:void(0)" ng-click="addNewAccount()" ng-show="noResults">Add new account</a>
              </div>
              <div class="row">
                <div class="col-md-6 col-sm-12">
                  <div class="form-group">
                    <select class="form-control"
                    name="voucherType" ng-model="item.sharedData.voucher.shortCode">
                      <option
                        ng-repeat="option in voucherTypeList"
                        ng-selected="{{option.shortCode == item.sharedData.voucher.shortCode}}"
                        value="{{option.shortCode}}">
                        {{option.name}}
                      </option>
                    </select>
                  </div>
                  <div class="form-group">
                    <input type="text" name="tag" class="form-control" ng-model="item.sharedData.tag" placeholder="Tag" />
                  </div>
                </div>
                <div class="col-md-6 col-sm-12">
                  <div class="form-group" ng-if="ftype == \'Update\'">
                    <label>Vouher no. </label>
                    {{item.sharedData.voucher.shortCode}}-{{item.sharedData.voucherNo}}
                  </div>
                  <div class="form-group">
                    <textarea class="form-control" name="description" ng-model="item.sharedData.description" placeholder="Description"></textarea>
                  </div>
                </div>
              </div>
              <div class="">
                <button ng-if="ftype == \'Update\'" class="btn btn-success" type="button" ng-disabled="{{formClass}}.$invalid || noResults"
                  ng-click="updateLedger({entry: item})">Update</button>
                <button  ng-if="ftype == \'Add\'" class="btn btn-success" type="button" ng-disabled="{{formClass}}.$invalid || noResults"
                  ng-click="addLedger({entry: item})">Add</button>

                <button ng-click="closeEntry()" class="btn btn-default mrL1" type="button">close</button>

                <button ng-click="closeAllEntry()" class="btn btn-default mrL1" type="button">close All</button>

                <button  ng-show="item.sharedData.uniqueName != undefined" class="pull-right btn btn-danger" ng-click="discardLedger({entry: item})">Delete Entry</button>
              </div>
            </div>
          </div>
        </div>')

      $document.on "click", (event)->
        onDocumentClick(event)

      scopeExpression = attrs.removeLedgdialog

      onDocumentClick = (event) ->
        isChild = elem.find(event.target).length > 0 || event.target.parentNode.nodeName is "LI"
        splCond = event.target.nodeName is "INPUT" || event.target.nodeName is "BUTTON"
        if !isChild
          if item.sharedData.multiEntry || item.sharedData.addType
            console.log "is child and multiEntry"
          else if splCond
            if event.target.nodeName is "BUTTON"
              console.log "by button click"
            if event.target.nodeName is "INPUT"
              scope.resetEntry(item, $rootScope.lItem)
          else
            scope.resetEntry(item, $rootScope.lItem)
          scope.$apply(scopeExpression)
          scope.removeClassInAllEle("ledgEntryForm", "open")
          scope.removeClassInAllEle("ledgEntryForm", "highlightRow")
          $document.off 'click'

      if childCount == 1
        scope.setItemInLocalItemArr(item)
        scope.removeLedgerDialog("all")
        $compile(popHtml)(scope)
        parentForm.append(popHtml)
        popHtml.css({
          display: "block",
          top: rect.height,
          left: "0px",
          visibility: "visible",
          maxWidth: rect.width,
          width: rect.width
        })
        popHtml.addClass('in')
      else
        return false
      return true
    scope.el = elem[0]
  }
]
