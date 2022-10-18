import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final emailProvider = StateProvider<Email>((ref) {
  print(Email);
  return Email('Sender ${generateRandomString(2)}', generateRandomString(25));
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  build(_, __) => MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Gmail landing page'),
    );
}

String generateRandomString(int length) {
  final random = Random();
  const availableChars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final randomString = List.generate(length,
          (index) => availableChars[random.nextInt(availableChars.length)]).join();

  return randomString;
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  build(_, ref) => Scaffold(
    appBar: AppBar(
        title: SizedBox(
          height: 40,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search in messages',
              iconColor: Colors.white,
            ),
          onChanged: (value) => {},
          ),
        ),
      ),
    drawer: Drawer(
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: const  [
          SizedBox(
            height: 55,
            child: DrawerHeader(
              child: Image(image: AssetImage("logo_gmail.png")),
            ),
          ),
          ListTile(
            title: Text('Inbox'),
          ),
          ListTile(
            title: Text('Send'),
          ),
          ListTile(
            title: Text('Favorites'),
          ),
          ListTile(
            title: Text('Draft'),
          ),
        ],
      ),
    ),
    body: Email(ref.read(emailProvider).sender, ref.read(emailProvider).body),
    floatingActionButton: ElevatedButton(
      onPressed: () => {},
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
        ),
      ),
      child: const Text('Send e-mail'),
    ),
    bottomNavigationBar: BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
            label: 'Inbox', icon: Icon(Icons.email_outlined)),
        BottomNavigationBarItem(
            label: 'Meet', icon: Icon(Icons.video_camera_back_outlined)),
      ],
      // selectedItemColor: Colors.amber[800],
    ),
  );
}

class Email extends ConsumerWidget {
  Email(this.sender, this.body, {super.key});
  final String sender;
  final String body;

  @override
  build(_, ref) => ListView(
    padding: const EdgeInsets.all(8.0),
    children: [
    for(int i = 0; i < 10; i++)
      Card(
        child: ListTile(
          leading: const FlutterLogo(size: 56.0),
          title: Text(sender),
          subtitle: Text(body),
          trailing: const Icon(Icons.more_vert),
          isThreeLine: true,
          onTap: () => ref.read(emailProvider),
        ),
      ),
    ],
  );
}
