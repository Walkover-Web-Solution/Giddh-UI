SettingsVoneController = ($rootScope) ->
  @showTemplate = false
  @tabs = [
    {
      "heading": "Templates"
      "active": true
      "template":"/public/webapp/Settings1/invoice-temp.html"
    }
    {
      "heading": "Dummy"
      "active": false
      "template":"/public/webapp/Settings1/dummy-temp.html"
    }
  ]
  @tempTypes = [ "Image", "String", "Entry"]
  @tempType = "String"

  # gridstack vars
  @widgets = [
    { sizeX: 6, sizeY: 1, row: 1, col: 0, name: "widget_0", data:"", type: 'Image' }
    { sizeX: 6, sizeY: 1, row: 1, col: 9, name: "widget_1", data:"", type: 'Image' }
    { sizeX: 7, sizeY: 1, row: 1, col: 17, name: "widget_2", data:"", type: 'String'}
    { sizeX: 24, sizeY: 1, row: 2, col: 0, name: "widget_4", data:"", type: 'String' }
  ]
  @gridsterOptions = {
    columns: 24,
    pushing: true,
    floating: true,
    swapping: false,
    width: 'auto',
    colWidth: 'auto',
    rowHeight: 200, 
    margins: [5, 5], # the pixel distance between each widget
    outerMargin: true, # whether margins apply to outer edges of the grid
    sparse: false, # "true" can increase performance of dragging and resizing for big grid (e.g. 20x50)
    isMobile: false, # stacks the grid items if true
    mobileBreakPoint: 600, # if the screen is not wider that this, remove the grid layout and stack the items
    mobileModeEnabled: true, # whether or not to toggle mobile mode when screen width is less than mobileBreakPoint
    minColumns: 1, # the minimum columns the grid must have
    minRows: 2, # the minimum height of the grid, in rows
    maxRows: 20, 
    resizable: {
       enabled: true,
       handles: ['n', 'e', 's', 'ne', 'se', 'sw']
    },
    draggable: {
       enabled: true 
       # handle: '.my-class'
    }
  };

  # html editor option
  @toolbarOptions = [
    ['h1', 'h2', 'h3'],
    ['bold']
  ];
  # ['html', 'insertImage','insertLink', 'insertVideo', 'wordcount', 'charcount']
  

  # assign universal this for ctrl
  $this = @;

  @showAddTemplate = ->
    console.log "in showAddTemplate"
    $this.showTemplate = true

  @getWidgetArrLength = ->
    len = $this.widgets.length
    return "widget_"+len

  @addWidget = ->
    getLastWidName = $this.getWidgetArrLength()
    console.log($this.tempType, getLastWidName)
    newWidget = { sizeX: 12, sizeY: 1, row: 1, col: 0, name: getLastWidName, data:"", type: $this.tempType }
    $this.widgets.push(newWidget)

  @removeWidget = (w) ->
    index = $this.widgets.indexOf(w)
    $this.widgets.splice index, 1

  @saveTemplate = ->
    console.log($this.widgets, $this.templateName)
    console.log "hit api for saveTemplate"
    

  
  return

SettingsVoneController.$inject = ['$rootScope']

giddh.webApp.controller('settingsVoneController', SettingsVoneController)