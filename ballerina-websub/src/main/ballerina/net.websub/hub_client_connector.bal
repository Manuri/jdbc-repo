package ballerina.net.websub;

import ballerina/log;
import ballerina/mime;
import ballerina/net.http;
import ballerina/security.crypto;

@Description {value:"HTTP client connector for outbound WebSub Subscription/Unsubscription requests to a Hub"}
public struct HubClientConnector {
    string hubUri;
    http:ClientEndpoint httpClientEndpoint;
}

@Description {value:"Function to send a subscription request to a WebSub Hub"}
@Param {value:"subscriptionRequest: The SubscriptionChangeRequest containing subscription details"}
@Return {value:"SubscriptionChangeResponse indicating subscription details, if the request was successful"}
@Return {value:"WebSubError if an error occurred with the subscription request"}
public function <HubClientConnector client> subscribe (SubscriptionChangeRequest subscriptionRequest) returns
(SubscriptionChangeResponse | WebSubError) {
    endpoint http:ClientEndpoint httpClientEndpoint = client.httpClientEndpoint;
    http:Request builtSubscriptionRequest = buildSubscriptionChangeRequest(MODE_SUBSCRIBE, subscriptionRequest);
    var response = httpClientEndpoint -> post("", builtSubscriptionRequest);
    return processHubResponse(client.hubUri, MODE_SUBSCRIBE, subscriptionRequest.topic, response);
}

@Description {value:"Function to send an unsubscription request to a WebSub Hub"}
@Param {value:"unsubscriptionRequest: The SubscriptionChangeRequest containing unsubscription details"}
@Return {value:"SubscriptionChangeResponse indicating unsubscription details, if the request was successful"}
@Return {value:"WebSubError if an error occurred with the unsubscription request"}
public function <HubClientConnector client> unsubscribe (SubscriptionChangeRequest unsubscriptionRequest) returns
(SubscriptionChangeResponse | WebSubError) {
    endpoint http:ClientEndpoint httpClientEndpoint = client.httpClientEndpoint;
    http:Request builtSubscriptionRequest = buildSubscriptionChangeRequest(MODE_UNSUBSCRIBE, unsubscriptionRequest);
    var response = httpClientEndpoint -> post("", builtSubscriptionRequest);
    return processHubResponse(client.hubUri, MODE_UNSUBSCRIBE, unsubscriptionRequest.topic, response);
}

@Description {value:"Function to register a topic in a Ballerina WebSub Hub against which subscribers can subscribe and
the publisher will publish updates, with a secret which will be used in signature generation to ensure publisher"}
@Param {value:"topic: The topic to register"}
@Param {value:"secret: The secret the publisher will use to generate a signature when publishing updates to the hub"}
public function <HubClientConnector client> registerTopic (string topic, string secret = "") {
    endpoint http:ClientEndpoint httpClientEndpoint = client.httpClientEndpoint;
    http:Request request = buildTopicRegistrationChangeRequest(MODE_REGISTER, topic, secret);
    _ = httpClientEndpoint -> post("", request);
}

@Description {value:"Function to unregister a topic in a Ballerina WebSub Hub which was registered specifying a secret"}
@Param {value:"topic: The topic to unregister"}
@Param {value:"secret: The secret the publisher used when registering the topic"}
public function <HubClientConnector client> unregisterTopic (string topic, string secret = "") {
    endpoint http:ClientEndpoint httpClientEndpoint = client.httpClientEndpoint;
    http:Request request = buildTopicRegistrationChangeRequest(MODE_UNREGISTER, topic, secret);
    _ = httpClientEndpoint -> post("", request);
}

@Description {value:"Function to publish an update to a remote Ballerina WebSub Hub"}
@Param {value:"topic: The topic for which the update occurred"}
@Param {value:"payload: The update payload"}
@Param {value:"secret: The secret used when registering the topic"}
@Return {value:"WebSubError if an error occurred with the update"}
public function <HubClientConnector client> publishUpdate (string topic, json payload,
            string secret = "", string signatureMethod = "sha256", json... headers) returns (WebSubError | null) {
    endpoint http:ClientEndpoint httpClientEndpoint = client.httpClientEndpoint;
    http:Request request = {};
    string queryParams = HUB_MODE + "=" + MODE_PUBLISH + "&" + HUB_TOPIC + "=" + topic;
    request.setJsonPayload(payload);

    if (secret != "") {
        string stringPayload = payload.toString();
        string publisherSignature = signatureMethod + "=";
        string generatedSignature = "";
        if (SHA1.equalsIgnoreCase(signatureMethod)) {
            generatedSignature = crypto:getHmac(stringPayload, secret, crypto:Algorithm.SHA1);
        } else if (SHA256.equalsIgnoreCase(signatureMethod)) {
            generatedSignature = crypto:getHmac(stringPayload, secret, crypto:Algorithm.SHA256);
        } else if (MD5.equalsIgnoreCase(signatureMethod)) {
            generatedSignature = crypto:getHmac(stringPayload, secret, crypto:Algorithm.MD5);
        }
        publisherSignature = publisherSignature + generatedSignature;
        request.setHeader(PUBLISHER_SIGNATURE, publisherSignature);
    }

    foreach headerJson in headers {
        request.setHeader(headerJson.headerKey.toString(), headerJson.headerValue.toString());
    }

    var response = httpClientEndpoint -> post("?" + queryParams, request);
        match (response) {
            http:Response => return null;
            http:HttpConnectorError httpConnectorError => { WebSubError webSubError = {
                      errorMessage:"Notification failed for topic [" + topic + "]", connectorError:httpConnectorError };
                                                        return webSubError;
            }
    }
}

@Description {value:"Function to build the topic registration change request to rgister/unregister a topic at the hub"}
@Param {value:"mode: Whether the request is for registration or unregistration"}
@Param {value:"subscriptionChangeRequest: The SubscriptionChangeRequest specifying the topic to subscribe to and the
                                        parameters to use"}
@Return {value:"The Request to send to the hub to subscribe/unsubscribe"}
function buildTopicRegistrationChangeRequest(string mode, string topic, string secret) returns (http:Request) {
    http:Request request = {};
    string body = HUB_MODE + "=" + mode + "&" + HUB_TOPIC + "=" + topic;
    if (secret != "") {
        body = body + "&" + PUBLISHER_SECRET + "=" + secret;
    }
    request.setStringPayload(body);
    request.setHeader(CONTENT_TYPE, mime:APPLICATION_FORM_URLENCODED);
    return request;
}

@Description {value:"Function to build the subscription request to subscribe at the hub"}
@Param {value:"mode: Whether the request is for subscription or unsubscription"}
@Param {value:"subscriptionChangeRequest: The SubscriptionChangeRequest specifying the topic to subscribe to and the
                                        parameters to use"}
@Return {value:"The Request to send to the hub to subscribe/unsubscribe"}
function buildSubscriptionChangeRequest(string mode, SubscriptionChangeRequest subscriptionChangeRequest) returns
(http:Request) {
    http:Request request = {};
    string body = HUB_MODE + "=" + mode
                  + "&" + HUB_TOPIC + "=" + subscriptionChangeRequest.topic
                  + "&" + HUB_CALLBACK + "=" + subscriptionChangeRequest.callback;
    if (mode == MODE_SUBSCRIBE) {
        body = body + "&" + HUB_SECRET + "=" + subscriptionChangeRequest.secret + "&" + HUB_LEASE_SECONDS + "="
               + subscriptionChangeRequest.leaseSeconds;
    }
    request.setStringPayload(body);
    request.setHeader(CONTENT_TYPE, mime:APPLICATION_FORM_URLENCODED);
    return request;
}

@Description {value:"Function to process the response from the hub on subscription/unsubscription and extract
                    required information"}
@Param {value:"hub: The hub to which the subscription/unsubscription request was sent"}
@Param {value:"mode: Whether the request was sent for subscription or unsubscription"}
@Param {value:"topic: The topic for which the subscription/unsubscription request was sent"}
@Param {value:"response: The response received from the hub"}
@Param {value:"httpConnectorError: Error, if occurred, with HTTP client connector invocation"}
@Return {value:"SubscriptionChangeResponse including details of subscription/unsubscription,
                if the request was successful"}
@Return { value : "WebSubErrror indicating any errors that occurred, if the request was unsuccessful"}
function processHubResponse(string hub, string mode, string topic, http:Response|http:HttpConnectorError response)
                                                                  returns (SubscriptionChangeResponse | WebSubError) {
    match response {
        http:HttpConnectorError httpConnectorError => {
            string errorMessage = "Error occurred for request: Mode[" + mode + "] at Hub[" + hub +"] - "
            + httpConnectorError.message;
            WebSubError webSubError = {errorMessage:errorMessage, connectorError:httpConnectorError};
            return webSubError;
        }
        http:Response httpResponse => {
            if (httpResponse.statusCode != 202) {
                var responsePayload = httpResponse.getStringPayload();
                string errorMessage = "Error in request: Mode[" + mode + "] at Hub[" + hub +"]";
                match (responsePayload) {
                    string responseErrorPayload => { errorMessage = errorMessage + " - " + responseErrorPayload; }
                    http:PayloadError payloadError => { errorMessage = errorMessage + " - "
                                                                       + "Error occurred identifying"
                                                                       + "cause: " + payloadError.message; }
                }
                WebSubError webSubError = {errorMessage:errorMessage};
                return webSubError;
            } else {
                SubscriptionChangeResponse subscriptionChangeResponse = {hub:hub, topic:topic, response:httpResponse};
                return subscriptionChangeResponse;
            }
        }
    }
}
