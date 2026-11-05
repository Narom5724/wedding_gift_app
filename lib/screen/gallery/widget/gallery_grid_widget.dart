import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:wedding_gift_app/models/gallery/gallery_image.dart';

class GalleryGridWidget extends StatelessWidget {
  const GalleryGridWidget({
    super.key,
    required this.images,
    required this.onDelete,
    required this.isLoading,
    required this.hasMore,
    required this.errorMessage,
    required this.onLoadMore,
    required this.onRetry,
  });

  final List<GalleryImage> images;
  final Future<bool> Function(String) onDelete;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final Future<void> Function() onLoadMore;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty && isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (images.isEmpty && errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 40),
              const SizedBox(height: 12),
              const Text('Unable to load gallery.'),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (images.isEmpty) {
      return const Center(child: Text('No images yet.'));
    }

    final groups = _groupImagesByDate(images);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 300 && hasMore && !isLoading) {
          onLoadMore();
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          for (final group in groups) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                child: Text(
                  _formatGroupDate(group.date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final image = group.images[index];
                return _buildThumbnail(context, image);
              }, childCount: group.images.length),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 136,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 1,
              ),
            ),
          ],
          if (hasMore || isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: errorMessage != null
                      ? IconButton(
                          tooltip: 'Retry loading images',
                          onPressed: onLoadMore,
                          icon: const Icon(Icons.refresh_rounded),
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, GalleryImage image) {
    return GestureDetector(
      onTap: () => _showImagePreview(context, image, onDelete),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Image.network(
            image.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.broken_image)),
          ),
        ),
      ),
    );
  }
}

List<_GalleryDayGroup> _groupImagesByDate(List<GalleryImage> images) {
  final groups = <_GalleryDayGroup>[];
  for (final image in images) {
    final date = image.createdAt?.toLocal();
    final day = date == null ? null : DateUtils.dateOnly(date);
    if (groups.isEmpty || groups.last.date != day) {
      groups.add(_GalleryDayGroup(date: day, images: [image]));
    } else {
      groups.last.images.add(image);
    }
  }
  return groups;
}

String _formatGroupDate(DateTime? date) {
  if (date == null) return 'Date unavailable';

  final today = DateUtils.dateOnly(DateTime.now());
  final daysAgo = today.difference(date).inDays;
  if (daysAgo == 0) return 'Today';
  if (daysAgo == 1) return 'Yesterday';
  if (date.year == today.year) return DateFormat('MMM d').format(date);
  return DateFormat('MMM d, yyyy').format(date);
}

Future<void> _showImagePreview(
  BuildContext context,
  GalleryImage image,
  Future<bool> Function(String) onDelete,
) {
  final date = image.createdAt?.toLocal();
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 64,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date == null
                              ? 'Date unavailable'
                              : DateFormat('MMMM d').format(date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (date != null)
                          Text(
                            DateFormat('h:mm a').format(date),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) async {
                      if (value == 'delete' &&
                          await onDelete(image.imageUrl) &&
                          context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete image',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Image.network(
                    image.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ViewerActionButton(
                    icon: Icons.delete_outline,
                    tooltip: 'Delete image',
                    onPressed: () async {
                      if (await onDelete(image.imageUrl) && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(width: 56),
                  _ViewerActionButton(
                    icon: Icons.info_outline,
                    tooltip: 'Image details',
                    onPressed: () => _showImageDetails(context, date),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _showImageDetails(BuildContext context, DateTime? date) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Image details'),
      content: Text(
        date == null
            ? 'Upload date unavailable.'
            : DateFormat('EEEE, MMMM d, yyyy · h:mm a').format(date),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class _ViewerActionButton extends StatelessWidget {
  const _ViewerActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: 28,
      color: Colors.white,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        padding: const EdgeInsets.all(14),
      ),
      icon: Icon(icon),
    );
  }
}

class _GalleryDayGroup {
  _GalleryDayGroup({required this.date, required this.images});

  final DateTime? date;
  final List<GalleryImage> images;
}
