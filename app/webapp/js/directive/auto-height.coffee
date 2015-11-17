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
        scope.item.entryDate = $filter('date')(new Date(), "dd-MM-yyyy")

    element.on 'blur', () ->
      if moment(element.context.value, "DD-MM-YYYY", true).isValid()
        element.removeClass('error')
      else
        toastr.error("Date is not valid.", "Error")
        element.addClass('error')
    return

  }

angular.module('ledger', [])
.directive 'ledgerPop', ($compile, $filter) ->
  {
  restrict: 'A'
  replace: true
  transclude: true
  scope:
    index: '=index'
    item: '=itemdata'
    aclist: '=acntlist'
    ftype: '=ftype'
    updateLedger: '&'
    addLedger: '&'
    removeLedgdialog: '&'
    discardLedger: '&'
    removeClassInAllEle: '&'
    el:'&'
  controller: 'ledgerController'
  template: "<form class='pr drEntryForm_{{index}} name='drEntryForm_{{index}}' novalidate tabindex='-1'>
      <div ng-click='openDialog(item, index, ftype)'>
          <table class='table ldgrInnerTbl'>
            <tr>
              <td width='28%'>
                <input type='text' class='nobdr test'
                  tabindex='-1' required
                  name='entryDate_{{index}}'
                  ng-model='item.entryDate' valid-date/>
              </td>
              <td width=44%'>
                <input type='hidden'  class='nobdr test'
                  name='trnsUniq_{{index}}'
                  ng-model='item.transactions[0].particular.uniqueName'>
                <input type='text'
                  tabindex='-1'  class='nobdr test' required
                  name='trnsName_{{index}}'
                  ng-model='item.transactions[0].particular'
                  typeahead='obj as obj.name for obj in aclist | filter:$viewValue | limitTo:8'
                  class='form-control'
                  typeahead-no-results='noResults'
                  typeahead-on-select='addCrossFormField($item, $model, $label)'>
              </td>
              <td width='28%'>
                <input type='text' class='nobdr'
                  tabindex='-1' required
                  name='amount_{{index}}'
                  ng-model='item.transactions[0].amount'
                  valid-number/>
              </td>
            </tr>
          </table>
        </div></form>"
  link: (scope, elem, attrs) ->
    scope.lItem = {}
    
    scope.addCrossFormField = (i, d, c) ->
      scope.item.transactions[0].particular.uniqueName = i.uName

    scope.resetEntry = (item, lItem) ->
      if _.isUndefined(lItem.uniqueName)
        item.entryDate = undefined
        item.transactions[0].particular = {}
        item.transactions[0].amount = undefined
      else
        angular.copy(lItem, item)

    scope.checkDateField = (item) ->
      if (item.entryDate is "" || item.entryDate is undefined || item.entryDate is null)
        item.entryDate = $filter('date')(new Date(), "dd-MM-yyyy")

    scope.openDialog = (item, index, ftype) ->
      scope.checkDateField(item)
      rect = elem.context.getBoundingClientRect()
      childCount = elem.context.childElementCount
      popHtml = angular.element('
          <div class="popover fade bottom ledgerPopDiv" id="popid_{{index}}">
          <div class="arrow"></div>
          <h3 class="popover-title" ng-if="ftype == \'Update\'">Update entry</h3>
          <h3 class="popover-title" ng-if="ftype == \'Add\'">Add new entry</h3>
          <div class="popover-content">
            <div class="mrT">
              <div class="form-group" ng-show="noResults">
                <a href="javascript:void(0)" ng-click="addNewAccount()">Add new account</a>
              </div>
              <div class="row">
                <div class="col-md-6 col-sm-12">
                  <div class="form-group">
                    <select class="form-control" name="voucherType" ng-model="item.voucher.shortCode">
                      <option
                        ng-repeat="option in voucherTypeList"
                        ng-selected="{{option.shortCode == item.voucher.shortCode}}"
                        value="{{option.shortCode}}">
                        {{option.name}}
                      </option>
                    </select>
                  </div>
                  <div class="form-group">
                    <input type="text" name="tag" class="form-control" ng-model="item.tag" placeholder="Tag" />
                  </div>
                </div>
                <div class="col-md-6 col-sm-12">
                  <div class="form-group" ng-if="ftype == \'Update\'">
                    <label>Vouher no. </label>
                    {{item.voucher.shortCode}}-{{item.voucherNo}}
                  </div>
                  <div class="form-group">
                    <textarea class="form-control" name="description" ng-model="item.description" placeholder="Description"></textarea>
                  </div>
                </div>
              </div>
              <div class="">
                <button ng-if="ftype == \'Update\'" class="btn btn-success"
                  type="button" ng-disabled="drEntryForm_{{index}}.$invalid"
                  ng-click="updateLedger({entry: item})">Update</button>

                <button ng-if="ftype == \'Add\'" class="btn btn-success"
                  type="button" ng-disabled="drEntryForm_{{index}}.$invalid || noResults"
                  ng-click="addLedger({entry: item})">Add</button>

                <button ng-click="removeLedgdialog(); resetEntry(item, lItem)" class="btn btn-default mrL1" type="button">close</button>

                <button ng-show="item.uniqueName != undefined" class="pull-right btn btn-danger" ng-click="discardLedger({entry: item})">Delete Entry</button>
              </div>
            </div>
          </div>
        </div>')

      if childCount == 1
        angular.copy(item, scope.lItem)
        scope.removeLedgerDialog("all")
        $compile(popHtml)(scope)
        elem.append(popHtml)
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
