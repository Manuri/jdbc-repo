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
 */

package org.ballerinalang.net.websub.nativeimpl;

import org.ballerinalang.bre.Context;
import org.ballerinalang.bre.bvm.BlockingNativeCallableUnit;
import org.ballerinalang.connector.api.BLangConnectorSPIUtil;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.model.values.BInteger;
import org.ballerinalang.natives.annotations.Argument;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.ReturnType;
import org.ballerinalang.net.websub.hub.Hub;

import static org.ballerinalang.net.websub.WebSubSubscriberConstants.STRUCT_WEBSUB_BALLERINA_HUB;
import static org.ballerinalang.net.websub.WebSubSubscriberConstants.WEBSUB_PACKAGE;

/**
 * Native function to start up the default Ballerina WebSub Hub.
 *
 * @since 0.965.0
 */
@BallerinaFunction(
        orgName = "ballerina", packageName = "websub",
        functionName = "startUpHubService",
        args = {@Argument(name = "port", type = TypeKind.INT)},
        returnType = {@ReturnType(type = TypeKind.OBJECT)},
        isPublic = true
)
public class StartUpHubService extends BlockingNativeCallableUnit {

    @Override
    public void execute(Context context) {
        Hub hubInstance = Hub.getInstance();
        String hubUrl;
        if (hubInstance.isStarted()) {
            hubUrl = hubInstance.retrieveHubUrl();
        } else {
            BInteger port = new BInteger(context.getIntArgument(0));
            hubUrl = hubInstance.startUpHubService(context.getProgramFile(), port);
        }
        context.setReturnValues(BLangConnectorSPIUtil.createBStruct(context, WEBSUB_PACKAGE,
                                                                    STRUCT_WEBSUB_BALLERINA_HUB, hubUrl));
    }

}
