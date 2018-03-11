/*
*  Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
*
*  WSO2 Inc. licenses this file to you under the Apache License,
*  Version 2.0 (the "License"); you may not use this file except
*  in compliance with the License.
*  You may obtain a copy of the License at
*
*    http://www.apache.org/licenses/LICENSE-2.0
*
*  Unless required by applicable law or agreed to in writing,
*  software distributed under the License is distributed on an
*  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
*  KIND, either express or implied.  See the License for the
*  specific language governing permissions and limitations
*  under the License.
*/

package org.ballerinalang.mime.nativeimpl;

import org.ballerinalang.bre.Context;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.model.values.BRefValueArray;
import org.ballerinalang.model.values.BStruct;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.natives.AbstractNativeFunction;
import org.ballerinalang.natives.annotations.Argument;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.Receiver;

import static org.ballerinalang.mime.util.Constants.BODY_PARTS;
import static org.ballerinalang.mime.util.Constants.FIRST_PARAMETER_INDEX;
import static org.ballerinalang.mime.util.Constants.SECOND_PARAMETER_INDEX;

/**
 * Set the entity body with body parts.
 *
 * @since 0.964.0
 */
@BallerinaFunction(
        orgName = "ballerina",
        packageName = "mime",
        functionName = "setBodyParts",
        receiver = @Receiver(type = TypeKind.STRUCT, structType = "Entity", structPackage = "mime"),
        args = {@Argument(name = "bodyParts", type = TypeKind.ARRAY)},
        isPublic = true
)
public class SetBodyParts extends AbstractNativeFunction {
    @Override
    public BValue[] execute(Context context) {
        BStruct entityStruct = (BStruct) this.getRefArgument(context, FIRST_PARAMETER_INDEX);
        BRefValueArray bodyParts = (BRefValueArray) this.getRefArgument(context, SECOND_PARAMETER_INDEX);
        entityStruct.addNativeData(BODY_PARTS, bodyParts);
        return AbstractNativeFunction.VOID_RETURN;
    }
}
