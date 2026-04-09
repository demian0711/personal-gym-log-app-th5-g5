import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/progress_photo_model.dart';
import '../providers/progress_photo_provider.dart';
import 'photo_detail_screen.dart';
import '../../../progress/presentation/widgets/photo_capture_widget.dart';

class ProgressPhotosScreen extends StatefulWidget {
  const ProgressPhotosScreen({super.key});

  @override
  State<ProgressPhotosScreen> createState() => _ProgressPhotosScreenState();
}

class _ProgressPhotosScreenState extends State<ProgressPhotosScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  /// Nhóm ảnh theo ngày
  Map<String, List<ProgressPhotoModel>> _groupPhotosByDate(
    List<ProgressPhotoModel> photos,
  ) {
    final grouped = <String, List<ProgressPhotoModel>>{};

    for (final photo in photos) {
      final dateKey = _getDateKey(photo.createdAt);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(photo);
    }

    return grouped;
  }

  /// Tạo khóa ngày dạng "dd/MM/yyyy"
  String _getDateKey(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Định dạng ngày đầy đủ với khôi phục tiếng Việt
  String _formatDateFull(DateTime date) {
    final formatter = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN');
    try {
      return formatter.format(date);
    } catch (_) {
      // Fallback nếu locale không khả dụng
      final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
      final dayName = days[(date.weekday - 1) % 7];
      return '$dayName, ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  /// Định dạng thời gian
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ảnh tiến trình')),
      body: Consumer<ProgressPhotoProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Section: Upload ảnh - Sử dụng PhotoCaptureWidget
              PhotoCaptureWidget(
                onPhotoUploaded: (message) {
                  // Optional: Xử lý sau khi upload thành công
                },
              ),
              const SizedBox(height: 20),

              // Section: Album ảnh theo ngày
              if (provider.photos.isEmpty && !provider.isUploading)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Chưa có ảnh nào',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Chụp ảnh đầu tiên để bắt đầu theo dõi tiến độ',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._buildPhotoAlbums(context, provider.photos, colorScheme),
            ],
          );
        },
      ),
    );
  }

  /// Xây dựng album ảnh được nhóm theo ngày
  List<Widget> _buildPhotoAlbums(
    BuildContext context,
    List<ProgressPhotoModel> photos,
    ColorScheme colorScheme,
  ) {
    final grouped = _groupPhotosByDate(photos);
    final sortedDates = grouped.keys.toList();

    return sortedDates.map((dateKey) {
      final photosInDate = grouped[dateKey]!;
      final firstPhoto = photosInDate.first;

      return Column(
        key: ValueKey(dateKey),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tiêu đề ngày
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDateFull(firstPhoto.createdAt),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${photosInDate.length} ảnh',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                ),
              ],
            ),
          ),

          // Photo List: Hiển thị ảnh dưới dạng list
          ...photosInDate.map(
            (photo) => _buildPhotoListItem(context, photo, colorScheme),
          ),

          const SizedBox(height: 24),
        ],
      );
    }).toList();
  }

  /// Xây dựng item trong list ảnh
  Widget _buildPhotoListItem(
    BuildContext context,
    ProgressPhotoModel photo,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PhotoDetailScreen(photo: photo),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Giờ chụp to
            Container(
              padding: const EdgeInsets.all(16),
              color: colorScheme.primaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatTime(photo.createdAt),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  if ((photo.note ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      photo.note!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Ảnh chụp
            Image.network(
              photo.imageUrl,
              fit: BoxFit.cover,
              height: 300, // Fixed height for a consistent look in the list
              width: double.infinity,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 300,
                  color: colorScheme.surfaceContainer,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: colorScheme.errorContainer.withOpacity(0.5),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Lỗi tải hình ảnh',
                          style: TextStyle(
                            color: colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sử dụng dữ liệu di động hoặc Wi-Fi để xem',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Thông tin chi tiết
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    context,
                    icon: Icons.flag_outlined,
                    label: 'Mục tiêu',
                    value: photo.goal,
                  ),
                  _buildInfoRow(
                    context,
                    icon: Icons.star_outline,
                    label: 'Tiêu chuẩn',
                    value: photo.standard,
                  ),
                  _buildInfoRow(
                    context,
                    icon: Icons.monitor_weight_outlined,
                    label: 'Cân nặng',
                    value: photo.weight != null ? '${photo.weight} kg' : null,
                  ),
                  _buildInfoRow(
                    context,
                    icon: Icons.note_outlined,
                    label: 'Ghi chú',
                    value: photo.note,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String? value,
  }) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
