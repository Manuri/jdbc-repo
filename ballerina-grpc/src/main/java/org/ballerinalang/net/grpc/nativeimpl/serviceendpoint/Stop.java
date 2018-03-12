/*
 *  Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package org.ballerinalang.net.grpc.nativeimpl.serviceendpoint;

import io.grpc.Server;
import org.ballerinalang.bre.Context;
import org.ballerinalang.connector.api.BLangConnectorSPIUtil;
import org.ballerinalang.connector.api.Struct;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.Receiver;
import org.ballerinalang.net.grpc.nativeimpl.AbstractGrpcNativeFunction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.ballerinalang.net.grpc.GrpcServicesBuilder.stop;

/**
 * Native function to respond the caller.
 *
 * @since 0.96.1
 */
@BallerinaFunction(
        packageName = "ballerina.net.grpc",
        functionName = "stop",
        receiver = @Receiver(type = TypeKind.STRUCT, structType = "ServiceEndpoint",
                structPackage = "ballerina.net.grpc"),
        isPublic = true
)
public class Stop extends AbstractGrpcNativeFunction {
    private static final Logger log = LoggerFactory.getLogger(Stop.class);
    
    @Override
    public void execute(Context context) {
        Struct serviceEndpoint = BLangConnectorSPIUtil.getConnectorEndpointStruct(context);
        Server server = getService(serviceEndpoint);
        stop(server);
    }
}
