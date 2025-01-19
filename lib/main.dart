import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'network_service.dart'; // Create this file to handle network operations.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NetworkService(),
      child: MaterialApp(
        title: 'LAN Messenger',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const UserListPage(),
      ),
    );
  }
}

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final networkService = Provider.of<NetworkService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Users'),
      ),
      body: ListView(
        children: networkService.onlineUsers.map((user) {
          return ListTile(
            title: Text(user.name),
            subtitle: Text(user.ipAddress),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(user: user),
                ),
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: networkService.sendPresence, // Broadcast your presence
        tooltip: 'Ping Network',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  final User user;

  const ChatPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${user.name}'),
      ),
      body: ChatBody(user: user),
    );
  }
}

class ChatBody extends StatelessWidget {
  final User user;

  const ChatBody({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: user.messages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(user.messages[index]),
              );
            },
          ),
        ),
        TextField(
          onSubmitted: (message) {
            Provider.of<NetworkService>(context, listen: false)
                .sendMessage(user, message);
          },
          decoration: const InputDecoration(hintText: 'Type a message...'),
        ),
      ],
    );
  }
}
