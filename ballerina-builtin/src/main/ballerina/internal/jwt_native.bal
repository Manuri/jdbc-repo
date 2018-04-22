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

documentation {
    VerifySignature the signature of a given jwt.

    P{{data}} Original data which has signed.
    P{{signature}} Signature string.
    P{{algorithm}} Signature algorithm.
    P{{keyAlias}} Public key alias.
    R{{}} Verified status. true or false.
}
native function verifySignature(string data, string signature, string algorithm, TrustStore trustStore)
    returns (boolean);
type TrustStore {
    string certificateAlias,
    string trustStoreFilePath,
    string trustStorePassword,
};

documentation {
    Sign the given input jwt data.

    P{{data}} Original that need to sign.
    P{{algorithm}} Signature string.
    P{{keyAlias}} Private key alias. If this is null use default private key.
    P{{keyPassword}} Private key password.
    R{{}} Signature. Signed string.
}
native function sign(string data, string algorithm, KeyStore keyStore) returns (string);

type KeyStore {
    string keyAlias,
    string keyPassword,
    string keyStoreFilePath,
    string keyStorePassword,
};

documentation {
    Parse JSON string to generate JSON object.

    P{{s}} JSON string
    R{{}} JSON object.
}
public native function parseJson(string s) returns (json|error);
