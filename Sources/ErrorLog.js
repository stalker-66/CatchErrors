const typeList = ['Warning','Crash'];

function clearWarning()
{
  // select sheet
  let sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(typeList[0]);
  let rows = sheet.getDataRange();
  let numRows = rows.getNumRows();

  for (let i = numRows; i >= 2; i--) {
    let filename = sheet.getRange("B" + i).getValue();
    filename = filename + '.zip';
    let files = DriveApp.getFilesByName(filename);

    while (files.hasNext()) {
      let file = files.next();
      file.setTrashed(true);
    }
  }

  for (let i = numRows; i >= 3; i--) {
    sheet.deleteRow(i);
  }
  sheet.getRange("A2"+":F2").setBackground("#ffe599").clearContent();
}

function clearCrash()
{
  // select sheet
  let sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(typeList[1]);
  let rows = sheet.getDataRange();
  let numRows = rows.getNumRows();

  for (let i = numRows; i >= 2; i--) {
    let filename = sheet.getRange("B" + i).getValue();
    filename = filename + '.zip';
    let files = DriveApp.getFilesByName(filename);

    while (files.hasNext()) {
      let file = files.next();
      file.setTrashed(true);
    }
  }

  for (let i = numRows; i >= 3; i--) {
    sheet.deleteRow(i);
  }
  sheet.getRange("A2"+":F2").setBackground("#ea9999").clearContent();
}

function getBlobs(rootFolder, path) {
  let blobs = [];
  let files = rootFolder.getFiles();
  while (files.hasNext()) {
    let file = files.next().getBlob();
    file.setName(path+file.getName());
    blobs.push(file);
  }
  let folders = rootFolder.getFolders();
  while (folders.hasNext()) {
    let folder = folders.next();
    let fPath = path+folder.getName()+'/';
    blobs.push(Utilities.newBlob([]).setName(fPath)); // comment/uncomment this line to skip/include empty folders
    blobs = blobs.concat(getBlobs(folder, fPath));
  }
  return blobs;
}

function doPost(e) {
  // contents
  let contents = JSON.parse('{}');
  if (e != null && e.postData != null && e.postData.contents != null) {
    contents = JSON.parse(e.postData.contents.replace(/\n/g, ''));
  }

  // get sheets list
  let sheets = SpreadsheetApp.getActive().getSheets();
  let sheetList = [];
  for (let j=0 ; j<sheets.length ; j++) {
    sheetList[j] = sheets[j].getName();
  }

  // search GID by type
  let curType = typeList[0];
  if (contents.type != null) {
    let reqType = Utilities.base64Decode( contents.type, Utilities.Charset.UTF_8 );
    reqType = Utilities.newBlob( reqType ).getDataAsString();

    for (let j = 0; j < typeList.length; j++) {
      if (reqType == typeList[j]) {
        curType = typeList[j];
      }
    }
  }

  // select active sheet
  let curSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(curType);
  let posSheet = curSheet.getLastRow() + 1;

  // date
  let date = '--/--/-- --:--:--';
  if (contents.date != null) {
    date = Utilities.base64Decode( contents.date, Utilities.Charset.UTF_8 );
    date = Utilities.newBlob( date ).getDataAsString();
  }

  // unic
  let unic = '0000-0000-0000';
  if (contents.unic != null) {
    unic = Utilities.base64Decode( contents.unic, Utilities.Charset.UTF_8 );
    unic = Utilities.newBlob( unic ).getDataAsString();
  }

  // code
  let code = '0';
  if (contents.code != null) {
    code = Utilities.base64Decode( contents.code, Utilities.Charset.UTF_8 );
    code = Utilities.newBlob( code ).getDataAsString();
  }

  // message
  let message = '--- --- --- --- --- ---';
  if (contents.message != null) {
    message = Utilities.base64Decode( contents.message, Utilities.Charset.UTF_8 );
    message = Utilities.newBlob( message ).getDataAsString();
  }

  // platform
  let platform = '------';
  if (contents.platform != null) {
    platform = Utilities.base64Decode( contents.platform, Utilities.Charset.UTF_8 );
    platform = Utilities.newBlob( platform ).getDataAsString();
  }

  // get parent folder
  let spreadsheetId =  SpreadsheetApp.getActiveSpreadsheet().getId();
  let spreadsheetFile =  DriveApp.getFileById(spreadsheetId);
  let folderId = spreadsheetFile.getParents().next().getId();

  // create folder
  let parentFolder = DriveApp.getFolderById(folderId);
  let newFolderId = parentFolder.createFolder(unic).getId();

  // get files
  for (let j = 1; j <= 10; j++) {
    if (contents['file' + j] != null && contents['filename' + j] != null) {
      let file = contents['file' + j];
      file = Utilities.base64Decode(file);
      let filename = contents['filename' + j];
      let blob = Utilities.newBlob(file, e.postData.type, filename);
      DriveApp.getFolderById(newFolderId).createFile(blob);
    }
  }

  // compress
  let folder = DriveApp.getFolderById(newFolderId);
  let zipped = Utilities.zip(getBlobs(folder, ''), folder.getName()+'.zip');
  let zipId = folder.getParents().next().createFile(zipped).getId();

  // garbage collector
  let folderToDelete = DriveApp.getFolderById(newFolderId);
  folderToDelete.setTrashed(true);

  // create link
  let link = 'https://drive.google.com/file/d/' + zipId + '/view?usp=sharing';

  // fill sheet
  curSheet.getRange("A" + posSheet).setValue(date);
  curSheet.getRange("B" + posSheet).setValue(unic);
  curSheet.getRange("C" + posSheet).setValue(code);
  curSheet.getRange("D" + posSheet).setValue(message);
  curSheet.getRange("E" + posSheet).setValue(platform);
  curSheet.getRange("F" + posSheet).setFormula('=HYPERLINK("' + link + '","Download")');

  // response
  let resp = {};
  resp.success = 1;
  resp.link = link;
  resp.unic = unic;

  return ContentService.createTextOutput(JSON.stringify(resp));
}