import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app/core/design_system/app_button.dart';
import 'package:rivo_app/core/design_system/app_text_field.dart';
import 'package:rivo_app/core/widgets/media_picker_widget.dart';
import 'package:rivo_app/features/post/presentation/viewmodels/upload_post_viewmodel.dart';
import 'package:rivo_app/features/post/presentation/widgets/category_dropdown.dart';
import 'package:rivo_app/features/post/presentation/widgets/tags_input_field.dart';
import 'package:rivo_app/core/localization/generated/app_localizations.dart';
import 'package:rivo_app/core/error_handling/app_exception.dart';
import 'package:go_router/go_router.dart';

class PostUploadScreen extends ConsumerStatefulWidget {
  const PostUploadScreen({super.key});

  @override
  ConsumerState<PostUploadScreen> createState() => _PostUploadScreenState();
}

class _PostUploadScreenState extends ConsumerState<PostUploadScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _chestController;
  late final TextEditingController _waistController;
  late final TextEditingController _lengthController;
  late final TextEditingController _captionController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(uploadPostViewModelProvider);
    _titleController = TextEditingController(text: state.title);
    _descriptionController = TextEditingController(text: state.description);
    _priceController = TextEditingController(text: state.price?.toString() ?? '');
    _chestController = TextEditingController(text: state.chest?.toString() ?? '');
    _waistController = TextEditingController(text: state.waist?.toString() ?? '');
    _lengthController = TextEditingController(text: state.length?.toString() ?? '');
    _captionController = TextEditingController(text: state.caption);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _lengthController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final viewModel = ref.read(uploadPostViewModelProvider.notifier);

    try {
      await viewModel.submit();
      if (!mounted) return;
      context.go('/home');
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadPostViewModelProvider);
    final viewModel = ref.read(uploadPostViewModelProvider.notifier);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.uploadPost),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RepaintBoundary(
  child: MediaPickerWidget(
    onSelected: viewModel.setMedia,
  ),
),

            const SizedBox(height: 16),
            const CategoryDropdown(),
            const SizedBox(height: 12),
            const TagsInputField(),
            const SizedBox(height: 12),
            AppTextField(
              controller: _titleController,
              hintText: localizations.title,
              onChanged: viewModel.setTitle,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _descriptionController,
              hintText: localizations.description,
              maxLines: 3,
              onChanged: viewModel.setDescription,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _priceController,
              hintText: localizations.price,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final price = double.tryParse(value);
                viewModel.setPrice(price);
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _chestController,
              hintText: localizations.chestMeasurementLabel,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final chest = double.tryParse(value);
                viewModel.setChest(chest);
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _waistController,
              hintText: localizations.waistMeasurementLabel,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final waist = double.tryParse(value);
                viewModel.setWaist(waist);
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _lengthController,
              hintText: localizations.lengthMeasurementLabel,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final length = double.tryParse(value);
                viewModel.setLength(length);
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _captionController,
              hintText: localizations.captionLabel,
              maxLines: 3,
              maxLength: 2200,
              onChanged: viewModel.setCaption,
            ),
            const SizedBox(height: 24),
            if (state.isSubmitting)
              const CircularProgressIndicator()
            else
              AppButton(
                onPressed: state.isValid ? _submitForm : null,
                text: localizations.upload,
              ),
          ],
        ),
      ),
    );
  }
}
