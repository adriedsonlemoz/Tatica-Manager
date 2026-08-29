package com.taticamanager.tatica_manager.matchgdx

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.graphics.OrthographicCamera
import com.badlogic.gdx.graphics.glutils.ShapeRenderer
import com.badlogic.gdx.math.MathUtils
import com.badlogic.gdx.math.Vector2
import kotlin.math.max
import kotlin.math.min

internal class LibGdxPitchPainter(
    private val homeKit: GdxKit,
    private val awayKit: GdxKit,
    private val homeGoalkeeperKit: GdxKit,
    private val awayGoalkeeperKit: GdxKit,
    private val homeTeamColor: Color,
    private val awayTeamColor: Color,
    private val ballStyle: Int,
    names: Map<String, String>,
) {
    private lateinit var shapes: ShapeRenderer
    private val labelPainter = LibGdxPlayerLabelPainter(
        names = names,
        homeTeamColor = homeTeamColor,
        awayTeamColor = awayTeamColor,
        homeGoalkeeperKit = homeGoalkeeperKit,
        awayGoalkeeperKit = awayGoalkeeperKit,
    )

    fun create() {
        shapes = ShapeRenderer()
        labelPainter.create()
    }

    fun draw(
        camera: OrthographicCamera,
        homePlayers: List<GdxPlayerState>,
        awayPlayers: List<GdxPlayerState>,
        dismissedHome: Set<Int>,
        dismissedAway: Set<Int>,
        homeIds: List<String>,
        awayIds: List<String>,
        ball: Vector2,
        ballStart: Vector2,
        ballProgress: Float,
        elapsed: Float,
        crowdPulse: Float,
        activeHome: Boolean?,
        activeIndex: Int?,
    ) {
        val left = GdxPitchGeometry.FIELD_MARGIN_X
        val bottom = GdxPitchGeometry.FIELD_MARGIN_Y
        val fieldWidth = GdxPitchGeometry.WORLD_WIDTH - GdxPitchGeometry.FIELD_MARGIN_X * 2f
        val fieldHeight = GdxPitchGeometry.WORLD_HEIGHT - GdxPitchGeometry.FIELD_MARGIN_Y * 2f
        shapes.projectionMatrix = camera.combined

        drawStadiumBase(
            camera = camera,
            left = left,
            bottom = bottom,
            fieldWidth = fieldWidth,
            fieldHeight = fieldHeight,
            crowdPulse = crowdPulse,
        )
        drawGrass(left, bottom, fieldWidth, fieldHeight)
        drawPitchLines(left, bottom, fieldWidth, fieldHeight)
        drawGoals(left, bottom, fieldWidth, fieldHeight)

        val entries = visibleEntries(homePlayers, awayPlayers, dismissedHome, dismissedAway)
        drawPlayers(entries, left, bottom, fieldWidth, fieldHeight, elapsed, activeHome, activeIndex)
        drawBall(ball, ballStart, ballProgress, left, bottom, fieldWidth, fieldHeight)
        labelPainter.draw(
            camera = camera,
            entries = entries,
            homeIds = homeIds,
            awayIds = awayIds,
            activeHome = activeHome,
            activeIndex = activeIndex,
            left = left,
            bottom = bottom,
            fieldWidth = fieldWidth,
            fieldHeight = fieldHeight,
        )
    }

    private fun drawStadiumBase(
        camera: OrthographicCamera,
        left: Float,
        bottom: Float,
        fieldWidth: Float,
        fieldHeight: Float,
        crowdPulse: Float,
    ) {
        shapes.begin(ShapeRenderer.ShapeType.Filled)
        shapes.color = Color(.025f, .060f, .050f, 1f)
        shapes.rect(0f, 0f, GdxPitchGeometry.WORLD_WIDTH, GdxPitchGeometry.WORLD_HEIGHT)
        shapes.color = Color(0f, 0f, 0f, .32f)
        shapes.rect(left - 8f, bottom - 8f, fieldWidth + 16f, fieldHeight + 16f)
        shapes.end()
        drawCrowd(
            camera = camera,
            left = left,
            bottom = bottom,
            fieldWidth = fieldWidth,
            fieldHeight = fieldHeight,
            crowdPulse = crowdPulse,
        )
    }

    private fun drawGrass(left: Float, bottom: Float, fieldWidth: Float, fieldHeight: Float) {
        shapes.begin(ShapeRenderer.ShapeType.Filled)
        shapes.color = Color(.048f, .305f, .145f, 1f)
        shapes.rect(left, bottom, fieldWidth, fieldHeight)

        val stripeWidth = fieldWidth / 12f
        for (i in 0 until 12) {
            shapes.color = if (i % 2 == 0) {
                Color(.055f, .345f, .165f, 1f)
            } else {
                Color(.043f, .285f, .135f, 1f)
            }
            shapes.rect(left + stripeWidth * i, bottom, stripeWidth, fieldHeight)
        }

        val bandHeight = fieldHeight / 8f
        for (row in 0 until 8 step 2) {
            shapes.color = Color(1f, 1f, 1f, .012f)
            shapes.rect(left, bottom + row * bandHeight, fieldWidth, bandHeight)
        }
        shapes.end()
    }

    private fun drawCrowd(
        camera: OrthographicCamera,
        left: Float,
        bottom: Float,
        fieldWidth: Float,
        fieldHeight: Float,
        crowdPulse: Float,
    ) {
        val pulse = .50f + crowdPulse * .45f
        shapes.projectionMatrix = camera.combined
        shapes.begin(ShapeRenderer.ShapeType.Filled)
        for (i in 0 until 64) {
            val x = (i * 43f + 17f) % GdxPitchGeometry.WORLD_WIDTH
            val topY = min(
                GdxPitchGeometry.WORLD_HEIGHT - 5f,
                bottom + fieldHeight + 10f + (i % 3) * 3f,
            )
            val bottomY = max(5f, bottom - 10f - (i % 3) * 3f)
            val team = if (i % 2 == 0) homeTeamColor else awayTeamColor
            shapes.color = Color(team).mul(pulse)
            shapes.circle(x, topY, 1.8f + (i % 3) * .45f, 10)
            shapes.circle(
                GdxPitchGeometry.WORLD_WIDTH - x,
                bottomY,
                1.7f + (i % 2) * .45f,
                10,
            )
        }
        shapes.end()
    }

    private fun drawPitchLines(left: Float, bottom: Float, fieldWidth: Float, fieldHeight: Float) {
        Gdx.gl.glLineWidth(2.2f)
        shapes.begin(ShapeRenderer.ShapeType.Line)
        shapes.color = Color(1f, 1f, 1f, .91f)
        shapes.rect(left, bottom, fieldWidth, fieldHeight)
        shapes.line(left + fieldWidth / 2f, bottom, left + fieldWidth / 2f, bottom + fieldHeight)
        shapes.circle(left + fieldWidth / 2f, bottom + fieldHeight / 2f, fieldHeight * .1345f, 56)

        val boxWidth = fieldWidth * .157f
        val boxHeight = fieldHeight * .593f
        val boxY = bottom + (fieldHeight - boxHeight) / 2f
        shapes.rect(left, boxY, boxWidth, boxHeight)
        shapes.rect(left + fieldWidth - boxWidth, boxY, boxWidth, boxHeight)

        val sixWidth = fieldWidth * .052f
        val sixHeight = fieldHeight * .270f
        val sixY = bottom + (fieldHeight - sixHeight) / 2f
        shapes.rect(left, sixY, sixWidth, sixHeight)
        shapes.rect(left + fieldWidth - sixWidth, sixY, sixWidth, sixHeight)
        shapes.end()

        shapes.begin(ShapeRenderer.ShapeType.Filled)
        shapes.color = Color(1f, 1f, 1f, .94f)
        shapes.circle(left + fieldWidth / 2f, bottom + fieldHeight / 2f, 3.2f, 16)
        shapes.circle(left + fieldWidth * .105f, bottom + fieldHeight / 2f, 3f, 16)
        shapes.circle(left + fieldWidth * .895f, bottom + fieldHeight / 2f, 3f, 16)
        shapes.end()
    }

    private fun drawGoals(left: Float, bottom: Float, fieldWidth: Float, fieldHeight: Float) {
        val goalHeight = fieldHeight * .108f
        val goalY = bottom + (fieldHeight - goalHeight) / 2f
        val depth = 26f

        shapes.begin(ShapeRenderer.ShapeType.Filled)
        shapes.color = Color(.92f, .96f, 1f, .10f)
        shapes.rect(left - depth, goalY, depth, goalHeight)
        shapes.rect(left + fieldWidth, goalY, depth, goalHeight)
        shapes.end()

        Gdx.gl.glLineWidth(1.7f)
        shapes.begin(ShapeRenderer.ShapeType.Line)
        shapes.color = Color(.90f, .95f, 1f, .55f)
        for (row in 1 until 7) {
            val y = goalY + goalHeight * row / 7f
            shapes.line(left - depth, y, left, y)
            shapes.line(left + fieldWidth, y, left + fieldWidth + depth, y)
        }
        for (col in 1 until 5) {
            val x = depth * col / 5f
            shapes.line(left - x, goalY, left - x, goalY + goalHeight)
            shapes.line(left + fieldWidth + x, goalY, left + fieldWidth + x, goalY + goalHeight)
        }
        shapes.color = Color(1f, 1f, 1f, .97f)
        Gdx.gl.glLineWidth(3f)
        shapes.rect(left - depth, goalY, depth, goalHeight)
        shapes.rect(left + fieldWidth, goalY, depth, goalHeight)
        shapes.end()
    }

    private fun drawPlayers(
        entries: List<GdxPlayerRenderEntry>,
        left: Float,
        bottom: Float,
        fieldWidth: Float,
        fieldHeight: Float,
        elapsed: Float,
        activeHome: Boolean?,
        activeIndex: Int?,
    ) {
        shapes.begin(ShapeRenderer.ShapeType.Filled)
        entries.forEach { entry ->
            val p = GdxPitchGeometry.canvasPoint(
                entry.player.position,
                left,
                bottom,
                fieldWidth,
                fieldHeight,
            )
            val depthScale = .90f + GdxPitchGeometry.displayPoint(entry.player.position).y * .16f
            val radius = GdxPitchGeometry.PLAYER_RADIUS * depthScale
            val active = activeHome == entry.home && activeIndex == entry.index
            val keeper = entry.index == 0
            val kit = kitFor(entry.home, keeper)

            shapes.color = Color(0f, 0f, 0f, .30f)
            shapes.ellipse(
                p.x - radius * 1.05f,
                p.y - radius * 1.55f,
                radius * 2.1f,
                radius * .68f,
            )

            if (active) {
                val pulse = 1.38f + .06f * MathUtils.sin(elapsed * 8f)
                shapes.color = Color(1f, .82f, .16f, .25f)
                shapes.circle(p.x, p.y, radius * pulse, 28)
            }

            shapes.color = kit.socks
            shapes.rect(p.x - radius * .62f, p.y - radius * 1.18f, radius * .38f, radius * .52f)
            shapes.rect(p.x + radius * .24f, p.y - radius * 1.18f, radius * .38f, radius * .52f)
            shapes.color = kit.shorts
            shapes.rect(p.x - radius * .74f, p.y - radius * .72f, radius * 1.48f, radius * .62f)

            shapes.color = Color(0f, 0f, 0f, .24f)
            shapes.circle(p.x, p.y + radius * .02f, radius * 1.02f, 24)
            shapes.color = kit.primary
            shapes.circle(p.x, p.y + radius * .04f, radius * .91f, 24)
            drawKitPattern(p, radius, kit)

            shapes.color = if (keeper) kit.primary else Color(.82f, .64f, .50f, 1f)
            val armWidth = if (keeper) radius * .36f else radius * .28f
            shapes.rect(p.x - radius * 1.14f, p.y - radius * .18f, armWidth, radius * .65f)
            shapes.rect(p.x + radius * .78f, p.y - radius * .18f, armWidth, radius * .65f)
            if (keeper) {
                shapes.color = kit.accent
                shapes.circle(p.x - radius * 1.03f, p.y - radius * .28f, radius * .24f, 12)
                shapes.circle(p.x + radius * 1.03f, p.y - radius * .28f, radius * .24f, 12)
            }

            shapes.color = Color(.86f, .69f, .55f, 1f)
            shapes.circle(p.x, p.y + radius * 1.02f, radius * .43f, 18)
            shapes.color = Color(.12f, .09f, .075f, .92f)
            shapes.rect(
                p.x - radius * .34f,
                p.y + radius * 1.22f,
                radius * .68f,
                radius * .14f,
            )
            if (keeper) {
                shapes.color = Color(1f, 1f, 1f, .62f)
                shapes.rect(p.x - radius * .36f, p.y + radius * .18f, radius * .72f, radius * .10f)
            }
        }
        shapes.end()

        Gdx.gl.glLineWidth(2.4f)
        shapes.begin(ShapeRenderer.ShapeType.Line)
        entries.forEach { entry ->
            if (activeHome != entry.home || activeIndex != entry.index) return@forEach
            val p = GdxPitchGeometry.canvasPoint(
                entry.player.position,
                left,
                bottom,
                fieldWidth,
                fieldHeight,
            )
            val depthScale = .90f + GdxPitchGeometry.displayPoint(entry.player.position).y * .16f
            shapes.color = Color(1f, .86f, .24f, .92f)
            shapes.circle(
                p.x,
                p.y,
                GdxPitchGeometry.PLAYER_RADIUS * depthScale * 1.28f,
                28,
            )
        }
        shapes.end()
    }

    private fun drawKitPattern(point: Vector2, radius: Float, kit: GdxKit) {
        when (kit.pattern) {
            "verticalStripes" -> {
                shapes.color = kit.secondary
                shapes.rect(point.x - radius * .18f, point.y - radius * .80f, radius * .36f, radius * 1.62f)
            }
            "horizontalStripes" -> {
                shapes.color = kit.secondary
                shapes.rect(point.x - radius * .78f, point.y - radius * .10f, radius * 1.56f, radius * .34f)
            }
            "halves" -> {
                shapes.color = kit.secondary
                shapes.rect(point.x, point.y - radius * .78f, radius * .80f, radius * 1.58f)
            }
            "sash" -> {
                shapes.color = kit.secondary
                shapes.rect(point.x - radius * .56f, point.y - radius * .68f, radius * .30f, radius * 1.40f)
            }
            "gradient" -> {
                shapes.color = Color(kit.secondary).apply { a = .60f }
                shapes.circle(point.x, point.y - radius * .18f, radius * .62f, 20)
            }
            else -> Unit
        }
    }

    private fun drawBall(
        ball: Vector2,
        ballStart: Vector2,
        ballProgress: Float,
        left: Float,
        bottom: Float,
        fieldWidth: Float,
        fieldHeight: Float,
    ) {
        val p = GdxPitchGeometry.canvasPoint(ball, left, bottom, fieldWidth, fieldHeight)
        val lift = if (ballProgress < 1f) {
            MathUtils.sin(MathUtils.PI * ballProgress) * 18f
        } else {
            0f
        }
        val radius = GdxPitchGeometry.BALL_RADIUS

        shapes.begin(ShapeRenderer.ShapeType.Filled)
        shapes.color = Color(0f, 0f, 0f, .30f)
        shapes.ellipse(p.x - radius * 1.05f, p.y - radius * 1.30f, radius * 2.1f, radius * .72f)

        if (ballProgress in .05f..0.95f) {
            shapes.color = Color(1f, 1f, 1f, .14f)
            val trail = Vector2(ballStart).lerp(ball, .68f)
            val t = GdxPitchGeometry.canvasPoint(trail, left, bottom, fieldWidth, fieldHeight)
            shapes.circle(t.x, t.y + lift * .50f, radius * .68f, 14)
        }

        shapes.color = Color(.08f, .10f, .11f, .85f)
        shapes.circle(p.x, p.y + lift, radius * 1.18f, 20)
        shapes.color = when (ballStyle % 3) {
            1 -> Color(.98f, .91f, .13f, 1f)
            2 -> Color(.95f, .20f, .14f, 1f)
            else -> Color.WHITE
        }
        shapes.circle(p.x, p.y + lift, radius, 20)
        shapes.color = Color(.08f, .10f, .11f, .92f)
        shapes.circle(p.x + radius * .26f, p.y + lift + radius * .14f, radius * .24f, 10)
        shapes.end()
    }

    private fun visibleEntries(
        homePlayers: List<GdxPlayerState>,
        awayPlayers: List<GdxPlayerState>,
        dismissedHome: Set<Int>,
        dismissedAway: Set<Int>,
    ): MutableList<GdxPlayerRenderEntry> {
        val entries = mutableListOf<GdxPlayerRenderEntry>()
        homePlayers.forEachIndexed { index, player ->
            if (index !in dismissedHome) entries += GdxPlayerRenderEntry(true, index, player)
        }
        awayPlayers.forEachIndexed { index, player ->
            if (index !in dismissedAway) entries += GdxPlayerRenderEntry(false, index, player)
        }
        entries.sortBy { GdxPitchGeometry.displayPoint(it.player.position).y }
        return entries
    }

    private fun kitFor(home: Boolean, goalkeeper: Boolean): GdxKit = if (goalkeeper) {
        if (home) homeGoalkeeperKit else awayGoalkeeperKit
    } else {
        if (home) homeKit else awayKit
    }

    fun dispose() {
        shapes.dispose()
        labelPainter.dispose()
    }
}
