import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:fitrack/common/color_extension.dart';
import 'package:fitrack/common_widget/round_button.dart';
import 'package:fitrack/view/home/Set_goals.dart';
// ignore_for_file: unused_import
import 'package:fitrack/view/home/activity_traker_view.dart';
import 'package:fitrack/view/home/view_more.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:fitrack/view/home/notification_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fitrack/models/user_model.dart';
import 'package:fitrack/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  UserModel? user;
  Map<String, dynamic>? currentUser;
  bool isLoading = true;
  
  // Dynamic data variables
  int _todayWaterIntake = 0;
  int _waterGoal = 2000;
  String _sleepDuration = '0h 0m';
  int _todayCalories = 0;
  int _calorieGoal = 1000; // Total calorie goal is 1000 kcal
  List<Map<String, dynamic>> _waterTimeline = [];
  List<Map<String, dynamic>> _calorieTimeline = [];
  List<Map<String, dynamic>> _dailyGoals = [];
  int _completedGoals = 0;
  int _totalGoals = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAllActivityData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
    _loadAllActivityData();
  }

  Future<void> _loadAllActivityData() async {
    await Future.wait([
      _loadWaterData(),
      _loadSleepData(),
      _loadCaloriesData(),
      _loadGoalsData(),
    ]);
    setState(() {});
  }

  Future<void> _refreshCalorieData() async {
    await _loadCaloriesData();
    setState(() {});
  }

  // Method to clean up corrupted calorie data
  Future<void> _cleanupCalorieData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLogs = prefs.getStringList('food_logs') ?? [];
    final validLogs = <String>[];
    
    for (final logString in savedLogs) {
      try {
        final logData = jsonDecode(logString);
        
        // Check if all required fields are present
        String? foodName = logData['foodName'];
        if (foodName == null) {
          foodName = logData['food']; // Fallback to old structure
        }
        
        if (foodName != null && 
            logData['calories'] != null && 
            logData['timestamp'] != null) {
          validLogs.add(logString);
        }
      } catch (e) {
        // Skip corrupted entries
      }
    }
    
    // Save only valid logs back
    await prefs.setStringList('food_logs', validLogs);
  }

  Future<void> _loadWaterData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLogs = prefs.getStringList('water_logs') ?? [];
      final savedGoal = prefs.getInt('water_goal') ?? 2000;
      
      _waterGoal = savedGoal;
      _todayWaterIntake = 0;
      _waterTimeline.clear();
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      for (final logString in savedLogs) {
        try {
          final logData = jsonDecode(logString);
          final timestamp = DateTime.parse(logData['timestamp']);
          final ml = logData['ml'] as int;
          
          if (timestamp.isAfter(today.subtract(const Duration(days: 1)))) {
            _todayWaterIntake += ml;
            
            // Create timeline entries
            final hour = timestamp.hour;
            String timeSlot;
            if (hour < 8) {
              timeSlot = "6am - 8am";
            } else if (hour < 11) {
              timeSlot = "9am - 11am";
            } else if (hour < 14) {
              timeSlot = "11am - 2pm";
            } else if (hour < 16) {
              timeSlot = "2pm - 4pm";
            } else {
              timeSlot = "4pm - now";
            }
            
            // Update timeline
            bool found = false;
            for (var entry in _waterTimeline) {
              if (entry['title'] == timeSlot) {
                entry['subtitle'] = "${int.parse(entry['subtitle'].replaceAll('ml', '')) + ml}ml";
                found = true;
                break;
              }
            }
            if (!found) {
              _waterTimeline.add({
                'title': timeSlot,
                'subtitle': '${ml}ml',
              });
            }
          }
        } catch (e) {
          // Skip invalid entries
        }
      }
      
      // Sort timeline by time
      _waterTimeline.sort((a, b) {
        final order = ['6am - 8am', '9am - 11am', '11am - 2pm', '2pm - 4pm', '4pm - now'];
        return order.indexOf(a['title']).compareTo(order.indexOf(b['title']));
      });
      
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadSleepData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final savedDate = prefs.getString('sleep_date') ?? today;
      
      if (savedDate == today) {
        final sleepStartString = prefs.getString('sleep_start');
        final sleepEndString = prefs.getString('sleep_end');
        
        if (sleepStartString != null && sleepEndString != null) {
          final sleepStart = DateTime.parse(sleepStartString);
          final sleepEnd = DateTime.parse(sleepEndString);
          final duration = sleepEnd.difference(sleepStart);
          
          int hours = duration.inHours;
          int minutes = duration.inMinutes % 60;
          _sleepDuration = '${hours}h ${minutes}m';
        } else {
          _sleepDuration = '0h 0m';
        }
      } else {
        _sleepDuration = '0h 0m';
      }
    } catch (e) {
      _sleepDuration = '0h 0m';
    }
  }

  Future<void> _loadCaloriesData() async {
    try {
      // Clean up any corrupted data first
      await _cleanupCalorieData();
      
      final prefs = await SharedPreferences.getInstance();
      final savedLogs = prefs.getStringList('food_logs') ?? [];
      
      _todayCalories = 0;
      _calorieTimeline.clear();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      for (final logString in savedLogs) {
        try {
          final logData = jsonDecode(logString);
          final timestamp = DateTime.parse(logData['timestamp']);
          final calories = logData['calories'] as int;
          
          // Handle both old and new data structures
          String? foodName = logData['foodName'];
          if (foodName == null) {
            foodName = logData['food']; // Fallback to old structure
          }
          
          if (foodName == null) {
            continue; // Skip entries without food name
          }
          
          if (timestamp.isAfter(today.subtract(const Duration(days: 1)))) {
            _todayCalories += calories;
            
            // Create timeline entries
            final hour = timestamp.hour;
            String timeSlot;
            if (hour < 8) {
              timeSlot = "6am - 8am";
            } else if (hour < 11) {
              timeSlot = "9am - 11am";
            } else if (hour < 14) {
              timeSlot = "11am - 2pm";
            } else if (hour < 16) {
              timeSlot = "2pm - 4pm";
            } else {
              timeSlot = "4pm - now";
            }
            
            // Update timeline
            bool found = false;
            for (var entry in _calorieTimeline) {
              if (entry['title'] == timeSlot) {
                entry['subtitle'] = "${int.parse(entry['subtitle'].replaceAll('kcal', '')) + calories}kcal";
                found = true;
                break;
              }
            }
            if (!found) {
              _calorieTimeline.add({
                'title': timeSlot,
                'subtitle': '${calories}kcal',
                'foodName': foodName,
              });
            }
          }
        } catch (e) {
          // Skip invalid entries
          print('Skipping invalid food log entry in home view: $e');
        }
      }
      
      // Sort timeline by time
      _calorieTimeline.sort((a, b) {
        final order = ['6am - 8am', '9am - 11am', '11am - 2pm', '2pm - 4pm', '4pm - now'];
        return order.indexOf(a['title']).compareTo(order.indexOf(b['title']));
      });
      
      // Use actual logged calories, no default fallback
      setState(() {});
    } catch (e) {
      _todayCalories = 0; // Start with 0 if no data
      setState(() {});
    }
  }

  Future<void> _loadGoalsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedGoals = prefs.getStringList('daily_goals') ?? [];
      
      _dailyGoals.clear();
      _completedGoals = 0;
      _totalGoals = savedGoals.length;
      
      for (final goalString in savedGoals) {
        try {
          final goalData = jsonDecode(goalString);
          final isCompleted = goalData['isCompleted'] ?? false;
          final text = goalData['text'] ?? '';
          final category = goalData['category'] ?? 'Custom';
          
          _dailyGoals.add({
            'text': text,
            'isCompleted': isCompleted,
            'category': category,
          });
          
          if (isCompleted) {
            _completedGoals++;
          }
        } catch (e) {
          // Skip invalid entries
        }
      }
    } catch (e) {
      _dailyGoals.clear();
      _completedGoals = 0;
      _totalGoals = 0;
    }
  }

  Future<void> _loadUserData() async {
    try {
      // Load both legacy UserModel and new API user data
      final userData = await UserModel.loadFromLocal();
      final apiUserData = await ApiService.getCurrentUser();
      
      setState(() {
        user = userData;
        currentUser = apiUserData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getUserName() {
    // Try to get name from API user data first
    if (currentUser != null) {
      if (currentUser!['firstName'] != null && currentUser!['lastName'] != null) {
        return '${currentUser!['firstName']} ${currentUser!['lastName']}';
      } else if (currentUser!['name'] != null) {
        return currentUser!['name'];
      }
    }
    
    // Fallback to legacy user model
    if (user?.name != null) {
      return user!.name!;
    }
    
    return "User";
  }

  double get _waterProgress => (_todayWaterIntake / _waterGoal).clamp(0, 1);
  double get _calorieProgress => (_todayCalories / _calorieGoal).clamp(0, 1); // Progress: 310/1000 = 31%
  int get _caloriesLeft => (_calorieGoal - _todayCalories).clamp(0, _calorieGoal); // 1000 - 310 = 690 kcal left

  void _showGoalCompletionToast(int newCompletedGoals) {
    final remainingGoals = _totalGoals - _completedGoals;
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

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back,",
                          style: TextStyle(color: TColor.grey, fontSize: 15),
                        ),
                        Text(
                          _getUserName(),
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationView(),
                          ),
                        );
                      },
                      icon: Image.asset(
                        "assets/img/notification.png",
                        width: 25,
                        height: 25,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: media.width * 0.05),
                Container(
                  height: media.width * 0.4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: TColor.primaryG),
                    borderRadius: BorderRadius.circular(media.width * 0.075),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 25,
                    horizontal: 25,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "BMI (Body Mass Index)",
                            style: TextStyle(
                              color: TColor.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            user?.bmiCategory ?? "Normal Weight",
                            style: TextStyle(
                              color: TColor.grey,
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: media.width * 0.05),
                          SizedBox(
                            width: 150,
                            height: 35,
                            child: RoundButton(
                              title: "View More",
                              type: RoundButtonType.bgSGradient,
                              fontSize: 12,
                              fontWeight: FontWeight.w100,
                              onPressed: () {
                                // TODO: Navigate to BMI detail page
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('BMI detail page coming soon!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      AspectRatio(
                        aspectRatio: 1,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {},
                            ),
                            startDegreeOffset: 250,
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 1,
                            centerSpaceRadius: 0,
                            sections: showingSections(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: media.width * 0.05),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                    color: TColor.primaryColor2.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Today's Target",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            width: 95,
                            height: 30,
                            child: RoundButton(
                              title: "Check",
                              type: RoundButtonType.bgGradient,
                              fontSize: 12,
                              onPressed: () async {
                                // Store the number of completed goals before navigation
                                final completedBefore = _completedGoals;
                                
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SetGoalsView(),
                                  ),
                                );
                                
                                // Refresh goals data when returning from goals screen
                                await _loadGoalsData();
                                setState(() {});
                                
                                // Show toast if new goals were completed
                                if (_completedGoals > completedBefore) {
                                  final newCompleted = _completedGoals - completedBefore;
                                  _showGoalCompletionToast(newCompleted);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_totalGoals > 0) ...[
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Progress",
                                    style: TextStyle(
                                      color: TColor.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "$_completedGoals of $_totalGoals completed",
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: TColor.primaryColor1.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  "${_totalGoals > 0 ? ((_completedGoals / _totalGoals) * 100).round() : 0}%",
                                  style: TextStyle(
                                    color: TColor.primaryColor1,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (_dailyGoals.isNotEmpty) ...[
                          Container(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _dailyGoals.length > 3 ? 3 : _dailyGoals.length,
                              itemBuilder: (context, index) {
                                final goal = _dailyGoals[index];
                                return Container(
                                  margin: EdgeInsets.only(right: 8),
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: goal['isCompleted'] 
                                        ? TColor.primaryColor1.withOpacity(0.1)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: goal['isCompleted'] 
                                          ? TColor.primaryColor1.withOpacity(0.3)
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        goal['isCompleted'] ? Icons.check_circle : Icons.radio_button_unchecked,
                                        color: goal['isCompleted'] ? TColor.primaryColor1 : Colors.grey.shade400,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          goal['text'],
                                          style: TextStyle(
                                            color: goal['isCompleted'] ? TColor.primaryColor1 : TColor.grey,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            decoration: goal['isCompleted'] ? TextDecoration.lineThrough : null,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ] else ...[
                        SizedBox(height: 8),
                        Text(
                          "No goals set for today",
                          style: TextStyle(
                            color: TColor.grey,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: media.width * 0.05),
                Text(
                  "Activity Status",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: media.width * 0.02),
                SizedBox(height: media.width * 0.05),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: media.width * 0.95,
                        padding: const EdgeInsets.symmetric(
                          vertical: 25,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(color: TColor.grey, blurRadius: 2),
                          ],
                        ),
                        child: Row(
                          children: [
                            SimpleAnimationProgressBar(
                              height: media.width * 0.85,
                              width: media.width * 0.07,
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: Colors.purple,
                              ratio: _waterProgress,
                              direction: Axis.vertical,
                              curve: Curves.fastLinearToSlowEaseIn,
                              duration: const Duration(seconds: 3),
                              borderRadius: BorderRadius.circular(15),
                              gradientColor: LinearGradient(
                                colors: TColor.primaryG,
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Water Intake",
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        colors: TColor.primaryG,
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ).createShader(
                                        Rect.fromLTRB(
                                          0,
                                          0,
                                          bounds.width,
                                          bounds.height,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "${(_todayWaterIntake / 1000).toStringAsFixed(1)} Liters",
                                      style: TextStyle(
                                        color: TColor.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: _waterTimeline.isEmpty 
                                      ? [
                                          Text(
                                            "No water logged today",
                                            style: TextStyle(
                                              color: TColor.grey,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ]
                                      : _waterTimeline.map((wObj) {
                                          var isLast = wObj == _waterTimeline.last;
                                          return Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                    ),
                                                    width: 10,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                      color: TColor.secondaryColor1,
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                  ),
                                                  if (!isLast)
                                                    DottedDashedLine(
                                                      height: media.width * 0.078,
                                                      width: 0,
                                                      dashColor: TColor.secondaryColor1,
                                                      axis: Axis.vertical,
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    wObj["title"].toString(),
                                                    style: TextStyle(
                                                      color: TColor.grey,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  ShaderMask(
                                                    blendMode: BlendMode.srcIn,
                                                    shaderCallback: (bounds) {
                                                      return LinearGradient(
                                                        colors: TColor.secondaryG,
                                                        begin: Alignment.centerLeft,
                                                        end: Alignment.centerRight,
                                                      ).createShader(
                                                        Rect.fromLTRB(
                                                          0,
                                                          0,
                                                          bounds.width,
                                                          bounds.height,
                                                        ),
                                                      );
                                                    },
                                                    child: Text(
                                                      wObj["subtitle"].toString(),
                                                      style: TextStyle(
                                                        color: TColor.white.withOpacity(0.7),
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: media.width * 0.05),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.maxFinite,
                            height: media.width * 0.42,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(color: TColor.grey, blurRadius: 2),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sleep",
                                  style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      colors: TColor.primaryG,
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ).createShader(
                                      Rect.fromLTRB(
                                        0,
                                        0,
                                        bounds.width,
                                        bounds.height,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    _sleepDuration,
                                    style: TextStyle(
                                      color: TColor.white.withOpacity(0.7),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Image.asset(
                                    "assets/img/sleep_grap.png",
                                    width: double.maxFinite,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: media.width * 0.05),
                          Container(
                            width: double.maxFinite,
                            height: media.width * 0.42,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(color: TColor.grey, blurRadius: 2),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Calories",
                                  style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      colors: TColor.primaryG,
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ).createShader(
                                      Rect.fromLTRB(
                                        0,
                                        0,
                                        bounds.width,
                                        bounds.height,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "$_todayCalories kCal",
                                    style: TextStyle(
                                      color: TColor.white.withOpacity(0.7),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: media.width * 0.2,
                                    height: media.width * 0.2,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: media.width * 0.16,
                                          height: media.width * 0.16,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: TColor.primaryG,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              media.width * 0.075,
                                            ),
                                          ),
                                          child: FittedBox(
                                            child: Text(
                                              "${_caloriesLeft}kCal\nleft",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: TColor.white,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: media.width * 0.2,
                                          height: media.width * 0.2,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Outer donut chart (calorie progress)
                                              CircularProgressIndicator(
                                                value: (_todayCalories / _calorieGoal).clamp(0, 1),
                                                strokeWidth: 12,
                                                backgroundColor: Colors.grey.shade200,
                                                valueColor: AlwaysStoppedAnimation<Color>(TColor.primaryColor1),
                                              ),
                                              // Inner donut chart (additional progress indicator)
                                              Container(
                                                width: media.width * 0.18,
                                                height: media.width * 0.18,
                                                child: CircularProgressIndicator(
                                                  value: (_todayCalories / _calorieGoal).clamp(0, 1),
                                                  strokeWidth: 8,
                                                  backgroundColor: Colors.grey.shade100,
                                                  valueColor: AlwaysStoppedAnimation<Color>(TColor.secondaryColor1),
                                                ),
                                              ),
                                              // Center container with text
                                              Container(
                                                width: media.width * 0.16,
                                                height: media.width * 0.16,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: TColor.primaryG,
                                                  ),
                                                  borderRadius: BorderRadius.circular(
                                                    media.width * 0.075,
                                                  ),
                                                ),
                                                child: FittedBox(
                                                  child: Text(
                                                    "${_caloriesLeft}kCal\nleft",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: TColor.white,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    final bmi = user?.bmi ?? 19.1;
    final bmiPercentage = (bmi / 40.0) * 100; // Assuming max BMI of 40 for visualization
    
    return List.generate(2, (i) {
      var color0 = TColor.secondaryColor1;

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: color0,
            value: bmiPercentage,
            title: '',
            radius: 55,
            titlePositionPercentageOffset: 0.55,
            badgeWidget: Text(
              bmi.toStringAsFixed(1),
              style: TextStyle(
                color: TColor.black,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.white,
            value: 100 - bmiPercentage,
            title: '',
            radius: 45,
            titlePositionPercentageOffset: 0.55,
          );

        default:
          throw Error();
      }
    });
  }
}

