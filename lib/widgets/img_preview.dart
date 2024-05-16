import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:local_rembg/local_rembg.dart';

class ImageSendScreen extends StatefulWidget {
  final String imagePath;

  const ImageSendScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _ImageSendScreenState createState() => _ImageSendScreenState();
}

class _ImageSendScreenState extends State<ImageSendScreen> {
  Uint8List? _imageBytes;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialImage();
  }

  void _loadInitialImage() {
    setState(() {
      _imageBytes = File(widget.imagePath).readAsBytesSync();
    });
  }

  Future<void> _removeBackground() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    print('Removing background from image at path: ${widget.imagePath}');

    try {
      LocalRembgResultModel result = await LocalRembg.removeBackground(
        imagePath: widget.imagePath,
      );

      print('Background removal result status: ${result.status}');

      if (result.status == 1) {
        setState(() {
          _imageBytes = Uint8List.fromList(result.imageBytes!);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result.errorMessage;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Error removing background: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController captionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Image'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : (_imageBytes != null
                          ? Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            )
                          : Center(child: Text(_errorMessage ?? ''))),
                ),
                if (_imageBytes != null)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: TextField(
                      controller: captionController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black54,
                        hintText: 'Add a caption...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: _removeBackground,
                  icon: const Icon(Icons.format_paint),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.orange,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    String caption = captionController.text;
                    // Handle the send action here, e.g., upload the image and caption
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Send'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
