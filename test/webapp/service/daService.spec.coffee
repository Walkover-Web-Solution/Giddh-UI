'use strict'

describe "Data Access Service", ->
  beforeEach module("serviceModule")

  beforeEach ->
    inject ($injector) ->
      @daService = $injector.get('DAServices')

  describe '#LedgerGet', ->
    it 'should set data in ledgerService', ->
      ledgerData = {"data": "dataDetails"}
      ledgerAccount = {"account": "accountDetail"}
      @daService.LedgerSet(ledgerData, ledgerAccount)
      result = @daService.LedgerGet()
      expect(result).toEqual({"ledgerData": ledgerData, "selectedAccount": ledgerAccount})

  describe '#LedgerSet', ->
    it 'should set value for service variable', ->
      data = {"data": "dataDetails"}
      account = {"account": "accountDetail"}
      @daService.LedgerSet(data, account)
      result = @daService.LedgerGet()
      expect(result).not.toEqual({})

  describe '#ClearData', ->
    it 'should clear ledgerService', ->
      data = {"data": "dataDetails"}
      account = {"account": "accountDetail"}
      spyOn(@daService, "LedgerSet")
      @daService.LedgerSet(data, account)
      result = @daService.ClearData()
      expect(result).toEqual({})
      