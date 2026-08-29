package com.taticamanager.tatica_manager.matchgdx

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.badlogic.gdx.backends.android.AndroidApplicationConfiguration
import com.badlogic.gdx.backends.android.AndroidFragmentApplication
import org.json.JSONObject
import java.util.concurrent.ConcurrentLinkedQueue

class LibGdxMatchPitchFragment : AndroidFragmentApplication() {
    private val pendingCommands = ConcurrentLinkedQueue<RendererCommand>()

    val tagForView: String
        get() = "tatica-libgdx-match-${requireArguments().getInt(ARG_VIEW_ID)}"

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View {
        val configJson = requireArguments().getString(ARG_CONFIG_JSON).orEmpty()
        val game = LibGdxMatchRenderer(JSONObject(configJson), pendingCommands)
        val config = AndroidApplicationConfiguration().apply {
            useAccelerometer = false
            useCompass = false
            useGyroscope = false
            useImmersiveMode = false
            useGL30 = false
            numSamples = 0
        }
        return initializeForView(game, config)
    }

    fun enqueueCommand(method: String, arguments: Any?) {
        pendingCommands.add(RendererCommand(method, arguments))
    }

    companion object {
        private const val ARG_VIEW_ID = "viewId"
        private const val ARG_CONFIG_JSON = "configJson"

        fun newInstance(viewId: Int, configJson: String) = LibGdxMatchPitchFragment().apply {
            arguments = Bundle().apply {
                putInt(ARG_VIEW_ID, viewId)
                putString(ARG_CONFIG_JSON, configJson)
            }
        }
    }
}

data class RendererCommand(val method: String, val arguments: Any?)
