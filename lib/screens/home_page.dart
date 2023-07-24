import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'add_page.dart';
import 'edit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _tasksBox = Hive.box('myTasks');

  bool dataEmpty = true;
  List<Map<String, dynamic>> tasks_list = [];
  int currentIndex = 0;
  String headerText = 'Tarefas';


  Future<void> refreshTasks() async {
    List taskKeys = _tasksBox.keys.toList();
    String newHeader = '';
    tasks_list.clear();

    if (currentIndex == 0) {
      newHeader = 'Todas Tarefas';

    }
    ;
    if (currentIndex == 1) {
      newHeader = 'Tarefas Incompletas';
    }
    ;

    if (currentIndex == 2) {
      newHeader = 'Tarefas Completas';
    }
    ;

    for (var i = 0; i < taskKeys.length; i++) {
      final item = _tasksBox.get(taskKeys[i]);

      if (currentIndex == 0) {
        tasks_list.add({
          'id': taskKeys[i],
          'name': item['taskName'],
          'date': item['date'],
          'priorityColor': item['priorityColor'],
          'category': item['category'],
          'completedStatus': item['completedStatus'],
        });
      }

      if (currentIndex == 1) {
        if (item['completedStatus'] == false) {
          tasks_list.add({
            'id': taskKeys[i],
            'name': item['taskName'],
            'date': item['date'],
            'priorityColor': item['priorityColor'],
            'category': item['category'],
            'completedStatus': item['completedStatus'],
          });
        }
      }
      if (currentIndex == 2) {
        if (item['completedStatus'] == true) {
          tasks_list.add({
            'id': taskKeys[i],
            'name': item['taskName'],
            'date': item['date'],
            'priorityColor': item['priorityColor'],
            'category': item['category'],
            'completedStatus': item['completedStatus'],

          });
        }
      }
    }

    setState(() {
      headerText = newHeader;
      tasks_list = tasks_list.reversed.toList();
    });
  }

  Future<void> updateStatus(id) async {
    var item = _tasksBox.get(id);
    item['completedStatus'] = !item['completedStatus'];

    _tasksBox.put(id, item);
    refreshTasks();
  }

  Future<void> deleteTask(id) async {
    _tasksBox.delete(id);

    refreshTasks();
  }

  Future<void> clearTasks() async {
    List taskKeys = _tasksBox.keys.toList();

    for (var i = 0; i < taskKeys.length; i++) {
      final item = _tasksBox.get(taskKeys[i]);

      if (currentIndex == 2 && item['completedStatus'] == true) {
        _tasksBox.delete(taskKeys[i]);
      }
    }

    refreshTasks();
  }

  void editTask(id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) =>
            EditPage(taskId: id, initialTask: _tasksBox.get(id)),
      ),
    );
  }

  List<Widget> navigationDestinations() {
    return <Widget>[
      const NavigationDestination(
        selectedIcon: Icon(
          Icons.home,
          color: Colors.black,
          size: 26,

        ),
        icon: Icon(
          Icons.home,
          color: Colors.white,
          size: 26,

        ),
        label: 'Início',
      ),

      const NavigationDestination(
        selectedIcon: Icon(
          Icons.warning_amber,
          color: Colors.black,
          size: 26,
        ),
        icon: Icon(
          Icons.warning_amber,
          color: Colors.white,
          size: 26,
        ),
        label: 'Incompletas',

      ),
      const NavigationDestination(

        selectedIcon: Icon(
          Icons.check,
          color: Colors.black,
          size: 26,
        ),


        icon: Icon(
          Icons.check,
          color: Colors.white,
          size: 26,
        ),

        label: 'Completas',
      ),
    ];

  }

  @override
  Widget build(BuildContext context) {
    refreshTasks();

    return Scaffold(

      backgroundColor: Colors.white,
      floatingActionButtonLocation: currentIndex == 2 && tasks_list.length != 0
          ? FloatingActionButtonLocation.miniStartFloat
          : FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: currentIndex == 2 && tasks_list.length != 0
          ? clearCompletedButton()
          : floatingButton(),
      appBar: appBarSection(),
      body: _tasksBox.isEmpty ? welcomeBody() : homeBody(),
      bottomNavigationBar: NavigationBar(
        indicatorColor: Colors.white,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        backgroundColor: Colors.blue,
        elevation: 0,
        destinations: navigationDestinations(),
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
            refreshTasks();
          });
        },
      ),
    );
  }

  Column welcomeBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Icon(
            Icons.four_g_plus_mobiledata,
            color: Colors.white,
            size: 26,
          ),
        ),
        SizedBox(
          height: 35,
        ),
        Text(
          'Adicionar tarefa',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: Colors.grey.withOpacity(0.2),
          ),
        )
      ],
    );
  }

  SingleChildScrollView homeBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 50, top: 8, left: 5, right: 5),
      scrollDirection: Axis.vertical,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 12, bottom: 12),
              child: Text(
                headerText,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.withOpacity(0.2)),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => SizedBox(
                height: 10,
              ),
              itemCount: tasks_list.length,
              itemBuilder: (context, index) {
                final item = tasks_list[index];

                return Container(
                  margin: EdgeInsets.all(5),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding:
                    const EdgeInsets.only(top: 12, bottom: 12, right: 8),
                    child: Row(
                      children: [
                        PopupMenuButton(
                          iconSize: 32,
                          color: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                              topLeft: Radius.circular(8.0),
                              topRight: Radius.circular(8.0),
                            ),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Text(
                                'Deletar Tarefa',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () {
                                deleteTask(item['id']);
                              },
                            ),
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(
                                'Editar Tarefa',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              editTask(item['id']);
                            }
                          },
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['date'],
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                item['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(item['priorityColor']),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 2.0, bottom: 2, right: 5, left: 5),
                                  child: Text(
                                    item['category'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Checkbox(
                          checkColor: Colors.white,
                          activeColor: Colors.blue,
                          value: item['completedStatus'],
                          onChanged: (value) {
                            updateStatus(item['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ]),
    );
  }

  AppBar appBarSection() {
    return AppBar(
      title: const Text('Lista de Tarefas'),
    );
  }

  clearCompletedButton() {
    return SizedBox(
      height: 45,
      width: 120,
      child: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          clearTasks();
        },
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Limpar Tarefas',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  FloatingActionButton floatingButton() {
    return FloatingActionButton(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => const AddPage(),
          ),
        );
      },
      child: Icon(
        Icons.add_circle,
        color: Colors.white,
        size: 26,
      ),
          );
  }
}
