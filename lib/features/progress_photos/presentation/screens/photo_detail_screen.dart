import 'package:flutter/material.dart';

import '../../data/models/progress_photo_model.dart';

class PhotoDetailScreen extends StatelessWidget {
  final ProgressPhotoModel photo;

  const PhotoDetailScreen({super.key, required this.photo});

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          '${photo.createdAt.day}/${photo.createdAt.month}/${photo.createdAt.year}',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Hero(
                tag: photo.id,
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image.network(
                    photo.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) {
                        return child;
                      }
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                    errorBuilder: (_, __, ___) {
                      return const Text(
                        'Không thể tải ảnh.',
                        style: TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: const Color.fromARGB(200, 0, 0, 0),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateTime(photo.createdAt),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if ((photo.note ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Ghi chú:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    photo.note!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
