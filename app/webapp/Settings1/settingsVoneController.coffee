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
    { sizeX: 2, sizeY: 1, row: 1, col: 0, name: "widget 1" }
  ]
  @gridsterOptions = {
    columns: 2,
    pushing: true,
    floating: true,
    swapping: false,
    width: 'auto',
    colWidth: 'auto',
    rowHeight: 200, 
    margins: [10, 10], # the pixel distance between each widget
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
       handles: ['n', 'e', 's', 'w', 'ne', 'se', 'sw', 'nw']
    },
    draggable: {
       enabled: true 
       # handle: '.my-class'
    }
  }
  

  # assign universal this for ctrl
  $this = @;

  @showAddTemplate = ->
    console.log "in showAddTemplate"
    $this.showTemplate = true

  @addWidget = ->
    console.log($this.tempType)
    newWidget = { sizeX: 2, sizeY: 1, row: 1, col: 0, name: "widget" }
    $this.widgets.push(newWidget)

  @removeWidget = (w) ->
    index = $this.widgets.indexOf(w)
    $this.widgets.splice index, 1
    

  
  return

SettingsVoneController.$inject = ['$rootScope']

giddh.webApp.controller('settingsVoneController', SettingsVoneController)