import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:iot_test/cert.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Connection{

  Future<MqttServerClient> connect() async {
    MqttServerClient client =
    MqttServerClient.withPort('ayf5du10muu8i-ats.iot.us-east-2.amazonaws.com', 'flutterTest', 8883);
    client.logging(on: true);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onUnsubscribed = onUnsubscribed;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;

    ByteData data1 = await rootBundle.load('AwsIotKeys/d18ad5a615-certificate.pem.crt');
    ByteData data2 = await rootBundle.load('AwsIotKeys/d18ad5a615-private.pem.key');
    ByteData data3 = await rootBundle.load('AwsIotKeys/AWSCAcertificate.txt');
    SecurityContext context = SecurityContext.defaultContext;

    try {
      context.setTrustedCertificatesBytes(utf8.encode(SC));
      context.setClientAuthoritiesBytes(utf8.encode(CA));
      context.usePrivateKeyBytes(utf8.encode(PvK));
    }
    on Exception catch (e) {
      print('error certificado' + e.toString());
    }

    // SecurityContext context = SecurityContext()
    //   ..useCertificateChain('AwsIotKeys/d18ad5a615-certificate.pem.crt')
    //   ..usePrivateKey('AwsIotKeys/d18ad5a615-private.pem.key')
    //   ..setClientAuthorities('AwsIotKeys/AWSCAcertificate.txt');
    client.secure = true;
    client.securityContext = context;
    client.setProtocolV311();

    final connMessage = MqttConnectMessage()
        .keepAliveFor(60)
        .withWillTopic('willtopic')
        .withWillMessage('oops')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;
    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload;
      final payload =
      MqttPublishPayload.bytesToStringAsString(message.payload.message);

      print('Received message:$payload from topic: ${c[0].topic}>');
    });

    return client;
  }
  void onConnected() {
    print('Connected');
  }

// unconnected
  void onDisconnected() {
    print('Disconnected');
  }

// subscribe to topic succeeded
  void onSubscribed(String topic) {
    print('Subscribed topic: $topic');
  }

// subscribe to topic failed
  void onSubscribeFail(String topic) {
    print('Failed to subscribe $topic');
  }

// unsubscribe succeeded
  void onUnsubscribed(String topic) {
    print('Unsubscribed topic: $topic');
  }

// PING response received
  void pong() {
    print('Ping response client callback invoked');
  }
}
