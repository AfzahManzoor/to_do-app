import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_rem/models/todos.dart';

import '../../helper/database_helper.dart';
import '../addTodo/add_todo.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  bool isGridMode = false;
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  late SharedPreferences prefs;

  List<Todos> myTodos = <Todos>[];
  int count = 0;
  final List _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.pinkAccent,
    Colors.lime,
    Colors.grey,
    Colors.purpleAccent,
    Colors.indigo,
  ];
  @override
  void initState() {
    super.initState();
    updateListView();
    getValue();
  }

  @override
  void dispose() {
    super.dispose();
    _databaseHelper.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todos',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isGridMode = !isGridMode;
                prefs.setBool('boolValue', isGridMode);
              });
            },
            icon: isGridMode
                ? const Icon(
                    Icons.view_list_sharp,
                  )
                : const Icon(Icons.grid_view_sharp),
          ),
        ],
        backgroundColor: Colors.purple,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Navigating to next Screen to add new Todo
          navigateToAddScreen('Add Todo', Todos('', '', 1, ''));
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              isGridMode
                  ? Expanded(child: showGridView())
                  : Expanded(child: showListView())
            ],
          ),
        ),
      ),
    );
  }

  MasonryGridView showGridView() {
    return MasonryGridView.count(
      itemCount: _colors.length,
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 12,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          //Based on Priority value, set card COlor
          color: _colors[index],
          child: Column(
            children: [
              Icon(myTodos[index].priority == 1
                  ? Icons.priority_high
                  : Icons.low_priority),
              ListTile(
                title: Text(
                  myTodos[index].title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  myTodos[index].description,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                        onTap: () {
                          delete(myTodos[index].id!);
                        },
                        child: const Icon(
                          Icons.delete,
                          color: Colors.black,
                        )),
                    const SizedBox(width: 8),
                    InkWell(
                        onTap: () {
                          navigateToAddScreen('Edit Todo', myTodos[index]);
                        },
                        child: const Icon(Icons.edit, color: Colors.black)),
                  ]),
            ],
          ),
        );
      },
    );
  }

  ListView showListView() {
    return ListView.builder(
      itemCount: myTodos.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          //Based on Priority value, set card COlor
          color: _colors[index],
          child: ListTile(
            title: Text(
              myTodos[index].title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              myTodos[index].description,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            leading: Icon(myTodos[index].priority == 1
                ? Icons.priority_high
                : Icons.low_priority),
            trailing: SizedBox(
              width: 56,
              child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                InkWell(
                    onTap: () {
                      delete(myTodos[index].id!);
                    },
                    child: const Icon(
                      Icons.delete,
                      color: Colors.black,
                    )),
                InkWell(
                    onTap: () {
                      navigateToAddScreen('Edit Todo', myTodos[index]);
                    },
                    child: const Icon(Icons.edit, color: Colors.black)),
              ]),
            ),
          ),
        );
      },
    );
  }

  navigateToAddScreen(String title, Todos todos) async {
    bool result = await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return AddTodoScreen(title, todos);
      },
    ));
    if (result == true) {
      updateListView();
    }
  }

  //updateListview
  updateListView() async {
    final Future<Database> dbFuture = _databaseHelper.initalizeDatabase();
    dbFuture.then(
      (value) {
        Future<List<Todos>> listFuture = _databaseHelper.getNoteList();
        listFuture.then(
          (list) {
            setState(() {
              myTodos = list;
              count = list.length;
            });
          },
        );
      },
    );
  }

  //Delete function
  void delete(int id) async {
    var result = _databaseHelper.deleteNote(id);
    // ignore: unrelated_type_equality_checks
    if (result != 0) {
      showSimpleNotification(
          autoDismiss: true,
          position: NotificationPosition.bottom,
          const Text("Todo Deleted Successfully"),
          background: Colors.purple);
    } else {
      showSimpleNotification(
          autoDismiss: true,
          position: NotificationPosition.bottom,
          const Text("Error Deleting!!!"),
          background: Colors.purple);
    }
    updateListView();
  }

  getValue() async {
    prefs = await _pref;
    setState(() {
      isGridMode = (prefs.containsKey('boolValue')
          ? prefs.getBool('boolValue')
          : false)!;
    });
  }
}
