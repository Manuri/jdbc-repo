/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

package org.ballerinalang.nativeimpl.io;


import org.ballerinalang.bre.Context;
import org.ballerinalang.bre.bvm.BlockingNativeCallableUnit;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.Receiver;

/**
 * Native function ballerina.io#writeInt
 *
 * @since 0.970.0-alpha1
 */
@BallerinaFunction(
  orgName = "ballerina", packageName = "io",
  functionName = "DataChannel.readFloat",
  receiver = @Receiver(type = TypeKind.STRUCT, structType = "DataChannel", structPackage = "ballerina.io"),
  isPublic = true
)
public class ReadFloat extends BlockingNativeCallableUnit{
        /**
         * {@inheritDoc}
         */
        @Override
        public void execute(Context context) {
                BValue refArgument = context.getRefArgument(0);
        }
}
