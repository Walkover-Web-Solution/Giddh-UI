'use strict'

angular.module('giddhWebApp').service('$confirm',
  ($modal, $confirmModalDefaults) ->
    $confirm =
      openModal: (data, settings) ->
        settings = angular.extend($confirmModalDefaults, settings or {})
        data = angular.extend({}, settings.defaultLabels, data or {})
        if 'templateUrl' of settings and 'template' of settings
          delete settings.template
        settings.resolve =
          data: () ->
            data
        $modal.open(settings).result

    $confirm
)