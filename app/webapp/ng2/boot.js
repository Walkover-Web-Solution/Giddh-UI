
// Boot NG2 App
var upgradeAdapter = new ng.upgrade.UpgradeAdapter();

angular.element(document.body).ready(function() {
  upgradeAdapter.bootstrap(document.body, ['giddhWebApp']);
});

// register and downgrade ng2 components to ng1 directives
app.directive('auditLogs', upgradeAdapter.downgradeNg2Component(app.AuditLogs));
app.directive('getLogs', upgradeAdapter.downgradeNg2Component(app.getLogs));
app.directive('loadMore', upgradeAdapter.downgradeNg2Component(app.loadMore));
