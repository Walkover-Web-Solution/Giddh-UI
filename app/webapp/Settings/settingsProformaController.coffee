settingsProformaController = ($rootScope, Upload, $timeout, toastr, settingsService, $http,invoiceService) ->
  @Upload = Upload
  @$rootScope = $rootScope
  @$timeout = $timeout
  @toastr = toastr
  # assign universal this for ctrl
  $this = @;
  
  @showTemplate = false
  @tempTypes = [ "Image", "String", "Entry"]
  @tempType = "String"
  @showtoolbar = false
  @selectedTemplate = {}
  @updateTemplate = false
  @templateList = {}

  @people = [
    { label: 'Joe'},
    { label: 'Mike'},
    { label: 'Diane'}
  ]
  

  @widgetsModel = () ->
    @model =  [
      { sizeX: 8, sizeY: 4, row: 1, col: 0, name: "widget_0", data:"", type: 'Image' , edit:false}
      { sizeX: 8, sizeY: 4, row: 1, col: 8, name: "widget_1", data:"", type: 'String' , edit:false}
      { sizeX: 8, sizeY: 4, row: 1, col: 17, name: "widget_2", data:"", type: 'String', edit:false}
      { sizeX: 12, sizeY: 4, row: 2, col: 0, name: "widget_3", data:"", type: 'String', edit:false}
      { sizeX: 12, sizeY: 4, row: 2, col: 13, name: "widget_4", data:"", type: 'String', edit:false}
      { sizeX: 24, sizeY: 5, row: 3, col: 0, name: "widget_5", data:"Particular will be shown here", type: 'Entry' , edit:false}
      { sizeX: 12, sizeY: 4, row: 4, col: 0, name: "widget_6", data:"", type: 'String', edit:false}
      { sizeX: 12, sizeY: 4, row: 4, col: 13, name: "widget_7", data:"", type: 'String', edit:false}
      { sizeX: 24, sizeY: 3, row: 5, col: 0, name: "widget_8", data:"", type: 'String' , edit:false}   
    ]

  # gridstack vars
  @widgets = new @widgetsModel()

  @gridsterOptions = {
    columns: 24,
    pushing: true,
    floating: true,
    swapping: true,
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
       handle: '.move-widget'
    }
  }

  $rootScope.placeholders = [
    { name: 'Tyra Porcelli' } 
    { name: 'Brigid Reddish' }
    { name: 'Ashely Buckler' }
    { name: 'Teddy Whelan' }
  ]


  @showToolbar = () ->
    if !@showtoolbar
      $rootScope.tinymceOptions.toolbar = 'styleselect | bold italic'
    else
      $rootScope.tinymceOptions.toolbar = false
    @showtoolbar = !@showtoolbar

  @getAllTemplates = () ->
    @success = (res) ->
      $this.templateList = _.sortBy(res.body, 'name')
    @failure = (res) ->
      if res.data.code != "NOT_FOUND"
        toastr.error(res.data.message)
    reqparam = {
      companyUniqueName : $rootScope.selectedCompany.uniqueName
    }
    settingsService.getAllTemplates(reqparam).then(@success, @failure)

  $this.parseData = (source, dest) ->
    _.each source.sections, (sec, sIdx) ->
      _.each dest.sections, (dec,dIdx) ->
        if sIDx == dIdx
          dec.styles.left = sec.leftOfBlock + '%'
          dec.styles.top = sec.topOfBlockt + '%'

  @getTemplate = (item, operation) ->
    @success = (res) ->
      @htmlData = JSON.parse(res.body.htmlData)
      # $this.parseData(res.body, @htmlData)
      $this.widgets = []
      $this.selectedTemplate = res.body
      $this.updateTemplate = true
      num = 0
      _.each($this.selectedTemplate.sections, (sect) ->
        pushThis = {}
        pushThis.col = sect.column
        pushThis.row = sect.row
        pushThis.data = sect.data
        pushThis.type = sect.entity
        pushThis.sizeX = sect.width
        pushThis.sizeY = sect.height
        pushThis.edit = false
        pushThis.name = "widget_" + num
        $this.widgets.push(pushThis)
        num = num + 1
      )
      $this.showTemplate = !$this.showTemplate
    @failure = (res) ->
      if res.data.code != "NOT_FOUND"
        toastr.error(res.data.message)
    reqparam = {
      companyUniqueName : $rootScope.selectedCompany.uniqueName
      templateUniqueName : item.uniqueName
      operation:operation
    }
    settingsService.getTemplate(reqparam).then(@success, @failure)


  @deleteTemplate = (item) ->
    @success = (res) ->
      toastr.success(res.body)
      $this.getAllTemplates()
    @failure = (res) ->
      toastr.error(res.data.message)
    reqparam = {
      companyUniqueName : $rootScope.selectedCompany.uniqueName
      templateUniqueName : item.uniqueName
    }
    settingsService.deleteTemplate(reqparam).then(@success, @failure)

  @getPlaceholders = (query, process, delimeter) ->
    @success = (res) ->
      $rootScope.placeholders = []
      _.each(res.data.body, (param) ->
        addThis = {name: param}
        $rootScope.placeholders.push(addThis)
      )
      $rootScope.tinymceOptions.mentions.source = $rootScope.placeholders
    @failure = (res) ->
      toastr.error(res.data.message)
    reqparam = {
      companyUniqueName : $rootScope.selectedCompany.uniqueName
      type: 'proforma'
    }
    url = "company/" + $rootScope.selectedCompany.uniqueName + "/placeholders?type=" + reqparam.type
    $http.get(url, {reqParam: reqparam}).then(@success, @failure)


  @updateProformaTemplates = () ->
    @success = (res) ->
      toastr.success(res.body)
    @failure = (res) ->
      toastr.error(res.data.message)
    template = {}
    template.name = $this.selectedTemplate.name
    template.uniqueName = $this.selectedTemplate.uniqueName
    template.type = "proforma"
    template.sections = []
    template.htmlData = {}
    template.htmlData.sections = []
    template.variables = []
    _.each @widgets, (wid) ->
      widget = {}
      widget.height = wid.sizeY
      widget.width = wid.sizeX
      widget.entity = wid.type
      widget.column = wid.col
      widget.row = wid.row
      widget.data = wid.data
      template.sections.push(widget)
      section = {}
      section.styles = {}
      section.styles.height = widget.height/24 *100 + '%'
      section.styles.width = widget.width/24 *100 + '%'
      section.type = wid.type
      section.elements = himalaya.parse(wid.data)
      $this.formatEditables(section.elements)
      template.htmlData.sections.push(section)  
    template.htmlData = JSON.stringify(template.htmlData)
    console.log template.htmlData
    $this.matchVariables(template)
    reqparam = {}
    reqparam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    reqparam.templateUniqueName = template.uniqueName
    reqparam.operation = 'update'
    settingsService.update(reqparam, template).then(@success, @failure)

  $timeout ( ->
    $this.getPlaceholders()
    $this.getAllTemplates()
  ),2000

  $rootScope.tinymceOptions =
    onChange: (e) ->
      # put logic here for keypress and cut/paste changes
      return
    inline: false
    plugins: 'mention'
    skin: 'lightgray'
    theme: 'modern'
    menubar : false
    statusbar: false
    toolbar : 'styleselect | bold italic'
    delimiter : '$'
    mentions : {
      source: $rootScope.placeholders
    }

  # @modifyInput = (text,e) ->
  #   if e.keyCode == 13
  #     text += "<br/>"
  #   console.log text

  @resetTemplate = () ->
    @widgets = new @widgetsModel()

  @showAddTemplate = ->
    $this.resetTemplate()
    $this.showTemplate = !$this.showTemplate
    $this.updateTemplate = false

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

  $this.parseChildren = (data) ->
    _.each data, (el) ->
      if el.type == 'Element'
        if el.children.length > 0
          $this.parseChildren(el.children)
      if el.type == 'Text'
        if el.content == "\n"
          el.content = "<br>"
        if el.content == "&nbsp;"
          el.content = " "

  $this.matchVariables = (template) ->
    _.each $rootScope.placeholders, (ph) ->
      if template.htmlData.indexOf(ph.name) != -1
        template.variables.push(ph.name)
      if template.htmlData.indexOf('$accountName') != -1  && template.htmlData.indexOf("$accountUniqueName") == -1
        template.variables.push("$accountUniqueName")

  $this.formatEditables = (elements) ->
    _.each elements, (elem) ->
      if elem.type == 'Text'
        newElem = null
        _.each $rootScope.placeholders,(pl) ->
          if elem.type == 'Text' && elem.content.indexOf(pl.name) != -1 && elem.content != pl.name
            elem.content = elem.content.replace(pl.name, "<p>"+pl.name+"</p>")
            newElem = himalaya.parse(elem.content)
            elem.type = 'Element'
            elem.attributes = {}
            elem.tagName = 'p'
            delete elem.content
            elem.children = newElem
          else if elem.content == pl.name
            elem.hasVar = true
            elem.model = pl.name
      if elem.children != undefined && elem.children.length > 0
        $this.formatEditables(elem.children)

  @saveTemplate = ->
    @success = (res) ->
      toastr.success(res.body)
      $this.showTemplate = false
      $this.getAllTemplates()
    @failure = (res) ->
      toastr.error(res.data.message)

    if _.isUndefined($this.templateName) || _.isEmpty($this.templateName)
      $this.toastr.warning("Template name can't be empty", "Warning")
    else
      template = {}
      $this.convertSectionToHtmlData(template)
      $this.matchVariables(template)
      reqparam = {}
      reqparam.companyUniqueName = $rootScope.selectedCompany.uniqueName
      settingsService.save(reqparam, template).then(@success, @failure)


  @convertSectionToHtmlData = (template) ->
    template.name = $this.templateName
    template.type = "proforma"
    template.sections = []
    template.htmlData = {}
    template.htmlData.sections = []
    template.variables = []
    _.each @widgets, (wid) ->
      widget = {}
      widget.height = wid.sizeY
      widget.width = wid.sizeX
      widget.entity = wid.type
      widget.column = wid.col
      widget.row = wid.row
      widget.data = wid.data
      template.sections.push(widget)
      section = {}
      section.styles = {}
      section.styles.height = widget.height/24 *100 + '%'
      section.styles.width = widget.width/24 *100 + '%'
      section.type = wid.type
      section.elements = himalaya.parse(wid.data)
      $this.formatEditables(section.elements)
      template.htmlData.sections.push(section)

    template.htmlData = JSON.stringify(template.htmlData)
    return template

  @resetUpload =()->
    console.log("resetUpload")


  # upload Images
  @uploadImages =(files,type, item, reset)->
    angular.forEach files, (file) ->
      file.fType = type
#      console.log file
      fileData = {
        file: file
        fType: type
      }
      if reset
        fileData.file = ""
      file.upload = Upload.upload(
        url: '/upload/' + $rootScope.selectedCompany.uniqueName + '/logo'
        # file: file
        # fType: type
        data : fileData
      )
      file.upload.then ((res) ->
        item.data = res.data.body.path
        toastr.success("Logo uploaded successfully")
      ), ((res) ->
        toastr.failure("Logo Upload Failed")
      ), (evt) ->
        console.log "file upload progress" ,Math.min(100, parseInt(100.0 * evt.loaded / evt.total))

  @setDefTemp = (value) ->
    @success = (res) ->
      toastr.success("Default template changed successfully")
      $this.getAllTemplates()
    @failure = (res) ->
      toastr.failure(res.data.message)
    if value.isDefault
      reqParam = {}
      reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
      reqBody = {}
      reqBody.templateUniqueName = value.uniqueName
      invoiceService.setDefaultProformaTemplate(reqParam, reqBody).then(@success, @failure)

  return
settingsProformaController.$inject = ['$rootScope', 'Upload', '$timeout', 'toastr', 'settingsService', '$http','invoiceService']

giddh.webApp.controller('settingsProformaController', settingsProformaController)



