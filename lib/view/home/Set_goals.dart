import 'package:fitrack/common/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SetGoalsView extends StatefulWidget {
  const SetGoalsView({super.key});

  @override
  _SetGoalsScreenState createState() => _SetGoalsScreenState();
}

class _SetGoalsScreenState extends State<SetGoalsView> {
  final TextEditingController _customGoalController = TextEditingController();
  final List<GoalItem> _goals = [];
  bool _isLoading = true;

  // Predefined goal categories
  final List<GoalCategory> _goalCategories = [
    GoalCategory(
      title: "Fitness Goals",
      icon: Icons.fitness_center,
      color: Colors.blue,
      goals: [
        "Walk 10,000 steps",
        "Exercise for 30 minutes",
        "Do 50 push-ups",
        "Run 5km",
        "Complete a workout",
      ],
    ),
    GoalCategory(
      title: "Nutrition Goals",
      icon: Icons.restaurant,
      color: Colors.green,
      goals: [
        "Drink 8 glasses of water",
        "Eat 5 servings of vegetables",
        "Limit sugar intake",
        "Eat protein with every meal",
        "Track all meals",
      ],
    ),
    GoalCategory(
      title: "Health Goals",
      icon: Icons.health_and_safety,
      color: Colors.orange,
      goals: [
        "Get 8 hours of sleep",
        "Meditate for 10 minutes",
        "Take vitamins",
        "Check blood pressure",
        "Reduce stress",
      ],
    ),
    GoalCategory(
      title: "Lifestyle Goals",
      icon: Icons.self_improvement,
      color: Colors.purple,
      goals: [
        "Read for 30 minutes",
        "Spend time outdoors",
        "Connect with friends",
        "Learn something new",
        "Practice gratitude",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedGoals = prefs.getStringList('daily_goals') ?? [];
      
      setState(() {
        _goals.clear();
        for (final goalString in savedGoals) {
          try {
            final goalData = jsonDecode(goalString);
            _goals.add(GoalItem(
              text: goalData['text'],
              isCompleted: goalData['isCompleted'] ?? false,
              category: goalData['category'] ?? 'Custom',
              timestamp: DateTime.parse(goalData['timestamp']),
            ));
          } catch (e) {
            // Skip invalid entries
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsToSave = _goals.map((goal) => jsonEncode({
        'text': goal.text,
        'isCompleted': goal.isCompleted,
        'category': goal.category,
        'timestamp': goal.timestamp.toIso8601String(),
      })).toList();
      
      await prefs.setStringList('daily_goals', goalsToSave);
    } catch (e) {
      // Handle error
    }
  }

  void _addCustomGoal() {
    if (_customGoalController.text.trim().isEmpty) return;
    
    setState(() {
      _goals.add(GoalItem(
        text: _customGoalController.text.trim(),
        category: 'Custom',
        timestamp: DateTime.now(),
      ));
      _customGoalController.clear();
    });
    _saveGoals();
  }

  void _addPredefinedGoal(String goalText, String category) {
    // Check if goal already exists
    final exists = _goals.any((goal) => goal.text == goalText);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Goal already added!'),
          backgroundColor: TColor.secondaryColor1,
        ),
      );
      return;
    }

    setState(() {
      _goals.add(GoalItem(
        text: goalText,
        category: category,
        timestamp: DateTime.now(),
      ));
    });
    _saveGoals();
  }

  void _toggleGoal(int index) {
    final wasCompleted = _goals[index].isCompleted;
    setState(() {
      _goals[index].isCompleted = !_goals[index].isCompleted;
    });
    _saveGoals();
    
    // Show toast message when a goal is completed
    if (!wasCompleted && _goals[index].isCompleted) {
      final remainingGoals = _goals.where((goal) => !goal.isCompleted).length;
      _showGoalCompletionToast(remainingGoals);
    }
  }

  void _showGoalCompletionToast(int remainingGoals) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: TColor.white,
              size: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                remainingGoals == 0 
                    ? "All goals completed! 🎉" 
                    : "$remainingGoals goal${remainingGoals == 1 ? '' : 's'} left to complete",
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: remainingGoals == 0 ? Colors.green : TColor.primaryColor1,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: "OK",
          textColor: TColor.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _deleteGoal(int index) {
    setState(() {
      _goals.removeAt(index);
    });
    _saveGoals();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.primaryColor1,
        elevation: 0,
        title: Text(
          "Today's Goals",
          style: TextStyle(
            color: TColor.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TColor.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: TColor.primaryColor1))
          : Column(
              children: [
                // Progress Summary
                Container(
                  margin: const EdgeInsets.all(15),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: TColor.primaryG),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Daily Progress",
                              style: TextStyle(
                                color: TColor.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "${_goals.where((g) => g.isCompleted).length} of ${_goals.length} completed",
                              style: TextStyle(
                                color: TColor.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: TColor.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "${_goals.isEmpty ? 0 : ((_goals.where((g) => g.isCompleted).length / _goals.length) * 100).round()}%",
                            style: TextStyle(
                              color: TColor.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Custom Goal Input
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customGoalController,
                          decoration: InputDecoration(
                            hintText: "Add your custom goal...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: TColor.grey),
                          ),
                          onSubmitted: (_) => _addCustomGoal(),
                        ),
                      ),
                      IconButton(
                        onPressed: _addCustomGoal,
                        icon: Icon(Icons.add_circle, color: TColor.primaryColor1),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Goal Categories
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Suggested Goals",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 15),
                        
                        // Goal Categories
                        ..._goalCategories.map((category) => _buildGoalCategory(category)),
                        
                        SizedBox(height: 20),
                        
                        // Current Goals
                        if (_goals.isNotEmpty) ...[
                          Text(
                            "Your Goals",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 15),
                          ..._goals.asMap().entries.map((entry) {
                            final index = entry.key;
                            final goal = entry.value;
                            return _buildGoalItem(goal, index);
                          }),
                        ],
                        
                        SizedBox(height: 100), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildGoalCategory(GoalCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(category.icon, color: category.color, size: 20),
              ),
              SizedBox(width: 10),
              Text(
                category.title,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: category.goals.map((goalText) {
              final isAdded = _goals.any((goal) => goal.text == goalText);
              return GestureDetector(
                onTap: isAdded ? null : () => _addPredefinedGoal(goalText, category.title),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isAdded ? Colors.grey.shade300 : category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isAdded ? Colors.grey.shade400 : category.color.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isAdded)
                        Icon(Icons.check, color: Colors.grey.shade600, size: 16)
                      else
                        Icon(Icons.add, color: category.color, size: 16),
                      SizedBox(width: 4),
                      Text(
                        goalText,
                        style: TextStyle(
                          color: isAdded ? Colors.grey.shade600 : category.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(GoalItem goal, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleGoal(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: goal.isCompleted ? TColor.primaryColor1 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: goal.isCompleted
                  ? Icon(Icons.check, color: TColor.white, size: 16)
                  : null,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.text,
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  goal.category,
                  style: TextStyle(
                    color: TColor.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteGoal(index),
            icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
          ),
        ],
      ),
    );
  }
}

class GoalItem {
  final String text;
  bool isCompleted;
  final String category;
  final DateTime timestamp;

  GoalItem({
    required this.text,
    this.isCompleted = false,
    required this.category,
    required this.timestamp,
  });
}

class GoalCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> goals;

  GoalCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.goals,
  });
}
