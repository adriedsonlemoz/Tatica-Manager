package com.taticamanager.tatica_manager.matchgdx

import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.math.Vector2
import kotlin.math.sqrt

internal data class GdxKit(
    val primary: Color,
    val secondary: Color,
    val shorts: Color,
    val socks: Color,
    val accent: Color,
    val pattern: String,
)

internal class GdxPlayerMotionState(val seed: Int) {
    var velocityX: Float = 0f
    var velocityY: Float = 0f
    var delayRemaining: Float = 0f
    var lastTarget: Vector2? = null
    var transitionStart: Vector2? = null
    var initialDistance: Float = 0f
    var curveStrength: Float = 0f
    var preparedDelay: Float? = null
    var preparedCurveScale: Float = 1f
    var transitionCount: Int = 0

    val speed: Float
        get() = sqrt(velocityX * velocityX + velocityY * velocityY)

    val movementAmount: Float
        get() = (speed / .50f).coerceIn(0f, 1f)

    val displayDirection: Float
        get() {
            val currentSpeed = speed
            if (currentSpeed < .005f) return 0f
            return (-velocityY / currentSpeed).coerceIn(-1f, 1f)
        }

    fun prepareNextTransition(delay: Float, curveScale: Float = 1f) {
        lastTarget = null
        preparedDelay = delay.coerceAtLeast(0f)
        preparedCurveScale = curveScale.coerceIn(0f, 1.4f)
    }

    fun clearPreparedTransition() {
        preparedDelay = null
        preparedCurveScale = 1f
    }
}

internal data class GdxPlayerState(
    val position: Vector2,
    val target: Vector2,
    val motion: GdxPlayerMotionState,
)

internal data class GdxPlayerRenderEntry(
    val home: Boolean,
    val index: Int,
    val player: GdxPlayerState,
)

internal object GdxPitchGeometry {
    const val WORLD_WIDTH = 1050f
    const val WORLD_HEIGHT = 680f
    const val FIELD_MARGIN_X = 38f
    const val FIELD_MARGIN_Y = 24f
    const val PLAYER_RADIUS = 15.2f
    const val BALL_RADIUS = 5.2f

    fun displayPoint(point: Vector2): Vector2 = Vector2(1f - point.y, point.x)

    fun canvasPoint(
        point: Vector2,
        left: Float,
        bottom: Float,
        fieldWidth: Float,
        fieldHeight: Float,
    ): Vector2 {
        val display = displayPoint(point)
        return Vector2(
            left + display.x * fieldWidth,
            bottom + display.y * fieldHeight,
        )
    }
}
