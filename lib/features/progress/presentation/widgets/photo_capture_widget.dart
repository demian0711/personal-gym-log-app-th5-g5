import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../../features/progress_photos/presentation/providers/progress_photo_provider.dart';

class PhotoCaptureWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String cameraButtonLabel;
  final String galleryButtonLabel;
  final String noteLabel;
  final String noteHint;
  final Function(String? message)? onPhotoUploaded;
  final Function(String error)? onError;
  final bool showImagePreview;

  const PhotoCaptureWidget({
    super.key,
    this.title = 'Thêm ảnh tiến độ',
    this.subtitle =
        'Theo dõi sự thay đổi cơ thể của bạn qua từng ngày luyện tập',
    this.cameraButtonLabel = 'Chụp ảnh',
    this.galleryButtonLabel = 'Thư viện',
    this.noteLabel = 'Ghi chú (tuỳ chọn)',
    this.noteHint = 'VD: Tăng cơ bắp, giảm mỡ, v.v',
    this.onPhotoUploaded,
    this.onError,
    this.showImagePreview = false,
  });

  @override
  State<PhotoCaptureWidget> createState() => _PhotoCaptureWidgetState();
}

class _PhotoCaptureWidgetState extends State<PhotoCaptureWidget> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _standardController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  XFile? _selectedImage;

  @override
  void dispose() {
    _noteController.dispose();
    _goalController.dispose();
    _standardController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload(BuildContext context, ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);

    if (file == null) {
      return;
    }

    if (widget.showImagePreview) {
      setState(() {
        _selectedImage = file;
      });
    }

    final bytes = await file.readAsBytes();
    if (!mounted) {
      return;
    }

    final message = await context.read<ProgressPhotoProvider>().uploadPhoto(
      imageBytes: bytes,
      fileName: file.name,
      goal: _goalController.text,
      standard: _standardController.text,
      weight: double.tryParse(_weightController.text),
      note: _noteController.text,
    );

    if (!mounted) {
      return;
    }

    if (message != null) {
      widget.onError?.call(message);
    } else {
      widget.onPhotoUploaded?.call(message);
      _noteController.clear();
      _goalController.clear();
      _standardController.clear();
      _weightController.clear();
      if (widget.showImagePreview) {
        setState(() {
          _selectedImage = null;
        });
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'Upload ảnh thành công.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<ProgressPhotoProvider>(
      builder: (context, provider, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                if (widget.showImagePreview && _selectedImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!.path as dynamic,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _goalController,
                  decoration: const InputDecoration(
                    labelText: 'Mục tiêu',
                    hintText: 'VD: Tăng cơ, giảm mỡ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _standardController,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu chuẩn',
                    hintText: 'VD: Body fat 15%',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.star_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Cân nặng (kg)',
                    hintText: 'VD: 70.5',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: widget.noteLabel,
                    hintText: widget.noteHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.note_outlined),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: provider.isUploading
                            ? null
                            : () => _pickAndUpload(context, ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: Text(widget.cameraButtonLabel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: provider.isUploading
                            ? null
                            : () =>
                                  _pickAndUpload(context, ImageSource.gallery),
                        icon: const Icon(Icons.image_outlined),
                        label: Text(widget.galleryButtonLabel),
                      ),
                    ),
                  ],
                ),
                if (provider.isUploading)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                if ((provider.errorMessage ?? '').isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            provider.errorMessage!,
                            style: TextStyle(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
