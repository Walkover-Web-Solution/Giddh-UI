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

