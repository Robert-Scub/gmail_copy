import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final emailProvider = StateProvider<Email>((ref) {
  print(ref);
  return Email('Sender ${generateRandomString(8)}', generateRandomString(25));
});

enum Routes {
  email_page,
  search_tap_page,
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  build(_, ref) => MaterialApp(
      title: 'Gmail landing page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Gmail landing page', ref: ref),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/${Routes.email_page.name}': (context) =>
            EmailPage(ref.read(emailProvider).sender,
                ref.read(emailProvider).body),
        '/${Routes.search_tap_page.name}': (context) => const SearchTapPage(),
      }
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

class MyHomePage extends ConsumerStatefulWidget {
  final title;
  final WidgetRef ref;
  const MyHomePage({super.key, required this.title, required this.ref});

  @override
  _MyHomePageState createState() => _MyHomePageState(ref);
}

final scrollingProvider = StateProvider<Scrolling>((ref) => scrollingStatus);
final scrollingStatus = Scrolling(isScrolling: false);

class Scrolling {
  late bool isScrolling;
  
  Scrolling({required this.isScrolling});
}

class _MyHomePageState extends ConsumerState<MyHomePage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  _MyHomePageState(WidgetRef ref);

  //ScrollNotifier evenement de scroll
  //provider, lance anime du bouton

  //overlay ou page qui vient d'en haut lors du clic

  //Search bar à faire fonctionner

  @override
  build(context) => SafeArea(
    child: NotificationListener(
      // onNotification: (notification) {
      //   print(notification);
      //   print(scrollingStatus.isScrolling);
      //   return notification ?
      //     scrollingStatus.isScrolling = true
      //           : scrollingStatus.isScrolling = false;
      // },
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
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => scaffoldKey.currentState?.openDrawer(),
              ),
              floating: true,
              pinned: false,
              snap: false,
              actions: const [
                CircleAvatar(child: Image(image: AssetImage('dracula.png'),),)
              ],
              title: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search in mail',
                ),
                onTap: () => Navigator.pushNamed(context, '/${Routes.search_tap_page.name}'),
              ),
            ),
            // if (!onSearchClick)
              SliverList(delegate: SliverChildListDelegate([
                for(int i = 0; i < 10; i++)
                  Email(ref.read(emailProvider).sender, ref.read(emailProvider).body)
              ],
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
          label: ref.watch(scrollingProvider).isScrolling ?
            const Text('')
              : const Text(style: TextStyle(fontSize: 18.0),'New e-mail'),
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
    ),
  );
}

class Email extends ConsumerWidget {
  const Email(this.sender, this.body, {super.key});
  final String sender;
  final String body;

  @override
  build(context, ref) => Card(
    child: ListTile(
      leading: const FlutterLogo(size: 56.0),
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(ref.read(emailProvider).sender),
      ),
      subtitle: Column(
        children: [
          Text(ref.read(emailProvider).body),
          Text(ref.read(emailProvider).body),
        ],
      ),
      trailing: const Icon(Icons.more_vert),
      isThreeLine: true,
      onTap: () => Navigator.pushNamed(context, '/${Routes.email_page.name}'),
    ),
  );
}

class EmailPage extends ConsumerWidget {
  EmailPage(this.sender, this.body, {super.key});
  final String sender;
  final String body;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  build(context, ref) =>
      SafeArea(
        child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            leading: IconButton(icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushNamed(context, '/'),),
            actions: [
              IconButton(icon: const Icon(Icons.archive_outlined),
                onPressed: () => Navigator.pushNamed(context, '/'),),
              IconButton(icon: const Icon(Icons.email_outlined),
                onPressed: () => Navigator.pushNamed(context, '/'),),
              IconButton(icon: const Icon(Icons.delete),
                onPressed: () => Navigator.pushNamed(context, '/'),),
              IconButton(icon: const Icon(Icons.more_horiz),
                onPressed: () => scaffoldKey.currentState!.openDrawer(),),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: const [
                ListTile(
                  title: Text('Edit label'),
                ),
                ListTile(
                  title: Text('Add to favorite'),
                ),
                ListTile(
                  title: Text('Ignore'),
                ),
                ListTile(
                  title: Text('Unsubscribe'),
                ),
                ListTile(
                  title: Text('Mark as spam'),
                ),
                ListTile(
                  title: Text('Paste'),
                ),
              ],
            ),
          ),
          body: Text(
            "Email Page",
            style: TextStyle(
              color: Colors.green[900],
              fontSize: 45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
}

class SearchTapPage extends ConsumerWidget {
  const SearchTapPage({super.key});

  @override
  build(context, ref) =>
      SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushNamed(context, '/'),),
            actions: [
              IconButton(onPressed: () {},
                  icon: const Icon(Icons.mic_rounded))
            ],
            title: const TextField(
              decoration: InputDecoration(
                hintText: 'Search in mail',
              ),
              //onTap: () => Navigator.pushNamed(context, '/'),
            ),
          ),
          body: Container(
            height: 50,
            child: CustomScrollView(
              scrollDirection: Axis.horizontal,
              slivers: [
                SliverList(delegate: SliverChildListDelegate([
                  for(int i = 0; i < 6; i++)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0),
                      child: ElevatedButton(onPressed: () {},
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                      ), child: Row(
                        children: const [
                          Text('Libellé'),
                          Icon(Icons.arrow_drop_down, size: 18.0,)
                        ],
                      ),),
                    )
                ]))
              ],
            ),
          )
        ),
      );
}
