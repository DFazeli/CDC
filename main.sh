1) wget https://downloads.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz
2) wget https://dlcdn.apache.org/zookeeper/zookeeper-3.8.4/apache-zookeeper-3.8.4-bin.tar.gz
3) mkdir -p /opt/kafka && mkdir -p /opt/kafka-bin/ && mkdir -p /opt/kafka-data && useradd kafka && chown -R kafka:kafka /opt/kafka && mkdir -p /var/log/kafka && chown -R kafka:kafka /var/log/kafka
4) mkdir -p /opt/zookeeper && mkdir -p /opt/zookeeper-bin/ && mkdir -p /opt/zookeeper-data && useradd zookeeper && chown -R zookeeper:zookeeper /opt/zookeeper && mkdir -p /var/log/zookeeper && chown -R zookeeper:zookeeper /var/log/zookeeper
5) vim /etc/systemd/system/kafka.service
   [Unit]
Description=Apache Kafka server (broker)
Documentation=http://kafka.apache.org/documentation.html
Requires=network.target remote-fs.target
After=network.target remote-fs.target zookeeper.service

[Service]
Type=simple
User=kafka
Group=kafka
Environment="KAFKA_JMX_OPTS=-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
Environment="JMX_PORT=9999"
Environment="LOG_DIR=/var/log/kafka"

ExecStart=/opt/kafka/kafka-bin/bin/kafka-server-start.sh /opt/kafka/kafka-bin/config/server.properties
ExecStop=/opt/kafka/kafka-bin/bin/kafka-server-start.sh

[Install]
WantedBy=multi-user.target

6) vim /etc/systemd/system/zookeeper.service
[Unit]
Description=Apache Zookeeper server
Documentation=http://zookeeper.apache.org
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=forking
User=zookeeper
Group=zookeeper
ExecStart=/opt/zookeeper/bin/zkServer.sh start
ExecStop=/opt/zookeeper/bin/zkServer.sh stop
ExecReload=/opt/zookeeper/bin/zkServer.sh restart
WorkingDirectory=/var/lib/zookeeper

[Install]
WantedBy=multi-user.target

7) vim /opt/zookeeper/conf/zoo.cfg
# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just
# example sakes.
dataDir=/opt/zookeeper/zookeeper-data
# the port at which the clients will connect
clientPort=2181
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the
# administrator guide before turning on autopurge.
#
# https://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1

## Metrics Providers
#
# https://prometheus.io Metrics Exporter
#metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider
#metricsProvider.httpHost=0.0.0.0
#metricsProvider.httpPort=7000
#metricsProvider.exportJvmInfo=true

server.161=172.16.2.161:2888:3888
server.162=172.16.2.162:2888:3888
server.163=172.16.2.163:2888:3888

8) add ZOO_LOG_DIR="/var/log/zookeeper/" to /opt/zookeeper/bin/zkEnv.sh in line #30

9) vim /opt/zookeeper/zookeeper-data/myid 
     
10) vim /opt/kafka/kafka-bin/config/server.properties	
root@mq-01:~# cat /opt/kafka/kafka-bin/config/server.properties
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This configuration file is intended for use in ZK-based mode, where Apache ZooKeeper is required.
# See kafka.server.KafkaConfig for additional details and defaults
#

############################# Server Basics #############################

# The id of the broker. This must be set to a unique integer for each broker.
broker.id=161

############################# Socket Server Settings #############################

# The address the socket server listens on. If not configured, the host name will be equal to the value of
# java.net.InetAddress.getCanonicalHostName(), with PLAINTEXT listener name, and port 9092.
#   FORMAT:
#     listeners = listener_name://host_name:port
#   EXAMPLE:
#     listeners = PLAINTEXT://your.host.name:9092
listeners=PLAINTEXT://172.16.2.161:9092

# Listener name, hostname and port the broker will advertise to clients.
# If not set, it uses the value for "listeners".
#advertised.listeners=PLAINTEXT://your.host.name:9092

# Maps listener names to security protocols, the default is for them to be the same. See the config documentation for more details
#listener.security.protocol.map=PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL

# The number of threads that the server uses for receiving requests from the network and sending responses to the network
num.network.threads=6

# The number of threads that the server uses for processing requests, which may include disk I/O
num.io.threads=8

# The send buffer (SO_SNDBUF) used by the socket server
socket.send.buffer.bytes=102400

# The receive buffer (SO_RCVBUF) used by the socket server
socket.receive.buffer.bytes=102400

# The maximum size of a request that the socket server will accept (protection against OOM)
socket.request.max.bytes=104857600


############################# Log Basics #############################

# A comma separated list of directories under which to store log files
log.dirs=/opt/kafka/kafka-data

# The default number of log partitions per topic. More partitions allow greater
# parallelism for consumption, but this will also result in more files across
# the brokers.
num.partitions=3

# The number of threads per data directory to be used for log recovery at startup and flushing at shutdown.
# This value is recommended to be increased for installations with data dirs located in RAID array.
num.recovery.threads.per.data.dir=1

############################# Internal Topic Settings  #############################
# The replication factor for the group metadata internal topics "__consumer_offsets" and "__transaction_state"
# For anything other than development testing, a value greater than 1 is recommended to ensure availability such as 3.
offsets.topic.replication.factor=3
transaction.state.log.replication.factor=3
transaction.state.log.min.isr=3

############################# Log Flush Policy #############################

# Messages are immediately written to the filesystem but by default we only fsync() to sync
# the OS cache lazily. The following configurations control the flush of data to disk.
# There are a few important trade-offs here:
#    1. Durability: Unflushed data may be lost if you are not using replication.
#    2. Latency: Very large flush intervals may lead to latency spikes when the flush does occur as there will be a lot of data to flush.
#    3. Throughput: The flush is generally the most expensive operation, and a small flush interval may lead to excessive seeks.
# The settings below allow one to configure the flush policy to flush data after a period of time or
# every N messages (or both). This can be done globally and overridden on a per-topic basis.

# The number of messages to accept before forcing a flush of data to disk
#log.flush.interval.messages=10000

# The maximum amount of time a message can sit in a log before we force a flush
#log.flush.interval.ms=1000

############################# Log Retention Policy #############################

# The following configurations control the disposal of log segments. The policy can
# be set to delete segments after a period of time, or after a given size has accumulated.
# A segment will be deleted whenever *either* of these criteria are met. Deletion always happens
# from the end of the log.

# The minimum age of a log file to be eligible for deletion due to age
log.retention.hours=168

# A size-based retention policy for logs. Segments are pruned from the log unless the remaining
# segments drop below log.retention.bytes. Functions independently of log.retention.hours.
#log.retention.bytes=1073741824

# The maximum size of a log segment file. When this size is reached a new log segment will be created.
#log.segment.bytes=1073741824

# The interval at which log segments are checked to see if they can be deleted according
# to the retention policies
log.retention.check.interval.ms=300000

############################# Zookeeper #############################

# Zookeeper connection string (see zookeeper docs for details).
# This is a comma separated host:port pairs, each corresponding to a zk
# server. e.g. "127.0.0.1:3000,127.0.0.1:3001,127.0.0.1:3002".
# You can also append an optional chroot string to the urls to specify the
# root directory for all kafka znodes.
zookeeper.connect=172.16.2.161:2181,172.16.2.162:2181,172.16.2.163:2181/kafka

# Timeout in ms for connecting to zookeeper
zookeeper.connection.timeout.ms=18000


############################# Group Coordinator Settings #############################

# The following configuration specifies the time, in milliseconds, that the GroupCoordinator will delay the initial consumer rebalance.
# The rebalance will be further delayed by the value of group.initial.rebalance.delay.ms as new members join the group, up to a maximum of max.poll.interval.ms.
# The default value for this is 3 seconds.
# We override this to 0 here as it makes for a better out-of-the-box experience for development and testing.
# However, in production environments the default value of 3 seconds is more suitable as this will help to avoid unnecessary, and potentially expensive, rebalances during application startup.
group.initial.rebalance.delay.ms=3000

11)apt install openjdk-19-jre-headless

12) systemctl restart zookeeper 
13) systemctl restart kafka 

14) cd /opt/zookeeper-bin/bin/ && zkcli.sh && ls /kafka/broker/ids

15) mkdir /opt/kafka/kafka-bin/connect && cd  /opt/kafka/kafka-bin/connect && wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/2.6.1.Final/debezium-connector-mysql-2.6.1.Final-plugin.tar.gz && tar xfz debezium-connector-mysql-2.6.1.Final-plugin.tar.gz && rm -fr debezium-connector-mysql-2.6.1.Final-plugin.tar.gz
16) add plugin.path=/opt/kafka/kafka-bin/connect to /opt/kafka/kafka-bin/config/connect-distributed.properties 
17) /opt/kafka/kafka-bin/bin/connect-distributed.sh  /opt/kafka/kafka-bin/config/connect-distributed.properties
18) vim /opt/debezium.json
   {
 "name": "advari-database",
 "config": {
   "connector.class": "io.debezium.connector.mysql.MySqlConnector",
   "database.user": "david",
   "database.server.id": "30",
   "database.history.kafka.bootstrap.servers": "172.16.2.161:9092,172.16.2.162:9092,172.16.2.163:9092",
   "schema.history.internal.kafka.bootstrap.servers": "172.16.2.161:9092,172.16.2.162:9092,172.16.2.163:9092",
   "database.history.kafka.topic": "sync-advari-organization",
   "schema.history.internal.kafka.topic": "sync-advari",
   "database.server.name": "advari",
   "topic.prefix": "mysql",
    "database.port": "3306",
    "include.schema.changes": "true",
    "database.hostname": "172.16.50.13",
    "database.password": "fnWIS1USrauTe5MWuFnC",
    "table.include.list": "organization",
    "database.include.list": "advari"
   }
}

19) cd /opt/ && curl -s  -X POST -H 'Content-type:application/json' -d  @debezium.json http://172.16.2.161:8083/connectors

20) 
curl -H "Application/json" 127.0.0.1:8083/connectors
curl -H "Application/json" 127.0.0.1:8083/connector-plugins
curl -H "Application/json" 127.0.0.1:8083/connectors/advari-database/status
curl -X POST  -H "Application/json" 127.0.0.1:8083/connectors/advari-database/restart 
curl -X "DELETE"    http://127.0.0.1:8083/connectors/advari-database

21) vim /opt/config.yml

kafka:
  clusters:
    -
      name: local
      bootstrapServers: 172.16.2.161:9092,172.16.2.162:9092,172.16.2.163:9092

22) docker run -it -p 8080:8080 -e spring.config.additional-location=/tmp/config.yml -v /opt/config.yml:/tmp/config.yml provectuslabs/kafka-ui
 
