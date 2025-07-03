import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NutritionPage extends StatefulWidget {
  @override
  _NutritionPageState createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _nutritionData;

  Future<void> _fetchNutrition(String query) async {
    final response = await http.get(
      Uri.parse('https://api.api-ninjas.com/v1/nutrition?query=$query'),
      headers: {'X-Api-Key': 'YOUR_API_KEY_HERE'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        setState(() {
          _nutritionData = data.first; // First food item
        });
      }
    } else {
      print('Failed to load data: ${response.body}');
      setState(() => _nutritionData = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter food (e.g., 1lb brisket and fries)',
              ),
            ),
            ElevatedButton(
              onPressed: () => _fetchNutrition(_controller.text),
              child: const Text('Get Nutrition'),
            ),
            const SizedBox(height: 20),
            if (_nutritionData != null)
              Expanded(
                child: ListView(
                  children:
                      _nutritionData!.entries.map((entry) {
                        return ListTile(
                          title: Text('${entry.key}: ${entry.value}'),
                        );
                      }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
