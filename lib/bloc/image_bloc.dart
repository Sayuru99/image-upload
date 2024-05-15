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
    on<SelectImageEvent>((event, emit) {
      add(event);
    });
  }
  Stream<ImageState> mapEventToState(ImageEvent event) async* {
    if (event is SelectImageEvent) {
      yield* _mapSelectImageToState();
    } else if (event is UploadImageEvent) {
      yield* _mapUploadImageToState(event.imagePath);
    }
  }

  Stream<ImageState> _mapSelectImageToState() async* {
    try {
      final imagePicker = ImagePicker();
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        yield ImageSelected(pickedFile.path);
      } else {
        yield ImageInitial();
      }
    } catch (e) {
      yield ImageInitial();
    }
  }

  Stream<ImageState> _mapUploadImageToState(String imagePath) async* {
    try {
      yield ImageUploadInProgress();

      final file = File(imagePath);
      final ref =
          _storage.ref().child('images').child(DateTime.now().toString());
      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();

      yield ImageUploadSuccess(imageUrl);
    } catch (e) {
      yield ImageUploadFailure('$e');
    }
  }
}
