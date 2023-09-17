
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:lab0345_1911143/services/notification_services.dart';
import 'package:lab0345_1911143/shared/constants.dart';
import 'package:nanoid/async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab0345_1911143/auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: Constants.apiKey,
            appId: Constants.appId,
            messagingSenderId: Constants.messagingSenderId,
            projectId: Constants.projectId));
  }
  else{
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const WidgetTree(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final User? user = Auth().currentUser;
  static List<Term> terms = <Term>[];
  static var increment = 0;

  late final LocalNotificationService service;

  @override
  void initState(){
    service = LocalNotificationService();
    service.intialize();
    super.initState();
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  void addFunction(BuildContext ct) {
    showModalBottomSheet(
        context: ct,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: NewElement(_addItemFunction),
          );
        });
  }

  Future<void> _addItemFunction(Term term) async {
    setState(() {
      term.setFunction(_deleteItem);
      term.setUserId(user!.uid);
      terms.add(term);
    });
    await service.showScheduledNotification(id: increment++, title: term.subjectName, body: 'Your term for this subject.', time: term.termDateTime);
  }

  void _deleteItem(var id) {
    setState(() {
      terms.removeWhere((element) => element.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    final List<Term> termsByUser = terms.where((element) => element.userId == user!.uid).toList();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Row(children: <Widget>[
              IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ShowCalendar())), icon: const Icon(Icons.calendar_month)),
              IconButton(onPressed: () => addFunction(context), icon: const Icon(Icons.add_sharp)),
            ],)
          ),
        ],
      ),
      body: Center(
          child: termsByUser.isEmpty
              ? const Text("The list is empty")
              : ListView.builder(
                  itemCount: termsByUser.length,
                  itemBuilder: (contx, index) {
                    return termsByUser[index];
                  })
      ),
      floatingActionButton: FloatingActionButton(onPressed: signOut,
        child: const Icon(Icons.logout),
      ),
    );
  }
}

class Term extends StatelessWidget {
  late final id;
  late final userId;
  final String subjectName;
  final DateTime termDateTime;
  late Function delete;

  Term(this.subjectName, this.termDateTime, {super.key}) {
    id = nanoid();
  }

  void setFunction(Function f) {
    delete = f;
  }

  void setUserId(String id){
    userId = id;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Card(
        elevation: 4,
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.date_range),
              title: Text(subjectName),
              subtitle:
                  Text("Exam on : " + termDateTime.toString().substring(0, 16)),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => delete(id),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ItemScreen())
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class NewElement extends StatefulWidget {
  final Function _function;

  const NewElement(this._function, {super.key});

  @override
  State<StatefulWidget> createState() => _NewElementState();
}

class _NewElementState extends State<NewElement> {
  final _subjectNameController = TextEditingController();
  final _dateTimeController = TextEditingController();

  _submitData() {
    if (_subjectNameController.text.isEmpty ||
        _dateTimeController.text.isEmpty) {
      return;
    }
    final term = Term(
        _subjectNameController.text, DateTime.parse(_dateTimeController.text));
    widget._function(term);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _subjectNameController,
            decoration: const InputDecoration(labelText: "Enter Subject Name"),
          ),
          DateTimeField(
            mode: DateTimeFieldPickerMode.dateAndTime,
            selectedDate: DateTime.now(),
            initialDate: DateTime.now(),
            onDateSelected: (DateTime value) {
              setState(() {
                _dateTimeController.text = value.toString();
              });
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: OutlinedButton(
                onPressed: _submitData, child: const Text("Submit")),
          ),
        ],
      ),
    );
  }
}

class ShowCalendar extends StatefulWidget {
  const ShowCalendar({super.key});

  @override
  State<ShowCalendar> createState() => _ShowCalendarState();
}

class _ShowCalendarState extends State<ShowCalendar> {

  var calendarFormat = CalendarFormat.month;
  var selectedDay = DateTime.now();
  var focusedDay = DateTime.now();

  bool compareDates(DateTime time, DateTime other){
    return time.year == other.year && time.month == other.month
        && time.day == other.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title:  const Text("Events")
      ),
      body: Column(
        children: <Widget>[
          TableCalendar(
            firstDay: DateTime.utc(2015),
            lastDay: DateTime.utc(2050),
            focusedDay: selectedDay,
            calendarFormat: calendarFormat,
            onFormatChanged: (CalendarFormat _format) {
              setState(() {
                calendarFormat = _format;
              });
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            daysOfWeekVisible: true,
            onDaySelected: (DateTime selectDay , DateTime focusDay) {
              setState(() {
                selectedDay = selectDay;
                focusedDay = focusDay;
              });
            },
            calendarStyle: const CalendarStyle (
              defaultDecoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              weekendDecoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              isTodayHighlighted: true,
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                shape: BoxShape.circle,
              )
            ),
            selectedDayPredicate: (DateTime day) {
              return isSameDay(selectedDay, day);
            },
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
              ),
              formatButtonTextStyle: const TextStyle(color: Colors.white),
            ),
          ),
          ..._MyHomePageState.terms.where((term) => compareDates(term.termDateTime, selectedDay)).map((term) =>
          Container(padding: const EdgeInsets.all(10.0), child: Card(
            elevation: 4, child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.date_range),
                title: Text(term.subjectName),
                subtitle: Text(term.termDateTime.toString().substring(0, 16)),
              )
            ],
          ),
          ),)),
        ],
      ),
    );
  }
}

class ItemScreen extends StatelessWidget {
  const ItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OSMFlutter(
      controller: MapController.withPosition(
        initPosition: GeoPoint(
          latitude: 42.006821,
          longitude: 20.973867,
        ),
      ),
      initZoom: 12,
      minZoomLevel: 8,
      maxZoomLevel: 14,
      stepZoom: 1.0,
      userLocationMarker: UserLocationMaker(
        personMarker: MarkerIcon(
          icon: Icon(
            Icons.location_history_rounded,
            color: Colors.red,
            size: 48,
          ),
        ),
        directionArrowMarker: MarkerIcon(
          icon: Icon(
            Icons.double_arrow,
            size: 48,
          ),
        ),
      ),
      roadConfiguration: RoadOption(
        roadColor: Colors.yellowAccent,
      ),
      markerOption: MarkerOption(
          defaultMarker: MarkerIcon(
            icon: Icon(
              Icons.person_pin_circle,
              color: Colors.blue,
              size: 56,
            ),
          )
      ), osmOption: null,
    );
  }
}