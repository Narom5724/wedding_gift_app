import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wedding_gift_app/models/gift/gift_model.dart';
import 'package:wedding_gift_app/models/guest/guest_model.dart';
import 'package:wedding_gift_app/models/wedding/wedding_model.dart';
import 'package:wedding_gift_app/services/guest_service.dart';
import 'package:wedding_gift_app/services/wedding_service.dart';
import 'package:wedding_gift_app/utils/currency_helper.dart';
import 'package:wedding_gift_app/screen/widgets/app_form_field.dart';

class GiftFormWidget extends StatefulWidget {
  const GiftFormWidget({
    super.key,
    this.initialGift,
    required this.isEditing,
    required this.onSubmit,
    this.onCancel,
  });

  final GiftModel? initialGift;
  final bool isEditing;
  final Future<void> Function(GiftModel) onSubmit;
  final VoidCallback? onCancel;

  @override
  State<GiftFormWidget> createState() => _GiftFormWidgetState();
}

class _GiftFormWidgetState extends State<GiftFormWidget> {
  static const _paymentMethods = ['Cash', 'ABA', 'ACLEDA'];
  static const _otherPaymentMethod = 'Other';

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _paymentMethodController;
  late final TextEditingController _notesController;
  late final TextEditingController _dateController;
  final _weddingService = WeddingService();
  final _guestService = GuestService();
  List<WeddingModel> _weddings = [];
  List<GuestModel> _guests = [];
  String? _selectedWeddingId;
  String? _selectedGuestId;
  String _selectedCurrency = CurrencyHelper.usd;
  late String _selectedPaymentMethod;
  String? _recordsError;
  bool _isLoadingRecords = true;
  bool _isSubmitting = false;
  int _guestLoadRequest = 0;

  @override
  void initState() {
    super.initState();
    final gift = widget.initialGift;
    _selectedWeddingId = gift?.weddingId;
    _selectedGuestId = gift?.guestId;
    _amountController = TextEditingController(
      text: gift == null ? '' : gift.amount.toString(),
    );
    final savedCurrency = gift?.currency.toUpperCase();
    _selectedCurrency =
        savedCurrency == CurrencyHelper.khr || savedCurrency == 'KH'
        ? CurrencyHelper.khr
        : CurrencyHelper.usd;
    _paymentMethodController = TextEditingController(
      text: gift?.paymentMethod ?? 'Cash',
    );
    _selectedPaymentMethod =
        _paymentMethods.contains(_paymentMethodController.text)
        ? _paymentMethodController.text
        : _otherPaymentMethod;
    _notesController = TextEditingController(text: gift?.notes ?? '');
    _dateController = TextEditingController(
      text: DateFormat(
        'yyyy-MM-dd',
      ).format(gift?.receivedDate ?? DateTime.now()),
    );
    _loadWeddings();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _paymentMethodController.dispose();
    _notesController.dispose();
    _dateController.dispose();
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
          _selectedGuestId = null;
        }
      });
      if (_selectedWeddingId != null) {
        await _loadGuests(_selectedWeddingId!);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _recordsError = error.toString());
    } finally {
      if (mounted) setState(() => _isLoadingRecords = false);
    }
  }

  Future<void> _loadGuests(String weddingId, {int? requestId}) async {
    final activeRequest = requestId ?? ++_guestLoadRequest;
    try {
      final guests = await _guestService.fetchGuests(weddingId: weddingId);
      if (!mounted || activeRequest != _guestLoadRequest) return;
      setState(() {
        _guests = guests;
        if (!_guests.any((guest) => guest.id == _selectedGuestId)) {
          _selectedGuestId = null;
        }
      });
    } catch (error) {
      if (!mounted || activeRequest != _guestLoadRequest) return;
      setState(() {
        _guests = [];
        _selectedGuestId = null;
        _recordsError = error.toString();
      });
    }
  }

  Future<void> _selectWedding(String? weddingId) async {
    final requestId = ++_guestLoadRequest;
    setState(() {
      _selectedWeddingId = weddingId;
      _selectedGuestId = null;
      _guests = [];
      _recordsError = null;
      _isLoadingRecords = weddingId != null;
    });
    if (weddingId != null) {
      await _loadGuests(weddingId, requestId: requestId);
      if (mounted && requestId == _guestLoadRequest) {
        setState(() => _isLoadingRecords = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      formKey: _formKey,
      title: (widget.isEditing ? 'edit_gift' : 'add_gift').tr,
      subtitle: widget.isEditing
          ? 'gift_edit_subtitle'.tr
          : 'gift_create_subtitle'.tr,
      icon: Icons.redeem_rounded,
      isEditing: widget.isEditing,
      isSaving: _isSubmitting,
      submitLabel: (widget.isEditing ? 'update_gift' : 'save_gift').tr,
      onCancel: _cancel,
      onSubmit: _submit,
      children: [
        AppFormSection(
          title: 'linked_records'.tr,
          subtitle: 'linked_records_subtitle'.tr,
          children: [
            AppFormFieldRow(
              first: DropdownButtonFormField<String>(
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
                  _isLoadingRecords && _weddings.isEmpty
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
                onChanged: _weddings.isEmpty ? null : _selectWedding,
                validator: (value) =>
                    value == null ? 'please_select_wedding'.tr : null,
              ),
              second: DropdownButtonFormField<String>(
                key: ValueKey('$_selectedWeddingId:${_guests.length}'),
                initialValue:
                    _guests.any((guest) => guest.id == _selectedGuestId)
                    ? _selectedGuestId
                    : null,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'guest'.tr,
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                hint: Text(
                  _selectedWeddingId == null
                      ? 'select_wedding_first'.tr
                      : _isLoadingRecords
                      ? 'loading_guests'.tr
                      : 'select_guest'.tr,
                ),
                items: _guests
                    .map(
                      (guest) => DropdownMenuItem(
                        value: guest.id,
                        child: Text(
                          guest.fullName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _selectedWeddingId == null || _isLoadingRecords
                    ? null
                    : (value) => setState(() => _selectedGuestId = value),
                validator: (value) =>
                    value == null ? 'please_select_guest'.tr : null,
              ),
            ),
            if (_recordsError != null) ...[
              const SizedBox(height: 8),
              Text(
                'unable_load_linked_records'.trParams({
                  'error': _recordsError!,
                }),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ] else if (!_isLoadingRecords && _weddings.isEmpty) ...[
              const SizedBox(height: 8),
              Text('create_wedding_before_gift'.tr),
            ] else if (_selectedWeddingId != null &&
                !_isLoadingRecords &&
                _guests.isEmpty) ...[
              const SizedBox(height: 8),
              Text('add_guest_before_gift'.tr),
            ],
          ],
        ),
        const SizedBox(height: 14),
        AppFormSection(
          title: 'gift_details'.tr,
          subtitle: 'gift_details_subtitle'.tr,
          children: [
            AppFormFieldRow(
              first: AppFormField(
                controller: _amountController,
                labelText: 'amount'.tr,
                hintText: 'amount_hint'.tr,
                prefixIcon: Icons.payments_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null || amount <= 0) {
                    return 'invalid_amount'.tr;
                  }
                  return null;
                },
              ),
              second: DropdownButtonFormField<String>(
                initialValue: _selectedCurrency,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'currency'.tr,
                  prefixIcon: const Icon(Icons.currency_exchange_rounded),
                ),
                items: const [
                  DropdownMenuItem(
                    value: CurrencyHelper.usd,
                    child: Text('USD (\$)'),
                  ),
                  DropdownMenuItem(
                    value: CurrencyHelper.khr,
                    child: Text('KHR (៛)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCurrency = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            AppFormFieldRow(
              first: DropdownButtonFormField<String>(
                initialValue: _selectedPaymentMethod,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'received_by'.tr,
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                ),
                items: [
                  ..._paymentMethods.map(
                    (method) =>
                        DropdownMenuItem(value: method, child: Text(method)),
                  ),
                  DropdownMenuItem(
                    value: _otherPaymentMethod,
                    child: Text('other'.tr),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    if (value != _otherPaymentMethod) {
                      _paymentMethodController.text = value;
                    } else if (_selectedPaymentMethod != _otherPaymentMethod) {
                      _paymentMethodController.clear();
                    }
                    _selectedPaymentMethod = value;
                  });
                },
              ),
              second: AppFormField(
                controller: _dateController,
                labelText: 'gift_date'.tr,
                prefixIcon: Icons.calendar_month_rounded,
                readOnly: true,
                onTap: _pickDate,
                validator: _requiredValidator('required_gift_date'.tr),
              ),
            ),
            if (_selectedPaymentMethod == _otherPaymentMethod) ...[
              const SizedBox(height: 12),
              AppFormField(
                controller: _paymentMethodController,
                labelText: 'received_by'.tr,
                hintText: 'payment_hint'.tr,
                prefixIcon: Icons.edit_outlined,
                textCapitalization: TextCapitalization.words,
                validator: _requiredValidator('required_payment_method'.tr),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        AppFormSection(
          title: 'additional_notes'.tr,
          subtitle: 'gift_notes_subtitle'.tr,
          children: [
            AppFormField(
              controller: _notesController,
              labelText: 'notes'.tr,
              hintText: 'gift_notes_hint'.tr,
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

  Future<void> _pickDate() async {
    final currentDate = DateTime.tryParse(_dateController.text);
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: currentDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(selected);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final model =
          (widget.initialGift ??
                  GiftModel(
                    id: '',
                    userId: '',
                    weddingId: '',
                    guestId: '',
                    amount: 0,
                    currency: 'USD',
                    receivedDate: DateTime.now(),
                  ))
              .copyWith(
                id: widget.initialGift?.id ?? '',
                userId: widget.initialGift?.userId ?? '',
                weddingId: _selectedWeddingId ?? '',
                guestId: _selectedGuestId ?? '',
                amount: double.tryParse(_amountController.text.trim()) ?? 0,
                currency: _selectedCurrency,
                paymentMethod: _paymentMethodController.text.trim(),
                receivedDate: DateTime.parse(_dateController.text),
                notes: _notesController.text.trim(),
              );

      await widget.onSubmit(model);
    } catch (error) {
      Get.snackbar(
        'unable_save_gift'.tr,
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
