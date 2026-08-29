import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../../game/match/renderer/libgdx_match_pitch_controller.dart';

class LibGdxMatchPitchView extends StatelessWidget {
  const LibGdxMatchPitchView({
    super.key,
    required this.controller,
  });

  final LibGdxMatchPitchController controller;

  @override
  Widget build(BuildContext context) => PlatformViewLink(
        viewType: LibGdxMatchPitchController.viewType,
        surfaceFactory: (context, platformController) => AndroidViewSurface(
          controller: platformController as AndroidViewController,
          gestureRecognizers:
              const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        ),
        onCreatePlatformView: (params) {
          final platformController = PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: LibGdxMatchPitchController.viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: controller.creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () => params.onFocusChanged(true),
          );
          platformController.addOnPlatformViewCreatedListener(
            params.onPlatformViewCreated,
          );
          platformController.addOnPlatformViewCreatedListener(
            controller.attachView,
          );
          platformController.create();
          return platformController;
        },
      );
}
