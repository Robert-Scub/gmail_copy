import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final emailProvider = StateProvider<Email>((ref) {
  print(ref);
  return Email('Sender ${generateRandomString(2)}', generateRandomString(25));
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  build(_, __) => MaterialApp(
      title: 'Gmail landing page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Gmail landing page'),
    );
}

String generateRandomString(int length) {
  final random = Random();
  const availableChars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
  final randomString = List.generate(length,
          (index) => availableChars[random.nextInt(availableChars.length)]).join();

  return randomString;
}

class MyHomePage extends StatefulWidget {
  final title;
  const MyHomePage({super.key, required this.title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final _animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
    reverseDuration: const Duration(seconds: 2),
  );
  bool onSearchClick = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  //ScrollNotifier evenement de scroll
  //provider, lance anime du bouton

  //overlay ou page qui vient d'en haut lors du clic

  //Navigator.push pour le clic sur un email

  //Search bar à faire fonctionner

  @override
  build(context) => SafeArea(
    child: Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            SizedBox(
              height: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset('logo_gmail.png'),
                  const Divider(color: Color.fromRGBO(
                      166, 159, 159, 0.3), thickness: 2),
                ],
              ),
            ),
            const ListTile(
              leading: Icon(Icons.email),
              title: Text('Inbox'),
            ),
            const ExpansionTile(
              leading: Icon(Icons.archive),
              trailing: Icon(Icons.keyboard_arrow_down_outlined),
              title: Text('Archives'),
              children: [
                ListTile(
                  title: Text('Work'),
                ),
                ListTile(
                  title: Text('Perso'),
                ),
              ],
            ),
            const ListTile(
              leading: Icon(Icons.send),
              title: Text('Send'),
            ),
            const ListTile(
              leading: Icon(Icons.note_alt),
              title: Text('Draft'),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: AnimatedSwitcher(
              duration: const Duration(seconds: 5),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: !onSearchClick ? IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => scaffoldKey.currentState?.openDrawer(),
              ) : IconButton(
                icon: AnimatedIcon(icon: AnimatedIcons.arrow_menu, progress: _animationController.view,),
                onPressed: () => scaffoldKey.currentState?.closeDrawer(),
              ),
            ),
            floating: true,
            pinned: false,
            snap: false,
            title: TextField(
              decoration: const InputDecoration(
                hintText: 'Search in messages',
              ),
              onTap: () {
                setState(() {
                  onSearchClick = !onSearchClick;
                });
              },
            ),
          ),
          SliverList(
          delegate: SliverChildListDelegate(
            [
            for(int i = 0; i < 10; i++)
              Card(
                child: ListTile(
                  leading: const FlutterLogo(size: 56.0),
                  title: Text(generateRandomString(8)),
                  subtitle: Text(generateRandomString(25)),
                  trailing: const Icon(Icons.more_vert),
                  isThreeLine: true,
                  // onTap: () => ref.read(emailProvider),
                ),
              ),
            ], // Email(ref.read(emailProvider).sender, ref.read(emailProvider).body),
          ),
        ),
      ],
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () => {},
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
          ),
        ),
        icon: const Icon(Icons.create),
        label: const Text(style: TextStyle(fontSize: 18.0),'Send e-mail'),
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
          // onTap: () => ref.read(emailProvider),
        ),
      ),
    ],
  );
}
