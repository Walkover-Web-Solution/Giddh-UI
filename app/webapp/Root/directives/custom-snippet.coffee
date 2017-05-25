angular.module('custom_snippet_giddh', [])
  .filter 'propsFilter', ->
    (items, props) ->
      out = []
      if angular.isArray(items)
        keys = Object.keys(props)
        items.forEach (item) ->
          itemMatches = false
          i = 0
          while i < keys.length
            prop = keys[i]
            text = props[prop].toLowerCase()
            if item[prop].toString().toLowerCase().indexOf(text) != -1
              itemMatches = true
              break
            i++
          if itemMatches
            out.push item
          return
      else
        # Let the output be the input untouched
        out = items
      out


  .filter 'hilite', ($sce)->
    escapeRegexp = (queryToEscape) ->
      ('' + queryToEscape).replace /([.?*+^$[\]\\(){}|-])/g, '\\$1'
    (matchItem, query) ->
      if query and matchItem
        str = $sce.trustAsHtml('<span class="ui-select-hilite">$&</span>')
        ('' + matchItem).replace(new RegExp(escapeRegexp(query), 'gi'), str) 
      else 
        matchItem
