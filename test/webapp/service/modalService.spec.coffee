'use strict'

describe 'modal Service', ->
  beforeEach module("giddhWebApp")

  beforeEach inject ($injector) ->
    @service = $injector.get('modalService')
    @uibModal = $injector.get('$uibModal')
    @confirmModalDefaults = $injector.get('$confirmModalDefaults')

  it 'should call $uibModal.open', ->
    spyOn(@uibModal, "open").andReturn({result: "ok"})
    @service.openConfirmModal()
    expect(@uibModal.open).toHaveBeenCalled()

  it 'should override the defaults with settings passed in', ->
    setting = {'template': 'hello'}
    spyOn(@uibModal, "open").andReturn({result: setting})

    result = @service.openConfirmModal({}, setting)
    expect(result).toBe(setting)

  it 'should override the default labels with the data passed in', ->
    data = {title: 'Title'}
    spyOn(@uibModal, "open").andReturn({result: data})

    result = @service.openConfirmModal(data)
    expect(result).toBe(data)

  it 'should remove template if templateUrl is passed in', ->
    setting = {templateUrl: 'abc.txt'}
    spyOn(@uibModal, "open").andReturn({result: setting})

    result = @service.openConfirmModal({}, setting)
    expect(result.template).not.toBeDefined()
    