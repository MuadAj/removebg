import 'dart:io';
import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:removebg/provider/provider.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  final GlobalKey<AnimatedFloatingActionButtonState> key =
  GlobalKey<AnimatedFloatingActionButtonState>();

  File? image;
  Uint8List? currentImage;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      this.image = File(image.path);
      context.read<RemoveBg>().removeBg(imageTemp);
      // setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<void> requestStoragePermission() async {
    final PermissionStatus permissionStatus =
    await Permission.storage.request();
    // if (permissionStatus == PermissionStatus.granted) {
    //   // do something
    // }
  }

  Future saveImage(Uint8List image) async {
    final PermissionStatus permissionStatus = await Permission.storage.status;
    if (permissionStatus.isGranted) {
      print("granted");
      final result =
      await ImageGallerySaver.saveImage(image, quality: 100, name: "image");
    } else {
      print("not granted");
      requestStoragePermission();
    }
  }

  Widget add() {
    return FloatingActionButton(
      onPressed: () {
        pickImage();
        key.currentState?.closeFABs();
      },
      heroTag: "Image",
      tooltip: 'Add',
      child: const Icon(Icons.upload_file),
    );
  }

  Widget uploade() {
    return FloatingActionButton(
      onPressed: () {
        saveImage(currentImage!);
      },
      heroTag: "Inbox",
      tooltip: 'Inbox',
      child: Icon(Icons.save),
    );
  }

  @override
  Widget build(BuildContext context) {
    var watcher = context.watch<RemoveBg>();
    currentImage = watcher.noBgImage;
    var provider = context.read<RemoveBg>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: (currentImage == null)
          ? noImageContent(
          isLoading: watcher.isLoading,
          isError: watcher.isError,
          context: context,
          retry: () {
            provider.removeBg(image!);
          })
          : Container(
          height: 500.0,
          width: 400.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: MemoryImage(watcher.noBgImage ?? Uint8List(0)),
              fit: BoxFit.scaleDown,
            ),
          )),
      floatingActionButton: AnimatedFloatingActionButton(
        key: key,
        fabButtons: <Widget>[
          add(),
          uploade(),
        ],
        colorStartAnimation: Colors.blue,
        // colorEndAnimation: Colors.red,
        animatedIconData: AnimatedIcons.menu_close,
      ),
    );
  }
}

// the content to show if there is no current image
Widget? noImageContent(
    {required bool isLoading, required bool isError, required BuildContext context, required Function retry}) {
  print("isLoading: $isLoading, isError: $isError");
  if (!isLoading && !isError) {
    return const Center(
      child: Text(
        "No image selected",
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
    );
  } else if (isLoading && !isError) {
    return const Center(child: CircularProgressIndicator(),);
  } else {
    showErrorSnackbar(context, retry);
    return null;
  }
}

//an error snackbar to show in case there are any errors
void showErrorSnackbar(BuildContext context, Function retry) {
  SnackBar snackBar = SnackBar(
    content: const Text('An error has occurred!'),
    action: SnackBarAction(label: 'Try Again', onPressed: () => retry(),
    ),duration: const Duration(days: 1),);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  });
}

class StartScreen extends StatelessWidget {
  const StartScreen({
    super.key,
    required String title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Title"),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 600,
            decoration: const BoxDecoration(
              borderRadius: BorderRadiusDirectional.only(
                  bottomEnd: Radius.circular(35.0),
                  bottomStart: Radius.circular(35.0)),
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 80, left: 80),
                  child: Container(
                      child: const Text(
                        'REMOVE BACKGROUND',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 200, left: 80),
                  child: Container(
                    width: 150,
                    height: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Image.asset(
                        "assets/im.jpeg",
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 200, left: 180),
                  child: Transform.rotate(
                    angle: 0.2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadiusDirectional.all(
                            (Radius.circular(35.0))),
                      ),
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: Image.asset(
                          "assets/ime.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Container(
              width: 300.0,
              child: ElevatedButton(
                onPressed: () {
                  // we don't want to go back to the welcome screen so we use pushReplacement
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomeScreen(
                              title: 'RemoveBg',
                            )),
                  );
                  // Respond to button press
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xff2196F3),
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
