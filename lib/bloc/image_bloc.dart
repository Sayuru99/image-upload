import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'image_event.dart';
import 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  ImageBloc() : super(ImageInitial()) {
    on<SelectImageEvent>(_onSelectImageEvent);
    on<UploadImageEvent>(_onUploadImageEvent);
  }

  Future<void> _onSelectImageEvent(
      SelectImageEvent event, Emitter<ImageState> emit) async {
    emit(ImageSelected(event.imagePath));
  }

  Future<void> _onUploadImageEvent(
      UploadImageEvent event, Emitter<ImageState> emit) async {
    try {
      emit(ImageUploadInProgress());

      final file = File(event.imagePath);
      final ref =
          _storage.ref().child('images').child(DateTime.now().toString());
      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();

      emit(ImageUploadSuccess(imageUrl));
    } catch (e) {
      emit(ImageUploadFailure('$e'));
    }
  }
}
