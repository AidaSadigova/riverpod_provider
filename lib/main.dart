import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

final usersProvider = FutureProvider<List<User>>((ref) async {
  final response =
      await http.get(Uri.parse("https://jsonplaceholder.typicode.com/users"));

  if (response.statusCode == 200) {
    final List<dynamic> responseData = json.decode(response.body);
    return responseData.map((data) => User.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load users');
  }
});

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserListScreen(),
    );
  }
}

class UserListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[600],
        title: Text('USERS'),
      ),
      body: usersAsync.when(
        data: (users) {
          return ListView.builder(
              itemCount: users.length,
              itemBuilder: (BuildContext context, int index) {
                final user = users[index];
                return SizedBox(
                  height: 80,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.00),
                      ),
                    ),
                    onPressed: () {
                      _showUserInfoDialog(context, user);
                    },
                    child: Text('See Information of User ${user.id}'),
                  ),
                );
              });
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _showUserInfoDialog(BuildContext context, User user) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shadowColor: Colors.pink,
          backgroundColor: Colors.pink[100],
          title: const Text(
            'User Information',
            style: TextStyle(color: Colors.pink, fontSize: 25),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${user.name}',
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
              Text('Email: ${user.email}',
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
              Text('Phone: ${user.phone}',
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.pink, fontSize: 23),
              ),
            ),
          ],
        );
      },
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
