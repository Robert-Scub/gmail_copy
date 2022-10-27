import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final emailProvider = StateProvider<EmailData>((ref) {
  print(ref);
  return const EmailData('Apple', 'Expiring subscription',
  'Action needed in your account, '
      'please update your payment preference because we could not proceed this month');
});

enum Routes {
  email_page,
  search_tap_page,
}

class EmailData {
  final String sender;
  final String object;
  final String body;
  const EmailData(this.sender, this.object, this.body);
}

final formattedDateTimeNow = DateFormat('kk:mm').format(DateTime.now());
bool scrollingStatus = false;
bool scrollingUp = false;

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
                ref.read(emailProvider).body, ref),
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

/*TODO */
//overlay ou page qui vient d'en haut lors du clic
//Search bar à faire fonctionner

class _MyHomePageState extends ConsumerState<MyHomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<SliverAnimatedListState> _listKey =
  GlobalKey<SliverAnimatedListState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ListModel<int> _list;
  int? _selectedItem;
  late int _nextItem;

  _MyHomePageState(WidgetRef ref);

  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    return CardMailItem(
      animation: animation,
      item: _list[index],
      selected: _selectedItem == _list[index],
      onTap: () {
        setState(() {
          _selectedItem = _selectedItem == _list[index] ? null : _list[index];
        });
      },
    );
  }

  Widget _buildRemovedItem(
      int item, BuildContext context, Animation<double> animation) {
    return CardMailItem(
      animation: animation,
      item: item,
    );
  }

  void _remove() {
    if (_selectedItem != null) {
      _list.removeAt(_list.indexOf(_selectedItem!));
      setState(() {
        _selectedItem = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _list = ListModel<int>(
      listKey: _listKey,
      initialItems: <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
      removedItemBuilder: _buildRemovedItem,
    );
    _nextItem = 13;
  }

  @override
  build(context) => SafeArea(
    child: NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        setState(() {
          notification.scrollDelta! < 0 ? scrollingUp = true : scrollingUp = false;
        });
        return scrollingStatus;
      },
      child: Scaffold(
        key: _scaffoldKey,
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
            _selectedItem != null ? SliverAppBar(
              floating: true,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pushNamed(context, '/'),
              ),
              title: Text(_selectedItem != null ? '1' : ''),
              actions: [
                IconButton(icon: const Icon(Icons.archive_outlined),
                  onPressed: () => Navigator.pushNamed(context, '/'),),
                IconButton(icon: const Icon(Icons.delete_outlined),
                  onPressed: () {
                    _remove();
                  },),
                IconButton(icon: const Icon(Icons.mark_email_read),
                  onPressed: () => Navigator.pushNamed(context, '/'),),
                IconButton(icon: const Icon(Icons.more_horiz),
                  onPressed: () => Navigator.pushNamed(context, '/'),),
              ],
            ) : SliverAppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              floating: true,
              pinned: false,
              snap: false,
              title: SearchInMail(Routes.search_tap_page.name),
              actions: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('dracula.png'),),
                )
              ],
            ),
            SliverAnimatedList(
              key: _listKey,
              initialItemCount: _list.length,
              itemBuilder: _buildItem,
            ),
          ],
        ),
        floatingActionButton: AnimatedContainer(
          width: scrollingUp ? 140 : 50,
          height: 50,
          duration: const Duration(milliseconds: 300),
          //transformAlignment: AlignmentDirectional.centerStart,
          child: ElevatedButton(
            onPressed: () {},
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
            child: Row(children: [
              const Icon(Icons.create, size: 18.0,),
              if (scrollingUp)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(style: TextStyle(fontSize: 16.0),'New e-mail'),
                )
              else const Padding(padding: EdgeInsets.zero)
            ],),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    ),
  );

  Widget? _buildBottomBar() => AnimatedContainer(
    height: scrollingUp ? 50 : 0,
    duration: const Duration(milliseconds: 300),
    child: Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 64.0, right: 64.0),
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.mail_outline_outlined)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 64.0, right: 64.0),
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.video_camera_back_outlined)),
          ),
        ],),
    ),
  );

}

class EmailList extends ConsumerWidget {
  EmailList(this.sender, this.object, this.body, {super.key});
  final String sender;
  final String object;
  final String body;

  @override
  build(context, ref) => ListTile(
    leading: const CircleAvatar(radius: 24, backgroundImage: AssetImage('avatar.png'),),
    title: Text(sender),
    subtitle: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Text(object, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Text(body, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    ),
    trailing: Column(
      children: [
        Text(formattedDateTimeNow),
        IconButton(
          padding: const EdgeInsets.only(top: 8.0),
          onPressed: () {},
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.star_border_outlined),),
      ],
    ),
    isThreeLine: true,
    //onTap: () => Navigator.pushNamed(context, '/${Routes.email_page.name}'),
  );
}

class EmailPage extends ConsumerWidget {
  EmailPage(this.sender, this.body, WidgetRef ref, {super.key});
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
              IconButton(icon: const Icon(Icons.delete_outlined),
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
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                ListTile(
                  title: Text(ref.read(emailProvider).object,
                    style: const TextStyle(fontSize: 18.0),),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.star_border_outlined)),
                ),
                ListTile(
                  leading: const CircleAvatar(radius: 24, backgroundImage: AssetImage('avatar.png'),),
                  title: Row(
                    children: [
                      Container(
                        width: 65,
                        child: Text(ref.read(emailProvider).sender, maxLines: 1,
                        overflow: TextOverflow.ellipsis,),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(formattedDateTimeNow),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('to me'),
                      Container(
                        height: 30,
                        width: 30,
                        child: IconButton(iconSize: 18.0, icon: const Icon(Icons.keyboard_arrow_down), onPressed: () {},))
                    ],
                  ),
                  isThreeLine: false,
                  trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz),),
                ),
              ],
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
            title: const SearchInMail(''),
          ),
          body: SizedBox(
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
                      ),
                      child: Row(
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

class SearchInMail extends StatelessWidget {
  const SearchInMail(this.name, {super.key});
  final String name;

  @override
  build(context) => TextFormField(
    style: const TextStyle(color: Colors.white,),
    decoration: const InputDecoration(
      hintStyle: TextStyle(color: Colors.white),
      border: InputBorder.none,
      hintText: 'Search in mail',
    ),
    onTap: () {
      if(name.isNotEmpty) {
        Navigator.pushNamed(context, '/$name');
      }
    },
  );
}

class CardMailItem extends ConsumerWidget {
  const CardMailItem({
    super.key,
    this.onTap,
    this.selected = false,
    required this.animation,
    required this.item,
  }) : assert(item >= 0);

  final Animation<double> animation;
  final VoidCallback? onTap;
  final int item;
  final bool selected;

  TextStyle boldOnSelect() {
    return selected ? const TextStyle(fontWeight: FontWeight.bold) :
      const TextStyle(fontWeight: FontWeight.normal);
  }

  @override
  build(context, ref) => SizeTransition(
    sizeFactor: animation,
    child: SizedBox(
      height: 90.0,
      child: Card(
        child: Slidable(
          direction: Axis.horizontal,
          startActionPane: ActionPane(
            motion: const BehindMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {},
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              )
            ],
          ),
          closeOnScroll: true,
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {},
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                icon: Icons.archive_outlined,
                label: 'Archive',
              )
            ],
          ),
          child: ListTile(
            leading: IconButton(
              iconSize: 44.0,
              onPressed: onTap,
              icon: selected ? Image.asset('tick.png') : const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20.0,
                backgroundImage: AssetImage('avatar.png'),),
            ),
            title: Text(ref.read(emailProvider).sender, style: boldOnSelect()),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Text(ref.read(emailProvider).object,
                      style: boldOnSelect(), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Text(ref.read(emailProvider).body,
                    style: boldOnSelect(), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
            trailing: Column(
              children: [
                Text(formattedDateTimeNow),
                IconButton(
                  padding: const EdgeInsets.only(top: 8.0),
                  onPressed: () {},
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.star_border_outlined),),
              ],
            ),
            isThreeLine: true,
            onTap: () => Navigator.pushNamed(context, '/${Routes.email_page.name}'),
          ),
        ),
      )
    ),
  );
}

class ListModel<E> {
  ListModel({
    required this.listKey,
    required this.removedItemBuilder,
    Iterable<E>? initialItems,
  }) : _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<SliverAnimatedListState> listKey;
  final RemovedItemBuilder removedItemBuilder;
  final List<E> _items;

  SliverAnimatedListState get _animatedList => listKey.currentState!;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList.removeItem(
        index,
            (BuildContext context, Animation<double> animation) =>
            removedItemBuilder(index, context, animation),
      );
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}

typedef RemovedItemBuilder = Widget Function(
    int item, BuildContext context, Animation<double> animation);
