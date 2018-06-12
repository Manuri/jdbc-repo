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
package org.ballerinalang.net.grpc.nativeimpl.servicestub;

import org.ballerinalang.bre.Context;
import org.ballerinalang.bre.bvm.CallableUnitCallback;
import org.ballerinalang.connector.api.BLangConnectorSPIUtil;
import org.ballerinalang.connector.api.Service;
import org.ballerinalang.connector.api.Value;
import org.ballerinalang.connector.impl.ValueImpl;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.model.values.BStruct;
import org.ballerinalang.model.values.BTypeDescValue;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.natives.annotations.Argument;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.Receiver;
import org.ballerinalang.natives.annotations.ReturnType;
import org.ballerinalang.net.grpc.Message;
import org.ballerinalang.net.grpc.MessageRegistry;
import org.ballerinalang.net.grpc.MessageUtils;
import org.ballerinalang.net.grpc.MethodDescriptor;
import org.ballerinalang.net.grpc.exception.GrpcClientException;
import org.ballerinalang.net.grpc.stubs.DefaultStreamObserver;
import org.ballerinalang.net.grpc.stubs.NonBlockingStub;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;

import static org.ballerinalang.bre.bvm.BLangVMErrors.PACKAGE_BUILTIN;
import static org.ballerinalang.bre.bvm.BLangVMErrors.STRUCT_GENERIC_ERROR;
import static org.ballerinalang.net.grpc.GrpcConstants.METHOD_DESCRIPTORS;
import static org.ballerinalang.net.grpc.GrpcConstants.ORG_NAME;
import static org.ballerinalang.net.grpc.GrpcConstants.PROTOCOL_PACKAGE_GRPC;
import static org.ballerinalang.net.grpc.GrpcConstants.PROTOCOL_STRUCT_PACKAGE_GRPC;
import static org.ballerinalang.net.grpc.GrpcConstants.SERVICE_STUB;
import static org.ballerinalang.net.grpc.GrpcConstants.SERVICE_STUB_REF_INDEX;

/**
 * {@code NonBlockingExecute} is the NonBlockingExecute action implementation of the gRPC Connector.
 *
 * @since 1.0.0
 */
@BallerinaFunction(
        orgName = ORG_NAME,
        packageName = PROTOCOL_PACKAGE_GRPC,
        functionName = "nonBlockingExecute",
        receiver = @Receiver(type = TypeKind.STRUCT, structType = SERVICE_STUB,
                structPackage = PROTOCOL_STRUCT_PACKAGE_GRPC),
        args = {
                @Argument(name = "methodID", type = TypeKind.STRING),
                @Argument(name = "payload", type = TypeKind.ANY),
                @Argument(name = "listenerService", type = TypeKind.TYPEDESC),
                @Argument(name = "headers", type = TypeKind.STRUCT, structType = "Headers",
                        structPackage = PROTOCOL_STRUCT_PACKAGE_GRPC)
        },
        returnType = {
                @ReturnType(type = TypeKind.ANY),
                @ReturnType(type = TypeKind.STRUCT, structType = STRUCT_GENERIC_ERROR, structPackage = PACKAGE_BUILTIN),
        },
        isPublic = true
)
public class NonBlockingExecute extends AbstractExecute {
    private static final Logger LOG = LoggerFactory.getLogger(NonBlockingExecute.class);
    private static final int MESSAGE_HEADER_REF_INDEX = 3;

    @Override
    public void execute(Context context, CallableUnitCallback callback) {
        BStruct serviceStub = (BStruct) context.getRefArgument(SERVICE_STUB_REF_INDEX);
        if (serviceStub == null) {
            notifyErrorReply(context, "Error while getting connector. gRPC Client connector is " +
                    "not initialized properly");
            return;
        }

        Object connectionStub = serviceStub.getNativeData(SERVICE_STUB);
        if (connectionStub == null) {
            notifyErrorReply(context, "Error while getting connection stub. gRPC Client connector " +
                    "is not initialized properly");
            return;
        }
        String methodName = context.getStringArgument(0);
        if (methodName == null) {
            notifyErrorReply(context, "Error while processing the request. RPC endpoint doesn't " +
                    "set properly");
            return;
        }

        Map<String, MethodDescriptor<Message, Message>> methodDescriptors = (Map<String, MethodDescriptor<Message,
                Message>>) serviceStub.getNativeData(METHOD_DESCRIPTORS);
        if (methodDescriptors == null) {
            notifyErrorReply(context, "Error while processing the request. method descriptors " +
                    "doesn't set properly");
            return;
        }

        com.google.protobuf.Descriptors.MethodDescriptor methodDescriptor = MessageRegistry.getInstance()
                .getMethodDescriptor(methodName);
        if (methodDescriptor == null) {
            notifyErrorReply(context, "No registered method descriptor for '" + methodName + "'");
            return;
        }


        // Update request headers when request headers exists in the context.
//        BValue headerValues = context.getNullableRefArgument(MESSAGE_HEADER_REF_INDEX);
//        MessageHeaders headers = getMessageHeaders(headerValues);

        if (connectionStub instanceof NonBlockingStub) {
            BValue payloadBValue = context.getRefArgument(1);
            Message requestMsg = MessageUtils.generateProtoMessage(payloadBValue, methodDescriptor.getInputType());
            NonBlockingStub nonBlockingStub = (NonBlockingStub) connectionStub;

            // Attach header read/write listener to the service stub.
//            AtomicReference<Metadata> headerCapture = new AtomicReference<>();
//            AtomicReference<Metadata> trailerCapture = new AtomicReference<>();
//            if (headers != null) {
//                nonBlockingStub = MetadataUtils.attachHeaders(nonBlockingStub, headers.getMessageMetadata());
//            }
//            nonBlockingStub = MetadataUtils.captureMetadata(nonBlockingStub, headerCapture, trailerCapture);

            BTypeDescValue serviceType = (BTypeDescValue) context.getRefArgument(2);
            Service callbackService = BLangConnectorSPIUtil.getServiceFromType(context.getProgramFile(), getTypeField
                    (serviceType));
            try {
                MethodDescriptor.MethodType methodType = getMethodType(methodDescriptor);
                if (methodType.equals(MethodDescriptor.MethodType.UNARY)) {
                    nonBlockingStub.executeUnary(requestMsg, new DefaultStreamObserver(callbackService),
                            methodDescriptors.get(methodName), callback);
                } else if (methodType.equals(MethodDescriptor.MethodType.SERVER_STREAMING)) {
                    nonBlockingStub.executeServerStreaming(requestMsg, new DefaultStreamObserver(callbackService),
                            methodDescriptors.get(methodName), callback);
                } else {
                    notifyErrorReply(context, "Error while executing the client call. Method type " +
                            methodType.name() + " not supported");
                    return;
                }
                context.setReturnValues();
                return;
            } catch (RuntimeException | GrpcClientException e) {
                notifyErrorReply(context, "gRPC Client Connector Error :" + e.getMessage());
                return;
            }
        }
        notifyErrorReply(context, "Error while processing the request message. Connection Sub " +
                "type not supported");
    }

    @Override
    public boolean isBlocking() {

        return false;
    }

    private Value getTypeField(BTypeDescValue refField) {
        if (refField == null) {
            return null;
        }
        return ValueImpl.createValue(refField);
    }
}
