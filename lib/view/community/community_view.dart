import 'package:flutter/material.dart';
import 'package:fitrack/common/color_extension.dart';

class CommunityView extends StatefulWidget {
  const CommunityView({super.key});

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  // Sample data with comments
  final List<Map<String, dynamic>> posts = [
    {
      'user': 'Alice',
      'avatar': null,
      'activity': 'Ran 5 km in 28:15',
      'time': '10 min ago',
      'likes': 12,
      'comments': ['Great job!', 'Impressive pace!', 'Keep it up!'],
    },
    {
      'user': 'Bob',
      'avatar': null,
      'activity': 'Drank 2L water 💧',
      'time': '30 min ago',
      'likes': 7,
      'comments': ['Hydration is key!'],
    },
    {
      'user': 'Charlie',
      'avatar': null,
      'activity': 'Burned 500 kcal cycling 🚴',
      'time': '1 hr ago',
      'likes': 15,
      'comments': [
        'Wow, amazing!',
        'How long did it take?',
        'Nice ride!',
        'You inspire me!',
      ],
    },
  ];

  void _incrementLike(int index) {
    setState(() {
      posts[index]['likes'] += 1;
    });
  }

  void _showComments(int index) {
    final TextEditingController commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 18,
            right: 18,
            top: 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Comments',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(posts[index]['comments'].length, (cIdx) {
                return ListTile(
                  leading: Icon(Icons.comment, color: TColor.primaryColor1),
                  title: Text(posts[index]['comments'][cIdx]),
                );
              }),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: TColor.primaryColor1),
                    onPressed: () {
                      final text = commentController.text.trim();
                      if (text.isNotEmpty) {
                        setState(() {
                          posts[index]['comments'].add(text);
                        });
                        commentController.clear();
                        Navigator.of(context).pop();
                        _showComments(index); // Reopen to show updated comments
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: TColor.primaryColor1,
        centerTitle: true,
        title: const Text(
          'Community',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 20,
            letterSpacing: 1.1,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            elevation: 0,
            color: TColor.lightgrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: TColor.primaryColor1,
                    child: Text(
                      post['user'][0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['user'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          post['activity'],
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              post['time'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () => _incrementLike(index),
                              borderRadius: BorderRadius.circular(20),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.thumb_up_alt_outlined,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('${post['likes']}'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () => _showComments(index),
                              borderRadius: BorderRadius.circular(20),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.comment_outlined,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('${post['comments'].length}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
