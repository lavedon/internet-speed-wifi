function runTest() {
    Logger.log("Hello, You handsome coding goat!");
    const ss = SpreadsheetApp.openByUrl("https://docs.google.com/spreadsheets/d/106dx2kUYgKkuGfMH6iqgIPeRpMPncz6DWzAGaPgWG_g/");
    const sheet = ss.getSheets()[0];
    Logger.log(ss.getName());
    Logger.log(sheet.getName());

    ss.getRange('A1').setValue('45');
    ss.getRange('A1').setBackground('red');
}