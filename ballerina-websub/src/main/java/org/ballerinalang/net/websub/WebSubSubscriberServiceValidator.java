/*
 *  Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  WSO2 Inc. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 *
 */

package org.ballerinalang.net.websub;

import org.ballerinalang.connector.api.ParamDetail;
import org.ballerinalang.connector.api.Resource;
import org.ballerinalang.model.values.BMap;
import org.ballerinalang.model.values.BString;
import org.ballerinalang.net.http.HttpResource;
import org.ballerinalang.net.http.HttpService;
import org.ballerinalang.util.exceptions.BallerinaException;

import java.util.ArrayList;
import java.util.List;

/**
 * Resource validator for WebSub Subscriber Services.
 *
 * @since 0.965.0
 */
class WebSubSubscriberServiceValidator {

    static void validateResources(HttpService service, String topicHeader, BMap<String, BString> topicResourceMap) {
        if (topicHeader != null && topicResourceMap != null) {
            validateCustomResources(service.getResources(), topicResourceMap);
        } else {
            validateDefaultResources(service.getResources());
        }
    }

    private static void validateDefaultResources(List<HttpResource> resources) {
        for (HttpResource resource : resources) {
            String resourceName = resource.getName();
            switch (resourceName) {
                case WebSubSubscriberConstants.RESOURCE_NAME_ON_INTENT_VERIFICATION:
                    validateOnIntentVerificationResource(resource.getBalResource());
                    break;
                case WebSubSubscriberConstants.RESOURCE_NAME_ON_NOTIFICATION:
                    validateOnNotificationResource(resource.getBalResource());
                    break;
                default:
                    throw new BallerinaException(String.format("Invalid resource name %s for WebSubSubscriberService. "
                                                        + "Allowed resource names [%s, %s]", resourceName,
                                                        WebSubSubscriberConstants.RESOURCE_NAME_ON_INTENT_VERIFICATION,
                                                        WebSubSubscriberConstants.RESOURCE_NAME_ON_NOTIFICATION));
            }
        }
    }

    private static void validateOnIntentVerificationResource(Resource resource) {
        List<ParamDetail> paramDetails = resource.getParamDetails();
        validateParamNumber(paramDetails, 2, resource.getName());
        validateStructType(resource.getName(), paramDetails.get(0), WebSubSubscriberConstants.WEBSUB_PACKAGE_PATH,
                           WebSubSubscriberConstants.SERVICE_ENDPOINT);
        validateStructType(resource.getName(), paramDetails.get(1), WebSubSubscriberConstants.WEBSUB_PACKAGE_PATH,
                           WebSubSubscriberConstants.STRUCT_WEBSUB_INTENT_VERIFICATION_REQUEST);
    }

    private static void validateOnNotificationResource(Resource resource) {
        List<ParamDetail> paramDetails = resource.getParamDetails();
        validateParamNumber(paramDetails, 1, resource.getName());
        validateStructType(resource.getName(), paramDetails.get(0), WebSubSubscriberConstants.WEBSUB_PACKAGE_PATH,
                           WebSubSubscriberConstants.STRUCT_WEBSUB_NOTIFICATION_REQUEST);
    }

    private static void validateParamNumber(List<ParamDetail> paramDetails, int expectedSize, String resourceName) {
        if (paramDetails == null || paramDetails.size() < expectedSize) {
            throw new BallerinaException(String.format("Invalid resource signature for WebSub Resource \"%s\"",
                                                       resourceName));
        }
    }

    private static void validateStructType(String resourceName, ParamDetail paramDetail, String packageName,
                                           String structName) {
        if (!paramDetail.getVarType().getPackagePath().equals(packageName)) {
            throw new BallerinaException(
                    String.format("Invalid parameter type %s:%s %s in resource %s. Requires %s:%s",
                                  paramDetail.getVarType().getPackagePath(), paramDetail.getVarType().getName(),
                                  paramDetail.getVarName(), resourceName, packageName, structName));
        }

        if (!paramDetail.getVarType().getName().equals(structName)) {
            throw new BallerinaException(
                    String.format("Invalid parameter type %s:%s %s in resource %s. Requires %s:%s",
                                  paramDetail.getVarType().getPackagePath(), paramDetail.getVarType().getName(),
                                  paramDetail.getVarName(), resourceName, packageName, structName));
        }
    }

    private static void validateCustomResources(List<HttpResource> resources, BMap<String, BString> topicResourceMap) {
        List<String> resourceNames = new ArrayList<>();
        List<String> invalidResourceNames = new ArrayList<>();

        for (String topic: topicResourceMap.keySet()) {
            resourceNames.add(topicResourceMap.get(topic).stringValue());
        }
        for (HttpResource resource : resources) {
            String resourceName = resource.getName();
            if (!resourceNames.contains(resourceName)) {
                invalidResourceNames.add(resourceName);
            } else {
                validateOnNotificationResource(resource.getBalResource());
                resourceNames.remove(resourceName);
            }
        }

        String errorMessage = null;
        if (!invalidResourceNames.isEmpty()) {
            errorMessage = "Resource name(s) not included in the topic-resource mapping found: " + invalidResourceNames
                    + "\n";
        }
        if (!resourceNames.isEmpty()) {
            errorMessage = "Resource(s) specified in topic-resource mapping not found: " + resourceNames;
        }
        if (errorMessage != null) {
            throw new BallerinaException(errorMessage);
        }
    }

}
