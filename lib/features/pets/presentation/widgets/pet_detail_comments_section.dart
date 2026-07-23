import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:voce_viu_meu_pet/core/theme/app_theme.dart';
import 'package:voce_viu_meu_pet/core/extensions/extensions.dart';
import 'package:voce_viu_meu_pet/features/comments/domain/entities/comment.dart';

class PetDetailCommentsSection extends StatefulWidget {
  final List<Comment> comments;
  final TextEditingController commentCtrl;
  final String currentUserId;
  final bool submittingComment;
  final VoidCallback onAddComment;
  final Function(String, bool) onTogglePinComment;
  final Function(String) onDeleteComment;

  const PetDetailCommentsSection({
    required this.comments,
    required this.commentCtrl,
    required this.currentUserId,
    required this.submittingComment,
    required this.onAddComment,
    required this.onTogglePinComment,
    required this.onDeleteComment,
  });

  @override
  State<PetDetailCommentsSection> createState() =>
      _PetDetailCommentsSectionState();
}

class _PetDetailCommentsSectionState extends State<PetDetailCommentsSection> {
  bool get _isOwner => false; // Will be passed from parent in future

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 16),

        // ── Comentários ─────────────────────────────
        Text('Comentários (${widget.comments.length})',
            style: context.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (widget.comments.isEmpty)
          Text('Seja o primeiro a comentar.',
              style: context.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecond))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.comments.length,
            itemBuilder: (context, i) {
              final comment = widget.comments[i];
              final isCommentAuthor = comment.authorId == widget.currentUserId;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: comment.isPinned
                      ? AppTheme.warning.withOpacity(0.06)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: comment.isPinned
                      ? Border.all(color: AppTheme.warning.withOpacity(0.3))
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      backgroundImage: comment.authorAvatarUrl != null
                          ? CachedNetworkImageProvider(comment.authorAvatarUrl!)
                          : null,
                      child: comment.authorAvatarUrl == null
                          ? const Text('👤', style: TextStyle(fontSize: 14))
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                comment.authorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              if (comment.isPinned) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.push_pin_rounded,
                                    size: 12, color: AppTheme.warning),
                              ],
                              const Spacer(),
                              Text(
                                comment.createdAt.timeAgo,
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comment.content,
                            style: context.textTheme.bodyMedium,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_isOwner)
                                IconButton(
                                  icon: Icon(
                                    comment.isPinned
                                        ? Icons.pin_drop_rounded
                                        : Icons.push_pin_outlined,
                                    size: 16,
                                    color: AppTheme.textSecond,
                                  ),
                                  onPressed: () =>
                                      widget.onTogglePinComment(comment.id, comment.isPinned),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              if (isCommentAuthor || _isOwner) ...[
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => widget.onDeleteComment(comment.id),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

        const SizedBox(height: 12),
        // Enviar comentário
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.commentCtrl,
                decoration: InputDecoration(
                  hintText: 'Escreva um comentário...',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  filled: true,
                  fillColor: context.isDark
                      ? AppTheme.cardDark
                      : const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (widget.submittingComment)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: const Icon(Icons.send_rounded, color: AppTheme.primary),
                onPressed: widget.onAddComment,
              ),
          ],
        ),
      ],
    );
  }
}
