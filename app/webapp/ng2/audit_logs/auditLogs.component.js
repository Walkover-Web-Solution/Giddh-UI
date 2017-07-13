// Component: Audit Logs

(function(app) {

    var locals = {};
    var httpService = app.AuditLogsHttpService;
    var toastr = app.toastr;
    locals.filters = ["create", "delete", "share", "unshare", "move", "merge", "unmerge", "delete-all", "update", "master-import", "daybook-import", "ledger-excel-import"];

    locals.entity = ["company", "group", "account", "ledger", "voucher", "logs"];

    var sharedService = function() {
        sharedService.prototype.update = new ng.core.EventEmitter();
        sharedService.prototype.updateData = function(req) {
            this.update.next(req);
        }
    };

    var AuditLogs =
        ng.core.Component({
            selector: 'audit-logs',
            providers: [ng.http.HTTP_PROVIDERS, httpService, sharedService],
            templateUrl: '/public/webapp/ng2/audit_logs/audit-logs.html',
        })
        .Class({
            constructor: [ng.http.Http, httpService, sharedService, function(http, service, shared) {
                this.result = {};
                this.http = http;
                this.service = service;
                this.logs = [];
                this.shared = shared;
            }],

            ngOnInit: function() {
                this.subscription = this.shared.update
                    .subscribe(function(res) {
                        if (res.reqBody.page > 1) {
                            for (i = 0; i < res.logs.length; i++) {
                                this.logs.push(res.logs[i]);
                            }
                        } else {
                            this.logs = res.logs;
                        }

                    }.bind(this), function(error) {
                        error = JSON.parse(error._body);
                        toastr.error(error.code);
                    });
            }
        });



    var getLogs = ng.core.Component({
            selector: 'get-logs',
            providers: [ng.http.HTTP_PROVIDERS, httpService, sharedService],
            template: "<button class='btn btn-success pull-left mrT2' (click)='getLogfilters()' >Get Logs</button>"
        })
        .Class({
            constructor: [ng.http.Http, httpService, sharedService, function(http, service, shared) {
                this.result = {};
                this.http = http;
                this.service = service;
                this.reqBody = {};
                this.shared = shared;

            }],

            getLogfilters: function() {
                var self = this;
                setTimeout(function() {
                    var reqBody = {};
                    options = app.logs.filterOptions;
                    reqBody.fromDate = options.selectedFromDate;
                    reqBody.toDate = options.selectedToDate;
                    reqBody.operation = options.selectedOption;
                    reqBody.entity = options.selectedEntity;
                    reqBody.userUniqueName = options.selectedUserUnq.userUniqueName;
                    reqBody.accountUniqueName = options.selectedAccountUnq.uniqueName;
                    reqBody.groupUniqueName = options.selectedGroupUnq.uniqueName;

                    if (options.selectedDateOption.value == 0) {
                        if (options.logOrEntry == "logDate") {
                            reqBody.logDate = options.selectedLogDate;
                            reqBody.fromDate = null;
                            reqBody.toDate = null;
                        } else if (options.logOrEntry == "entryDate") {
                            reqBody.entryDate = options.selectedEntryDate;
                            reqBody.fromDate = null;
                            reqBody.toDate = null;
                        }
                    } else {
                        reqBody.logDate = null;
                        reqBody.entryDate = null;
                    }

                    var req = {
                        body: {},
                        page: 1
                    }

                    var reqProps = Object.keys(reqBody);

                    for (i = 0; i < reqProps.length; i++) {
                        if (reqBody[reqProps[i]] != "" && reqBody[reqProps[i]] != undefined && reqBody[reqProps[i]] != null && reqBody[reqProps[i]] != 'All') {
                            req.body[reqProps[i]] = reqBody[reqProps[i]]
                        }
                    }

                    self.service.getLogs(req).subscribe(
                        function(res) {
                            setTimeout(function() {
                                this.result = JSON.parse(res._body);
                                var logTracker = {
                                    logs: this.result.body.logs,
                                    reqBody: req,
                                    totalPages: this.result.body.totalPages
                                }
                                self.shared.updateData(logTracker);
                            }, 100)
                        }.bind(self), // on Success

                        function(error) {
                            error = JSON.parse(error._body);
                            options.toastr.error(error.message)
                        }.bind(self)); //  on Error
                });

            }

        });

    var loadMore = ng.core.Component({
        selector: 'load-more',
        providers: [ng.http.HTTP_PROVIDERS, httpService, sharedService],
        template: "<button class='btn btn-success pull-left mrT2 mrB2' (click)='loadMoreLogs()' *ngIf='page > 0 && page < totalPages'>Load More</button>"
    }).Class({
        constructor: [ng.http.Http, httpService, sharedService, function(http, service, shared) {
            this.result = {};
            this.http = http;
            this.service = service;
            this.req = {};
            this.shared = shared;
            this.page = 0;
            this.totalPages = 0;
        }],
        ngOnInit: function() {
            this.subscription = this.shared.update
                .subscribe(function(res) {
                    this.req = res.reqBody;
                    this.page = this.req.page;
                    this.totalPages = res.totalPages;
                    //console.log(res, this.page, this.totalPages)
                }.bind(this), function(error) {
                    error = JSON.parse(error._body);
                    //toastr.error(error.code, error.message);
                });
        },

        loadMoreLogs: function() {
            var options = app.logs.filterOptions;
            var self = this;

            setTimeout(function() {
                req = self.req;
                req.page += 1;
                self.service.getLogs(req).subscribe(
                    function(res) {
                        setTimeout(function() {
                            self.result = JSON.parse(res._body);
                            var logTracker = {
                                logs: self.result.body.logs,
                                reqBody: self.req,
                                totalPages: this.result.body.totalPages
                            }
                            self.shared.updateData(logTracker);
                        })
                    }.bind(self), // on Success

                    function(error) {
                        error = JSON.parse(error._body);
                        options.toastr.error(error.message)
                    }.bind(self)); //  on Error
            }, 100)
        }

    })

    app.AuditLogs = AuditLogs;
    app.getLogs = getLogs;
    app.sharedService = sharedService;
    app.loadMore = loadMore;

})(app = window.giddh.webApp || (window.giddh.webApp = {}));