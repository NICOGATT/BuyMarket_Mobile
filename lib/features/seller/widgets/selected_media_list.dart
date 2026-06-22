import 'package:flutter/material.dart';

import '../models/selected_media.dart';

class SelectedMediaList extends StatelessWidget {
  final List<SelectedMedia> media;
  final ValueChanged<SelectedMedia> onPreview;
  final ValueChanged<SelectedMedia>? onRemove;

  const SelectedMediaList({
    super.key,
    required this.media,
    required this.onPreview,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
        ),
        child: const Text(
          'Todavia no agregaste imagenes o videos',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: media.map((item) {
        return Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            onTap: () => onPreview(item),
            leading: Icon(
              item.isImage ? Icons.image_outlined : Icons.videocam_outlined,
              color: const Color(0xff168BEE),
            ),
            title: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: onRemove == null
                ? const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  )
                : IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => onRemove!(item),
                  ),
          ),
        );
      }).toList(),
    );
  }
}
