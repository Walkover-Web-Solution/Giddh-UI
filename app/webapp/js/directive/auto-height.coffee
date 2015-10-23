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

angular.module('valid-date', []).
directive 'validDate', ->
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
        if event.keyCode == 32
          event.preventDefault()
        return
      return

  }


(->
  angular.module('ledger', []).directive 'giddhLedger', ->
    { link: (scope, ele, attrs) ->
      childs = undefined
      siblingDiv = undefined
      siblingDiv = ele.context.nextElementSibling
      childs = ele.context
      ele.bind 'mouseenter', ->
        # console.log("mouseenter", ele);
        return
      ele.bind 'mouseleave', ->
        #do nothing
        return
      return
 }
  angular.module('ledgerD', []).directive 'myForm', ->
    {
      restrict: 'E'
      scope: false
      transclude: true
      replace: true
      template: '<div>' + '<a href="" ng-transclude></a>' + 
      '<div ng-hide="!formVisible" ng-attr-popover="">' + 
      '<div class="form-group"><input type="text" class="form-control" name="extraForm.name"></div>' + 
      '<div class="form-group"><input type="text" class="form-control" name="extraForm.cname"></div>' + 
      '<div class="">' + 
      '<button ng-click="submit($event, extraForm)" type="button" class="btn btn-primary">OK</button>' + 
        '<button type="button" class="btn" ng-click="formVisible=false">close</button>' + 
          '</div>' + 
          '<div class="editable-error help-block" ng-show="error">{{ error }}</div>' + 
            '</div>' + 
            '</div>'
      controller: ($scope, $element, $attrs) ->
        $scope.formVisible = false

        $scope.submit = (evt, formdata) ->
          console.log formdata, 'form submit', evt
          $scope.formVisible = false
          return

        return

    }
  angular.module('ledgerB', []).directive 'popover', ($compile) ->
    {
      restrict: 'A'
      scope: false
      compile: (tElement, tAttrs, transclude) ->
        {
          pre: (scope, iElement, iAttrs, controller) ->
          post: (scope, iElement, iAttrs, controller) ->
            attrs = iAttrs
            element = iElement
            # We assume that the trigger (i.e. the element the popover will be
            # positioned at is the previous child.
            trigger = element.prev()
            popup = element
            # Connect scope to popover.
            trigger.on 'shown', ->
              tip = trigger.data('popover').tip()
              $compile(tip) scope
              scope.$digest()
              return
            trigger.popover
              html: true
              title: 'Hey DUDE'
              content: ->
                scope.$apply ->
                  scope.formVisible = true
                  return
                popup
              container: 'body'
            scope.$watch 'formVisible', (formVisible) ->
              console.log formVisible
              if !formVisible
                trigger.popover 'hide'
              return
            if trigger.data('popover')
              trigger.data('popover').tip().css 'width', '500px'
            return

        }

    }
  return
).call this

