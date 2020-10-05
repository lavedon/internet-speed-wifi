// Make an object of the data you want to record - get everything set up first
// Then test out the post request

const doPost = (request = {}) => {
  const { parameter, postData: { contents, type } = {} } = request;
  Logger.log("The contents are:")
  Logger.log(JSON.parse(contents));
  const data = JSON.parse(contents);
  return ContentService.createTextOutput(data.time);
}

const doGet = (event = {}) => {
  const { parameter } = event;
  const { name = 'Anonymous', color = 'Black' } = parameter;
  const html = `<p><b>${name}'s</b> favorite color is <font color="${color}">${color}</font></p>`;
  return HtmlService.createHtmlOutput(html)
    .setTitle('Apps Script Webpage')
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
};

function openSheet() {
  const ss = SpreadsheetApp.openByUrl("https://docs.google.com/spreadsheets/d/106dx2kUYgKkuGfMH6iqgIPeRpMPncz6DWzAGaPgWG_g/");
  Logger.log("opened Spreadsheet");
  Logger.log(ss.getId());
  const sheet = ss.getSheets()[0];
  Logger.log("Got sheet from Spreadsheet");
  Logger.log(sheet.getSheetName());
  
  Logger.log("Getting range.");
  let myRange = sheet.getRange(2,1,14,4);

  Logger.log("Number of rows in range is " + myRange.getNumRows()+ " Number of columns in range is " + myRange.getNumColumns());
}