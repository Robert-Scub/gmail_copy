import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final emailProvider = StateProvider<EmailData>((ref) =>
  const EmailData('Apple', 'Expiring subscription',
  'Action needed in your account, '
      'please update your payment preference because we could not proceed this month'));
final cardMailItemProvider = StateProvider<List<int>>((ref) => listOfSelectedMail);
final favoriteMailProvider = StateProvider<List<int>>((ref) => favoriteMailList);
final optionMailSelectProvider = StateProvider<List<int>>((ref) => favoriteMailList);

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
final List<int> listOfSelectedMail = [];
final List<int> favoriteMailList = [];
final List<int> optionMailSelectList = [];
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
            ref.read(emailProvider).body, ref,
              () => ref.watch(optionMailSelectProvider)),
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
  late AnimationController animationController;
  bool appBarReturnSelected = false;

  _MyHomePageState(WidgetRef ref);

  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    bool emailSelected = ref.watch(cardMailItemProvider).contains(_list[index]);
    bool favEmailSelected = ref.watch(favoriteMailProvider).contains(_list[index]);
    return CardMailItem(
      animation: animation,
      item: _list[index],
      selected: !ref.watch(cardMailItemProvider).contains(_list[index]),
      favoriteTap : () {
        setState(() {
          if (!favEmailSelected) {
            ref.watch(favoriteMailProvider).add(_list[index]);
          } else {
            ref.watch(favoriteMailProvider).remove(_list[index]);
          }
        });
      },
      onTap: () {
        setState(() {
          if (!emailSelected) {
            animationController.forward();
            ref.watch(cardMailItemProvider).add(_list[index]);
          } else {
            animationController.reverse();
            ref.watch(cardMailItemProvider).remove(_list[index]);
          }
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
    List<int> listFromProvider = ref.watch(cardMailItemProvider);
    List<int> cardMailToRemove = [];
    listFromProvider.forEach((element) {
      if (listFromProvider.contains(element)) {
        _list.removeAt(_list.indexOf(element));
        cardMailToRemove.add(element);
      }
    });
    listFromProvider.removeWhere((element) => cardMailToRemove.contains(element));
    animationController.reverse();
  }

  @override
  void initState() {
    super.initState();
    _list = ListModel<int>(
      listKey: _listKey,
      initialItems: <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
      removedItemBuilder: _buildRemovedItem,
    );
    animationController =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
      );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
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
            ref.watch(cardMailItemProvider).isNotEmpty ? SliverAppBar(
              floating: true,
              pinned: true,
              leading:
              IconButton(
                icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow, progress: animationController),
                splashRadius: 2,
                onPressed: () {
                  List<int> listFromProvider = ref.watch(cardMailItemProvider);
                  List<int> cardMailToRemove = [];
                  listFromProvider.forEach((element) {
                    if (listFromProvider.contains(element)) {
                      cardMailToRemove.add(element);
                    }
                  });
                  listFromProvider.removeWhere((element) => cardMailToRemove.contains(element));
                }
              ),
              title: Text(ref.watch(cardMailItemProvider).isNotEmpty ?
                ref.watch(cardMailItemProvider).length.toString() : ''),
              actions: [
                IconButton(icon: const Icon(Icons.archive_outlined),
                  splashRadius: 2,
                  onPressed: () => Navigator.pushNamed(context, '/'),),
                IconButton(icon: const Icon(Icons.delete_outlined),
                  splashRadius: 2,
                  onPressed: () {
                    setState(() {
                      _remove();
                    });
                  },),
                IconButton(icon: const Icon(Icons.mark_email_read),
                  splashRadius: 2,
                  onPressed: () => Navigator.pushNamed(context, '/'),),
                IconButton(icon: const Icon(Icons.more_horiz),
                  splashRadius: 2,
                  onPressed: () => Navigator.pushNamed(context, '/'),),
              ],
            ) :
            SliverAppBar(
              leading: IconButton(
                icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow, progress: animationController),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              floating: true,
              pinned: false,
              snap: false,
              title: SearchInMail(Routes.search_tap_page.name),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PopupMenuButton(
                    offset: const Offset(-50, 50),
                    itemBuilder: (context) => [
                      PopupMenuItem(child: Center(
                        widthFactor: 0.8,
                        child: ListTile(
                          leading: IconButton(onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, size: 20.0, color: Colors.black45,),),
                          subtitle: Image(image: AssetImage('google_logo.png'), height: 70,),
                        ),
                      )),
                      const PopupMenuItem(child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 24.0,
                          backgroundImage: AssetImage('dracula.png'),),
                        title: Text('Dracula'),
                        subtitle: Text('dracula@gmail.com'),
                        ),),
                      PopupMenuItem(child: Center(
                        child: ElevatedButton(onPressed: () {},
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(Colors.black45),
                            backgroundColor: MaterialStateProperty.all(Colors.white),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                          ),),
                          child: Text('Google Account'),
                          ),
                      ),),
                      PopupMenuItem(child: ListTile(
                        leading: ShaderMask(
                            blendMode: BlendMode.srcATop,
                            shaderCallback: (Rect bounds) =>
                              const LinearGradient(
                                colors: <Color>[Colors.blue, Colors.red,
                                  Colors.yellow, Colors.green,
                                ],
                                tileMode: TileMode.repeated,
                              ).createShader(bounds),
                            child: Icon(Icons.cloud_outlined, color: Colors.blue)),
                        subtitle: Text('Espace de stockage utilisé : 5% sur 15Go'),
                      ),),
                    ],
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage('dracula.png'),
                    ),
                  ),
                ),
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
            child: IconButton(
                splashRadius: 2,
                onPressed: () {}, icon: const Icon(Icons.mail_outline_outlined)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 64.0, right: 64.0),
            child: IconButton(
                splashRadius: 2,
                onPressed: () {}, icon: const Icon(Icons.video_camera_back_outlined)),
          ),
        ],),
    ),
  );

}


class EmailPage extends ConsumerWidget {
  EmailPage(this.sender, this.body, WidgetRef ref, this.onOptionSelected, {super.key});
  final String sender;
  final String body;
  final VoidCallback? onOptionSelected;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  build(context, ref) =>
      SafeArea(
        child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              splashRadius: 2,
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushNamed(context, '/'),),
            actions: [
              IconButton(
                splashRadius: 2,
                icon: const Icon(Icons.archive_outlined),
                onPressed: () => Navigator.pushNamed(context, '/'),),
              IconButton(
                splashRadius: 2,
                icon: const Icon(Icons.email_outlined),
                onPressed: () => Navigator.pushNamed(context, '/'),),
              IconButton(
                splashRadius: 2,
                icon: const Icon(Icons.delete_outlined),
                onPressed: () => Navigator.pushNamed(context, '/'),),
              IconButton(
                splashRadius: 2,
                icon: const Icon(Icons.more_horiz),
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
                      splashRadius: 2,
                      onPressed: () {},
                      icon: IconButton(
                        icon: const Icon(Icons.star_border_outlined),
                        splashRadius: 2,
                        onPressed: () {})),
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
                          child: IconButton(
                            splashRadius: 2, iconSize: 18.0,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            onPressed: () {},))
                    ],
                  ),
                  isThreeLine: false,
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.reply_outlined),
                        PopupMenuButton(
                            icon: const Icon(Icons.more_horiz),
                            onSelected: (value) => {},
                            itemBuilder: (context) => [
                              const PopupMenuItem(child: Text('Edit')),
                              const PopupMenuItem(child: Text('Edit')),
                            ]),
                      ],

                      ),

                  ),
                  // IconButton(splashRadius: 2,
                  //   onPressed: () => _mailOptionSelect(ref),
                  //   icon: const Icon(Icons.more_horiz),),
                ),
              ],
            ),
          ),
        ),
      );

  _mailOptionSelect(WidgetRef ref) {
    List<int> list = ref.watch(optionMailSelectProvider);
    if (list.isNotEmpty && list.contains(1)) {
      list.remove(1);
    } else {
      list.add(1);
    }
  }
}

class SearchTapPage extends ConsumerWidget {
  const SearchTapPage({super.key});

  @override
  build(context, ref) =>
      SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              splashRadius: 2,
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushNamed(context, '/'),),
            actions: [
              IconButton(icon: const Icon(Icons.mic_rounded),
                splashRadius: 2,
                onPressed: () {},)
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
    this.favoriteTap,
    required this.animation,
    required this.item,
  }) : assert(item >= 0);

  final Animation<double> animation;
  final VoidCallback? onTap;
  final int item;
  final bool selected;
  final VoidCallback? favoriteTap;

  TextStyle _boldOnSelect(WidgetRef ref) {
    if (ref.watch(cardMailItemProvider).isNotEmpty &&
        ref.watch(cardMailItemProvider).contains(item)) {
      return const TextStyle(fontWeight: FontWeight.bold);
    } else {
      return const TextStyle(fontWeight: FontWeight.normal);
    }
  }

  Color _backgroundColorOnSelect(WidgetRef ref) {
    if (ref.watch(cardMailItemProvider).isNotEmpty &&
        ref.watch(cardMailItemProvider).contains(item)) {
      return Colors.blue.shade200;
    } else {
      return Colors.white;
    }
  }

  @override
  build(context, ref) => SizeTransition(
    sizeFactor: animation,
    child: SizedBox(
      height: 90.0,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: _backgroundColorOnSelect(ref),
        child: Slidable(
          direction: Axis.horizontal,
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {},
                backgroundColor: const Color.fromRGBO(0, 255, 0, 0.6),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              )
            ],
          ),
          closeOnScroll: true,
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {},
                backgroundColor: const Color.fromRGBO(0, 255, 0, 0.6),
                foregroundColor: Colors.white,
                icon: Icons.archive_outlined,
                label: 'Archive',
              )
            ],
          ),
          child: ListTile(
            leading: IconButton(
              splashRadius: 2,
              iconSize: 44.0,
              onPressed: onTap,
              icon: _buildSelectionOnAvatar(ref),
            ),
            title: Text(ref.read(emailProvider).sender, style: _boldOnSelect(ref)),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Text(ref.read(emailProvider).object,
                      style: _boldOnSelect(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Text(ref.read(emailProvider).body,
                    style: _boldOnSelect(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
            trailing: Column(
              children: [
                Text(formattedDateTimeNow),
                IconButton(
                  splashRadius: 2,
                  padding: const EdgeInsets.only(top: 8.0),
                  onPressed: favoriteTap,
                  constraints: const BoxConstraints(),
                  icon: ref.watch(favoriteMailProvider).isNotEmpty &&
                      ref.watch(favoriteMailProvider).contains(item) ?
                        const Icon(Icons.star, color: Color.fromRGBO(220, 176, 0, 1.0),)
                        : const Icon(Icons.star_border_outlined),color: const Color.fromRGBO(220, 176, 0, 1.0)),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              // _remove();
              Navigator.pushNamed(context, '/${Routes.email_page.name}');
            }
          ),
        ),
      )
    ),
  );

  Widget _buildSelectionOnAvatar(WidgetRef ref) {
    if (ref.watch(cardMailItemProvider).isNotEmpty &&
        ref.watch(cardMailItemProvider).contains(item)) {
      return const Image(image: AssetImage('tick.png'),
        color: Colors.black45,);
    } else {
      return const CircleAvatar(
      backgroundColor: Colors.white,
      radius: 20.0,
      backgroundImage: AssetImage('avatar.png'),);
    }
  }
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
