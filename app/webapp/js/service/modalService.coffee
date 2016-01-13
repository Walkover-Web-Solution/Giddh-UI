'use strict'

# confirm modal settings
giddh.serviceModule.value('$confirmModalDefaults',
  templateUrl: '/public/webapp/views/confirmModal.html',
  controller: 'ConfirmModalController',
  defaultLabels:
    title: 'Confirm'
    ok: 'OK'
    cancel: 'Cancel')

giddh.serviceModule.service('modalService',
  ($uibModal, $confirmModalDefaults, $rootScope) ->
    modalService =
      openConfirmModal: (data, settings) ->
        settings = angular.extend($confirmModalDefaults, settings or {})
        data = angular.extend({}, settings.defaultLabels, data or {})
        if 'templateUrl' of settings and 'template' of settings
          delete settings.template
        settings.resolve =
          data: () ->
            data
        $uibModal.open(settings).result

      openManageGroupsModal: () ->
        $uibModal.open(
          templateUrl: '/public/webapp/views/addManageGroupModal.html'
          size: "liq90"
          backdrop: 'static'
          controller: 'groupController'
        )
      openImportListModal: (data, showImportListData) ->
        $uibModal.open(
          templateUrl: '/public/webapp/views/openImportListModal.html'
          size: "md"
          backdrop: 'static'
          controller: 'accountController'
        )
    modalService
)