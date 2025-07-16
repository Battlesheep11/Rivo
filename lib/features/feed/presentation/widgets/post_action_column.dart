import 'package:flutter/material.dart';
import 'action_glass_button.dart';

/// The right-side vertical column of action buttons for a feed post.
class PostActionColumn extends StatelessWidget {
  final bool isLikedByMe;
  final int likeCount;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onAdd;
  final String? avatarUrl;
  
  const PostActionColumn({
    super.key,
    required this.isLikedByMe,
    required this.likeCount,
    required this.onLike,
    required this.onComment,
    required this.onAdd,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Like button: uses red icon if liked, otherwise default ActionGlassButton color
          ActionGlassButton(
            icon: isLikedByMe ? Icons.favorite : Icons.favorite_border,
            iconColor: isLikedByMe ? Colors.red : Colors.white,
            backgroundColor: Colors.white, // matches ActionGlassButton default
            count: likeCount,
            onPressed: onLike,
          ),
          
          const SizedBox(height: 12),
          
          // Comment button: uses ActionGlassButton defaults
          // TODO(comments): Implement comment count functionality - currently using placeholder value of 0
          ActionGlassButton(
            icon: Icons.comment_bank_outlined,
            onPressed: onComment,
          ),
          
          const SizedBox(height: 12),
          
          // Save button: uses ActionGlassButton defaults
          ActionGlassButton(
            icon: Icons.save,
            onPressed: onAdd,
          ),
          
          const SizedBox(height: 16),
          
          // User avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.1).round()),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[200],
              backgroundImage: avatarUrl != null && avatarUrl!.startsWith('http')
                  ? NetworkImage(avatarUrl!) as ImageProvider
                  : null,
              child: (avatarUrl == null || !avatarUrl!.startsWith('http'))
                  ? const Icon(Icons.person, size: 24, color: Colors.grey)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
