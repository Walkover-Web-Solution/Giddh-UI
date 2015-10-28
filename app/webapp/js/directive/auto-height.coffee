angular.module('twygmbh.auto-height', []).
directive 'autoHeight', ['$window', '$timeout', ($window, $timeout) ->
  link: ($scope, $element, $attrs) ->
    combineHeights = (collection) ->
      heights = 0
      heights += node.offsetHeight for node in collection
      heights

    siblings = ($elm) ->
      elm for elm in $elm.parent().children() when elm != $elm[0]

    angular.element($window).bind 'resize', ->
      additionalHeight = $attrs.additionalHeight || 0
      parentHeight = $window.innerHeight - $element.parent()[0].getBoundingClientRect().top
      $element.css('height', (parentHeight - combineHeights(siblings($element)) - additionalHeight) + "px")

    $timeout ->
      angular.element($window).triggerHandler('resize')
    , 1000
]

angular.module('valid-number', []).
directive 'validNumber', ->
  {
    require: '?ngModel'
    link: (scope, element, attrs, ngModelCtrl) ->
      if !ngModelCtrl
        return
      ngModelCtrl.$parsers.push (val) ->
        `var val`
        if angular.isUndefined(val)
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
      element.bind 'keypress', (event) ->
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
        `var val`
        if angular.isUndefined(val)
          val = ''
        clean = val.replace(/[^0-9\-]/g, '')
        hyphenCheck = clean.split('-')
        if !angular.isUndefined(hyphenCheck[2])
          clean = hyphenCheck[0] + '-' + hyphenCheck[1] + '-' + hyphenCheck[2]
        if val != clean
          ngModelCtrl.$setViewValue clean
          ngModelCtrl.$render()
        clean
      element.bind 'keypress', (event) ->
        element.removeClass('error')
        if event.keyCode == 32
          event.preventDefault()
        return
      element.bind 'focus', () ->
        if element.context.value is "" || element.context.value is undefined || element.context.value is null
          element.context.value = $filter('date')(new Date(),"dd-MM-yyyy")

      element.bind 'blur', () ->
        if moment(element.context.value, "DD-MM-YYYY", true).isValid()
          element.removeClass('error')
        else
          toastr.error("Date is not valid.", "Error")
          element.addClass('error')
      return

  }


angular.module('ledger', []).directive 'ledgerPop', ($compile) ->
  {
    restrict: 'A'
    replace: false
    transclude: false
    scope:
      index: '=index'
      item: '=itemdata'
      aclist: '=acntlist'
    template: "<div ng-click='openDialog(item, index)'>
          <table class='table ldgrInnerTbl'>
            <tr>
              <td width='28%'>
                <input type='text' class='nobdr'
                  tabindex='-1'
                  name='drEntryForm_{{index}}.entryDate' 
                  ng-model='item.entryDate' valid-date/>
              </td>
              <td width=v44%'>
                <input type='hidden'  class='nobdr'
                  name='drEntryForm_{{index}}.trnsUniq'
                  ng-model='item.transactions[0].particular.uniqueName'>
                <input type='text'
                  tabindex='-1'  class='nobdr'
                  name='drEntryForm_{{index}}.trnsName'
                  ng-model='item.transactions[0].particular.name'
                  typeahead='obj as obj.name for obj in aclist | filter:$viewValue | limitTo:8'
                  class='form-control'
                  typeahead-no-results='noResults'
                  typeahead-on-select='addCrossFormField($item, $model, $label)'>
              </td>
              <td width='28%'>
                <input type='text'  class='nobdr'
                  tabindex='-1'
                  name='drEntryForm_{{index}}.amount' 
                  ng-model='item.transactions[0].amount'
                  valid-number/>
              </td>
            </tr>
          </table>
        </div>"
    controller: 'ledgerController'
    controllerAs: 'ctrl'
    link: (scope, elem, attrs) ->
      
      scope.removeDialog = (type) ->
        allPopElem = angular.element(document.querySelector('.ledgerPopDiv'))
        allPopElem.remove()
        return true

      scope.openDialog = (item, index) ->
        rect = elem.context.getBoundingClientRect()
        childCount = elem.context.childElementCount
        # console.log rect, childCount
        popHtml = angular.element('
          <div class="popover fade bottom ledgerPopDiv" id="popid_{{index}}">
          <div class="arrow"></div>
          <h3 class="popover-title">Update Entry</h3>
          <div class="popover-content">
            <div class="">
              <div class="form-group clearfix">
                <a class="pull-left" ng-show="noResults" href="javascript:void(0)" ng-click="addNewAccount()">Add new account</a>
                <a href="javascript:void(0)" class="pull-right" ng-click="discardEntry()">Discard</a>
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
                    <input type="text" name="tag" class="form-control" ng-model="item.tag" />
                  </div>
                </div>
                <div class="col-md-6 col-sm-12">
                  <textarea class="form-control" name="description" ng-model="item.description"></textarea>
                </div>
              </div>
              <div class="">
                <button class="btn btn-primary" type="button" ng-click="updateEntry(item)">Update</button>
                <button ng-click="removeDialog()" class="btn" type="button">close</button>
              </div>
            </div>
          </div>
        </div>')
        
        if childCount == 1
          scope.removeDialog("all")
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
  }
