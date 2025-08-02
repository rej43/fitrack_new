import 'package:flutter/material.dart';
import 'package:fitrack/common/color_extension.dart';
import 'package:fitrack/view/main_tab/maintab_view.dart';
import 'package:fitrack/models/user_model.dart';

class CommunityView extends StatefulWidget {
  const CommunityView({super.key});

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  // Fetch current user's name from UserModel (replace with your actual user fetching logic if needed)
  String get currentUserName => _userName ?? 'User';
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = await UserModel.loadFromLocal();
    setState(() {
      _userName = user?.name ?? 'User';
    });
  }

  // Sample data with comments and likedBy
  final List<Map<String, dynamic>> posts = [
    {
      'user': 'Alice',
      'avatar': null,
      'activity': 'Ran 5 km in 28:15 🏃‍♀️',
      'time': '10 min ago',
      'likes': 12,
      'likedBy': <String>{'Alice'},
      'comments': ['Great job!', 'Impressive pace!', 'Keep it up!'],
      'activityType': 'running',
    },
    {
      'user': 'Bob',
      'avatar': null,
      'activity': 'Drank 2L water today 💧',
      'time': '30 min ago',
      'likes': 7,
      'likedBy': <String>{},
      'comments': ['Hydration is key!', 'Stay hydrated!'],
      'activityType': 'hydration',
    },
    {
      'user': 'Charlie',
      'avatar': null,
      'activity': 'Burned 500 kcal cycling 🚴',
      'time': '1 hr ago',
      'likes': 15,
      'likedBy': <String>{},
      'comments': [
        'Wow, amazing!',
        'How long did it take?',
        'Nice ride!',
        'You inspire me!',
      ],
      'activityType': 'cycling',
    },
    {
      'user': 'Diana',
      'avatar': null,
      'activity': 'Completed 30 min yoga session 🧘‍♀️',
      'time': '2 hrs ago',
      'likes': 8,
      'likedBy': <String>{},
      'comments': ['Namaste!', 'Great flexibility!'],
      'activityType': 'yoga',
    },
  ];

  void _incrementLike(int index) {
    final likedBy = (posts[index]['likedBy'] ?? <String>{}) as Set<String>;
    if (!likedBy.contains(currentUserName)) {
      setState(() {
        posts[index]['likes'] += 1;
        likedBy.add(currentUserName);
        posts[index]['likedBy'] = likedBy; // Ensure it's set back
      });
    }
  }

  void _showComments(int index) {
    final TextEditingController commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Comments',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: TColor.black,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${posts[index]['comments'].length} comments',
                      style: TextStyle(
                        color: TColor.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: posts[index]['comments'].isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No comments yet',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Be the first to comment!',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: posts[index]['comments'].length,
                          itemBuilder: (context, cIdx) {
                            final commentText = posts[index]['comments'][cIdx];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: TColor.primaryColor1.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: TColor.primaryColor1,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'User ${cIdx + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: TColor.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          commentText,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: TColor.black.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const Divider(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: TColor.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: TColor.primaryG),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white, size: 20),
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
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddPostDialog() {
    final TextEditingController postController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: TColor.primaryG),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Share your achievement',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: TColor.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: postController,
                decoration: InputDecoration(
                  hintText: 'What do you want to share?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TColor.primaryColor1),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 3,
                autofocus: true,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: TColor.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          final text = postController.text.trim();
                          if (text.isNotEmpty) {
                            setState(() {
                              posts.insert(0, {
                                'user': currentUserName,
                                'avatar': null,
                                'activity': text,
                                'time': 'Just now',
                                'likes': 1, // Self-like
                                'likedBy': <String>{currentUserName},
                                'comments': [],
                                'activityType': 'custom',
                              });
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.primaryColor1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Post',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'running':
        return Icons.directions_run;
      case 'cycling':
        return Icons.directions_bike;
      case 'hydration':
        return Icons.water_drop;
      case 'yoga':
        return Icons.self_improvement;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getActivityColor(String activityType) {
    switch (activityType) {
      case 'running':
        return Colors.blue;
      case 'cycling':
        return Colors.green;
      case 'hydration':
        return Colors.cyan;
      case 'yoga':
        return Colors.purple;
      default:
        return TColor.primaryColor1;
    }
  }

  String _getActivityTypeLabel(String activityType) {
    switch (activityType) {
      case 'running':
        return 'Running';
      case 'cycling':
        return 'Cycling';
      case 'hydration':
        return 'Hydration';
      case 'yoga':
        return 'Yoga';
      default:
        return 'Fitness';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: TColor.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TColor.black),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainTabView()),
              (route) => false,
            );
          },
        ),
        title: Text(
          'Community',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TColor.black,
            fontSize: 20,
          ),
        ),
      ),
      body: posts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: TColor.primaryColor1.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Icon(
                      Icons.people_outline,
                      size: 60,
                      color: TColor.primaryColor1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No posts yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: TColor.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to share your achievement!',
                    style: TextStyle(
                      fontSize: 16,
                      color: TColor.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final post = posts[index];
                final likedBy = (post['likedBy'] ?? <String>{}) as Set<String>;
                final isLiked = likedBy.contains(currentUserName);
                final activityType = post['activityType'] ?? 'custom';
                
                return Container(
                  decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: TColor.primaryG),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Center(
                                child: Text(
                                  post['user'][0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['user'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: TColor.black,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: TColor.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        post['time'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: TColor.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getActivityColor(activityType).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getActivityIcon(activityType),
                                color: _getActivityColor(activityType),
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            post['activity'],
                            style: TextStyle(
                              fontSize: 15,
                              color: TColor.black,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildActionButton(
                              icon: isLiked ? Icons.favorite : Icons.favorite_border,
                              label: '${post['likes']}',
                              isActive: isLiked,
                              onTap: () => _incrementLike(index),
                            ),
                            const SizedBox(width: 16),
                            _buildActionButton(
                              icon: Icons.chat_bubble_outline,
                              label: '${post['comments'].length}',
                              isActive: false,
                              onTap: () => _showComments(index),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getActivityColor(activityType).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getActivityTypeLabel(activityType),
                                style: TextStyle(
                                  color: _getActivityColor(activityType),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: TColor.primaryG),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: TColor.primaryColor1.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddPostDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          tooltip: 'Add Post',
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? TColor.primaryColor1 : TColor.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive ? TColor.primaryColor1 : TColor.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
