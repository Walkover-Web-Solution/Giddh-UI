'use strict';

const pug = require('pug');
const fs = require('fs');
const phantom = require("phantom-html-to-pdf")
({
  phantomPath: require("phantomjs-prebuilt").path,
  tmpDir: '/tmp/',
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
        // console.log(err);
        // response.status = 'error';
        // response.body = JSON.stringify(err);
        res.send(err);
      }
       var pdfPath = pdf.stream.path;
      console.log(pdfPath);
      response.status = 'success';
      response.body = pdfPath.substring(0, pdfPath.lastIndexOf('.'));
      res.send(response);
      phantom.kill();
    }
  );
};

function bufferToArrayBuffer(buf) {
  var arrBuf = new ArrayBuffer(buf.length);
  var uArr = new Uint8Array(arrBuf);
  for (var i = 0; i < buf.length; ++i) {
    uArr[i] = buf[i];
  }
  return uArr;
}

function stringToUTF8ByteArray(str) {
  var utf8 = [];
  for (var i=0; i < str.length; i++) {
    var charcode = str.charCodeAt(i);
    if (charcode < 0x80) utf8.push(charcode);
    else if (charcode < 0x800) {
      utf8.push(0xc0 | (charcode >> 6), 0x80 | (charcode & 0x3f));
    }
    else if (charcode < 0xd800 || charcode >= 0xe000) {
      utf8.push(0xe0 | (charcode >> 12), 
        0x80 | ((charcode>>6) & 0x3f), 
        0x80 | (charcode & 0x3f));
    }
    // surrogate pair
    else {
      i++;
      // UTF-16 encodes 0x10000-0x10FFFF by
      // subtracting 0x10000 and splitting the
      // 20 bits of 0x0-0xFFFFF into two halves
      charcode = 0x10000 + (((charcode & 0x3ff)<<10)
        | (str.charCodeAt(i) & 0x3ff));
      
      utf8.push(0xf0 | (charcode >>18), 
        0x80 | ((charcode>>12) & 0x3f), 
        0x80 | ((charcode>>6) & 0x3f), 
        0x80 | (charcode & 0x3f));
    }
  }
  return utf8;
}

module.exports = invoice;
