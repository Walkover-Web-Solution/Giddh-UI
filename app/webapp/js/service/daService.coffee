'use strict'

angular.module('giddhWebApp').service 'DAServices', ($resource, $q) ->
  ledgerData = {}
  ledgerAccount = {}

  DAServices =
    LedgerGet: () ->
      {"ledgerData": ledgerData, "selectedAccount": ledgerAccount}

    LedgerSet: (data, account) ->
      ledgerData = data
      ledgerAccount = account

  DAServices