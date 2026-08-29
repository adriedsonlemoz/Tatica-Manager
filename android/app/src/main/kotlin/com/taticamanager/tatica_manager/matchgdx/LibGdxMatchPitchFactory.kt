package com.taticamanager.tatica_manager.matchgdx

import android.content.Context
import androidx.fragment.app.FragmentActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class LibGdxMatchPitchFactory(
    private val activity: FragmentActivity,
    private val messenger: BinaryMessenger,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationArgs = (args as? Map<*, *>) ?: emptyMap<Any?, Any?>()
        return LibGdxMatchPitchPlatformView(
            activity = activity,
            messenger = messenger,
            viewId = viewId,
            creationArgs = creationArgs,
        )
    }
}
