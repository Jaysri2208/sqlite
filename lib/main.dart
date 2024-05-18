import 'package:flutter/material.dart';
import 'note_model.dart';
import 'db_helper.dart';

void main() {
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Sqlite'),
      routes: {
        '/note_model': (context) => notePage(),  // Define the route for the SQLite page
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  int? _selectedIndex;
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final data = await _dbHelper.getItems();
    setState(() {
      _items = data;
    });
  }

  Future<void> _insertItem() async {
    if (_controller.text.isEmpty) return;
    await _dbHelper.insertItem(_controller.text);
    _controller.clear();
    _loadItems();
  }

  Future<void> _updateItem() async {
    if (_controller.text.isEmpty || _selectedIndex == null) return;
    final id = _items[_selectedIndex!]['id'];
    await _dbHelper.updateItem(id, _controller.text);
    _controller.clear();
    _selectedIndex = null;
    _loadItems();
  }

  Future<void> _deleteItem(int index) async {
    final id = _items[index]['id'];
    await _dbHelper.deleteItem(id);
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD with SQLite'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter Value',
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _insertItem,
                  child: Text('Insert'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _updateItem,
                  child: Text('Update'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_items[index]['value']),
                    onTap: () {
                      setState(() {
                        _controller.text = _items[index]['value'];
                        _selectedIndex = index;
                      });
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteItem(index),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/note_model');  
              },
              child: Text('Go to Hive Page'),
            ),
          ],
        ),
      ),
    );
  }
  }
