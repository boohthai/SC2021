import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uidev/TaskList/widgets/input_field.dart';

import 'task.dart';

class AddNewTask extends StatefulWidget {
  final String id;
  final bool isEditMode;

  AddNewTask({
    this.id,
    this.isEditMode,
  });

  @override
  _AddNewTaskState createState() => _AddNewTaskState();
}

class _AddNewTaskState extends State<AddNewTask> {
  Task task;
  DateTime _selectedDate;
  TimeOfDay _selectedTime;
  String _inputDescription;
  int _mode;

  final _formKey = GlobalKey<FormState>();
  String _selectedMode = 'None';
  List<String> modeList = [
    'None',
    'Important and Urgent',
    'Important but not Urgent',
    'Not Important but Urgent',
    'Not Important and not Urgent',
  ];

  @override
  void initState() {
    if (widget.isEditMode) {
      task =
          Provider.of<TaskProvider>(context, listen: false).getById(widget.id);
      _selectedDate = task.dueDate;
      _inputDescription = task.description;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Title', style: Theme.of(context).textTheme.subtitle1),
            SizedBox(
              height: 5,
            ),
            Container(
              //padding: EdgeInsets.only(left: 14.0),
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.0,
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(12.0)),
              child: TextFormField(
                initialValue:
                    _inputDescription == null ? null : _inputDescription,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: 'Describe your task',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                onSaved: (value) {
                  _inputDescription = value;
                },
              ),
            ),

            SizedBox(
              height: 20,
            ),
            Text('Due date', style: Theme.of(context).textTheme.subtitle1),
            SizedBox(
              height: 5,
            ),
            Container(
              //padding: EdgeInsets.only(left: 14.0),
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.0,
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(12.0)),
              child: TextFormField(
                onTap: () {
                  _pickUserDueDate();
                },
                readOnly: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: _selectedDate == null
                      ? 'Provide your due date'
                      : DateFormat.yMMMd().format(_selectedDate).toString(),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text('Mode', style: Theme.of(context).textTheme.subtitle1),
            SizedBox(
              height: 5,
            ),
            Container(
              padding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.0,
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(12.0)),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedMode,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black,
                      ),
                      elevation: 4,
                      underline: Container(height: 0),
                      onChanged: (String newValue) {
                        setState(() {
                          _selectedMode = newValue;
                        });
                      },
                      items: modeList.map<DropdownMenuItem<String>>(
                              (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            // InputField(
            //   title: "Mode",
            //   hint: _selectedMode,
            //   widget: Row(
            //     children: [
            //       DropdownButton<String>(
            //         icon: Icon(
            //           Icons.keyboard_arrow_down,
            //           color: Colors.grey,
            //         ),
            //         iconSize: 32,
            //         elevation: 4,
            //         underline: Container(height: 0),
            //         onChanged: (String newValue) {
            //           setState(() {
            //             _selectedMode = newValue;
            //           });
            //         },
            //         items: modeList.map<DropdownMenuItem<String>>(
            //                 (String value) {
            //               return DropdownMenuItem<String>(
            //                 value: value,
            //                 child: Text(value),
            //               );
            //             }).toList(),
            //       ),
            //       SizedBox(width: 6),
            //     ],
            //   ),
            // ),
            Container(
              alignment: Alignment.bottomRight,
              child: FlatButton(
                child: Text(
                  !widget.isEditMode ? 'ADD TASK' : 'EDIT TASK',
                  style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontFamily: 'Lato',
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _validateForm();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickUserDueDate() {
    showDatePicker(
            context: context,
            initialDate: widget.isEditMode ? _selectedDate : DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030))
        .then((date) {
      if (date == null) {
        return;
      }
      date = date;
      setState(() {
        _selectedDate = date;
      });
    });
  }

  // void _pickUserDueTime() {
  //   showTimePicker(
  //     context: context,
  //     initialTime: widget.isEditMode ? _selectedTime : TimeOfDay.now(),
  //   ).then((time) {
  //     if (time == null) {
  //       return;
  //     }
  //     setState(() {
  //       _selectedTime = time;
  //     });
  //   });
  // }

  void _validateForm() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (_selectedDate == null) {
        _selectedDate = DateTime.now();
      }
      if (!widget.isEditMode) {
        Provider.of<TaskProvider>(context, listen: false).createNewTask(
          Task(
            id: DateTime.now().toString(),
            description: _inputDescription,
            dueDate: _selectedDate,
            mode: _mode,
          ),
        );
      } else {
        Provider.of<TaskProvider>(context, listen: false).editTask(
          Task(
            id: task.id,
            mode: _mode,
            description: _inputDescription,
            dueDate: _selectedDate,
          ),
        );
      }
      Navigator.of(context).pop();
    }
  }
}