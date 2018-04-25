// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
// under the License.package http;


import ballerina/io;
import ballerina/runtime;
import ballerina/mime;

@final string EMPTY_STRING = "";
@final string WHITE_SPACE = " ";
@final string COLON = ":";
@final string CONTENT_TYPE_HEADER = "Content-Type";
@final string BASIC_SCHEME = "basic";
@final string OAUTH_SCHEME = "oauth";
@final string JWT_SCHEME = "jwt";

documentation {
    Provides the HTTP actions for interacting with an HTTP server. Apart from the standard HTTP methods, `forward()`
    and `execute()` functions are provided. `forward()` takes an incoming HTTP requests and sends it to an upstream
    HTTP endpoint while `execute()` can be used for sending HTTP requests with custom verbs. More complex and specific
    endpoint types can be created by wrapping this generic HTTP actions implementation.

    F{{serviceUri}} The URL of the remote HTTP endpoint
    F{{config}} The configurations of the client endpoint associated with this HttpActions instance
}
public type HttpSecureClient object {
    //These properties are populated from the init call to the client connector as these were needed later stage
    //for retry and other few places.
    public {
        string serviceUri;
        ClientEndpointConfig config;
        CallerActions httpClient;
    }

    public new(serviceUri, config) {
        self.httpClient = createSimpleHttpClient(serviceUri, config);
    }

    documentation {
        The `post()` function can be used to send HTTP POST requests to HTTP endpoints.

        P{{path}} Resource path
        P{{request}} An HTTP outbound request message
        R{{}} The inbound response message
        R{{}} The error occurred while attempting to fulfill the HTTP request
	}
    public function post(string path, Request? request = ()) returns (Response|HttpConnectorError) {
        Request req = request ?: new;
        check generateSecureRequest(req, config);
        Response response = check httpClient.post(path, request = req);
        boolean isRetry = isRetryRequired(response, config);
        if (isRetry) {
            Request newOutRequest = check cloneRequest(req);
            check updateRequestAndConfig(newOutRequest, config);
            return httpClient.post(path, request = newOutRequest);
        }
        return response;
    }

    documentation {
        The `head()` function can be used to send HTTP HEAD requests to HTTP endpoints.

        P{{path}} Resource path
        P{{request}} An HTTP outbound request message
        R{{}} The inbound response message
        R{{}} The error occurred while attempting to fulfill the HTTP request
	}
    public function head(string path, Request? request = ()) returns (Response|HttpConnectorError) {
        Request req = request ?: new;
        check generateSecureRequest(req, config);
        Response response = check httpClient.head(path, request = req);
        boolean isRetry = isRetryRequired(response, config);
        if (isRetry) {
            Request newOutRequest = check cloneRequest(req);
            check updateRequestAndConfig(newOutRequest, config);
            return httpClient.head(path, request = newOutRequest);
        }
        return response;
    }

    documentation {
        The `put()` function can be used to send HTTP PUT requests to HTTP endpoints.

        P{{path}} Resource path
        P{{request}} An HTTP outbound request message
        R{{}} The inbound response message
        R{{}} The error occurred while attempting to fulfill the HTTP request
	}
    public function put(string path, Request? request = ()) returns (Response|HttpConnectorError) {
        Request req = request ?: new;
        check generateSecureRequest(req, config);
        Response response = check httpClient.put(path, request = req);
        boolean isRetry = isRetryRequired(response, config);
        if (isRetry) {
            Request newOutRequest = check cloneRequest(req);
            check updateRequestAndConfig(newOutRequest, config);
            return httpClient.put(path, request = newOutRequest);
        }
        return response;
    }

    documentation {
		Invokes an HTTP call with the specified HTTP verb.

        P{{httpVerb}} HTTP verb value
        P{{path}} Resource path
        P{{request}} An HTTP outbound request message
        R{{}} The inbound response message
        R{{}} The error occurred while attempting to fulfill the HTTP request
	}
    public function execute(string httpVerb, string path, Request request) returns (Response|HttpConnectorError) {
        var details = generateSecureRequest(request, config);
        check generateSecureRequest(request, config);
        Response response = check httpClient.execute(httpVerb, path, request);
        boolean isRetry = isRetryRequired(response, config);
        if (isRetry) {
            Request newOutRequest = check cloneRequest(request);
            check updateRequestAndConfig(newOutRequest, config);
            return httpClient.execute(httpVerb, path, newOutRequest);
        }
        return response;
    }

    documentation {
		The `patch()` function can be used to send HTTP PATCH requests to HTTP endpoints.

        P{{path}} Resource path
        P{{request}} An HTTP outbound request message
        R{{}} The inbound response message
        R{{}} The error occurred while attempting to fulfill the HTTP request
	}
    public function patch(string path, Request? request = ()) returns (Response|HttpConnectorError) {
        Request req = request ?: new;
        check generateSecureRequest(req, config);
        Response response = check httpClient.patch(path, request = req);
        boolean isRetry = isRetryRequired(response, config);
        if (isRetry) {
            Request newOutRequest = check cloneRequest(req);
            check updateRequestAndConfig(newOutRequest, config);
            return httpClient.patch(path, request = newOutRequest);
        }
        return response;
    }

    documentation {
		The `delete()` function can be used to send HTTP DELETE requests to HTTP endpoints.

        P{{path}} Resource path
        P{{request}} An HTTP outbound request message
        R{{}} The inbound response message
        R{{}} The error occurred while attempting to fulfill the HTTP request
	}
    public function delete(string path, Request? request = ()) returns (Response|HttpConnectorError) {
        Request req = request ?: new;
        check generateSecureRequest(req, config);
        Response response = check httpClient.delete(path, request = req);
        boolean isRetry = isRetryRequired(response, config);
        if (isRetry) {
            Request newOutRequest = check cloneRequest(req);
            check updateRequestAndConfig(newOutRequest, config);
            return httpClient.delete(path, request = newOutRequest);
        }
        return response;
    }

    documentation {
		The `get()` function can be used to send HTTP GET requests to HTTP endpoints.

        P{{path}} Request path
        P{{request}} An HTTP outbound request message
        R{{}} The inbound response message
        R{{}} The error occurred while attempting to fulfill the HTTP request
	}
    public function get(string path, Request? request = ()) returns (Response|HttpConnectorError) {
        Request req = request ?: new;
        check generateSecureRequest(req, config);
        Response response = check httpClient.get(path, request = req);
        boolean isRetry = isRetryRequired(response, config);
        if (isRetry) {
            Request newOutRequest = check cloneRequest(req);
            check updateRequestAndConfig(newOutRequest, config);
            return httpClient.get(path, request = newOutRequest);
        }
        return response;
    }

    documentation {
		The `options()` function can be used to send HTTP OPTIONS requests to HTTP endpoints.

        P{{path}} Request path
        P{{request}} An HTTP outbound request message
        R{{}} The inbound response message
        R{{}} The error occurred while attempting to fulfill the HTTP request
	}
    public function options(string path, Request? request = ()) returns (Response|HttpConnectorError) {
        Request req = request ?: new;
        check generateSecureRequest(req, config);
        Response response = check httpClient.options(path, request = req);
        boolean isRetry = isRetryRequired(response, config);
        if (isRetry) {
            Request newOutRequest = check cloneRequest(req);
            check updateRequestAndConfig(newOutRequest, config);
            return httpClient.options(path, request = newOutRequest);
        }
        return response;
    }

    documentation {
		The `forward()` function can be used to invoke an HTTP call with inbound request's HTTP verb

        P{{path}} Request path
        P{{request}} An HTTP inbound request message
        R{{}} The inbound response message
        R{{}} The error occurred while attempting to fulfill the HTTP request
	}
    public function forward(string path, Request request) returns (Response|HttpConnectorError) {
        check generateSecureRequest(request, config);
        Response response = check httpClient.forward(path, request);
        boolean isRetry = isRetryRequired(response, config);
        if (isRetry) {
            Request newOutRequest = check cloneRequest(request);
            check updateRequestAndConfig(newOutRequest, config);
            return httpClient.forward(path, newOutRequest);
        }
        return response;
    }

    documentation {
		Submits an HTTP request to a service with the specified HTTP verb.
		The `submit()` function does not give out a `Response` as the result,
		rather it returns an `HttpFuture` which can be used to do further interactions with the endpoint.

        P{{httpVerb}} The HTTP verb value
        P{{path}} The resource path
        P{{request}} An HTTP outbound request message
        R{{}} An `HttpFuture` that represents an asynchronous service invocation, or an error if the submission fails
	}
    public function submit(string httpVerb, string path, Request request) returns (HttpFuture|HttpConnectorError) {
        check generateSecureRequest(request, config);
        return httpClient.submit(httpVerb, path, request);
    }

    documentation {
		Retrieves the `Response` for a previously submitted request.

        P{{httpFuture}} The `HttpFuture` relates to a previous asynchronous invocation
        R{{}} An HTTP response message, or an error if the invocation fails
	}
    public function getResponse(HttpFuture httpFuture) returns (Response|HttpConnectorError) {
        return httpClient.getResponse(httpFuture);
    }

    documentation {
		Checks whether a `PushPromise` exists for a previously submitted request.

        P{{httpFuture}} The `HttpFuture` relates to a previous asynchronous invocation
        R{{}} A `boolean` that represents whether a `PushPromise` exists
	}
    public function hasPromise(HttpFuture httpFuture) returns boolean {
        return httpClient.hasPromise(httpFuture);
    }

    documentation {
		Retrieves the next available `PushPromise` for a previously submitted request.

        P{{httpFuture}} The `HttpFuture` relates to a previous asynchronous invocation
        R{{}} An HTTP Push Promise message, or an error if the invocation fails
	}
    public function getNextPromise(HttpFuture httpFuture) returns (PushPromise|HttpConnectorError) {
        return httpClient.getNextPromise(httpFuture);
    }

    documentation {
		Retrieves the promised server push `Response` message.

        P{{promise}} The related `PushPromise`
        R{{}} A promised HTTP `Response` message, or an error if the invocation fails
	}
    public function getPromisedResponse(PushPromise promise) returns (Response|HttpConnectorError) {
        return httpClient.getPromisedResponse(promise);
    }

    documentation {
		Rejects a `PushPromise`.
		When a `PushPromise` is rejected, there is no chance of fetching a promised response using the rejected promise.

        P{{promise}} The Push Promise to be rejected
	}
    public function rejectPromise(PushPromise promise) {
        return httpClient.rejectPromise(promise);
    }
};

documentation {
    Creates an HTTP client capable of securing HTTP requests with authentication.

    P{{url}} Base URL
    P{{config}} Client endpoint configurations
    R{{}} Created secure HTTP client
}
public function createHttpSecureClient(string url, ClientEndpointConfig config) returns CallerActions {
    match config.auth {
        AuthConfig => {
            HttpSecureClient httpSecureClient = new(url, config);
            return httpSecureClient;
        }
        () => {
            CallerActions httpClient = createSimpleHttpClient(url, config);
            return httpClient;
        }
    }
}

documentation {
    Prepare HTTP request with the required headers for authentication.

    P{{req}} An HTTP outbound request message
    P{{config}} Client endpoint configurations
    R{{}} The Error occured during HTTP client invocation
}
function generateSecureRequest(Request req, ClientEndpointConfig config) returns (()|HttpConnectorError) {
    string scheme = config.auth.scheme but { () => EMPTY_STRING };
    if (scheme == BASIC_SCHEME) {
        string username = config.auth.username but { () => EMPTY_STRING };
        string password = config.auth.password but { () => EMPTY_STRING };
        string str = username + COLON + password;
        string token = check str.base64Encode();
        req.setHeader(AUTH_HEADER, AUTH_SCHEME_BASIC + WHITE_SPACE + token);
    } else if (scheme == OAUTH_SCHEME) {
        string accessToken = config.auth.accessToken but { () => EMPTY_STRING };
        if (accessToken == EMPTY_STRING) {
            string refreshToken = config.auth.refreshToken but { () => EMPTY_STRING };
            string clientId = config.auth.clientId but { () => EMPTY_STRING };
            string clientSecret = config.auth.clientSecret but { () => EMPTY_STRING };
            string refreshUrl = config.auth.refreshUrl but { () => EMPTY_STRING };

            if (refreshToken != EMPTY_STRING && clientId != EMPTY_STRING && clientSecret != EMPTY_STRING) {
                return updateRequestAndConfig(req, config);
            } else {
                HttpConnectorError httpConnectorError = {};
                httpConnectorError.message = "Valid accessToken or refreshToken is not available to process the request"
                ;
                return httpConnectorError;
            }
        } else {
            req.setHeader(AUTH_HEADER, AUTH_SCHEME_BEARER + WHITE_SPACE + accessToken);
        }
    } else if (scheme == JWT_SCHEME){
        string authToken = runtime:getInvocationContext().authContext.authToken;
        req.setHeader(AUTH_HEADER, AUTH_SCHEME_BEARER + WHITE_SPACE + authToken);
    }
    return ();
}

documentation {
    Update request and client config with new access tokens retrieved.

    P{{req}} Request object to be updated
    P{{config}} Client endpoint configurations
    R{{}} The Error occured during HTTP client invocation
}
function updateRequestAndConfig(Request req, ClientEndpointConfig config) returns (()|HttpConnectorError) {
    string accessToken = check getAccessTokenFromRefreshToken(config);
    req.setHeader(AUTH_HEADER, AUTH_SCHEME_BEARER + WHITE_SPACE + accessToken);
    AuthConfig? authConfig = config.auth;
    match authConfig {
        () => {}
        AuthConfig ac => ac.accessToken = accessToken;
    }
    return ();
}

documentation {
    Request an access token from authorization server using the provided refresh token.

    P{{config}} Client endpoint configurations
    R{{}} AccessToken received from the authorization server
    R{{}} Error occured during HTTP client invocation
}
function getAccessTokenFromRefreshToken(ClientEndpointConfig config) returns (string|HttpConnectorError) {
    string refreshToken = config.auth.refreshToken but { () => EMPTY_STRING };
    string clientId = config.auth.clientId but { () => EMPTY_STRING };
    string clientSecret = config.auth.clientSecret but { () => EMPTY_STRING };
    string refreshUrl = config.auth.refreshUrl but { () => EMPTY_STRING };

    CallerActions refreshTokenClient = createHttpSecureClient(refreshUrl, {});

    string clientIdSecret = clientId + COLON + clientSecret;
    string base64ClientIdSecret = check clientIdSecret.base64Encode();

    Request refreshTokenRequest = new;
    refreshTokenRequest.addHeader(AUTH_HEADER, AUTH_SCHEME_BASIC + WHITE_SPACE + base64ClientIdSecret);
    refreshTokenRequest.setTextPayload("grant_type=refresh_token&refresh_token=" + refreshToken,
        contentType = mime:APPLICATION_FORM_URLENCODED);
    Response refreshTokenResponse = check refreshTokenClient.post(EMPTY_STRING, request = refreshTokenRequest);

    json generatedToken = check refreshTokenResponse.getJsonPayload();
    if (refreshTokenResponse.statusCode == OK_200) {
        return generatedToken.access_token.toString();
    } else {
        HttpConnectorError httpConnectorError = {};
        httpConnectorError.message = "Failed to generate new access token from the given refresh token";
        return httpConnectorError;
    }
}

documentation {
    Clone the given request into a new request with request entity.

    P{{req}} Request object to be cloned
    R{{}} New request object created
}
function cloneRequest(Request req) returns (Request|HttpConnectorError) {
    mime:Entity mimeEntity = check req.getEntity();
    Request newOutRequest = new;
    newOutRequest.setEntity(mimeEntity);
    return newOutRequest;
}

documentation {
    Check whether retry is required for the response. This returns true if the scheme is OAuth and the response status
    is 401 only. That implies user has given a expired access token and the client should update it with the given
    refresh url.

    P{{response}} Response object
    P{{config}} Client endpoint configurations
    R{{}} Whether the client should retry or not
}
function isRetryRequired(Response response, ClientEndpointConfig config) returns boolean {
    string scheme = config.auth.scheme but { () => EMPTY_STRING };
    if (scheme == OAUTH_SCHEME && response.statusCode == UNAUTHORIZED_401) {
        return true;
    }
    return false;
}
