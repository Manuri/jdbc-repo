/*
 *  Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *  WSO2 Inc. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */
package org.ballerinalang.nativeimpl.observe.metrics;

import org.ballerinalang.bre.Context;
import org.ballerinalang.bre.bvm.BlockingNativeCallableUnit;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.model.values.BInteger;
import org.ballerinalang.model.values.BStruct;
import org.ballerinalang.natives.annotations.Argument;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.Receiver;
import org.ballerinalang.natives.annotations.ReturnType;
import org.ballerinalang.util.metrics.Counter;

/**
 * This is the nativeIncrement function implementation of the Counter object.
 */

@BallerinaFunction(
        orgName = "ballerina",
        packageName = "observe",
        functionName = "nativeIncrement",
        receiver = @Receiver(type = TypeKind.OBJECT, structType = Constants.COUNTER,
                structPackage = Constants.OBSERVE_PACKAGE_PATH),
        args = {
                @Argument(name = "amount", type = TypeKind.INT)
        },
        returnType = @ReturnType(type = TypeKind.INT)
)
public class CounterNativeIncrement extends BlockingNativeCallableUnit {

    @Override
    public void execute(Context context) {
        BStruct bStruct = (BStruct) context.getRefArgument(0);
        long amount = context.getIntArgument(0);
        BCounter bCounter = (BCounter) bStruct.getNativeData(Constants.COUNTER);
        Counter counter = Utils.getCounter(bCounter);
        counter.increment(amount);
        context.setReturnValues(new BInteger(counter.getValue()));
    }
}
