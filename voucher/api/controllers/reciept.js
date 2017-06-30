'use strict';

const pug = require('pug');
const fs = require('fs');
const phantom = require("phantom-html-to-pdf")
({
  phantomPath: require("phantomjs-prebuilt").path,
  tmpDir: '/home/app-downloads/',
  numberOfWorkers: 1,
});


var reciept = {};

reciept.downloadReciept = function(req,res){

//response.status = 'success';
//response.body = pdfPath.substring(0, pdfPath.lastIndexOf('.'));
var recieptObj = req.body.reciept[0];

const recieptPug = pug.compileFile('./voucher/api/models/reciept/templates/reciept_a.pug');
//const recieptFoot = pug.compileFile('./voucher/api/models/reciept/templates/reciept_a_footer.pug')

var addressArray = [recieptObj.company.address,recieptObj.company.city,recieptObj.company.pincode,recieptObj.company.state, recieptObj.company.country];
var accountArray = [recieptObj.account.email,recieptObj.account.mobileNumber]
//#{companyCity} #{companyPincode} (#{companyState})   
var htmlRes =(recieptPug({
  voucherNumber: recieptObj.voucherNumber,
  voucherDate: recieptObj.voucherDate,
  voucherType: recieptObj.voucherType,

  companyName: recieptObj.company.name,
  companyCity: recieptObj.company.city,
  companyAddress: recieptObj.company.address,
  companyCountry: recieptObj.company.country,
  companyState: recieptObj.company.state,
  companyPincode: recieptObj.company.pincode,
  companyContactNumber: recieptObj.company.contactNo,
  companyEmail: recieptObj.company.email,
  logo: recieptObj.logo.path,
  chequeNumber : recieptObj.chequeNumber, 
  accountName: recieptObj.account.name,
  attentionTo: recieptObj.account.attentionTo,
  accountEmail: recieptObj.account.email,
  accountMobileNumber: recieptObj.account.mobileNumber,
  accountClosingBalance : recieptObj.accountClosingBalance.amount,
  grandTotal: recieptObj.grandTotal,
  taxTotal: recieptObj.taxTotal,
  subTotal : recieptObj.subTotal,
  addressDetailsArray :  addressArray,
  accountDetailsArray : accountArray,
  companyIdentitiesData : recieptObj.companyIdentity.data
}));

// footerResource = (recieptFoot({
//   addressDetailsArray :  addressArray,
//   companyIdentitiesData : recieptObj.companyIdentity.data,
//   companyName: recieptObj.company.name
// }))


  var response = {};
  var fileName = '';
  phantom(
    { 
      html: htmlRes, 
     // footer: footerResource, 
     // paperSize: {
     // footerHeight: '3.2in'
     // }, 
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
      response.body = pdfPath
      res.send(response);
      phantom.kill();
    }
  );
};

  


// 'use strict';

// const pug = require('pug');
// const fs = require('fs');
// const phantom = require("phantom-html-to-pdf")
// ({
//   phantomPath: require("phantomjs-prebuilt").path,
//   tmpDir: './invoice/download/',
//   numberOfWorkers: 2,
// });
// var invoice = {};

// invoice.downloadInvoice = function(req, res) {
//   var invoiceObj = req.body.invoice[0];
//   //if(invoiceObj.template.uniqueName == "template_b") {
//   // const bodyCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/test.pug') 
//   // const footerCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/test_foot_b.pug') 
//   //}
//   //else
//   //{
//   const bodyCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/template_a.pug');
//   const footerCompiledFunction = pug.compileFile('./invoice/api/models/invoice/templates/footer_a.pug');
  
//   //  //}
//   var companyIdentitiesDataArray = invoiceObj.companyIdentities.data.split(",");
//   var footerResource = (footerCompiledFunction({
//   companyIdentitiesData: companyIdentitiesDataArray,
//   terms: invoiceObj.terms,
//   companyData: invoiceObj.company.data,
//   companyName: invoiceObj.company.name
//   }));
  
//  //  var footerResource = (footerCompiledFunction({
//  //  companyIdentitiesData: invoiceObj.companyIdentities.data,
//  //  terms: invoiceObj.terms
//  //  })); 
 
//   var htmlRes = (bodyCompiledFunction({
//     name: invoiceObj.account.name,
//     invoiceNumber: invoiceObj.invoiceDetails.invoiceNumber,
//     companyName: invoiceObj.company.name,
//     companyData: invoiceObj.company.data,
//     logo: invoiceObj.logo.path,
//     grandTotal: invoiceObj.grandTotal,
//     subTotal: invoiceObj.subTotal,
//     invoiceDate: invoiceObj.invoiceDetails.invoiceDate,
//     entries: invoiceObj.entries,
//     taxes: invoiceObj.taxes,
//     roundOff: invoiceObj.roundOff,
//     signatureData: invoiceObj.signature.data,
//     terms: invoiceObj.terms,
//     companyIdentitiesData: companyIdentitiesDataArray,
//     totalAsWords: invoiceObj.totalAsWords,
//     accountNameForInvoice: invoiceObj.account.name,
//     accountAttentionToForInvoice: invoiceObj.account.attentionTo,
//     accountEmailForInvoice: invoiceObj.account.email,
//     accountMobileNumber: invoiceObj.account.mobileNumber 
//   }));
//  // var footerRes = fs.readFileSync('./api/models/invoice/templates/footer.html', 'utf8');
  
//   var response = {};
//   var fileName = '';
//   phantom(
//     { 
//       html: htmlRes, 
//       footer: footerResource, 
//       paperSize: {
//       footerHeight: '3.2in'
//       }, 
//     }, 
//     function(err, pdf) {
//       if(err) {
//         console.log(err);
//         response.status = 'error';
//         response.body = JSON.stringify(err);
//         res.send(err);
//       }
//       var pdfPath = pdf.stream.path;
//       response.status = 'success';
//       response.body = pdfPath.substring(0, pdfPath.lastIndexOf('.'));
//       res.send(response);
//       phantom.kill();
//     }
//   );
// };

 module.exports = reciept;
