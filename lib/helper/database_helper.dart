// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:todo_rem/models/todos.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper; // Singleton-Executes only once
  static Database? _database; //Singleton

  String todoTable = 'todo_table';
  String colID = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  //Creating an instance of databse
  //This is a named constructor responsible for creating databse
  // This is also a singleton method which is going to run once only
  DatabaseHelper._createInstance();

  //with NullSafety
  factory DatabaseHelper() {
    return _databaseHelper ??= DatabaseHelper._createInstance();
  }

  //Initiliaze database
  //Initilization with NullSafety
  Future<Database> get database async {
    return _database ??= await initalizeDatabase();
  }

  Future<Database> initalizeDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'todos.db');
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    //debugPrint('DB CREATED' + path.toString());
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $todoTable ($colID INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await database;
    //optional
    // var result = await db.rawQuery('SELECT * from $noteTable order by $colPriority ASC');
    var result = await db.query(todoTable, orderBy: '$colPriority ASC');
    return result;
  }

  Future<int> insertNote(Todos todo) async {
    Database db = await database;
    var result = await db.insert(todoTable, todo.toMap());
    return result;
  }

  Future<int> updateNote(Todos todo) async {
    Database db = await database;
    var result = await db.update(todoTable, todo.toMap(),
        where: '$colID = ?', whereArgs: [todo.id]);
    return result;
  }

  Future<int> deleteNote(int id) async {
    Database db = await database;
    var result =
        await db.rawDelete('DELETE FROM $todoTable where $colID = $id');
    return result;
  }

// Counting total values inside a database
  Future<int?> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $todoTable');
    int result = Sqflite.firstIntValue(x)!;
    return result;
  }

//Converting everything from a todolist to a maplist
  Future<List<Todos>> getNoteList() async {
    var todoMapList = await getNoteMapList();

    int count = todoMapList.length;

    List<Todos> todolist = <Todos>[];
    for (int i = 0; i < count; i++) {
      todolist.add(Todos.fromMapObject(todoMapList[i]));
    }
    return todolist;
  }

  Future close() async => _database!.close();
}
