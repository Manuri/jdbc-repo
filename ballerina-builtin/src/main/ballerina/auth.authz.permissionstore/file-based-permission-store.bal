// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

package ballerina.auth.authz.permissionstore;

import ballerina/config;
import ballerina/log;

@Description {value:"Configuration key for groups in userstore"}
const string PERMISSIONSTORE_GROUPS_ENTRY = "groups";

const string EMPTY_STRING = "";

@Description {value:"Represents the permission store"}
public struct FileBasedPermissionStore {
}

@Description {value:"Checks if the the user has sufficient permission to access a resource with the specified scope"}
@Param {value:"username: user name"}
@Param {value:"scopes: array of scope names"}
@Return {value:"boolean: true if authorized, else false"}
public function <FileBasedPermissionStore permissionStore> isAuthorized (string username,
                                                                         string[] scopes) returns (boolean) {
    string[] groupsForScope = [];
    foreach scopeName in scopes  {
        groupsForScope = combineArrays(groupsForScope, getGroupsArray(permissionStore.readGroupsOfScope(scopeName)));
    }
    if (lengthof groupsForScope == 0) {
        // no groups for found for the scopes - cannot authorize
        return false;

    }
    string[] groupsForUser = getGroupsArray(permissionStore.readGroupsOfUser(username));
    if (lengthof groupsForUser == 0) {
        // no groups for user
        return false;
    }
    return matchGroups(groupsForScope, groupsForUser);
}

@Description {value:"Appends the contents of the second array to the first"}
@Param {value:"primaryArray: name of the primary array to which content is appended"}
@Param {value:"combiningArray: secondary array, elements of which will be appended to first"}
@Return {value:"string[]: combined array"}
function combineArrays (string[] primaryArray, string[] combiningArray) returns (string[]) {
    if (lengthof combiningArray == 0) {
        return primaryArray;
    }
    int i = 0;
    while (i < lengthof combiningArray) {
        primaryArray[lengthof primaryArray + i] = combiningArray[i];
        i = i + 1;
    }
    return primaryArray;
}

@Description {value:"Reads groups for the given scopes"}
@Param {value:"scopeName: name of the scope"}
@Return {value:"string: comma separated groups specified for the scopename"}
public function <FileBasedPermissionStore permissionStore> readGroupsOfScope (string scopeName) returns (string) {
    return getPermissionStoreConfigValue(scopeName, PERMISSIONSTORE_GROUPS_ENTRY);
}

@Description {value:"Matches the groups passed"}
@Param {value:"requiredGroupsForScope: array of groups for the scope"}
@Param {value:"groupsOfUser: array of groups belonging to the user"}
@Return {value:"boolean: true if two arrays are equal in content, else false"}
function matchGroups (string[] groupsOfScope, string[] groupsOfUser) returns (boolean) {
    foreach groupOfUser in groupsOfUser {
        foreach groupOfScope in groupsOfScope {
            if (groupOfUser == groupOfScope) {
                // if user is in one group that is equal to a group of a scope, authorization passes
                return true;
            }
        }
    }
    return false;
}

@Description {value:"Construct an array of groups from the comma separed group string passed"}
@Param {value:"groupString: comma separated string of groups"}
@Return {value:"string[]: array of groups, null if the groups string is empty/null"}
function getGroupsArray (string groupString) returns (string[]) {
    string[] groupsArr = [];
    if (lengthof groupString == 0) {
        return groupsArr;
    }
    return groupString.split(",");
}

@Description {value:"Reads the groups for a user"}
@Param {value:"string: username"}
@Return {value:"string: comma separeted groups list, as specified in the userstore file"}
public function <FileBasedPermissionStore permissionStore> readGroupsOfUser (string username) returns (string) {
    string userId = getPermissionStoreConfigValue(username, "userid");
    if (userId == EMPTY_STRING) {
        return EMPTY_STRING;
    }
    return getPermissionStoreConfigValue(userId, PERMISSIONSTORE_GROUPS_ENTRY);
}

@Description {value:"Reads the user id for the given username"}
@Param {value:"string: username"}
@Return {value:"string: user id read from the userstore, or null if not found"}
function readUserId (string username) returns (string|null) {
    return config:getAsString(username + ".userid");
}

function getPermissionStoreConfigValue (string instanceId, string property) returns (string) {
    match config:getAsString(instanceId + "." + property) {
        string value => {
            return value == null ? "" : value;
        }
        any|null => return "";
    }
}
