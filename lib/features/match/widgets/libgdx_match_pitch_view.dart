import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../../game/match/renderer/libgdx_match_pitch_controller.dart';

/// Hosts the libGDX SurfaceView inside the exact rectangle reserved by Flutter.
///
/// libGDX inserts its GLSurfaceView after the PlatformView itself is created.
/// Forcing Hybrid Composition avoids Flutter selecting TLHC before that
/// SurfaceView exists, which can otherwise make the native surface escape the
/// widget bounds or use an incorrect size/z-order.
class LibGdxMatchPitchView extends StatelessWidget {
  const LibGdxMatchPitchView({
    super.key,
    required this.controller,
  });

  final LibGdxMatchPitchController controller;

  @override
  Widget build(BuildContext context) => ClipRect(
        child: PlatformViewLink(
          viewType: LibGdxMatchPitchController.viewType,
          surfaceFactory: (context, platformController) => AndroidViewSurface(
            controller: platformController as AndroidViewController,
            gestureRecognizers:
                const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          ),
          onCreatePlatformView: (params) {
            // Always use real Hybrid Composition. The libGDX SurfaceView is
            // attached later by the Fragment, so the adaptive surface path can
            // choose TLHC too early and render the SurfaceView out of bounds.
            return PlatformViewsService.initExpensiveAndroidView(
              id: params.id,
              viewType: LibGdxMatchPitchController.viewType,
              layoutDirection: TextDirection.ltr,
              creationParams: controller.creationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () => params.onFocusChanged(true),
            )
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..addOnPlatformViewCreatedListener(controller.attachView)
              ..create();
          },
        ),
      );
}
