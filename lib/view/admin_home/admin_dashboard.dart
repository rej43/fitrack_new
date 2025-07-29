import 'package:fitrack/common/color_extension.dart';
import 'package:fitrack/common_widget/round_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fitrack/view/login/login_view.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'Daily';
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly'];
  final TextEditingController _notificationController = TextEditingController();
  late TabController _tabController;

  List<FlSpot> get _chartData {
    switch (_selectedPeriod) {
      case 'Weekly':
        return [
          FlSpot(0, 10),
          FlSpot(1, 20),
          FlSpot(2, 15),
          FlSpot(3, 30),
          FlSpot(4, 25),
          FlSpot(5, 40),
          FlSpot(6, 35),
        ];
      case 'Monthly':
        return List.generate(
          30,
          (i) => FlSpot(i.toDouble(), (i * 2 % 25 + 10).toDouble()),
        );
      case 'Daily':
      default:
        return [
          FlSpot(0, 5),
          FlSpot(1, 8),
          FlSpot(2, 6),
          FlSpot(3, 12),
          FlSpot(4, 7),
          FlSpot(5, 10),
          FlSpot(6, 9),
        ];
    }
  }

  List<String> get _xLabels {
    switch (_selectedPeriod) {
      case 'Weekly':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case 'Monthly':
        return List.generate(30, (i) => (i + 1).toString());
      case 'Daily':
      default:
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _notificationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(color: TColor.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          onPressed: () async {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
            );
            if (shouldLogout == true) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginView()),
                (route) => false,
              );
            }
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: TColor.primaryColor2,
          unselectedLabelColor: TColor.grey,
          indicatorColor: TColor.primaryColor2,
          tabs: const [
            Tab(text: 'Analytics', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Notifications', icon: Icon(Icons.notifications)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Analytics Tab
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: media.width * 0.05),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: TColor.primaryG),
                      borderRadius: BorderRadius.circular(media.width * 0.075),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 25,
                      horizontal: 25,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  "assets/img/activity.png",
                                  width: 28,
                                  height: 28,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'User Activity',
                                  style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: TColor.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedPeriod,
                                underline: const SizedBox(),
                                borderRadius: BorderRadius.circular(16),
                                items:
                                    _periods.map((period) {
                                      return DropdownMenuItem<String>(
                                        value: period,
                                        child: Text(
                                          period,
                                          style: TextStyle(color: TColor.black),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedPeriod = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              minY: 0,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                getDrawingHorizontalLine:
                                    (value) => FlLine(
                                      color: TColor.white.withOpacity(0.2),
                                      strokeWidth: 1,
                                    ),
                                getDrawingVerticalLine:
                                    (value) => FlLine(
                                      color: TColor.white.withOpacity(0.2),
                                      strokeWidth: 1,
                                    ),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 36,
                                    getTitlesWidget:
                                        (value, meta) => Text(
                                          value.toInt().toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: TColor.black.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                        ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 32,
                                    interval:
                                        _selectedPeriod == 'Monthly' ? 4 : 1,
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      if (_selectedPeriod == 'Monthly') {
                                        // Only show labels for 1, 5, 9, 13, 17, 21, 25, 30
                                        const showIdx = [
                                          0,
                                          4,
                                          8,
                                          12,
                                          16,
                                          20,
                                          24,
                                          29,
                                        ];
                                        if (!showIdx.contains(idx)) {
                                          return const SizedBox.shrink();
                                        }
                                      }
                                      if (idx < 0 || idx >= _xLabels.length) {
                                        return const SizedBox.shrink();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          _xLabels[idx],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: TColor.black.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _chartData,
                                  isCurved: true,
                                  barWidth: 4,
                                  color: TColor.secondaryColor2,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        TColor.secondaryColor2.withOpacity(0.3),
                                        TColor.primaryColor1.withOpacity(0.1),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  dotData: FlDotData(show: true),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: media.width * 0.1),
                ],
              ),
            ),
          ),
          // Notification Tab
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: media.width * 0.07),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: TColor.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: TColor.grey.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 25,
                      horizontal: 25,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              "assets/img/notification.png",
                              width: 28,
                              height: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Send Notification',
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Send a message to all users instantly',
                          style: TextStyle(color: TColor.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _notificationController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Enter notification message',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: RoundButton(
                            title: "Send Notification",
                            type: RoundButtonType.bgGradient,
                            onPressed: () {
                              final message =
                                  _notificationController.text.trim();
                              if (message.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Notification sent: "$message"',
                                    ),
                                  ),
                                );
                                _notificationController.clear();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: media.width * 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
