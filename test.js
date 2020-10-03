// Make an object of the data you want to record - get everything set up first
// Then test out the post request

function doPost(e) {
    Logger.log(e);
    const ss = SpreadsheetApp.openByUrl("https://docs.google.com/spreadsheets/d/106dx2kUYgKkuGfMH6iqgIPeRpMPncz6DWzAGaPgWG_g/");
    console.log(sheet)
    const sheet = ss.getSheets()[0];
    return "Message received!";
  
    let body = JSON.parse(e.postData.contents.body);
    Logger.log(body);
    console.log(body);
  
    ss.getRange('A1').setValue(body);
    ss.getRange('A1').setBackground('red');
  
    
}

function doGet(e) {
  const ss = SpreadsheetApp.openByUrl("https://docs.google.com/spreadsheets/d/106dx2kUYgKkuGfMH6iqgIPeRpMPncz6DWzAGaPgWG_g/");
  const sheet = ss.getSheets()[0];
  
  ss.getRange('A1').setValue("GET!");
  ss.getRange('A1').setBackground('Green');
}