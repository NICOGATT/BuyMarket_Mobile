import 'package:image_picker/image_picker.dart';

class SelectedMedia {
  final XFile file;
  final String type;

  const SelectedMedia({
    required this.file,
    required this.type,
  });

  String get name => file.name;
  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
}
