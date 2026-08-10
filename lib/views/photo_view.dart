import 'dart:io';
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';

class PhotoViewPage extends StatelessWidget {
  const PhotoViewPage(
    this.name,
    this.path,
  );
  final String name;
  final String path;

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        child: Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
        title: Text(name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.shareFiles(<String>[path],
                mimeTypes: <String>["image/jpeg"]),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: const SizedBox(),
          ),
          ExtendedImage.file(
            File(path),
            filterQuality: FilterQuality.high,
            fit: BoxFit.contain,
            mode: ExtendedImageMode.gesture,
            initGestureConfigHandler: (state) {
              return GestureConfig(
                minScale: 1.0,
                animationMinScale: 1.0,
                maxScale: 5.0,
                animationMaxScale: 5.0,
                initialScale: 1.0,
              );
            },
          ),
        ],
      ),
      floatingActionButton: Builder(builder: (context) {
        IconData getSaveIcon() {
          if (Platform.isAndroid ||
              Platform.isIOS ||
              defaultTargetPlatform == TargetPlatform.ohos) {
            return Icons.save;
          } else {
            return Icons.open_in_new;
          }
        }

        return FloatingActionButton(
          child: Icon(getSaveIcon()),
          onPressed: () async {
            if (Platform.isAndroid ||
                Platform.isIOS ||
                defaultTargetPlatform == TargetPlatform.ohos) {
              await GallerySaver.saveImage(path);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  width: 300,
                  showCloseIcon: true,
                  content: Text(S.current.photo_saved),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            } else if (Platform.isWindows ||
                Platform.isMacOS ||
                Platform.isLinux) {
              launchUrl(Uri.parse('file:///$path'));
            }
          },
        );
      }),
    ));
  }
}
