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

package org.ballerinalang.net.grpc.nativeimpl.connection.client.clientendpoint;

import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import org.ballerinalang.bre.Context;
import org.ballerinalang.connector.api.BLangConnectorSPIUtil;
import org.ballerinalang.connector.api.BallerinaConnectorException;
import org.ballerinalang.connector.api.Struct;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.model.values.BStruct;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.natives.AbstractNativeFunction;
import org.ballerinalang.natives.annotations.Argument;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.Receiver;
import org.ballerinalang.net.grpc.EndpointConstants;
import org.ballerinalang.net.grpc.MessageUtils;
import org.ballerinalang.net.grpc.config.EndpointConfiguration;
import org.ballerinalang.util.exceptions.BallerinaException;


/**
 * Get the ID of the connection.
 *
 * @since 0.966
 */

@BallerinaFunction(
        packageName = "ballerina.net.grpc",
        functionName = "initEndpoint",
        receiver = @Receiver(type = TypeKind.STRUCT, structType = "Client",
                             structPackage = "ballerina.net.grpc"),
        args = {@Argument(name = "epName", type = TypeKind.STRING),
                @Argument(name = "config", type = TypeKind.STRUCT, structType = "ClientEndpointConfiguration")},
        isPublic = true
)
public class InitEndpoint extends AbstractNativeFunction {



    @Override
    public BValue[] execute(Context context) {
        try {
            Struct clientEndpoint = BLangConnectorSPIUtil.getConnectorEndpointStruct(context);
            // Creating server connector
            Struct endpointConfig = clientEndpoint.getStructField(EndpointConstants.ENDPOINT_CONFIG);
            EndpointConfiguration configuration = getEndpointConfiguration(endpointConfig);

            endpointConfig
            ManagedChannel channel = ManagedChannelBuilder.forAddress(configuration.getHost(), configuration.getPort())
                    .usePlaintext(true)
                    .build();
            clientEndpoint.addNativeData(EndpointConstants.CHANNEL_KEY, channel);

            return new BValue[]{null};
        } catch (Throwable throwable) {
            BStruct errorStruct = MessageUtils.getServerConnectorError(context, throwable);
            return new BValue[]{errorStruct};
        }

    }


    private EndpointConfiguration getEndpointConfiguration(Struct endpointConfig) {
        String host = endpointConfig.getStringField(EndpointConstants.ENDPOINT_CONFIG_HOST);
        long port = endpointConfig.getIntField(EndpointConstants.ENDPOINT_CONFIG_PORT);
        Struct sslConfig = endpointConfig.getStructField(EndpointConstants.ENDPOINT_CONFIG_SSL);

        EndpointConfiguration endpointConfiguration = new EndpointConfiguration();

        if (host == null || host.isEmpty()) {
            endpointConfiguration.setHost(EndpointConstants.HTTP_DEFAULT_HOST);
        } else {
            endpointConfiguration.setHost(host);
        }
        endpointConfiguration.setPort(Math.toIntExact(port));

        if (sslConfig != null) {
            return setSslConfig(sslConfig, endpointConfiguration);
        }
        return endpointConfiguration;
    }

    private EndpointConfiguration setSslConfig(Struct sslConfig, EndpointConfiguration endpointConfiguration) {
        endpointConfiguration.setScheme(EndpointConstants.PROTOCOL_HTTPS);
        String keyStoreFile = sslConfig.getStringField(EndpointConstants.SSL_CONFIG_KEY_STORE_FILE);
        String keyStorePassword = sslConfig.getStringField(EndpointConstants.SSL_CONFIG_KEY_STORE_PASSWORD);
        String trustStoreFile = sslConfig.getStringField(EndpointConstants.SSL_CONFIG_STRUST_STORE_FILE);
        String trustStorePassword = sslConfig.getStringField(EndpointConstants.SSL_CONFIG_STRUST_STORE_PASSWORD);
        String sslVerifyClient = sslConfig.getStringField(EndpointConstants.SSL_CONFIG_SSL_VERIFY_CLIENT);
        String certPassword = sslConfig.getStringField(EndpointConstants.SSL_CONFIG_CERT_PASSWORD);
        String sslEnabledProtocols = sslConfig.getStringField(EndpointConstants.SSL_CONFIG_SSL_ENABLED_PROTOCOLS);
        String cipher = sslConfig.getStringField(EndpointConstants.SSL_CONFIG_CIPHERS);
        String sslProtocol = sslConfig.getStringField(EndpointConstants.SSL_CONFIG_SSL_PROTOCOL);
        boolean validateCertificateEnabled = sslConfig.getBooleanField(EndpointConstants
                .SSL_CONFIG_VALIDATE_CERT_ENABLED);
        long cacheSize = sslConfig.getIntField(EndpointConstants.SSL_CONFIG_CACHE_SIZE);
        long cacheValidationPeriod = sslConfig.getIntField(EndpointConstants.SSL_CONFIG_CACHE_VALIDITY_PERIOD);

        if (keyStoreFile == null) {
            //TODO get from language pack, and add location
            throw new BallerinaConnectorException("Keystore location must be provided for secure connection");
        }
        if (keyStorePassword == null) {
            //TODO get from language pack, and add location
            throw new BallerinaConnectorException("Keystore password value must be provided for secure connection");
        }
        if (certPassword == null) {
            //TODO get from language pack, and add location
            throw new BallerinaConnectorException("Certificate password value must be provided for secure connection");
        }
        if ((trustStoreFile == null) && sslVerifyClient != null) {
            //TODO get from language pack, and add location
            throw new BallerinaException("Truststore location must be provided to enable Mutual SSL");
        }
        if ((trustStorePassword == null) && sslVerifyClient != null) {
            //TODO get from language pack, and add location
            throw new BallerinaException("Truststore password value must be provided to enable Mutual SSL");
        }


        endpointConfiguration.setTLSStoreType(EndpointConstants.PKCS_STORE_TYPE);
        endpointConfiguration.setKeyStoreFile(keyStoreFile);
        endpointConfiguration.setKeyStorePass(keyStorePassword);
        endpointConfiguration.setCertPass(certPassword);

        endpointConfiguration.setVerifyClient(sslVerifyClient);
        endpointConfiguration.setTrustStoreFile(trustStoreFile);
        endpointConfiguration.setTrustStorePass(trustStorePassword);
        endpointConfiguration.setValidateCertEnabled(validateCertificateEnabled);
        if (validateCertificateEnabled) {
            endpointConfiguration.setCacheSize(Math.toIntExact(cacheSize));
            endpointConfiguration.setCacheValidityPeriod(Math.toIntExact(cacheValidationPeriod));
        }

        if (sslProtocol != null) {
            endpointConfiguration.setSSLProtocol(sslProtocol);
        }

        return endpointConfiguration;
    }
}
