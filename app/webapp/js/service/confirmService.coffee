'use strict'

angular.module('giddhWebApp').service('$confirm',
  ($modal, $confirmModalDefaults) ->
    (data, settings) ->
      console.log data, "data and settings", settings

      settings = angular.extend($confirmModalDefaults, settings or {})

      data = angular.extend({}, settings.defaultLabels, data or {})

      if 'templateUrl' of settings and 'template' of settings
        delete settings.template

      settings.resolve = data: () ->
        data
        
      console.log settings, "pop up settings"
      $modal.open(settings).result
)