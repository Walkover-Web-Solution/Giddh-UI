'use strict';

var settings = require('../../../public/routes/util/settings');
const pug = require('pug');
const fs = require('fs');
const phantom = require("phantom-html-to-pdf")
({
  phantomPath: require("phantomjs-prebuilt").path,
  tmpDir: settings.giddhPdfPath,
  numberOfWorkers: 2,
});
var invoice = {};

invoice.downloadInvoice = function(req, res) {

  var invoiceObj = req.body.invoice[0];
  
  const headerCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/invoice_gst_header.pug');
  const bodyCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/invoice_gst_body.pug');
  const footerCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/invoice_gst_footer.pug');
  

  var headerRes =(headerCompiledFunction({
    invoiceDate: invoiceObj.invoiceDetails.invoiceDate,
    invoiceNumber: invoiceObj.invoiceDetails.invoiceNumber,
    companyName: invoiceObj.company.name,
    companyData: invoiceObj.company.data,
    showTaxes: invoiceObj.gstDetails.showTaxes,
    grandTotal: invoiceObj.grandTotal,
    companyGstDetailsObject : invoiceObj.gstDetails.companyGstDetails
  }));

  var bodyRes = (bodyCompiledFunction({
    name: invoiceObj.account.name,
    //invoice details
    invoiceDueDate : invoiceObj.invoiceDetails.dueDate,
    //company details
    companyName: invoiceObj.company.name,
    companyData: invoiceObj.company.data,
    logo: invoiceObj.logo.path,
    //various totals
    taxTotal: invoiceObj.taxTotal,
    grandTotal: invoiceObj.grandTotal,
    subTotal: invoiceObj.subTotal,
    totalAsWords: invoiceObj.totalAsWords,
    gstEntriesTotal : invoiceObj.gstDetails.gstEntriesTotal,
    gstTaxableValueTotal :invoiceObj.gstDetails.gstTaxableValueTotal,
    gstEntries : invoiceObj.gstDetails.gstEntries,
    gstDetails : invoiceObj.gstDetails,
    //both addresses billing and shipping 
    accountBillingAddressObject : invoiceObj.gstDetails.accountGstBillingDetails,
    accountShippingAddressObject :  invoiceObj.gstDetails.accountGstShippingDetails,
    //flags
    showHsn: invoiceObj.gstDetails.showHsn,
    showSac: invoiceObj.gstDetails.showSac,
    showQty: invoiceObj.gstDetails.showQty,
    showRate: invoiceObj.gstDetails.showRate,
    showDiscount: invoiceObj.gstDetails.showDiscount,
    showTaxes: invoiceObj.gstDetails.showTaxes,
    //taxes
    gstTaxesForHeaders: invoiceObj.gstDetails.gstTaxesTotal,
    entries: invoiceObj.entries,
    taxes: invoiceObj.taxes,
    roundOff: invoiceObj.roundOff,
    signatureData: invoiceObj.signature.data,
    terms: invoiceObj.terms,
    companyIdentitiesData: companyIdentitiesDataArray,
    accountNameForInvoice: invoiceObj.account.name,
    accountAttentionToForInvoice: invoiceObj.account.attentionTo,
    accountEmailForInvoice: invoiceObj.account.email,
    accountMobileNumber: invoiceObj.account.mobileNumber 
  }));


  var companyIdentitiesDataArray = invoiceObj.companyIdentities.data.split(",");
  var footerResource = (footerCompiledFunction({
    companyIdentitiesData: companyIdentitiesDataArray,
    terms: invoiceObj.terms,
    companyData: invoiceObj.company.data,
    companyName: invoiceObj.company.name,
    companyAddressGst : invoiceObj.gstDetails.companyGstDetails.address
  }));
  
  
  var response = {};
  var fileName = '';
  phantom(
    { 
      header: headerRes,
      html: bodyRes, 
      footer: footerResource, 
      paperSize: {
        footerHeight: '2.4in',
        headerHeight: '1.8in'
      }
    }, 
    function(err, pdf) {
      if(err) {
        response.status = 'error';
        response.body = JSON.stringify(err);
        res.send(err);
      }
      if(pdf === undefined) {
        response.status = 'error';
        response.body = "Something went wrong while generating PDF";
        res.send(response);
      }
      else{
        var pdfPath = pdf.stream.path;
        response.status = 'success';
        response.body = pdfPath;
        res.send(response);
        phantom.kill();
      }
    }
  );
};

module.exports = invoice;
