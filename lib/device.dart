import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:upnp/server.dart';
import 'package:upnp/upnp.dart';
import 'package:web_socket_channel/io.dart';
import 'package:wake_on_lan/wake_on_lan.dart';
import 'key_codes.dart';

final int kConnectionTimeout = 60;
final kKeyDelay = 200;
final kWakeOnLanDelay = 5000;
final kUpnpTimeout = 1000;

// import wol from 'wake_on_lan'
// import WebSocket from 'ws'
// import request from 'request-promise'
// import SSDP from 'node-ssdp'

// import { getLogger } from 'appium-logger'
// import { KEY_CODES } from './constants'

// const log = getLogger('SamsungRemote')

// const CONNECTION_TIMEOUT = 60000
// const KEY_DELAY = 200
// const WAKE_ON_LAN_DELAY = 5000
// const UPNP_TIMEOUT = 1000

class SamsungSmartTV {
  final List<Map<String, dynamic>> services;
  final String host;
  final String mac;
  final String api;
  final String wsapi;
  final String deviceName;
  bool isConnected = false;
  String token;
  dynamic info;
  IOWebSocketChannel ws;
  Timer timer;

  SamsungSmartTV({this.host, this.mac, this.deviceName})
      : api = "http://$host:8001/api/v2/",
        wsapi = "wss://$host:8002/api/v2/",
        services = [];

  // ignore: slash_for_doc_comments
  /**
     * add UPNP service
     * @param [Object] service  UPNP service description
     */
  addService(service) {
    this.services.add(service);
  }

  Future<void> connect(
      {appName = 'SamsungSmartRemote', String tokenValue}) async {
    var completer = new Completer();

    if (this.isConnected) {
      return;
    }

    // // make sure to turn on TV in case it is turned off
    // if (mac != null) {
    //   await this.wol(this.mac);
    // }

    // get device info
    info = await getDeviceInfo();

    print("Device info: " + info.toString());

    // establish socket connection
    final appNameBase64 = base64.encode(utf8.encode(appName));
    String channel =
        "${wsapi}channels/samsung.remote.control?name=$appNameBase64";
    //"${wsapi}channels/com.samsung.art-app?name=$appNameBase64";
    if (tokenValue != null) {
      channel += '&token=$tokenValue';
      this.token = tokenValue;
    } else {
      channel += '&token=$token';
    }

    // log.info(`Connect to ${channel}`)
    // ws = IOWebSocketChannel.connect(channel);
    ws = IOWebSocketChannel.connect(channel,
        badCertificateCallback: (X509Certificate cert, String host, int port) =>
            true);

    ws.stream.listen((message) {
      // timer?.cancel();

      Map<String, dynamic> data;
      try {
        data = json.decode(message);
      } catch (e) {
        throw ('Could not parse TV response $message');
      }

      if (data["data"] != null && data["data"]["token"] != null) {
        token = data["data"]["token"];
      }

      if (data["event"] != 'ms.channel.connect') {
        print('TV responded with $data');

        // throw ('Unable to connect to TV');
      }

      print('Connection successfully established');
      isConnected = true;
      completer.complete();

      // timer = Timer(Duration(seconds: kConnectionTimeout), () {
      //   throw ('Unable to connect to TV: timeout');
      // });

      // ws.sink.add("received!");
    });

    return completer.future;
  }

  // request TV info like udid or model name

  Future<http.Response> getDeviceInfo() async {
    print("Get device info from $api");
    return await http.get(this.api);
  }

  // disconnect from device

  disconnect() {
    // ws.sink.close(status.goingAway);
    ws.sink.close();
  }

  // request TV info like udid or model name

  Future<http.Response> openTVApp(String app) async {
    String address;
    switch (app) {
      case "Prime":
        {
          address = "http://$host:8001/api/v2/applications/3201512006785";
        }
        break;
      case "HBO":
        {
          address = "http://$host:8001/api/v2/applications/3201512006785";
        }
        break;

      default:
        {
          address = "http://$host:8001/ws/apps/$app";
        }
        break;
    }
    return http.post(address);
  }

  // disconnect from device

  sendKey(KEY_CODES key) async {
    if (!isConnected) {
      throw ('Not connected to device. Call `tv.connect()` first!');
    }

    print("Send key command  ${key.toString().split('.').last}");
    final data = json.encode({
      "method": 'ms.remote.control',
      "params": {
        "Cmd": 'Click',
        "DataOfCmd": key.toString().split('.').last,
        "Option": false,
        "TypeOfRemote": 'SendRemoteKey',
      }
    });

    ws.sink.add(data);

    // add a delay so TV has time to execute
    Timer(Duration(seconds: kConnectionTimeout), () {
      throw ('Unable to connect to TV: timeout');
    });

    return Future.delayed(Duration(milliseconds: kKeyDelay));
  }

  newSendKey(String key) async {
    if (!isConnected) {
      throw ('Not connected to device. Call `tv.connect()` first!');
    }

    print("Send key command  ${key.toString().split('.').last}");
    final data = json.encode({
      "method": 'ms.remote.control',
      "params": {
        "Cmd": 'Click',
        "DataOfCmd": key.toString(),
        "Option": false,
        "TypeOfRemote": 'SendRemoteKey',
      }
    });

    ws.sink.add(data);

    // add a delay so TV has time to execute
    Timer(Duration(seconds: kConnectionTimeout), () {
      throw ('Unable to connect to TV: timeout');
    });

    return Future.delayed(Duration(milliseconds: kKeyDelay));
  }

// send text input
  sendInputString(String key) async {
    if (!isConnected) {
      throw ('Not connected to device. Call `tv.connect()` first!');
    }

    print("Send key command  ${key.toString()}");
    final data = json.encode({
      "method": 'ms.remote.control',
      "params": {
        "Cmd": base64.encode(utf8.encode(key)),
        "DataOfCmd": 'base64',
        "TypeOfRemote": 'SendInputString',
      }
    });

    ws.sink.add(data);

    // add a delay so TV has time to execute
    Timer(Duration(seconds: kConnectionTimeout), () {
      throw ('Unable to connect to TV: timeout');
    });

    return Future.delayed(Duration(milliseconds: kKeyDelay));
  }

//Get installed Apps
  Future<http.Response> getInstalledApps() async {
    if (!isConnected) {
      throw ('Not connected to device. Call `tv.connect()` first!');
    }

    final data = json.encode({
      "method": 'ms.channel.emit',
      "params": {"data": '', "event": 'ed.installedApp.get', "to": 'host'}
    });
    ws.sink.add(data);
    // add a delay so TV has time to execute
    Timer(Duration(seconds: kConnectionTimeout), () {
      throw ('Unable to connect to TV: timeout');
    });

    return Future.delayed(Duration(milliseconds: kKeyDelay));
  }

  getApplication() async {
    if (!isConnected) {
      throw ('Not connected to device. Call `tv.connect()` first!');
    }
    final data = json.encode({
      "method": 'ms.channel.emit',
      "params": {"data": '', "event": 'ed.edenApp.get', "to": 'host'}
    });
    ws.sink.add(data);
  }

  getApplicationIcon() async {
    if (!isConnected) {
      throw ('Not connected to device. Call `tv.connect()` first!');
    }
    final data = json.encode({
      "method": 'ms.channel.emit',
      "params": {
        "data": {
          "icon_path":
              "/opt/share/webappservice/apps_icon/FirstScreen/11101200001/250x250.png",
        },
        "event": 'ed.apps.icon',
        "to": 'host'
      }
    });
    ws.sink.add(data);
  }

  //static method to discover Samsung Smart TVs in the network using the UPNP protocol

  static discover() async {
    var completer = new Completer();

    final client = DeviceDiscoverer();
    final List<SamsungSmartTV> tvs = [];

    await client.start(ipv6: false);

    client.quickDiscoverClients().listen((client) async {
      RegExp re = RegExp(r'^.*?Samsung.+UPnP.+SDK\/1\.0$');

      //ignore other devices
      if (!re.hasMatch(client.server)) {
        return;
      }
      try {
        final device = await client.getDevice();
        Uri location = Uri.parse(client.location);

        final deviceExists = tvs.firstWhere((tv) => tv.host == location.host,
            orElse: () => null);

        if (deviceExists == null) {
          print("Found ${device.friendlyName} on IP ${location.host}");
          final tv = SamsungSmartTV(
              host: location.host, deviceName: device.friendlyName);
          tv.addService({
            "location": client.location,
            "server": client.server,
            "st": client.st,
            "usn": client.usn
          });
          tvs.add(tv);
        }
      } catch (e, stack) {
        print("ERROR: $e - ${client.location}");
        print(stack);
      }
    }).onDone(() {
      if (tvs.isEmpty) {
        completer.completeError(
            "No Samsung TVs found. Make sure the UPNP protocol is enabled in your network.");
      }
      completer.complete(tvs.first);
    });

    return completer.future;
  }

  static wakeOnLan(String _ip, String _mac) {
    try {
      String ip = _ip;
      String mac = _mac;
      // Validate that the two strings are formatted correctly
      if (!IPv4Address.validate(ip)) {
        print('Invalid IPv4 Address String');
        return false;
      }
      if (!MACAddress.validate(mac)) {
        print('Invalid MAC Address String');
        return false;
      }
      // Create the IPv4 and MAC objects
      IPv4Address ipv4Address = IPv4Address.from(ip);
      MACAddress macAddress = MACAddress.from(mac);
      // Send the WOL packet
      // Port parameter is optional, set to 55 here as an example, but defaults to port 9
      WakeOnLAN.from(ipv4Address, macAddress, port: 55).wake();
      return true;
    } catch (e) {
      print("error waking lan");
      return false;
    }
  }
}
