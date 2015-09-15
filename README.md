# README

The following is a quick guide to preparing the internal 'Giddh' web
application.

Prerequisites
-------------

* node 0.12.4
* npm 2.12.1
* bower 1.4.1
* grunt 0.4.5
* grunt-cli 0.1.13

Use [homebrew](http://mxcl.github.com/homebrew/) and [npm]() to install the stuff you need.

Usual build tasks
-----------------

* Single run over the Coffee specs
`grunt test` or `grunt karma:unit`

* Watch over the Coffee specs
`grunt karma:continuous` or `grunt karma`

* To initialize project before starting server
`grunt init`

* Start server
`node server.js`

* Watch over the Coffee changes
`grunt coffee`

* Check coffee syntax
`grunt coffeelint`

