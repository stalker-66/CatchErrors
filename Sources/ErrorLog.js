// Parameters
let typeList = ['Warning','Crash'];
let colors = ["#ffffbf","#ffd6d6"];

let sheetWarning = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Warning');
let sheetCrash = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Crash');
let startDataPosition = 1;

// Clear Warning List
function clearWarning(skipErrors)
{
  let lastRow = sheetWarning.getLastRow();
  let deleteDelta = lastRow-startDataPosition;
  let sPos = startDataPosition+1;

  // remove files
  for (let i = sPos; i <= lastRow; i++) {
    let filename = sheetWarning.getRange("B" + i).getValue();
    filename = filename + '.zip';
    let files = DriveApp.getFilesByName(filename);

    while (files.hasNext()) {
      let file = files.next();
      file.setTrashed(true);
    }
  }
  
  // clear list
  if (deleteDelta>1) {
    sheetWarning.deleteRows(sPos, deleteDelta-1);
    sheetWarning.getRange('A' + sPos + ':' + 'H' + sPos).setBackground(colors[0]).clearContent();
  } else if (deleteDelta==1) {
    sheetWarning.getRange('A' + sPos + ':' + 'H' + sPos).setBackground(colors[0]).clearContent();
  } else {
    sheetWarning.getRange('A' + sPos + ':' + 'H' + sPos).setBackground(colors[0]);
    if (skipErrors && skipErrors == true) {
    } else {
      throw new Error( 'Warning is empty.' );
    };
  };
}

// Clear Crash List
function clearCrash(skipErrors)
{
  let lastRow = sheetCrash.getLastRow();
  let deleteDelta = lastRow-startDataPosition;
  let sPos = startDataPosition+1;

  // remove files
  for (let i = sPos; i <= lastRow; i++) {
    let filename = sheetWarning.getRange("B" + i).getValue();
    filename = filename + '.zip';
    let files = DriveApp.getFilesByName(filename);

    while (files.hasNext()) {
      let file = files.next();
      file.setTrashed(true);
    }
  }
  
  // clear list
  if (deleteDelta>1) {
    sheetCrash.deleteRows(sPos, deleteDelta-1);
    sheetCrash.getRange('A' + sPos + ':' + 'H' + sPos).setBackground(colors[1]).clearContent();
  } else if (deleteDelta==1) {
    sheetCrash.getRange('A' + sPos + ':' + 'H' + sPos).setBackground(colors[1]).clearContent();
  } else {
    sheetCrash.getRange('A' + sPos + ':' + 'H' + sPos).setBackground(colors[1]);
    if (skipErrors && skipErrors == true) {
    } else {
      throw new Error( 'Crash is empty.' );
    };
  };
}

// Post request
function doPost(e) {
  if (!e) {
    // fake request
    e = {
      parameter: {
        unic: 'errorUnicTest',
        type: 'Warning', // Warning or Crash
        date: '12/28/22 19:44:07',
        code: 3333,
        message: 'VGVzdCBFcnJvciBNZXNzYWdl',
        platform: 'Sandbox',
        appVersion: '1.002',
        customParams: '{ "name": "John Doe", "email": "jd@jd.com" }'
      }
    };
  };

  // response
  let resp = drawLog(e.parameter,e.postData);

  console.log(resp);

  return ContentService.createTextOutput(JSON.stringify(resp));
};

// Draw log
function drawLog(params,postData) {
  params = params ? params : {};
  postData = postData ? postData : {};

  let unic = params.unic ? params.unic : '0000-0000-0000';
  let type = params.type ? params.type : 'undefined';
  let date = params.date ? params.date : 'undefined';
  let code = params.code ? params.code : 'undefined';
  let message = params.message ? params.message : 'dW5kZWZpbmVk';
  let platform = params.platform ? params.platform : 'undefined';
  let appVersion = params.appVersion ? params.appVersion : 'undefined';
  let customParams = params.customParams ? params.customParams : '{}';

  let link = undefined;
  
  let sheet = type === 'Crash' ? sheetCrash : sheetWarning;
  let lastRow = sheet.getLastRow();
  let startLength = lastRow + 1;

  // check exist error
  if ( checkExistError(unic,sheet) ) {
    return { 
      success: 1,
      unic: unic,
      desc: 'Error is exist.'
    };
  };
  
  // start draw
  let drawList = [];

  // get parent folder
  let spreadsheetId =  SpreadsheetApp.getActiveSpreadsheet().getId();
  let spreadsheetFile =  DriveApp.getFileById(spreadsheetId);
  let folderId = spreadsheetFile.getParents().next().getId();

  // create folder
  let parentFolder = DriveApp.getFolderById(folderId);
  let newFolderId = parentFolder.createFolder(unic).getId();

  // get files
  for (let i = 1; i <= 10; i++) {
    if (params['file' + i] != null && params['filename' + i] != null) {
      let file = params['file' + i];
      file = Utilities.base64Decode(file);
      let filename = params['filename' + i];
      let blob = Utilities.newBlob(file, postData.type, filename);
      DriveApp.getFolderById(newFolderId).createFile(blob);
    };
  };

  // compress
  let folder = DriveApp.getFolderById(newFolderId);
  let blobs = getBlobs(folder, '');
  let isZip = blobs.length > 0;

  let zipped = isZip ? Utilities.zip(blobs, folder.getName()+'.zip') : null;
  let zipId = isZip ? folder.getParents().next().createFile(zipped).getId() : null;

  // garbage collector
  let folderToDelete = DriveApp.getFolderById(newFolderId);
  folderToDelete.setTrashed(true);

  // create link
  link = isZip ? 'https://drive.google.com/file/d/' + zipId + '/view?usp=sharing' : null;

  // parse message
  message = Utilities.base64Decode( message, Utilities.Charset.UTF_8 );
  message = Utilities.newBlob( message ).getDataAsString();

  // parse custom params
  let customParamsParse = JSON.parse(customParams);
  let customParamsString = '';
  let dev = '';
  for (let k in customParamsParse) {
    customParamsString = customParamsString + dev + k + ': ' + customParamsParse[k];
    dev = '\n';
  };

  let values = [
    date,
    unic,
    code,
    message,
    platform,
    appVersion,
    customParamsString
  ];
  drawList.push(values);

  if (drawList.length > 0) {
    let finishLength = lastRow + drawList.length;
    sheet.getRange('A' + startLength + ':G' + finishLength).setValues(drawList).setBackground(colors[ type === 'Crash' ? 1 : 0 ]);
    sheet.getRange("H" + finishLength).setFormula( isZip ? '=HYPERLINK("' + link + '","Download")' : null );
  };

  return { 
    success: 1,
    unic: unic,
    link: link
  };
};

// Check existsError
function checkExistError(unic,sheet) {
  // params
  unic = unic ? unic : '';
  sheet = sheet ? sheet : sheetWarning;

  // search errors
  let rows = sheet.getDataRange();
  let numRows = rows.getNumRows();

  for (let i = numRows; i >= 2; i--) {
    let curUnic = sheet.getRange("B" + i).getValue();
    if ( curUnic === unic ) {
      return true
    };
  };

  return false;
};

// Get Blobs
function getBlobs(rootFolder, path) {
  let blobs = [];
  let files = rootFolder.getFiles();
  while (files.hasNext()) {
    let file = files.next().getBlob();
    file.setName(path+file.getName());
    blobs.push(file);
  };
  let folders = rootFolder.getFolders();
  while (folders.hasNext()) {
    let folder = folders.next();
    let fPath = path+folder.getName()+'/';
    blobs.push(Utilities.newBlob([]).setName(fPath)); // comment/uncomment this line to skip/include empty folders
    blobs = blobs.concat(getBlobs(folder, fPath));
  };
  return blobs;
};