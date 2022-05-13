import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

String adurl='https://naver.com';
String adimage='assets/eye.png';
class TakePictureScreenState extends State<TakePictureScreen> {
  Uri _url=Uri.parse(adurl);
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  void _launchUrl() async {
    if (await (canLaunchUrl(_url))) {
      await launchUrl(_url, webOnlyWindowName: "_blank");
    } else {
      throw 'Could not launch $_url';
    }
  }

  void _showOverlay(BuildContext context) async {
    // Declaring and Initializing OverlayState
    // and OverlayEntry objects
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        height: MediaQuery.of(context).size.width * 0.75,
        width: MediaQuery.of(context).size.width,
        bottom: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white,
          ),
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  _launchUrl();
                },
                child: Image.asset(
                  adimage,
                ),
              ),
              Positioned(
                right: 20,
                top: 20,
                child: GestureDetector(
                  onTap: () {
                    // When the icon is pressed the OverlayEntry
                    // is removed from Overlay
                    overlayEntry?.remove();
                  },
                  child: Container(
                    height: 30.0,
                    width: 30.0,
                    padding: const EdgeInsets.all(1.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.0),
                      color: Colors.white,
                    ),
                    child: Icon(Icons.close,
                        color: Colors.black,
                        size: MediaQuery.of(context).size.height * 0.025),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
    overlayState?.insert(overlayEntry);
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                ),
              ),
            );
            _showOverlay(context);
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}

/*final Uri _url = Uri.parse('https://naver.com');

class CameraExample extends StatefulWidget {
  const CameraExample({Key? key}) : super(key: key);

  @override
  _CameraExampleState createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample> {
  CameraController? _cameraController;
  Future<void>? _initCameraControllerFuture;
  int cameraIndex = 0;

  bool isCapture = false;
  File? captureImage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _cameraController =
        CameraController(cameras[cameraIndex], ResolutionPreset.veryHigh);
    _initCameraControllerFuture = _cameraController!.initialize().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _cameraController!.dispose();
    super.dispose();
  }

  void _launchUrl() async {
    if (await (canLaunchUrl(_url))) {
      await launchUrl(_url, webOnlyWindowName: "_blank");
    } else {
      throw 'Could not launch $_url';
    }
  }

  void _showOverlay(BuildContext context) async {
    // Declaring and Initializing OverlayState
    // and OverlayEntry objects
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        height: MediaQuery.of(context).size.width * 0.75,
        width: MediaQuery.of(context).size.width,
        bottom: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white,
          ),
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  _launchUrl();
                },
                child: Image.asset(
                  'assets/eye.png',
                ),
              ),
              Positioned(
                right: 20,
                top: 20,
                child: GestureDetector(
                  onTap: () {
                    // When the icon is pressed the OverlayEntry
                    // is removed from Overlay
                    overlayEntry?.remove();
                  },
                  child: Container(
                    height: 30.0,
                    width: 30.0,
                    padding: const EdgeInsets.all(1.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.0),
                      color: Colors.white,
                    ),
                    child: Icon(Icons.close,
                        color: Colors.black,
                        size: MediaQuery.of(context).size.height * 0.025),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
    overlayState?.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: isCapture
          ? Column(
              // 촬영 된 이미지 출력
              children: [
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: SizedBox(
                    width: size.width,
                    height: size.width,
                    child: ClipRect(
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: SizedBox(
                          width: size.width,
                          child: AspectRatio(
                            aspectRatio:
                                1 / _cameraController!.value.aspectRatio,
                            child: Container(
                              width: size.width,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: MemoryImage(
                                      captureImage!.readAsBytesSync()),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // 재촬영 선택시 카메라 삭제 및 상태 변경
                            captureImage!.delete();
                            captureImage = null;
                            setState(() {
                              isCapture = false;
                            });
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 16.0),
                                Text(
                                  "다시 찍기",
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: FutureBuilder<void>(
                    future: _initCameraControllerFuture,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return SizedBox(
                          width: size.width,
                          height: size.width,
                          child: ClipRect(
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: SizedBox(
                                width: size.width,
                                child: AspectRatio(
                                    aspectRatio: 1 /
                                        _cameraController!.value.aspectRatio,
                                    child: CameraPreview(_cameraController!)),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            try {
                              await _cameraController!
                                  .takePicture()
                                  .then((value) {
                                captureImage = File(value.path);
                              });
                              // 화면 상태 변경 및 이미지 저장
                              setState(() {
                                isCapture = true;
                              });
                              _showOverlay(context);
                            } catch (e) {
                              print("$e");
                            }
                          },
                          child: Container(
                            height: 80.0,
                            width: 80.0,
                            padding: const EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.black, width: 1.0),
                              color: Colors.white,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.black, width: 3.0),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () async {
                              //await, async 비동기 처리
                              // 후면 카메라 <-> 전면 카메라 변경
                              cameraIndex = cameraIndex == 0 ? 1 : 0;
                              await _initCamera();
                            },
                            icon: const Icon(
                              Icons.flip_camera_android,
                              color: Colors.white,
                              size: 34.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
*/