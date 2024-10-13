import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../helper/database_helper.dart';
import '../../models/todos.dart';

class AddTodoScreen extends StatefulWidget {
  static String routeName = "/add";
  const AddTodoScreen(
    this.title,
    this.todosData, {
    super.key,
  });
  final String title;
  final Todos? todosData;

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  //Our database class
  DatabaseHelper helper = DatabaseHelper();

  //Priorities arrray
  final _priorities = ['High', 'Low'];

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  //a MODEL CLASS object

  late Todos todos = Todos.withId(
      widget.todosData!.id,
      widget.todosData!.title,
      widget.todosData!.date,
      widget.todosData!.priority,
      widget.todosData!.description);

  @override
  Widget build(BuildContext context) {
    titleController.text = widget.todosData!.title;
    descriptionController.text = widget.todosData!.description;
    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();

        throw ('Error');
      },
      child: Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.purple,
          automaticallyImplyLeading: true,
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
            ),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 25.0, bottom: 5.0),
                  //dropdown menu
                  child: ListTile(
                    leading: const Icon(Icons.low_priority),
                    title: DropdownButton(
                        items: _priorities.map((String dropDownStringItem) {
                          return DropdownMenuItem<String>(
                            value: dropDownStringItem,
                            child: Text(
                              dropDownStringItem,
                              style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black),
                            ),
                          );
                        }).toList(),
                        value: setPriorityAsString(todos.priority),
                        onChanged: (valueSelectedByUser) {
                          setState(() {
                            setPriorityAsInt(valueSelectedByUser.toString());
                          });
                        }),
                  ),
                ),
                // Second Element
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, bottom: 15.0, left: 15.0),
                  child: TextField(
                      controller: titleController,
                      onChanged: (value) {
                        updateTitle();
                      },
                      cursorColor: Colors.purple,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Colors.purple),
                        labelText: 'Title',
                        icon: Icon(Icons.title),
                      )),
                ),

                // Third Element
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, bottom: 15.0, left: 15.0),
                  child: TextField(
                    cursorColor: Colors.purple,
                    controller: descriptionController,
                    // style: textStyle,
                    onChanged: (value) {
                      updateDescription();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Details',
                      icon: Icon(
                        Icons.details,
                      ),
                    ),
                  ),
                ),

                // Fourth Element
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              saveTodos();
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.purple),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.all(15)),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.purple),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: const BorderSide(color: Colors.purple),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            textScaleFactor: 1.5,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  updateTitle() {
    todos.setTitle = titleController.text;
  }

  updateDescription() {
    todos.setDescription = descriptionController.text;
  }

  setPriorityAsString(int value) {
    String? priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  setPriorityAsInt(String value) {
    switch (value) {
      case 'High':
        todos.setPriority = 1;

        break;
      case 'Low':
        todos.setPriority = 2;
        break;
    }
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  saveTodos() async {
    todos.setDate = DateFormat.MMMEd().format(DateTime.now());
    int result;
    if (todos.id == null) {
      result = await helper.insertNote(todos);
    } else {
      result = await helper.updateNote(todos);
    }
    if (result != 0) {
      showSimpleNotification(
          autoDismiss: true,
          position: NotificationPosition.bottom,
          const Text("Todo Saved Successfully"),
          background: Colors.purple);
    } else {
      showSimpleNotification(
          autoDismiss: true,
          position: NotificationPosition.bottom,
          const Text("Error Saving Todo"),
          background: Colors.purple);
    }
    moveToLastScreen();
  }
}
