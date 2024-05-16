import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

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
      final apiKey = '01ee2dc2923acb3bdcb3f1bafadaa9f37a102adf';
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://sdk.photoroom.com/v1/segment'),
      );
      request.headers['x-api-key'] = apiKey;
      request.files.add(
        await http.MultipartFile.fromPath(
          'image_file',
          widget.imagePath,
        ),
      );

      var response = await request.send();
      print('Background removal API response: ${response.statusCode}');
      if (response.statusCode == 200) {
        var contentType = response.headers['content-type'];
        if (contentType?.startsWith('application/json') ?? false) {
          var responseData = await response.stream.bytesToString();
          final Map<String, dynamic> data = json.decode(responseData);
          final String? imageUrl = data['result'];

          if (imageUrl != null) {
            final imageResponse = await http.get(Uri.parse(imageUrl));
            if (imageResponse.statusCode == 200) {
              setState(() {
                _imageBytes = imageResponse.bodyBytes;
                _isLoading = false;
              });
            } else {
              throw 'Failed to download the processed image';
            }
          } else {
            throw 'Image URL is null';
          }
        } else if (contentType?.startsWith('image/png') ?? false) {
          final imageData = await response.stream.toBytes();
          setState(() {
            _imageBytes = imageData;
            _isLoading = false;
          });
        } else {
          throw 'Unexpected content type: $contentType';
        }
      } else {
        throw 'Failed to remove background. Status code: ${response.statusCode}';
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
