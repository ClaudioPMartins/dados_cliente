import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Database db;

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    db = await openDatabase('clientes.db', version: 1, onCreate: (db, version) {
      return db.execute('CREATE TABLE clientes (cpf TEXT, nome TEXT)');
    });
    _query(); // Carrega a lista de clientes ao abrir o app
  }

  Future<void> _insert(String cpf, String nome) async {
    await db.rawInsert(
        'INSERT INTO clientes (cpf, nome) VALUES (?, ?)', [cpf, nome]);
    _query(); // Atualiza a lista de clientes após a inserção
  }

  Future<void> _query() async {
    final List<Map<String, dynamic>> clientes = await db.query('clientes');
    setState(() {
      this.clientes = clientes;
    });
  }

  List<Map<String, dynamic>> clientes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter App'),
      ),
      body: ListView.builder(
        itemCount: clientes.length,
        itemBuilder: (context, index) {
          final Map<String, dynamic> cliente = clientes[index];
          return ListTile(
            title: Text(cliente['nome'] as String),
            subtitle: Text(cliente['cpf'] as String),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Exibe um modal de inserção de dados
          showDialog(
            context: context,
            builder: (context) {
              final TextEditingController cpfController =
                  TextEditingController();
              final TextEditingController nomeController =
                  TextEditingController();

              return AlertDialog(
                title: const Text('Inserir cliente'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: cpfController,
                      decoration: const InputDecoration(labelText: 'CPF'),
                    ),
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Salvar'),
                    onPressed: () {
                      // Insere os dados no banco de dados
                      _insert(cpfController.text, nomeController.text);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
