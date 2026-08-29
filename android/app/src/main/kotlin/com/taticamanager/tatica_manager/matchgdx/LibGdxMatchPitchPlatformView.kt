package com.taticamanager.tatica_manager.matchgdx

import android.view.View
import android.widget.FrameLayout
import androidx.fragment.app.FragmentActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import org.json.JSONObject

class LibGdxMatchPitchPlatformView(
    private val activity: FragmentActivity,
    messenger: BinaryMessenger,
    viewId: Int,
    creationArgs: Map<*, *>,
) : PlatformView {
    private val container = FrameLayout(activity).apply {
        id = View.generateViewId()
        setBackgroundColor(android.graphics.Color.rgb(6, 18, 14))
        clipChildren = true
        clipToPadding = true
        isSaveEnabled = false
    }
    private val fragment = LibGdxMatchPitchFragment.newInstance(
        viewId = viewId,
        configJson = JSONObject(creationArgs).toString(),
    )
    private val channel = MethodChannel(
        messenger,
        "tatica_manager/libgdx_match_pitch/$viewId",
    )
    private var fragmentAdded = false
    private var disposed = false

    init {
        channel.setMethodCallHandler { call, result ->
            if (disposed) {
                result.success(null)
                return@setMethodCallHandler
            }
            fragment.enqueueCommand(call.method, call.arguments)
            result.success(null)
        }
        container.addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
            override fun onViewAttachedToWindow(v: View) {
                attachFragment()
            }

            override fun onViewDetachedFromWindow(v: View) = Unit
        })
        container.post { attachFragment() }
    }

    private fun attachFragment() {
        if (disposed || fragmentAdded || !container.isAttachedToWindow) return
        val manager = activity.supportFragmentManager
        if (manager.isDestroyed) return
        fragmentAdded = true
        manager.beginTransaction()
            .replace(container.id, fragment, fragment.tagForView)
            .commitNowAllowingStateLoss()
    }

    override fun getView(): View = container

    override fun dispose() {
        if (disposed) return
        disposed = true
        channel.setMethodCallHandler(null)
        val manager = activity.supportFragmentManager
        if (!manager.isDestroyed && fragment.isAdded) {
            manager.beginTransaction().remove(fragment).commitAllowingStateLoss()
        }
    }
}
