import 'package:meta/meta.dart';

@immutable
abstract class ImageState {}

class ImageInitial extends ImageState {}

class ImageSelected extends ImageState {
  final String imagePath;

  ImageSelected(this.imagePath);
}

class ImageUploadInProgress extends ImageState {}

class ImageUploadSuccess extends ImageState {
  final String imageUrl;

  ImageUploadSuccess(this.imageUrl);
}

class ImageUploadFailure extends ImageState {
  final String errorMessage;

  ImageUploadFailure(this.errorMessage);
}
