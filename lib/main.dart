import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:files/bloc/image_bloc.dart';
import 'package:files/bloc/image_state.dart';
import 'package:image_picker/image_picker.dart';

import 'widgets/img_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Upload Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider(
        create: (context) => ImageBloc(),
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Uploader'),
      ),
      body: BlocBuilder<ImageBloc, ImageState>(
        builder: (context, state) {
          if (state is ImageInitial) {
            return const Center(
              child: Text('Select an image from gallery'),
            );
          } else if (state is ImageUploadInProgress) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ImageUploadSuccess) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Image Uploaded Successfully!'),
                  const SizedBox(height: 20),
                  Image.network(
                    state.imageUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            );
          } else if (state is ImageUploadFailure) {
            return Center(
              child: Text('Failed to upload image: ${state.errorMessage}'),
            );
          } else {
            return Container();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final picker = ImagePicker();
          final pickedFile =
              await picker.pickImage(source: ImageSource.gallery);

          if (pickedFile != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ImageSendScreen(imagePath: pickedFile.path),
              ),
            );
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
