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
  var invoiceObj = req.body;
  //if(invoiceObj.template.uniqueName == "template_b") {
  // const bodyCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/test.pug') 
  // const footerCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/test_foot_b.pug') 
  //}
  //else
  //{
 

  //const bodyCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/template_a.pug');
  //const footerCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/footer_a.pug');
  console.log(invoiceObj.gstDetails.gstEntries[0].rate)
  const headerCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/invoice_gst_header.pug');
  const bodyCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/invoice_gst_body.pug');
  const footerCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/invoice_gst_footer.pug');
  

  // //}

  var headerRes =(headerCompiledFunction({
  invoiceDate: invoiceObj.invoiceDetails.invoiceDate,
  invoiceNumber: invoiceObj.invoiceDetails.invoiceNumber, 
  
  companyName: invoiceObj.company.name,
  companyData: invoiceObj.company.data,

  grandTotal: invoiceObj.grandTotal,
    
  //company gst details
  companyGstDetailsObject : invoiceObj.gstDetails.companyGstDetails
  }));
 //  var footerResource = (footerCompiledFunction({
 //  companyIdentitiesData: invoiceObj.companyIdentities.data,
 //  terms: invoiceObj.terms
 //  })); 
  var bodyRes = (bodyCompiledFunction({
    name: invoiceObj.account.name,
    //invoice details
    
    invoiceDueDate : invoiceObj.invoiceDetails.dueDate,
    //company details
    companyName: invoiceObj.company.name,
    companyData: invoiceObj.company.data,
    logo: invoiceObj.logo.path,
    //various totals
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
    //accountBillingAddressArray : invoiceObj.gstDetails.accountBillingAddress.address[0],
    //flags
    showHsn: invoiceObj.gstDetails.showHsn,
    showSac: invoiceObj.gstDetails.showSac,
    showQty: invoiceObj.gstDetails.showQty,
    showRate: invoiceObj.gstDetails.showRate,
    showDiscount: invoiceObj.gstDetails.showDiscount,
    showTaxes: invoiceObj.gstDetails.showTaxes,
    //taxes
    gstTaxesForHeaders: invoiceObj.gstDetails.gstTaxesTotal,
    
    // discountValue :   ,
    // taxableValue : ,
    // //all gsts that are applied on this entry transaction : for column making and data feeding
    // taxesGstArray : , 
      
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
 // var footerRes = fs.readFileSync('./api/models/invoice/templates/footer.html', 'utf8');

  
  
  var response = {};
  var fileName = '';
  phantom(
    { 
      header: headerRes,
      html: bodyRes, 
      footer: footerResource, 
      paperSize: {
      footerHeight: '3in',
      headerHeight: '2.2in'
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
      response.body = pdfPath;
      res.send(response);
      phantom.kill();
    }
  );
};

module.exports = invoice;
