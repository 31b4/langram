import 'package:flutter/material.dart';
import 'dart:convert'; // For encoding/decoding messages.
import 'dart:io'; // Sockets and networking.

class NetworkService extends ChangeNotifier {
  final List<User> _onlineUsers = [];

  List<User> get onlineUsers => List.unmodifiable(_onlineUsers);

  // For sending "I'm online" messages periodically
  Future<void> sendPresence() async {
    final message = 'I_AM_ONLINE:${InternetAddress.tryParse("192.168.1.2")}';
    final socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4, 4445); // Choose port for LAN broadcasting
    socket.broadcastEnabled = true;
    socket.send(message.codeUnits, InternetAddress("255.255.255.255"), 4445);

    // Listen for incoming broadcast messages
    socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final packet = socket.receive();
        if (packet != null) {
          _processPacket(packet);
        }
      }
    });
  }

  // Process incoming packets
  void _processPacket(Datagram packet) {
    final data = utf8.decode(packet.data);
    if (data.startsWith('I_AM_ONLINE:')) {
      final address = data.replaceFirst('I_AM_ONLINE:', '');
      if (_onlineUsers
          .every((user) => user.ipAddress != address)) {
        _onlineUsers.add(User(
          name: 'User@${_onlineUsers.length}',
          ipAddress: address,
          messages: [],
        ));
        notifyListeners();
      }
    }
  }

  void sendMessage(User user, String message) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    final messageData = 'MSG:$message';
    socket.send(messageData.codeUnits, InternetAddress(user.ipAddress), 4446);
    socket.close();

    user.messages.add(message);
    notifyListeners();
  }
}

class User {
  final String name;
  final String ipAddress;
  final List<String> messages;

  User({required this.name, required this.ipAddress, required this.messages});
}
