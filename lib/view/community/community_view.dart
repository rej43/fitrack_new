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
      'activity': 'Ran 5 km in 28:15',
      'time': '10 min ago',
      'likes': 12,
      'likedBy': <String>{'Alice'},
      'comments': ['Great job!', 'Impressive pace!', 'Keep it up!'],
    },
    {
      'user': 'Bob',
      'avatar': null,
      'activity': 'Drank 2L water 💧',
      'time': '30 min ago',
      'likes': 7,
      'likedBy': <String>{},
      'comments': ['Hydration is key!'],
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
                final commentText = posts[index]['comments'][cIdx];
                return ListTile(
                  leading: Icon(Icons.comment, color: TColor.primaryColor1),
                  title: Text(commentText),
                  onTap: () {
                    // Copy comment to input for editing/resending
                    commentController.text = commentText;
                    // Optionally, focus the input field
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
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

  void _showAddPostDialog() {
    final TextEditingController postController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('New Post'),
            content: TextField(
              controller: postController,
              decoration: const InputDecoration(
                hintText: 'What do you want to share?',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
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
                      });
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Post'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: TColor.primaryColor1,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainTabView()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'Community',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 20,
            letterSpacing: 1.1,
          ),
        ),
        // Removed actions to eliminate the top right three-dot menu
      ),
      backgroundColor: Colors.white,
      body: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final post = posts[index];
          final likedBy = (post['likedBy'] ?? <String>{}) as Set<String>;
          final isLiked = likedBy.contains(currentUserName);
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
                                    isLiked
                                        ? Icons.thumb_up_alt
                                        : Icons.thumb_up_alt_outlined,
                                    size: 16,
                                    color:
                                        isLiked
                                            ? TColor.primaryColor1
                                            : Colors.grey.shade600,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        backgroundColor: TColor.primaryColor1,
        tooltip: 'Add Post',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
