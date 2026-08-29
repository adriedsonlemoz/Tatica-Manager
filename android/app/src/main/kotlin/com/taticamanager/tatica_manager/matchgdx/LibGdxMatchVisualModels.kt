package com.taticamanager.tatica_manager.matchgdx

import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.math.Vector2

internal data class GdxKit(
    val primary: Color,
    val secondary: Color,
    val shorts: Color,
    val socks: Color,
    val accent: Color,
    val pattern: String,
)

internal data class GdxPlayerState(
    val position: Vector2,
    val target: Vector2,
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
