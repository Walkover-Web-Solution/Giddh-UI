SettingsInvoiceController = ($rootScope, Upload, $timeout, toastr) ->

  @Upload = Upload
  @$rootScope = $rootScope
  @$timeout = $timeout
  @toastr = toastr
  # assign universal this for ctrl
  $this = @;
  
  @showTemplate = false
  @tempTypes = [ "Image", "String", "Entry"]
  @tempType = "String"

  @peoples = [
    { label: 'Joe'},
    { label: 'Mike'},
    { label: 'Diane'}
  ]
  

  # gridstack vars
  @widgets = [
    { sizeX: 6, sizeY: 3, row: 1, col: 0, name: "widget_0", data:"", type: 'Image' }
    { sizeX: 6, sizeY: 2, row: 1, col: 9, name: "widget_1", data:"", type: 'String' }
    { sizeX: 7, sizeY: 2, row: 1, col: 17, name: "widget_2", data:"", type: 'String'}
    { sizeX: 24, sizeY: 2, row: 4, col: 0, name: "widget_4", data:"", type: 'String' }
  ]
  @gridsterOptions = {
    columns: 24,
    pushing: true,
    floating: true,
    swapping: false,
    width: 'auto',
    colWidth: 'auto',
    rowHeight: 50, 
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
       handles: ['e','s', 'se', 'sw', 'nw']
    },
    draggable: {
       enabled: true 
       handle: '.gridster-item-heading'
    }
  }

  @showAddTemplate = ->
    console.log "in showAddTemplate"
    $this.showTemplate = true

  @getWidgetArrLength = ->
    return $this.widgets.length

  @getLastRowPos = ->
    _.max($this.widgets, (obj)->
      return obj.row 
    )

  @checkEntryWidget = ->
    return _.findWhere($this.widgets, {type: 'Entry'})


  @addWidget = ->

    getLastRow = $this.getLastRowPos()
    getLastRowPos = getLastRow.row + getLastRow.sizeY
    getLastWidName = "widget_"+$this.getWidgetArrLength()
    
    # init obj with default param
    newWidget = { sizeX: 12, sizeY: 2, row: getLastRowPos, col: 0, name: getLastWidName, data:"", type: $this.tempType }
    
    # "Image", "String", "Entry", "Tosec"
    switch $this.tempType
      when 'Entry'
        # checking if already have entry widget than prevent user to add new one
        isHaveEntryWidgetObj = $this.checkEntryWidget()    
        if !_.isUndefined(isHaveEntryWidgetObj)
          $this.toastr.warning("Can't add more than once Entry widget", "Warning")
          return false
        else
          newWidget.sizeX = 24
          newWidget.sizeY = 4
          newWidget.maxSizeY= 4
      else
        console.log "Else case"

    $this.widgets.push(newWidget)

  @removeWidget = (w) ->
    index = $this.widgets.indexOf(w)
    $this.widgets.splice index, 1

  @saveTemplate = ->
    console.log($this.widgets, $this.templateName)
    if _.isUndefined($this.templateName) || _.isEmpty($this.templateName)
      $this.toastr.warning("Template name can't be empty", "Warning")
    else
      console.log "hit api for saveTemplate"

  @resetUpload =()->
    console.log("resetUpload")

  # upload Images
  @uploadImages =(files,type)->
    console.log(files,type, "uploadImages")
    

  
  return

SettingsInvoiceController.$inject = ['$rootScope', 'Upload', '$timeout', 'toastr']

giddh.webApp.controller('settingsInvoiceController', SettingsInvoiceController)