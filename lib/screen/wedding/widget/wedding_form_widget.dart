import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:wedding_gift_app/models/wedding/wedding_model.dart';
import 'package:wedding_gift_app/services/storage_service.dart';
import 'package:wedding_gift_app/screen/widgets/app_form_field.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_image_picker.dart';

class WeddingFormWidget extends StatefulWidget {
  const WeddingFormWidget({
    super.key,
    this.initialWedding,
    required this.isEditing,
    required this.onSubmit,
    this.onCancel,
  });

  final WeddingModel? initialWedding;
  final bool isEditing;
  final Future<void> Function(WeddingModel) onSubmit;
  final VoidCallback? onCancel;

  @override
  State<WeddingFormWidget> createState() => _WeddingFormWidgetState();
}

class _WeddingFormWidgetState extends State<WeddingFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _imageFieldKey = GlobalKey<FormFieldState<String>>();
  late final TextEditingController _titleController;
  late final TextEditingController _groomController;
  late final TextEditingController _brideController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _locationController;
  late final TextEditingController _contactPhoneController;
  late final TextEditingController _descriptionController;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final wedding = widget.initialWedding;
    _titleController = TextEditingController(text: wedding?.weddingTitle ?? '');
    _groomController = TextEditingController(text: wedding?.groomName ?? '');
    _brideController = TextEditingController(text: wedding?.brideName ?? '');
    _dateController = TextEditingController(
      text: wedding == null
          ? ''
          : DateFormat('yyyy-MM-dd').format(wedding.weddingDate),
    );
    _timeController = TextEditingController(text: wedding?.weddingTime ?? '');
    _locationController = TextEditingController(
      text: wedding?.weddingLocation ?? '',
    );
    _contactPhoneController = TextEditingController(
      text: wedding?.contactPhone ?? '',
    );
    _descriptionController = TextEditingController(
      text: wedding?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _groomController.dispose();
    _brideController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _contactPhoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      formKey: _formKey,
      title: (widget.isEditing ? 'edit_wedding' : 'add_wedding').tr,
      subtitle: widget.isEditing
          ? 'wedding_edit_subtitle'.tr
          : 'wedding_create_subtitle'.tr,
      icon: Icons.cake_rounded,
      isEditing: widget.isEditing,
      isSaving: _isSubmitting,
      submitLabel: (widget.isEditing ? 'update_wedding' : 'save_wedding').tr,
      onCancel: _cancel,
      onSubmit: _submit,
      children: [
        AppFormSection(
          title: 'basic_information'.tr,
          subtitle: 'wedding_identity_subtitle'.tr,
          children: [
            AppFormField(
              controller: _titleController,
              labelText: 'wedding_title'.tr,
              hintText: 'wedding_title_hint'.tr,
              prefixIcon: Icons.title_rounded,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            AppFormFieldRow(
              first: AppFormField(
                controller: _groomController,
                labelText: '${'groom_name'.tr} *',
                prefixIcon: Icons.person_outline_rounded,
                textCapitalization: TextCapitalization.words,
                validator: _requiredValidator('required_groom_name'.tr),
              ),
              second: AppFormField(
                controller: _brideController,
                labelText: '${'bride_name'.tr} *',
                prefixIcon: Icons.person_2_outlined,
                textCapitalization: TextCapitalization.words,
                validator: _requiredValidator('required_bride_name'.tr),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppFormSection(
          title: 'wedding_details'.tr,
          subtitle: 'wedding_details_subtitle'.tr,
          children: [
            AppFormFieldRow(
              first: AppFormField(
                controller: _dateController,
                labelText: '${'wedding_date'.tr} *',
                prefixIcon: Icons.calendar_month_rounded,
                readOnly: true,
                onTap: _pickDate,
                validator: _requiredValidator('required_date'.tr),
              ),
              second: AppFormField(
                controller: _timeController,
                labelText: 'wedding_time'.tr,
                hintText: 'wedding_time_hint'.tr,
                prefixIcon: Icons.access_time_rounded,
                keyboardType: TextInputType.datetime,
              ),
            ),
            const SizedBox(height: 12),
            AppFormField(
              controller: _locationController,
              labelText: '${'location'.tr} *',
              hintText: 'location_hint'.tr,
              prefixIcon: Icons.location_on_outlined,
              textCapitalization: TextCapitalization.words,
              validator: _requiredValidator('required_wedding_location'.tr),
            ),
            const SizedBox(height: 12),
            AppFormField(
              controller: _contactPhoneController,
              labelText: '${'contact_phone'.tr} *',
              hintText: 'contact_phone_hint'.tr,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: _requiredValidator('required_contact_phone'.tr),
            ),
            const SizedBox(height: 12),
            AppFormField(
              controller: _descriptionController,
              labelText: '${'notes'.tr} *',
              hintText: 'wedding_notes_hint'.tr,
              prefixIcon: Icons.notes_rounded,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              validator: _requiredValidator('required_wedding_notes'.tr),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppFormSection(
          title: '${'wedding_image'.tr} *',
          subtitle: 'wedding_image_subtitle'.tr,
          children: [
            FormField<String>(
              key: _imageFieldKey,
              initialValue: widget.initialWedding?.coverImageUrl ?? '',
              validator: (value) => value == null || value.isEmpty
                  ? 'required_wedding_image'.tr
                  : null,
              builder: (fieldState) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WeddingImagePicker(
                    imageUrl: widget.initialWedding?.coverImageUrl ?? '',
                    selectedImage: _selectedImage,
                    selectedImageBytes: _selectedImageBytes,
                    isBusy: _isSubmitting,
                    onPick: () => _pickImage(fieldState),
                    onClear: () {
                      setState(() {
                        _selectedImage = null;
                        _selectedImageBytes = null;
                      });
                      fieldState.didChange(
                        widget.initialWedding?.coverImageUrl ?? '',
                      );
                      fieldState.validate();
                    },
                  ),
                  if (fieldState.errorText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      fieldState.errorText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? Function(String?) _requiredValidator(String message) {
    return (value) => value == null || value.trim().isEmpty ? message : null;
  }

  void _cancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Get.back();
    }
  }

  Future<void> _pickImage(FormFieldState<String> imageField) async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedImage = image;
        _selectedImageBytes = bytes;
      });
      imageField.didChange(image.path);
      imageField.validate();
    } catch (error, stackTrace) {
      debugPrint('Unable to select wedding image: $error\n$stackTrace');
      Get.snackbar(
        'unable_select_image'.tr,
        'image_selection_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _pickDate() async {
    final currentDate = DateTime.tryParse(_dateController.text);
    final selected = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(selected);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedDate = DateTime.tryParse(_dateController.text);
    if (selectedDate == null) {
      Get.snackbar(
        'invalid_date'.tr,
        'select_wedding_date_before_saving'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    String? uploadedStoragePath;

    try {
      var coverImageUrl = widget.initialWedding?.coverImageUrl ?? '';
      if (_selectedImage != null) {
        final uploadResult = await StorageService().uploadImage(
          file: _selectedImage!,
          folder: 'weddings',
        );
        coverImageUrl = uploadResult['imageUrl']!;
        uploadedStoragePath = uploadResult['storagePath'];
      }

      final model =
          (widget.initialWedding ??
                  WeddingModel(
                    id: '',
                    userId: '',
                    weddingTitle: '',
                    groomName: '',
                    brideName: '',
                    weddingDate: selectedDate,
                  ))
              .copyWith(
                id: widget.initialWedding?.id ?? '',
                userId: widget.initialWedding?.userId ?? '',
                weddingTitle: _titleController.text.trim(),
                groomName: _groomController.text.trim(),
                brideName: _brideController.text.trim(),
                weddingDate: selectedDate,
                weddingTime: _timeController.text.trim(),
                weddingLocation: _locationController.text.trim(),
                contactPhone: _contactPhoneController.text.trim(),
                description: _descriptionController.text.trim(),
                coverImageUrl: coverImageUrl,
              );

      await widget.onSubmit(model);
    } catch (error, stackTrace) {
      debugPrint('Unable to save wedding: $error\n$stackTrace');
      // A timed-out Firestore write may still complete in the background; keep
      // the uploaded photo so a successful late write won't point to a deleted file.
      if (uploadedStoragePath != null && error is! TimeoutException) {
        try {
          await StorageService().deleteImage(uploadedStoragePath);
        } catch (cleanupError, cleanupStackTrace) {
          debugPrint(
            'Unable to clean up uploaded wedding image: '
            '$cleanupError\n$cleanupStackTrace',
          );
          Get.snackbar(
            'image_cleanup_failed'.tr,
            'image_cleanup_failed_message'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
      Get.snackbar(
        'unable_save_wedding'.tr,
        error is TimeoutException
            ? 'wedding_connection_unavailable'.tr
            : 'wedding_save_failed_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
