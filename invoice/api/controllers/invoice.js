'use strict';

const pug = require('pug');
const fs = require('fs');
const phantom = require("phantom-html-to-pdf")
({
  phantomPath: require("phantomjs-prebuilt").path,
  tmpDir: '/home/app-downloads/',
  numberOfWorkers: 2,
});
var invoice = {};

invoice.downloadInvoice = function(req, res) {
  var invoiceObj = req.body.invoice[0];
  //if(invoiceObj.template.uniqueName == "template_b") {
  // const bodyCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/test.pug') 
  // const footerCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/test_foot_b.pug') 
  //}
  //else
  //{
  console.log(req);
  const bodyCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/template_a.pug');
  const footerCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/footer_a.pug');
  
  //  //}
  var companyIdentitiesDataArray = invoiceObj.companyIdentities.data.split(",");
  var footerResource = (footerCompiledFunction({
  companyIdentitiesData: companyIdentitiesDataArray,
  terms: invoiceObj.terms,
  companyData: invoiceObj.company.data,
  companyName: invoiceObj.company.name
  }));
  
 //  var footerResource = (footerCompiledFunction({
 //  companyIdentitiesData: invoiceObj.companyIdentities.data,
 //  terms: invoiceObj.terms
 //  })); 
 
  var htmlRes = (bodyCompiledFunction({
    name: invoiceObj.account.name,
    invoiceNumber: invoiceObj.invoiceDetails.invoiceNumber,
    companyName: invoiceObj.company.name,
    companyData: invoiceObj.company.data,
    logo: invoiceObj.logo.path,
    grandTotal: invoiceObj.grandTotal,
    subTotal: invoiceObj.subTotal,
    invoiceDate: invoiceObj.invoiceDetails.invoiceDate,
    entries: invoiceObj.entries,
    taxes: invoiceObj.taxes,
    roundOff: invoiceObj.roundOff,
    signatureData: invoiceObj.signature.data,
    terms: invoiceObj.terms,
    companyIdentitiesData: companyIdentitiesDataArray,
    totalAsWords: invoiceObj.totalAsWords,
    accountNameForInvoice: invoiceObj.account.name,
    accountAttentionToForInvoice: invoiceObj.account.attentionTo,
    accountEmailForInvoice: invoiceObj.account.email,
    accountMobileNumber: invoiceObj.account.mobileNumber 
  }));
 // var footerRes = fs.readFileSync('./api/models/invoice/templates/footer.html', 'utf8');
  
  var response = {};
  var fileName = '';
  phantom(
    { 
      html: htmlRes, 
      footer: footerResource, 
      paperSize: {
      footerHeight: '3.2in'
      }, 
    }, 
    function(err, pdf) {
      if(err) {
        console.log(err);
        response.status = 'error';
        response.body = JSON.stringify(err);
        res.send(err);
      }
      var pdfPath = pdf.stream.path;
      response.status = 'success';
      response.body = pdfPath.substring(0, pdfPath.lastIndexOf('.'));
      res.send(response);
      phantom.kill();
    }
  );
};

module.exports = invoice;
