import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'home_page.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  bool isVisibleButton = false;
  final _tasksBox = Hive.box('myTasks');

  final formKey = GlobalKey<FormState>();
  TextEditingController dateController = TextEditingController();
  TextEditingController taskNameController = TextEditingController();


  // default selected priority
  int prioritySelected = 0;
  String priorityName = 'Alta';
  int priorityColor = 0xffE00000;

  Future<void> createTask(Map<String, dynamic> newItem) async {
    await _tasksBox.add(newItem);
  }

  void saveTask() {
    createTask({
      'taskName': taskNameController.text,
      'date': dateController.text,
      'priorityColor': priorityColor,
      'category': priorityName,
      'completedStatus': false,
    });

    taskNameController.clear();
    dateController.clear();
  }



  Widget CustomRadioButton(String btnText, int index, int color) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          prioritySelected = index;
          priorityName = btnText;
          priorityColor = color;
        });
      },
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          btnText,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Color(color)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        side: MaterialStateProperty.all(
          BorderSide(
            color: (prioritySelected == index)
                ? Colors.blue.shade300
                : Colors.transparent,
            width: 4,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.blue,
      appBar: _appBarSection(context),
      body: Column(
        children: [
          _headerText(),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: taskNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tarefa';
                          } else {
                            return null;
                          }
                        },
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.5,
                                color: Colors.black,
                              )),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.5,
                              color: Color.fromARGB(255, 0, 170, 255),
                            ),
                          ),
                          labelText: 'Tarefa',
                          labelStyle: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          hintText: 'Ex. Academia',
                        ),
                      ),
                      // SizedBox(
                      //   height: 30,
                      // ),
                      TextFormField(
                          controller: dateController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Data';
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.calendar_month, size: 35),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2.5,
                                  color: Colors.black,
                                )),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: Color.fromARGB(255, 0, 170, 255),
                              ),
                            ),
                            labelText: 'Data',
                            labelStyle: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            hintText: 'Ex. 22, junho 2023',
                          ),
                          onTap: () async {
                            DateTime currentDate = DateTime.now();
                            DateTime nextDay = currentDate.add(const Duration(days: 1));
                            DateTime? pickedDate = await showDatePicker(

                                context: context,
                                initialDate: nextDay,
                                firstDate: DateTime(2023),
                                lastDate: DateTime(2025));
                           // DateTime currentDate = DateTime.now();
                            //DateTime nextDay = currentDate.add(const Duration(days: 1));

                            if (pickedDate != null) {
                              if(pickedDate.isAfter(currentDate)){
                                setState(() {
                                  nextDay = pickedDate;
                                  isVisibleButton = true;
                                });

                              }else{
                                const snackBar =  SnackBar(
                                  content:  Text('Data Invalida! Selecione uma posterior a data de Hoje'),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                setState(() {
                                  nextDay = pickedDate;
                                  isVisibleButton = false;
                                });
                              }

                              dateController.text =
                                  DateFormat("dd/MM/yyyy")
                                      .format(pickedDate);
                            }
                          }),
                      // SizedBox(
                      //   height: 30,
                      // ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prioridade',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomRadioButton('Alta', 0, 0xffE00000),
                              CustomRadioButton('Media', 1, 0xffFFB800),
                              CustomRadioButton('Baixa', 2, 0xff04E000),
                            ],
                          ),
                        ],
                      ),
                      // for save button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: isVisibleButton ? Colors.blue : Colors.grey),
                            onPressed:  isVisibleButton ? () {
                              saveTask();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      backgroundColor: Colors.blue,
                                      content: Text(
                                        'Tarefa Adicionada',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      )),
                                );
                            } : null, // Define null para desabilitar o botão
                            child: const Text('Adicionar'),


                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _headerText() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'Tarefas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  AppBar _appBarSection(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => const HomePage(),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color.fromARGB(126, 255, 255, 255),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 26,
          ),



        ),
      ),
    );
  }
}
