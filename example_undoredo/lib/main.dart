import 'package:flutter/material.dart';
import 'package:neat_notifier/neat_notifier.dart';
import 'todo_notifier.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neat Undo/Redo Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: NeatState<TodoNotifier, List<String>, dynamic>(
        create: (_) => TodoNotifier(),
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();

  void _addTodo(BuildContext context) {
    if (_controller.text.isNotEmpty) {
      context.read<TodoNotifier>().add(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // We watch the notifier to rebuild on ANY state change (add/remove/undo/redo)
    final notifier = context.watch<TodoNotifier>();
    final todos = notifier.value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Undo/Redo Todos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: notifier.canUndo ? () => notifier.undo() : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
            onPressed: notifier.canRedo ? () => notifier.redo() : null,
          ),
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: 'Clear History',
            onPressed: (notifier.canUndo || notifier.canRedo)
                ? () => notifier.clearHistory()
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter a Todo...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(context),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addTodo(context),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: todos.isEmpty
                ? const Center(child: Text('No todos yet. Add some!'))
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return ListTile(
                        title: Text(todo),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            context.read<TodoNotifier>().removeAt(index);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
