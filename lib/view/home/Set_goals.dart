import 'package:fitrack/common/color_extension.dart';
import 'package:flutter/material.dart';

class SetGoalsView extends StatefulWidget {
  const SetGoalsView({Key? key}) : super(key: key);

  @override
  _SetGoalsScreenState createState() => _SetGoalsScreenState();
}

class _SetGoalsScreenState extends State<SetGoalsView> {
  final TextEditingController _goalController = TextEditingController();
  final List<_GoalItem> _goals = [];

  void _addGoal() {
    if (_goalController.text.trim().isEmpty) return;
    setState(() {
      _goals.add(_GoalItem(text: _goalController.text.trim()));
      _goalController.clear();
    });
  }

  void _toggleGoal(int index) {
    setState(() {
      _goals[index].isCompleted = !_goals[index].isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.primaryColor1,
        title: const Text(
          "Set Today's Goals",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _goalController,
                    decoration: const InputDecoration(
                      labelText: 'Enter a goal',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addGoal, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _goals.isEmpty
                      ? const Center(child: Text('No goals yet.'))
                      : ListView.builder(
                        itemCount: _goals.length,
                        itemBuilder: (context, index) {
                          final goal = _goals[index];
                          return ListTile(
                            leading: Checkbox(
                              value: goal.isCompleted,
                              onChanged: (_) => _toggleGoal(index),
                            ),
                            title: Text(
                              goal.text,
                              style: TextStyle(
                                decoration:
                                    goal.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalItem {
  final String text;
  bool isCompleted;

  _GoalItem({required this.text, this.isCompleted = false});
}
