'use strict'

giddh.serviceModule.service 'DAServices', () ->
  ledgerData = {}
  ledgerAccount = {}

  DAServices =
    LedgerGet: () ->
      {"ledgerData": ledgerData, "selectedAccount": ledgerAccount}

    LedgerSet: (data, account) ->
      ledgerData = data
      ledgerAccount = account

    ClearData: () ->
    	ledgerData = {}
    	ledgerAccount = {}
  DAServices