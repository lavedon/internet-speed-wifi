// Make an object of the data you want to record - get everything set up first
// Then test out the post request

const doPost = (request = {}) => {
  const { parameter, postData: { contents, type } = {} } = request;
  Logger.log("The contents are:")
  Logger.log(JSON.parse(contents));
  const data = JSON.parse(contents);
  updateSheet(data);
  Logger.log("Returning from doPost and Returning text output");
  return ContentService.createTextOutput("POST request received.  Your data time " + data.time);
}

function updateSheet(data) {
  Logger.log("appending " + data.time + " To sheet");
  const ss = SpreadsheetApp.openByUrl("https://docs.google.com/spreadsheets/d/106dx2kUYgKkuGfMH6iqgIPeRpMPncz6DWzAGaPgWG_g/");
  Logger.log("opened Spreadsheet");
  Logger.log(ss.getId());
  const sheet = ss.getSheets()[0];
  Logger.log("Got sheet from Spreadsheet");
  Logger.log(sheet.getSheetName());

  sheet.appendRow([data.time, data.downloadSpeed, data.uploadSpeed,  data.packetLoss, data.latency, data.serverHost, data.serverLocation, data.jitter])
  
}
