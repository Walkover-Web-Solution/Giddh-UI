'use strict'

describe '$confirm Service', ->

  beforeEach module("giddhWebApp")

  beforeEach inject ($injector, $modal, $confirmModalDefaults) ->
    @service = $injector.get('$confirm')
    @modal = $injector.get('$modal')
    @confirmModalDefaults = $injector.get('$confirmModalDefaults')
    



  it 'should call $modal.open', ->
    spyOn(@modal, "open")
    @service()
    expect(@modal.open).toHaveBeenCalled()
    
  # it 'should override the defaults with settings passed in', ->
  #   settings = $confirm({}, 'template': 'hello')
  #   expect(settings.template).toEqual 'hello'
    
  # it 'should override the default labels with the data passed in', ->
  #   settings = $confirm(title: 'Title')
  #   data = settings.resolve.data()
  #   expect(data.title).toEqual 'Title'
  #   expect(data.ok).toEqual 'OK'
    
  # it 'should remove template if templateUrl is passed in', ->
  #   settings = $confirm({}, templateUrl: 'abc.txt')
  #   expect(settings.template).not.toBeDefined()
    