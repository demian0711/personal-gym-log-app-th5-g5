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
        title: const Text('Chi tiết ảnh'),
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
                    cacheWidth: 1000, // Optimize memory for large images
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) {
                        return child;
                      }
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Đang tải: ${progress.expectedTotalBytes != null ? ((progress.cumulativeBytesLoaded / progress.expectedTotalBytes!) * 100).toStringAsFixed(0) : '...'}%',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white70,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Không thể hiển thị ảnh',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Đã xảy ra lỗi khi tải hình ảnh từ máy chủ. Vui lòng kiểm tra kết nối mạng hoặc thử lại sau.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Simple way to retry: mark for rebuild
                                (context as Element).markNeedsBuild();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Thử lại'),
                            ),
                          ],
                        ),
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
                _buildInfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Thời gian',
                  value: _formatDateTime(photo.createdAt),
                ),
                _buildInfoRow(
                  icon: Icons.flag_outlined,
                  label: 'Mục tiêu',
                  value: photo.goal,
                ),
                _buildInfoRow(
                  icon: Icons.star_outline,
                  label: 'Tiêu chuẩn',
                  value: photo.standard,
                ),
                _buildInfoRow(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Cân nặng',
                  value: photo.weight != null ? '${photo.weight} kg' : null,
                ),
                _buildInfoRow(
                  icon: Icons.note_outlined,
                  label: 'Ghi chú',
                  value: photo.note,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String? value,
  }) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
