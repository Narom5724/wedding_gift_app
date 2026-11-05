import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wedding_gift_app/controller/auth_controller.dart';
import 'package:wedding_gift_app/controller/setting_controller.dart';

class ProfileScreen extends GetView<AuthController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingController>();

    return Scaffold(
      appBar: AppBar(title: Text('profile'.tr)),
      body: Obx(() {
        final name = controller.userName.value;
        final email = controller.userEmail.value;
        final phoneNumber = controller.userPhoneNumber.value;
        final photoUrl = controller.userPhotoUrl.value;
        final language = settings.language.value;
        final notificationsEnabled = settings.notificationsEnabled.value;
        final isDarkMode = settings.isDark.value;

        return LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    28,
                  ),
                  children: [
                    _ProfileHeader(
                      name: name,
                      email: email,
                      photoUrl: photoUrl,
                    ),
                    const SizedBox(height: 20),
                    _ProfileSection(
                      icon: Icons.person_outline_rounded,
                      title: 'personal_information'.tr,
                      child: Column(
                        children: [
                          _ProfileInfoRow(
                            label: 'full_name'.tr,
                            value: name.isEmpty ? 'wedding_planner'.tr : name,
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 12),
                          _ProfileInfoRow(
                            label: 'email'.tr,
                            value: email.isEmpty ? 'not_provided'.tr : email,
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 12),
                          _ProfileInfoRow(
                            label: 'phone_number'.tr,
                            value: phoneNumber.isEmpty
                                ? 'not_provided'.tr
                                : phoneNumber,
                            icon: Icons.phone_outlined,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ProfileSection(
                      icon: Icons.settings_outlined,
                      title: 'preferences'.tr,
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            leading: const Icon(Icons.language_rounded),
                            title: Text('language'.tr),
                            subtitle: Text('language_description'.tr),
                            trailing: DropdownButton<String>(
                              value: language,
                              underline: const SizedBox.shrink(),
                              items: [
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text('english'.tr),
                                ),
                                DropdownMenuItem(
                                  value: 'km',
                                  child: Text('khmer'.tr),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  _updateSetting(
                                    () => settings.changeLanguage(value),
                                  );
                                }
                              },
                            ),
                          ),
                          const Divider(height: 1, indent: 56),
                          SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            secondary: const Icon(Icons.notifications_outlined),
                            title: Text('notifications'.tr),
                            subtitle: Text('notifications_description'.tr),
                            value: notificationsEnabled,
                            onChanged: (value) => _updateSetting(
                              () => settings.setNotificationsEnabled(value),
                            ),
                          ),
                          const Divider(height: 1, indent: 56),
                          SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            secondary: const Icon(Icons.dark_mode_outlined),
                            title: Text('dark_mode'.tr),
                            subtitle: Text('dark_mode_description'.tr),
                            value: isDarkMode,
                            onChanged: (value) => _updateSetting(
                              () => settings.setDarkMode(value),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.errorContainer,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onErrorContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            await controller.logout();
                          } catch (error) {
                            Get.snackbar(
                              'sign_out_failed'.tr,
                              error.toString(),
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                        icon: const Icon(Icons.logout_rounded),
                        label: Text('sign_out'.tr),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Future<void> _updateSetting(Future<void> Function() update) async {
    try {
      await update();
    } catch (error) {
      Get.snackbar(
        'settings_update_failed'.tr,
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  final String name;
  final String email;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = name.isEmpty ? 'wedding_planner'.tr : name;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          children: [
            _ProfileAvatar(photoUrl: photoUrl, radius: 46),
            const SizedBox(height: 14),
            Text(
              displayName,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                email,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 14),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium_outlined,
                      size: 17,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Admin',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photoUrl, required this.radius});

  final String photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      child: Icon(
        Icons.person_rounded,
        size: radius,
        color: Theme.of(context).colorScheme.primary,
      ),
    );

    if (photoUrl.isEmpty) return fallback;

    return ClipOval(
      child: Image.network(
        photoUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: Icon(icon, color: theme.colorScheme.primary),
              title: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Divider(height: 1, color: theme.dividerColor),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelMedium),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
