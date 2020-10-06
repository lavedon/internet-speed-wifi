function willSucceed() {
  var person = {
    contact: {
      email: 'jeffeverhart383@gmail.com'
    }
  }
  
  MailApp.sendEmail(person.contact.email, 'This should succeed', 'Success!!!')
}

function willFail() {
  var person = {
    contact: {
      emailAddress: 'jeffeverhart@383@gmail.com'
    }
  }
  
  Logger.log(person.contact.email);
  Logger.log(person.contact.emailAddress);
  MailApp.sendEmail(person.contact.email, 'This should fail', 'No dice!!!')
}