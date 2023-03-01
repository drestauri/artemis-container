# artemis-container
This project was created to test development of an Artemis container with SSL enabled, clustering, and High Availability (live/backup servers).

# Notices
These scripts were developed on a RHEL 8 VM and are not guaranteed to work on other OSs due to differences in the available packages.

Currently, the scripts are setup to support testing of an SSL enabled client-broker connection which has been unsuccessful so far.

# Getting Started
The shell scripts included in this project should contain all of the commands necessary to setup dependencies, build, and run an Artemis Broker with SSL enabled and a Client with the ActiveMQ Client libraries and GMSEC API installed.

Once the container's are run, verify they are running with
``` podman ps ```

You should see 2 containers with the names "ssl-container" and "client-container". You can now run scripts 7 and 8 to get a terminal in either of those containers. 

Both containers are currently setup to still need you to manually start the Artemis bus (ssl-container) and run whichever pub_test.sh (client-container) you wish to test.

# Usage
You should be able to just run scripts 0 through 6 to build and set everything up. Rerun individual scripts as needed to rebuild the Artemis servers or Clients. Then login to the running containers with scripts 7 and 8. Occasionally, you can run script 99 to clean up stale containers.

The way the scripts are setup, the ssl-container will have 3 ports open (61616, 61617, 61618) with 3 different certifate solutions applied (my own certs, GMSEC script generated certs, and the certs provided with the Artemis examples) and an additional port for TCP connections (61619).

The client-container has all 3 cert types in the home directory with 4 scripts for testing each of the above 4 connection methods. 

Note that all 3 SSL solutions result in the same failed connection and error messages, though the certs generated via my own cert process have an additional error so are likely no good. I am keeping them in there for future testing.

# TODO
 - Consider installing nslookup
 - Test thoroughly
 - Implement & Verify SSL enabled server
 - Implement Backup servers

# Template broker.xml from a cluster with HA:
```
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!--
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
-->
<configuration xmlns="urn:activemq" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:activemq /schema/artemis-configuration.xsd">
    <core xmlns="urn:activemq:core">

        <bindings-directory>./data/bindings</bindings-directory>

        <journal-directory>./data/journal</journal-directory>

        <large-messages-directory>./data/largemessages</large-messages-directory>

        <paging-directory>./data/paging</paging-directory>

        <journal-retention unit="DAYS" directory="history" period="365" storage-limit="10G"/>

        <!-- The cluster username and password is used to by other nodes in the cluster to connect to this broker (and vice versa) -->
        <!-- TEMPLATE NOTE: should be part of the template automation -->
        <cluster-user>egsclusteruser</cluster-user>
        <cluster-password>egsclusterpassword</cluster-password>


        <!-- High Availability settings for live/backup servers -->
        <ha-policy>
            <replication>
                <!-- TEMPLATE NOTE: "master" or "slave" based on live vs backup server (see inventory, "01" in hostname means live, otherwise backup) -->
                <master>
                    <!-- group-name enables backup servers to connect to a live server in the same node -->
                    <!-- TEMPLATE NOTE: group-name is based on the node of the cluster this server is a part of (suggest a var be defined for each group in inventory) -->
                    <group-name>node-A</group-name>
         
                    <!-- DISABLED (false): Configuration to support failback does not work with multiple backup servers -->
                    <check-for-live-server>false</check-for-live-server>
                </master>
            </replication>
        </ha-policy>


        <!--
            ======= CONNECTOR SETTINGS =======
            Connectors specify all of the places this broker is aware of that connections can be made (by cluster members or clients).
            A connector for this broker is included as that is what will get broadcast to other nodes of the cluster as the connection
            point for this broker as part of the "discovery" mechanism of the cluster.    
            Each connector has SSL parameters associated with them to make sure the clients and other brokers connect using SSL.
        -->
         <connectors>
            <!-- TEMPLATE NOTE: connector name and fqdn based server name in inventory. Includes itself (see cluster configuration section) -->
          
            <!-- NODE A SERVERS -->
            <!-- TEMPLATE NOTE: Each node needs to know which connector points to themselves (artemis-a01 in this example, see cluster configuration section)  -->
            <connector name="artemis-a01-connector">tcp://artemis-a01_fqdn:port?sslEnabled=true;keyStorePath=keystore.ks;keyStorePassword=securepass;trustStorePath=truststore.ks;trustStorePassword=securepass</connector>
         
            <!-- TEMPLATE NOTE: Each node requires at least one connector for another node, but it's probably safest to just have all other nodes' connectors listed to ensure they always have an entry point to the cluster  -->
            <connector name="artemis-a02-connector">tcp://artemis-a02_fqdn:port?sslEnabled=true;keyStorePath=keystore.ks;keyStorePassword=securepass;trustStorePath=truststore.ks;trustStorePassword=securepass</connector>
            <connector name="artemis-a03-connector">tcp://artemis-a03_fqdn:port?sslEnabled=true;keyStorePath=keystore.ks;keyStorePassword=securepass;trustStorePath=truststore.ks;trustStorePassword=securepass</connector>
         
            <!-- NODE B SERVERS (if deployed) -->
            <connector name="artemis-b01-connector">tcp://artemis-b01_fqdn:port?sslEnabled=true;keyStorePath=keystore.ks;keyStorePassword=securepass;trustStorePath=truststore.ks;trustStorePassword=securepass</connector>
            <connector name="artemis-b02-connector">tcp://artemis-b02_fqdn:port?sslEnabled=true;keyStorePath=keystore.ks;keyStorePassword=securepass;trustStorePath=truststore.ks;trustStorePassword=securepass</connector>
            <connector name="artemis-b03-connector">tcp://artemis-b02_fqdn:port?sslEnabled=true;keyStorePath=keystore.ks;keyStorePassword=securepass;trustStorePath=truststore.ks;trustStorePassword=securepass</connector> 

        </connectors>


        <!--
            ======= ACCEPTOR SETTINGS =======
            Acceptors define the ports on which this broker will be listening for connections.
            Multiple acceptors can be defined if, for example, you want to accept different protocols on different ports, or use
            different keystores or truststores.
            However, one acceptor is sufficient for both client and cluster connections if both can be authenticated using the same truststore.
        -->
        <acceptors>
            <!-- TEMPLATE NOTE: Only the port should need to be templated -->
            <acceptor name="broker-ssl-acceptor">tcp://0.0.0.0:port?sslEnabled=true;needClientAuth=true;keyStorePath=server-keystore.jks;keyStorePassword=securepass;trustStorePath=client-ca-truststore.jks;trustStorePassword=securepass;tcpSendBufferSize=1048576;tcpReceiveBufferSize=1048576<!--ssl_settings--></acceptor>
        </acceptors>


         <!--
            ======= CLUSTER SETTINGS =======
            Define the cluster settings. The key information to note in this section include the name of the cluster and
            static-connectors which should point to this server's backup server and at least one other node in the cluster
        -->
        <cluster-connections>
            <cluster-connection name="my-cluster">
                <!-- TEMPLATE NOTE: The connector name for this broker is needed here as this is what gets relayed throughout the cluster as the connection point to this broker  -->
                <connector-ref>artemis-a01-connector</connector-ref>
                <retry-interval>500</retry-interval>
                <use-duplicate-detection>true</use-duplicate-detection>
                <!-- Distribute messages to nodes with matching queues and active consumers -->
                <message-load-balancing>ON_DEMAND</message-load-balancing>
                <max-hops>1</max-hops>
                <address-settings>
                    <!-- Enable redistribution for all addresses -->
                    <address-setting match="#">
                        <!-- Enable redistribution with no delay -->
                        <redistribution-delay>0</redistribution-delay>
                    </address-setting>
                </address-settings>
                <static-connectors>
                    <!-- TEMPLATE NOTE: all connectors EXCEPT itself -->
                    <connector-ref>artemis-a02-connector</connector-ref>
                    <connector-ref>artemis-a03-connector</connector-ref>
                    <connector-ref>artemis-b01-connector</connector-ref>
                    <connector-ref>artemis-b02-connector</connector-ref>
                    <connector-ref>artemis-b03-connector</connector-ref>
                </static-connectors>
            </cluster-connection>
        </cluster-connections>


        <!--
            ======= TOPIC/QUEUE SECURITY SETTINGS =======
            Defines the permissions for each role. Can be set to apply to specific subjects but "#" is
            used to apply these settings to all topics.
        -->
        <security-settings>
            <!-- Security Settings for General Clients -->
            <security-setting match="#">
                <permission roles="broker,guest" type="createDurableQueue"/>
                <permission roles="broker,guest" type="deleteDurableQueue"/>
                <permission roles="broker,guest" type="createNonDurableQueue"/>
                <permission roles="broker,guest" type="deleteNonDurableQueue"/>
                <permission roles="broker,guest" type="createAddress"/>
                <permission roles="broker,guest" type="deleteAddress"/>
                <permission roles="broker,guest" type="consume"/>
                <permission roles="broker,guest" type="send"/>
         
                <!--  Other Security Settings that may be considered for other use cases (such as connection routing which is currently disabled -->
                <permission roles="broker," type="manage"/>
            </security-setting>
        </security-settings>

        <!--
            ======= ADDRESS SETTINGS =======
            Defines additional address options for certain topics. Currently, it just defines a Dead Letter
            Queue and Expiry Queue for messages that are discarded for various reasons related to being undelivered.
        -->
        <address-settings>
            <address-setting match="#">
                  <dead-letter-address>DLQ</dead-letter-address>
                  <expiry-address>ExpiryQueue</expiry-address>
                  <redelivery-delay>0</redelivery-delay>
                  <max-size-bytes>-1</max-size-bytes>
                  <message-counter-history-day-limit>10</message-counter-history-day-limit>
                  <address-full-policy>PAGE</address-full-policy>
                  <auto-create-queues>true</auto-create-queues>
                  <auto-create-addresses>true</auto-create-addresses>
             </address-setting>     
        </address-settings>
         
        <!-- Addresses can be used to create permanent queues that specific sets of settings can be applied to -->
        <addresses>
         
             <!-- Admin queues for recovering abandoned (failed delivery) and expired messages -->
             <address name="DLQ">
                  <anycast>
                       <queue name="DLQ" />
                  </anycast>
             </address>
         
             <address name="ExpiryQueue">
                  <anycast>
                       <queue name="ExpiryQueue" />
                  </anycast>
             </address>
        </addresses>
        
    </core>
</configuration>
```
