import 'package:flutter/material.dart';
import 'action_glass_button.dart';

class PostActionColumn extends StatelessWidget {
  final bool isLikedByMe;
  final int likeCount;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onAdd;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  
  const PostActionColumn({
    super.key,
    required this.isLikedByMe,
    required this.likeCount,
    required this.onLike,
    required this.onComment,
    required this.onAdd,
    this.avatarUrl,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Like button
          ActionGlassButton(
            icon: isLikedByMe ? Icons.favorite : Icons.favorite_border,
            count: likeCount,
            onPressed: onLike,
            isActive: isLikedByMe,
          ),
          // Save button
          ActionGlassButton(
            icon: Icons.bookmark_border_rounded,
            onPressed: onAdd,
          ),
          
          const SizedBox(height: 16),
          
          // User avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withAlpha(200),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: avatarUrl != null && avatarUrl!.startsWith('http')
                  ? Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 24, color: Colors.grey),
    );
  }
}