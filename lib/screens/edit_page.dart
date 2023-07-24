import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'home_page.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key, required this.initialTask, required this.taskId});

  final Map<dynamic, dynamic> initialTask;
  final int taskId;

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  bool isVisibleButton = false;

  late final TextEditingController taskNameController;

  @override
  void initState() {
    super.initState();
    taskNameController = TextEditingController(text: widget.initialTask['taskName']);
  }


  final _tasksBox = Hive.box('myTasks');

  final formKey = GlobalKey<FormState>();
  TextEditingController date_controller = TextEditingController();

  int prioritySelected = 0;
  String priorityName = 'Alta';
  int priorityColor = 0xffE00000;

  Future<void> createTask(int id, Map<String, dynamic> newItem) async {
    await _tasksBox.put(id, newItem);
  }

  void saveTask(id) {
    var item = _tasksBox.get(id);

    createTask(id, {
      'taskName': taskNameController.text,
      'date': date_controller.text,
      'priorityColor': priorityColor,
      'category': priorityName,
      'completedStatus': item['completedStatus'],
    });

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
        padding: const EdgeInsets.all(8.0),
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
                      TextFormField(
                          controller: date_controller.text != ''? date_controller
                              :TextEditingController(text:
                          widget.initialTask['date']),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Data';
                            } else {
                              date_controller.text = value;
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

                              date_controller.text =
                                  DateFormat("dd/MM/yyyy")
                                      .format(pickedDate);
                            }
                          }),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Prioridade',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomRadioButton('Alto', 0, 0xffE00000),
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
                              saveTask(widget.taskId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    backgroundColor: Colors.blue,
                                    content: Text(
                                      'Tarefa Editada',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    )),
                              );
                            } : null, // Define null para desabilitar o botão
                            child: const Text('Salvar'),


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
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
      child: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          'Editar Tarefa',
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
          margin: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.backspace,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
