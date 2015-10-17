'use strict'

describe 'modal Service', ->
  beforeEach module("giddhWebApp")

  beforeEach inject ($injector) ->
    @service = $injector.get('modalService')
    @modal = $injector.get('$modal')
    @confirmModalDefaults = $injector.get('$confirmModalDefaults')

  it 'should call $modal.open', ->
    spyOn(@modal, "open").andReturn({result: "ok"})
    @service.openConfirmModal()
    expect(@modal.open).toHaveBeenCalled()

  it 'should override the defaults with settings passed in', ->
    setting = {'template': 'hello'}
    spyOn(@modal, "open").andReturn({result: setting})

    result = @service.openConfirmModal({}, setting)
    expect(result).toBe(setting)

  it 'should override the default labels with the data passed in', ->
    data = {title: 'Title'}
    spyOn(@modal, "open").andReturn({result: data})

    result = @service.openConfirmModal(data)
    expect(result).toBe(data)

  it 'should remove template if templateUrl is passed in', ->
    setting = {templateUrl: 'abc.txt'}
    spyOn(@modal, "open").andReturn({result: setting})

    result = @service.openConfirmModal({}, setting)
    expect(result.template).not.toBeDefined()
    