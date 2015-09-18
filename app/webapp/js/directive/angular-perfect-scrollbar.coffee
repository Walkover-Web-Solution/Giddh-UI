angular.module('perfect_scrollbar', []).directive 'perfectScrollbar', [
  '$parse'
  '$window'
  ($parse, $window) ->
    psOptions = [
      'wheelSpeed'
      'wheelPropagation'
      'minScrollbarLength'
      'useBothWheelAxes'
      'useKeyboard'
      'suppressScrollX'
      'suppressScrollY'
      'scrollXMarginOffset'
      'scrollYMarginOffset'
      'includePadding'
    ]
    {
      restrict: 'EA'
      transclude: true
      template: '<div><div ng-transclude></div></div>'
      replace: true
      link: ($scope, $elem, $attr) ->
        jqWindow = angular.element($window)
        options = {}

        update = (event) ->
          $scope.$evalAsync ->
            if $attr.scrollDown == 'true' and event != 'mouseenter'
              setTimeout (->
                $($elem).scrollTop $($elem).prop('scrollHeight')
                return
              ), 100
            $elem.perfectScrollbar 'update'
            return
          return

        i = 0
        l = psOptions.length
        while i < l
          opt = psOptions[i]
          if $attr[opt] != undefined
            options[opt] = $parse($attr[opt])()
          i++
        $scope.$evalAsync ->
          $elem.perfectScrollbar options
          onScrollHandler = $parse($attr.onScroll)
          $elem.scroll ->
            scrollTop = $elem.scrollTop()
            scrollHeight = $elem.prop('scrollHeight') - $elem.height()
            $scope.$apply ->
              onScrollHandler $scope,
                scrollTop: scrollTop
                scrollHeight: scrollHeight
              return
            return
          return
        # This is necessary when you don't watch anything with the scrollbar
        $elem.bind 'mouseenter', update('mouseenter')
        # Possible future improvement - check the type here and use the appropriate watch for non-arrays
        if $attr.refreshOnChange
          $scope.$watchCollection $attr.refreshOnChange, ->
            update()
            return
        # this is from a pull request - I am not totally sure what the original issue is but seems harmless
        if $attr.refreshOnResize
          jqWindow.on 'resize', update
        $elem.bind '$destroy', ->
          jqWindow.off 'resize', update
          $elem.perfectScrollbar 'destroy'
          return
        return

    }
]
