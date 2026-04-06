import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/models/progress_photo_model.dart';
import '../providers/progress_photos_provider.dart';
import 'photo_detail_screen.dart';

class ProgressPhotosScreen extends StatelessWidget {
  const ProgressPhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress Photos')),
      body: Consumer<ProgressPhotosProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && !provider.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(provider.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: provider.loadPhotos,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!provider.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Chưa có ảnh progress. Nhấn "Add Photo" để bắt đầu.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final photos = provider.photos;

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 84),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  final previous = index == 0 ? null : photos[index - 1];
                  final showDateHeader =
                      previous == null ||
                      !_isSameDate(previous.createdAt, photo.createdAt);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showDateHeader)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, bottom: 8),
                          child: Text(
                            _formatFullDate(photo.createdAt),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      _TimelinePhotoTile(photo: photo),
                    ],
                  );
                },
              ),
              if (provider.isUploading)
                Container(
                  color: Colors.black.withValues(alpha: 0.18),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<ProgressPhotosProvider>(
        builder: (context, provider, _) {
          return FloatingActionButton.extended(
            onPressed: provider.isUploading
                ? null
                : () => _showAddPhotoOptions(context, provider),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Add Photo'),
          );
        },
      ),
    );
  }

  Future<void> _showAddPhotoOptions(
    BuildContext context,
    ProgressPhotosProvider provider,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Chụp ảnh'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await provider.addPhoto(ImageSource.camera);
                  if (context.mounted && provider.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(provider.errorMessage!)),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Chọn từ gallery'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await provider.addPhoto(ImageSource.gallery);
                  if (context.mounted && provider.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(provider.errorMessage!)),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimelinePhotoTile extends StatelessWidget {
  final ProgressPhotoModel photo;

  const _TimelinePhotoTile({required this.photo});

  @override
  Widget build(BuildContext context) {
    final heroTag = 'progress_photo_${photo.id}';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  PhotoDetailScreen(imageUrl: photo.imageUrl, heroTag: heroTag),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    photo.imageUrl,
                    width: 86,
                    height: 86,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 86,
                      height: 86,
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.broken_image_outlined),
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
                      'Progress Photo',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Thời gian: ${_formatTime(photo.createdAt)}'),
                  ],
                ),
              ),
              const Icon(Icons.open_in_full_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatFullDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year;
  return '$day/$month/$year';
}

String _formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
