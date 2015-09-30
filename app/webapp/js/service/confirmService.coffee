'use strict'

angular.module('giddhWebApp').service('$confirm',
  ($modal, $confirmModalDefaults) ->
   (data, settings) ->
      console.log "in confirm service"
      settings = angular.extend($confirmModalDefaults, settings or {})
      data = angular.extend({}, settings.defaultLabels, data or {})
      if 'templateUrl' of settings and 'template' of settings
        delete settings.template
      settings.resolve = data: () ->
        data
      console.log "in confirm service"
      $modal.open(settings).result
)