import 'package:equatable/equatable.dart';

abstract class ImageEvent extends Equatable {
  const ImageEvent();

  @override
  List<Object> get props => [];
}

class SelectImageEvent extends ImageEvent {
  final String imagePath;

  const SelectImageEvent(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

class UploadImageEvent extends ImageEvent {
  final String imagePath;

  const UploadImageEvent(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}
