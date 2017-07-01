'use strict';

var settings = require('../../../public/routes/util/settings');
const pug = require('pug');
const fs = require('fs');
const phantom = require("phantom-html-to-pdf")
({
  phantomPath: require("phantomjs-prebuilt").path,
  tmpDir: settings.giddhPdfPath,
  numberOfWorkers: 1,
});


var reciept = {};

reciept.downloadReciept = function(req,res){

  var recieptObj = req.body.reciept[0];

  const recieptPug = pug.compileFile('./voucher/api/models/reciept/templates/reciept_a.pug');

  var addressArray = [recieptObj.company.address,recieptObj.company.city,recieptObj.company.pincode,recieptObj.company.state, recieptObj.company.country];
  var accountArray = [recieptObj.account.email,recieptObj.account.mobileNumber]

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

  var response = {};
  var fileName = '';
  phantom(
    { 
      html: htmlRes,
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
        response.body = pdfPath
        res.send(response);
        phantom.kill();
      }
    }
  );
};

module.exports = reciept;