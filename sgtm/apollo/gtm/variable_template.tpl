﻿___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "gps-apollo",
  "description": "Get data from a Google Sheet in realtime. A quick \u0026 lightweight route to get data without needing more complex cloud setups.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "spreadsheet_id",
    "displayName": "The spreadsheet id that we get the data from.",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "age",
    "displayName": "The value of age group that we input in the form.",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "address",
    "displayName": "The address that we input in the form.",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "job",
    "displayName": "The related job that we input in the form.",
    "simpleValueType": true
  }
]


___SANDBOXED_JS_FOR_SERVER___

// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

const getGoogleAuth = require("getGoogleAuth");
const sendHttpRequest = require("sendHttpRequest");
const setResponseBody = require("setResponseBody");
const setResponseHeader = require("setResponseHeader");
const setResponseStatus = require("setResponseStatus");
const Promise = require("Promise");
const JSON = require("JSON");
const logToConsole = require("logToConsole");

logToConsole("age :" + data.age);
logToConsole("address :" + data.address);
logToConsole("job :" + data.job);

const SPREADSHEET_ID = data.spreadsheet_id;
const SHEET_NAME = data.job;
const COLUMN_NO = data.address;
const ROW_NO = data.age;
const TARGET = "!" + COLUMN_NO + ROW_NO + ":" + COLUMN_NO + ROW_NO;

const url = "https://sheets.googleapis.com/v4/spreadsheets/" + SPREADSHEET_ID + "/values/" + SHEET_NAME + TARGET;
logToConsole("url :" + url);


// Get Google credentials from the service account running the container.
const auth = getGoogleAuth({
  scopes: [
    "https://www.googleapis.com/auth/spreadsheets"]
});

const requestOptions = {
  headers: {key: "value"},
  method: "GET",
  authorization: auth,
  timeout: 5000,
};

// request.
return sendHttpRequest(url, requestOptions).then((result) => {
  setResponseStatus(result.statusCode);
  setResponseBody(result.body);
  setResponseHeader('cache-control', result.headers['cache-control']);
  const result_object = JSON.parse(result.body);
  const return_value = result_object.values[0][0];
  logToConsole("return_value :" + return_value);
  
  return return_value;
});


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_response",
        "versionId": "1"
      },
      "param": [
        {
          "key": "writeResponseAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "writeHeaderAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "writeStatusAllowed",
          "value": {
            "type": 8,
            "boolean": true
          }
        },
        {
          "key": "writeHeadersAllowed",
          "value": {
            "type": 8,
            "boolean": true
          }
        },
        {
          "key": "writeBodyAllowed",
          "value": {
            "type": 8,
            "boolean": true
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://sheets.googleapis.com/"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "use_google_credentials",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedScopes",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://www.googleapis.com/auth/spreadsheets"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Test case to show getting data from the spreadsheet behaves as expected
  code: |-
    const mockData = {
      spreadsheet_id: "abcdefghijklmn",
      age: 1,
      address: "A",
      job: "it"
    };

    mock("sendHttpRequest", () => {
      return Promise.create((resolve) => {
        resolve({
          "statusCode": 200,
          "body": JSON.stringify({ "values": [["100"]]}),
          "headers": {
            "cache-control": "max-age=120"
          }
        });
      });
    });

    runCode(mockData).then((resp) => {
      assertThat(resp).isString();
      assertThat(resp).isEqualTo("100");
    });
setup: |-
  const JSON = require("JSON");
  const Promise = require("Promise");


___NOTES___

Created on 4/30/2024, 5:13:58 AM


