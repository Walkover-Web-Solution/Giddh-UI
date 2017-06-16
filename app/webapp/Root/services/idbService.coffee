'use strict'

giddh.serviceModule.service 'idbService', [
  '$rootScope'
  ($rootScope) ->
    idbService = {}
    # set browser specific values
    #indexedDB = window.indexedDB or window.mozIndexedDB or window.webkitIndexedDB or window.msIndexedDB
    #IDBTransaction = window.IDBTransaction or window.webkitIDBTransaction or window.msIDBTransaction or READ_WRITE: 'readwrite'
    #IDBKeyRange = window.IDBKeyRange or window.webkitIDBKeyRange or window.msIDBKeyRange
    # create a new database

    idbService.openDb = (dbConfig) ->
      idbService.db = indexedDB.open(dbConfig.name, dbConfig.version)
      idbService.db.onsuccess = dbConfig.success
      idbService.db.onerror = dbConfig.failure
      idbService.db.onupgradeneeded = dbConfig.upgrade
      idbService.db.onblocked = dbConfig.onblocked
      return

    idbService
]
