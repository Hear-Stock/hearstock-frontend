import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LivePriceSocket {
  WebSocketChannel? channel;
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  void connect(String code) {
    if (channel != null) return;

    final wsUrl = 'ws://$baseUrl/api/stock/ws/trade-price';

    channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    // 연결되면 subscribe 전송
    Future.delayed(Duration(milliseconds: 100), () {
      channel?.sink.add(jsonEncode({"action": "subscribe", "code": code}));
    });
  }

  Stream<dynamic>? get stream => channel?.stream.asBroadcastStream();

  void disconnect() {
    channel?.sink.add(jsonEncode({"action": "unsubscribe"}));
    channel?.sink.close();
    channel = null;
  }
}
