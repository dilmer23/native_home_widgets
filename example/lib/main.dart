import 'package:flutter/material.dart';
import 'package:native_home_widgets/native_home_widgets.dart';

void main() {
  runApp(const NativeHomeWidgetsExampleApp());
}

class NativeHomeWidgetsExampleApp extends StatelessWidget {
  const NativeHomeWidgetsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native Home Widgets Examples',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const ExamplesHomePage(),
    );
  }
}

class ExamplesHomePage extends StatefulWidget {
  const ExamplesHomePage({super.key});

  @override
  State<ExamplesHomePage> createState() => _ExamplesHomePageState();
}

class _ExamplesHomePageState extends State<ExamplesHomePage> {
  final _plugin = NativeHomeWidgets();
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    _initPlatform();
    _plugin.startListening();
  }

  @override
  void dispose() {
    _plugin.stopListening();
    super.dispose();
  }

  Future<void> _initPlatform() async {
    try {
      final version = await _plugin.getPlatformVersion();
      if (mounted) {
        setState(() => _platformVersion = version ?? 'Unknown');
      }
    } catch (_) {
      if (mounted) setState(() => _platformVersion = 'Failed to get version');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Native Home Widgets'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Platform: $_platformVersion',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use the examples below to test widget functionality. '
                    'After configuring a widget, add it to your home screen.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ExampleCard(
            title: 'Counter',
            description: 'Simple counter with increment button',
            icon: Icons.add_circle_outline,
            onTap: () => _navigateTo(const CounterExample()),
          ),
          _ExampleCard(
            title: 'Todo List',
            description: 'Track your tasks from the home screen',
            icon: Icons.checklist,
            onTap: () => _navigateTo(const TodoExample()),
          ),
          _ExampleCard(
            title: 'Weather',
            description: 'Display weather information',
            icon: Icons.wb_sunny_outlined,
            onTap: () => _navigateTo(const WeatherExample()),
          ),
          _ExampleCard(
            title: 'Calendar',
            description: 'Upcoming events at a glance',
            icon: Icons.calendar_today_outlined,
            onTap: () => _navigateTo(const CalendarExample()),
          ),
          _ExampleCard(
            title: 'Interactive',
            description: 'Widget with click actions and deep links',
            icon: Icons.touch_app_outlined,
            onTap: () => _navigateTo(const InteractiveExample()),
          ),
        ],
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ── Counter Example ───────────────────────────────────────

class CounterExample extends StatefulWidget {
  const CounterExample({super.key});

  @override
  State<CounterExample> createState() => _CounterExampleState();
}

class _CounterExampleState extends State<CounterExample> {
  final _plugin = NativeHomeWidgets();
  int _counter = 0;

  static const _widgetId = 'counter_widget';

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final saved = await _plugin.getData<int>(key: 'count', widgetId: _widgetId);
    if (saved != null && mounted) {
      setState(() => _counter = saved);
    }
  }

  Future<void> _increment() async {
    setState(() => _counter++);
    await _plugin.saveData(key: 'count', value: _counter, widgetId: _widgetId);
    await _plugin.saveData(key: 'title', value: 'Counter', widgetId: _widgetId);
    await _plugin.saveData(key: 'value', value: '$_counter', widgetId: _widgetId);
    await _plugin.update(widgetId: _widgetId);
  }

  Future<void> _reset() async {
    setState(() => _counter = 0);
    await _plugin.saveData(key: 'count', value: 0, widgetId: _widgetId);
    await _plugin.saveData(key: 'value', value: '0', widgetId: _widgetId);
    await _plugin.update(widgetId: _widgetId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HomeWidgetBuilder(
              widgetId: _widgetId,
              semanticLabel: 'Counter showing $_counter items',
              child: const SizedBox.shrink(),
            ),
            const Text('Counter Value:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _increment,
                  icon: const Icon(Icons.add),
                  label: const Text('Increment'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Todo Example ──────────────────────────────────────────

class TodoExample extends StatefulWidget {
  const TodoExample({super.key});

  @override
  State<TodoExample> createState() => _TodoExampleState();
}

class _TodoExampleState extends State<TodoExample> {
  final _plugin = NativeHomeWidgets();
  final List<String> _todos = [];
  final _controller = TextEditingController();

  static const _widgetId = 'todo_widget';

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    final saved = await _plugin.getData<List>(key: 'todos', widgetId: _widgetId);
    if (saved != null && mounted) {
      setState(() {
        _todos.clear();
        _todos.addAll(saved.cast<String>());
      });
    }
  }

  Future<void> _addTodo() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _todos.add(_controller.text.trim());
      _controller.clear();
    });
    await _saveAndUpdate();
  }

  Future<void> _removeTodo(int index) async {
    setState(() => _todos.removeAt(index));
    await _saveAndUpdate();
  }

  Future<void> _saveAndUpdate() async {
    await _plugin.saveData(key: 'title', value: 'Todos', widgetId: _widgetId);
    await _plugin.saveData(key: 'value', value: '${_todos.length} tasks', widgetId: _widgetId);
    await _plugin.saveData(key: 'todos', value: _todos, widgetId: _widgetId);
    await _plugin.update(widgetId: _widgetId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Add a task...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addTodo,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_todos[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _removeTodo(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weather Example ───────────────────────────────────────

class WeatherExample extends StatefulWidget {
  const WeatherExample({super.key});

  @override
  State<WeatherExample> createState() => _WeatherExampleState();
}

class _WeatherExampleState extends State<WeatherExample> {
  final _plugin = NativeHomeWidgets();
  int _temperature = 22;
  String _condition = 'Sunny';
  final String _city = 'San Francisco';

  static const _widgetId = 'weather_widget';

  static const _conditions = ['Sunny', 'Cloudy', 'Rainy', 'Snowy', 'Windy'];

  Future<void> _updateWeather() async {
    await _plugin.saveData(key: 'title', value: _city, widgetId: _widgetId);
    await _plugin.saveData(key: 'value', value: '$_temperature°', widgetId: _widgetId);
    await _plugin.saveData(
      key: 'description',
      value: _condition,
      widgetId: _widgetId,
    );
    await _plugin.update(widgetId: _widgetId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Example')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_temperature°',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              Text(_condition, style: Theme.of(context).textTheme.titleLarge),
              Text(_city, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: () {
                      setState(() => _temperature--);
                      _updateWeather();
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 16),
                  IconButton.filled(
                    onPressed: () {
                      setState(() => _temperature++);
                      _updateWeather();
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: _conditions.map((condition) {
                  return ChoiceChip(
                    label: Text(condition),
                    selected: _condition == condition,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _condition = condition);
                        _updateWeather();
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Calendar Example ──────────────────────────────────────

class CalendarExample extends StatefulWidget {
  const CalendarExample({super.key});

  @override
  State<CalendarExample> createState() => _CalendarExampleState();
}

class _CalendarExampleState extends State<CalendarExample> {
  final _plugin = NativeHomeWidgets();
  final List<_Event> _events = [
    _Event('Team Meeting', DateTime.now().add(const Duration(hours: 2))),
    _Event('Lunch with Alex', DateTime.now().add(const Duration(days: 1))),
    _Event('Project Deadline', DateTime.now().add(const Duration(days: 3))),
  ];

  static const _widgetId = 'calendar_widget';

  Future<void> _updateWidget() async {
    final next = _events.where((e) => e.date.isAfter(DateTime.now())).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (next.isNotEmpty) {
      await _plugin.saveData(key: 'title', value: 'Next Event', widgetId: _widgetId);
      await _plugin.saveData(key: 'value', value: next.first.name, widgetId: _widgetId);
      await _plugin.saveData(
        key: 'description',
        value: _formatDate(next.first.date),
        widgetId: _widgetId,
      );
    } else {
      await _plugin.saveData(key: 'title', value: 'Calendar', widgetId: _widgetId);
      await _plugin.saveData(key: 'value', value: 'No events', widgetId: _widgetId);
    }
    await _plugin.update(widgetId: _widgetId);
  }

  String _formatDate(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.month}/${date.day} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar Example')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${event.date.day}'),
              ),
              title: Text(event.name),
              subtitle: Text(_formatDate(event.date)),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateWidget,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _Event {
  _Event(this.name, this.date);
  final String name;
  final DateTime date;
}

// ── Interactive Example ───────────────────────────────────

class InteractiveExample extends StatefulWidget {
  const InteractiveExample({super.key});

  @override
  State<InteractiveExample> createState() => _InteractiveExampleState();
}

class _InteractiveExampleState extends State<InteractiveExample> {
  final _plugin = NativeHomeWidgets();
  int _tapCount = 0;
  String _lastAction = 'None';

  static const _widgetId = 'interactive_widget';

  @override
  void initState() {
    super.initState();
    _loadState();
    _setupDeepLink();
  }

  Future<void> _loadState() async {
    final saved = await _plugin.getData<int>(key: 'taps', widgetId: _widgetId);
    if (saved != null && mounted) {
      setState(() => _tapCount = saved);
    }
  }

  Future<void> _setupDeepLink() async {
    await _plugin.saveDeepLink(
      widgetId: _widgetId,
      uri: 'nativehomewidgets://interactive',
    );
  }

  Future<void> _recordTap() async {
    setState(() {
      _tapCount++;
      _lastAction = 'Tap #$_tapCount';
    });
    await _plugin.saveData(key: 'taps', value: _tapCount, widgetId: _widgetId);
    await _plugin.saveData(key: 'title', value: 'Interactive', widgetId: _widgetId);
    await _plugin.saveData(key: 'value', value: 'Taps: $_tapCount', widgetId: _widgetId);
    await _plugin.update(widgetId: _widgetId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interactive Example')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.touch_app, size: 64),
              const SizedBox(height: 16),
              Text(
                'Tap Count: $_tapCount',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text('Last Action: $_lastAction'),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _recordTap,
                icon: const Icon(Icons.touch_app),
                label: const Text('Simulate Widget Tap'),
              ),
              const SizedBox(height: 16),
              Text(
                'Tap the widget on your home screen to increment the counter. '
                'A deep link is configured to open this screen.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
