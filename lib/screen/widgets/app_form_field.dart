import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wedding_gift_app/constants/app_theme.dart';

class AppFormDialog extends StatelessWidget {
  const AppFormDialog({
    super.key,
    required this.formKey,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isEditing,
    required this.isSaving,
    required this.submitLabel,
    required this.onCancel,
    required this.onSubmit,
    required this.children,
  });

  final GlobalKey<FormState> formKey;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isEditing;
  final bool isSaving;
  final String submitLabel;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final availableHeight = media.size.height - media.viewInsets.bottom - 32;
    final contentPadding = media.size.width < 600 ? 14.0 : 22.0;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      elevation: 12,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 920,
          maxHeight: availableHeight.clamp(240.0, media.size.height).toDouble(),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    contentPadding,
                    contentPadding,
                    contentPadding * 0.6,
                    16,
                  ),
                  child: AppFormHeader(
                    title: title,
                    subtitle: subtitle,
                    icon: icon,
                    isEditing: isEditing,
                    onClose: isSaving ? null : onCancel,
                  ),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(contentPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    contentPadding,
                    0,
                    contentPadding,
                    contentPadding,
                  ),
                  child: AppFormActions(
                    isSaving: isSaving,
                    submitLabel: submitLabel,
                    onCancel: onCancel,
                    onSubmit: onSubmit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppFormHeader extends StatelessWidget {
  const AppFormHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isEditing,
    required this.onClose,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isEditing;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.softPink,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: AppColors.rosePink),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isEditing
                          ? const Color(0xFFF3E8D2)
                          : AppColors.softPink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (isEditing ? 'edit_tag' : 'new_tag').tr,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isEditing
                            ? const Color(0xFF80663A)
                            : AppColors.rosePink,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'close'.tr,
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class AppFormSection extends StatelessWidget {
  const AppFormSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
      validator: validator,
    );
  }
}

class AppFormFieldRow extends StatelessWidget {
  const AppFormFieldRow({
    super.key,
    required this.first,
    required this.second,
    this.breakpoint = 560,
  });

  final Widget first;
  final Widget second;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(children: [first, const SizedBox(height: 12), second]);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 12),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class AppFormActions extends StatelessWidget {
  const AppFormActions({
    super.key,
    required this.isSaving,
    required this.submitLabel,
    required this.onCancel,
    required this.onSubmit,
  });

  final bool isSaving;
  final String submitLabel;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cancelButton = OutlinedButton.icon(
          onPressed: isSaving ? null : onCancel,
          icon: const Icon(Icons.close_rounded),
          label: Text('cancel'.tr),
        );
        final submitButton = FilledButton.icon(
          onPressed: isSaving ? null : onSubmit,
          icon: isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_rounded),
          label: Text(submitLabel),
        );

        if (constraints.maxWidth < 380) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 48, child: submitButton),
              const SizedBox(height: 8),
              SizedBox(height: 44, child: cancelButton),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            cancelButton,
            const SizedBox(width: 10),
            Flexible(child: SizedBox(height: 48, child: submitButton)),
          ],
        );
      },
    );
  }
}
