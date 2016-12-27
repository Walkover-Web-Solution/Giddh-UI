var gr = require('grunt');
if ( process.env.NODE_ENV == "production" ) {
	gr.tasks(['init-prod']);
} else {
	gr.tasks(['init']);
}
