SettingsVoneController = ($rootScope, Upload, $timeout) ->

  @Upload = Upload
  @$rootScope = $rootScope
  # assign universal this for ctrl
  $this = @;
  

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
  @tempTypes = [ "Image", "String", "Entry", "Tosec"]
  @tempType = "String"

  @peoples = [
    { label: 'Joe'},
    { label: 'Mike'},
    { label: 'Diane'}
  ]
  @tinymceOptions = {
    inline: false
    menubar: false
    toolbar: 'bold italic | h1 h2 h3'
    skin: 'lightgray'
    theme : 'modern'
    statusbar: false
  };

  @tinymceOptionsWithMentio = {
    inline: false
    menubar: false
    toolbar: 'bold italic | h1 h2 h3'
    skin: 'lightgray'
    theme : 'modern'
    statusbar: false
    init_instance_callback: (editor) ->
      $this.iframeElement = editor.iframeElement
  };

  # gridstack vars
  @widgets = [
    { sizeX: 6, sizeY: 1, row: 1, col: 0, name: "widget_0", data:"", type: 'Image' }
    { sizeX: 6, sizeY: 1, row: 1, col: 9, name: "widget_1", data:"", type: 'Image' }
    { sizeX: 7, sizeY: 1, row: 1, col: 17, name: "widget_2", data:"", type: 'Tosec'}
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
       handles: ['n', 'e', 'w', 's', 'ne', 'se', 'sw', 'nw']
    },
    draggable: {
       enabled: true 
       # handle: '.my-class'
    }
  }

  @showAddTemplate = ->
    console.log "in showAddTemplate"
    $this.showTemplate = true

  @getWidgetArrLength = ->
    len = $this.widgets.length
    return "widget_"+len

  @addWidget = ->
    getLastWidName = $this.getWidgetArrLength()
    
    # init obj with default param
    newWidget = { sizeX: 12, sizeY: 1, row: 1, col: 0, name: getLastWidName, data:"", type: $this.tempType }

    console.log($this.tempType, getLastWidName)
    
    # "Image", "String", "Entry", "Tosec"
    switch $this.tempType
      when 'Entry'
        newWidget.sizeX = 24
      else
        console.log "Else"

    $this.widgets.push(newWidget)

  @removeWidget = (w) ->
    index = $this.widgets.indexOf(w)
    $this.widgets.splice index, 1

  @saveTemplate = ->
    console.log($this.widgets, $this.templateName)
    console.log "hit api for saveTemplate"

  @resetUpload =()->
    console.log("resetUpload")

  # upload Images
  @uploadImages =(files,type)->
    console.log(files,type, "uploadImages")
    

  
  return

SettingsVoneController.$inject = ['$rootScope', 'Upload', '$timeout']

giddh.webApp.controller('settingsVoneController', SettingsVoneController)