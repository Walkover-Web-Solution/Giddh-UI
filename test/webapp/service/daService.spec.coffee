'use strict'

describe "Data Access Service", ->
  beforeEach module("giddhWebApp")

  beforeEach ->
    inject ($injector) ->
      @daService = $injector.get('DAServices')

  describe '#ledger set and then check did we get it or not', ->
    it 'should set value for service variable and then get it', ->
      ledgerData = {"data": "dataDetails"}
      ledgerAccount = {"account": "accountDetail"}
      @daService.LedgerSet(ledgerData, ledgerAccount)
      result = @daService.LedgerGet()
      expect(result).toEqual({"ledgerData": ledgerData, "selectedAccount": ledgerAccount})