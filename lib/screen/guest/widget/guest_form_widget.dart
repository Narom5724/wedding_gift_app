import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/guest/guest_model.dart';
import '../../../models/wedding/wedding_model.dart';
import '../../../services/wedding_service.dart';
import '../../widgets/app_form_field.dart';

class GuestFormWidget extends StatefulWidget {
  const GuestFormWidget({
    super.key,
    this.initialGuest,
    required this.isEditing,
    required this.onSubmit,
    this.onCancel,
  });

  final GuestModel? initialGuest;
  final bool isEditing;
  final Future<void> Function(GuestModel) onSubmit;
  final VoidCallback? onCancel;

  @override
  State<GuestFormWidget> createState() => _GuestFormWidgetState();
}

class _GuestFormWidgetState extends State<GuestFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _genderController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _relationshipController;
  late final TextEditingController _notesController;
  final _weddingService = WeddingService();
  List<WeddingModel> _weddings = [];
  String? _selectedWeddingId;
  String? _recordsError;
  bool _isLoadingWeddings = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final guest = widget.initialGuest;
    _selectedWeddingId = guest?.weddingId;
    _fullNameController = TextEditingController(text: guest?.fullName ?? '');
    _genderController = TextEditingController(text: guest?.gender ?? '');
    _phoneController = TextEditingController(text: guest?.phone ?? '');
    _addressController = TextEditingController(text: guest?.address ?? '');
    _relationshipController = TextEditingController(
      text: guest?.relationship ?? '',
    );
    _notesController = TextEditingController(text: guest?.notes ?? '');
    _loadWeddings();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _genderController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _relationshipController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadWeddings() async {
    try {
      final weddings = await _weddingService.fetchWeddings();
      if (!mounted) return;
      setState(() {
        _weddings = weddings;
        if (!_weddings.any((wedding) => wedding.id == _selectedWeddingId)) {
          _selectedWeddingId = null;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _recordsError = error.toString());
    } finally {
      if (mounted) setState(() => _isLoadingWeddings = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      formKey: _formKey,
      title: (widget.isEditing ? 'edit_guest' : 'add_guest').tr,
      subtitle: widget.isEditing
          ? 'guest_edit_subtitle'.tr
          : 'guest_create_subtitle'.tr,
      icon: Icons.person_add_alt_1_rounded,
      isEditing: widget.isEditing,
      isSaving: _isSubmitting,
      submitLabel: (widget.isEditing ? 'update_guest' : 'save_guest').tr,
      onCancel: _cancel,
      onSubmit: _submit,
      children: [
        AppFormSection(
          title: 'guest_information'.tr,
          subtitle: 'guest_information_subtitle'.tr,
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey(_weddings.length),
              initialValue:
                  _weddings.any((wedding) => wedding.id == _selectedWeddingId)
                  ? _selectedWeddingId
                  : null,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'wedding'.tr,
                prefixIcon: Icon(Icons.favorite_border_rounded),
              ),
              hint: Text(
                _isLoadingWeddings
                    ? 'loading_weddings'.tr
                    : 'select_wedding'.tr,
              ),
              items: _weddings
                  .map(
                    (wedding) => DropdownMenuItem(
                      value: wedding.id,
                      child: Text(
                        wedding.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _isLoadingWeddings || _weddings.isEmpty
                  ? null
                  : (value) => setState(() => _selectedWeddingId = value),
              validator: (value) =>
                  value == null ? 'please_select_wedding'.tr : null,
            ),
            if (_recordsError != null) ...[
              const SizedBox(height: 8),
              Text(
                'unable_load_weddings'.trParams({'error': _recordsError!}),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ] else if (!_isLoadingWeddings && _weddings.isEmpty) ...[
              const SizedBox(height: 8),
              Text('create_wedding_before_guest'.tr),
            ],
            const SizedBox(height: 12),
            AppFormField(
              controller: _fullNameController,
              labelText: 'full_name'.tr,
              hintText: 'guest_name_hint'.tr,
              prefixIcon: Icons.person_outline_rounded,
              textCapitalization: TextCapitalization.words,
              validator: _requiredValidator('required_guest_name'.tr),
            ),
            const SizedBox(height: 12),
            AppFormFieldRow(
              first: AppFormField(
                controller: _genderController,
                labelText: 'gender'.tr,
                prefixIcon: Icons.wc_rounded,
                textCapitalization: TextCapitalization.words,
              ),
              second: AppFormField(
                controller: _phoneController,
                labelText: 'phone_number'.tr,
                hintText: 'contact_number'.tr,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppFormSection(
          title: 'relationship_notes'.tr,
          subtitle: 'relationship_subtitle'.tr,
          children: [
            AppFormField(
              controller: _relationshipController,
              labelText: 'relationship'.tr,
              hintText: 'relationship_hint'.tr,
              prefixIcon: Icons.diversity_3_rounded,
              textCapitalization: TextCapitalization.sentences,
              validator: _requiredValidator('required_relationship'.tr),
            ),
            const SizedBox(height: 12),
            AppFormField(
              controller: _addressController,
              labelText: 'address'.tr,
              hintText: 'address_hint'.tr,
              prefixIcon: Icons.location_on_outlined,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            AppFormField(
              controller: _notesController,
              labelText: 'additional_notes'.tr,
              hintText: 'guest_notes_hint'.tr,
              prefixIcon: Icons.notes_rounded,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final model =
          (widget.initialGuest ??
                  GuestModel(
                    id: '',
                    userId: '',
                    weddingId: '',
                    fullName: '',
                    phone: '',
                    relationship: '',
                  ))
              .copyWith(
                id: widget.initialGuest?.id ?? '',
                userId: widget.initialGuest?.userId ?? '',
                weddingId: _selectedWeddingId ?? '',
                fullName: _fullNameController.text.trim(),
                gender: _genderController.text.trim(),
                phone: _phoneController.text.trim(),
                address: _addressController.text.trim(),
                relationship: _relationshipController.text.trim(),
                notes: _notesController.text.trim(),
              );

      await widget.onSubmit(model);
    } catch (error) {
      Get.snackbar(
        'unable_save_guest'.tr,
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
