package com.taticamanager.tatica_manager.matchgdx

import com.badlogic.gdx.ApplicationAdapter
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.graphics.GL20
import com.badlogic.gdx.graphics.OrthographicCamera
import com.badlogic.gdx.graphics.g2d.BitmapFont
import com.badlogic.gdx.graphics.g2d.GlyphLayout
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import com.badlogic.gdx.graphics.glutils.ShapeRenderer
import com.badlogic.gdx.math.MathUtils
import com.badlogic.gdx.math.Vector2
import org.json.JSONObject
import java.util.concurrent.ConcurrentLinkedQueue
import kotlin.math.max
import kotlin.math.min

class LibGdxMatchRenderer(
    config: JSONObject,
    private val commands: ConcurrentLinkedQueue<RendererCommand>,
) : ApplicationAdapter() {
    private data class Kit(
        val primary: Color,
        val secondary: Color,
        val shorts: Color,
        val socks: Color,
        val accent: Color,
        val pattern: String,
    )

    private data class PlayerState(
        val position: Vector2,
        val target: Vector2,
    )

    private val homeClubId = config.optString("homeClubId")
    private val awayClubId = config.optString("awayClubId")
    private val homeKit = kitFromJson(config.optJSONObject("homeKit"))
    private val awayKit = kitFromJson(config.optJSONObject("awayKit"))
    private val homeGoalkeeperKit = kitFromJson(config.optJSONObject("homeGoalkeeperKit"))
    private val awayGoalkeeperKit = kitFromJson(config.optJSONObject("awayGoalkeeperKit"))
    private val homeTeamColor = argbToColor(config.optLong("homeColor", 0xFF0F7D46L))
    private val awayTeamColor = argbToColor(config.optLong("awayColor", 0xFFFFFFFFL))
    private val ballStyle = config.optInt("ballStyle", 0)
    private val names = mutableMapOf<String, String>()
    private var homeIds = jsonStringList(config.optJSONArray("homePlayerIds"))
    private var awayIds = jsonStringList(config.optJSONArray("awayPlayerIds"))

    private val homeBase = listOf(
        Vector2(.50f, .90f), Vector2(.15f, .75f), Vector2(.38f, .78f),
        Vector2(.62f, .78f), Vector2(.85f, .75f), Vector2(.27f, .58f),
        Vector2(.50f, .54f), Vector2(.73f, .58f), Vector2(.18f, .35f),
        Vector2(.50f, .29f), Vector2(.82f, .35f),
    )
    private val awayBase = listOf(
        Vector2(.50f, .10f), Vector2(.15f, .25f), Vector2(.38f, .22f),
        Vector2(.62f, .22f), Vector2(.85f, .25f), Vector2(.27f, .42f),
        Vector2(.50f, .46f), Vector2(.73f, .42f), Vector2(.18f, .65f),
        Vector2(.50f, .71f), Vector2(.82f, .65f),
    )
    private val homePlayers = homeBase.map { PlayerState(Vector2(it), Vector2(it)) }
    private val awayPlayers = awayBase.map { PlayerState(Vector2(it), Vector2(it)) }
    private val dismissedHome = mutableSetOf<Int>()
    private val dismissedAway = mutableSetOf<Int>()

    private lateinit var camera: OrthographicCamera
    private lateinit var shapes: ShapeRenderer
    private lateinit var batch: SpriteBatch
    private lateinit var font: BitmapFont
    private val layout = GlyphLayout()

    private var ball = Vector2(.5f, .5f)
    private var ballStart = Vector2(.5f, .5f)
    private var ballTarget = Vector2(.5f, .5f)
    private var ballProgress = 1f
    private var ballDuration = .3f
    private var eventRemaining = 0f
    private var resetDelay = 0f
    private var activeHome: Boolean? = null
    private var activeIndex: Int? = null
    private var replayActive = false
    private var elapsed = 0f
    private var crowdPulse = .12f
    private var currentType = ""

    init {
        config.optJSONObject("playerNames")?.let { objectNames ->
            val iterator = objectNames.keys()
            while (iterator.hasNext()) {
                val key = iterator.next()
                names[key] = objectNames.optString(key)
            }
        }
    }

    override fun create() {
        camera = OrthographicCamera()
        shapes = ShapeRenderer()
        batch = SpriteBatch()
        font = BitmapFont().apply {
            color = Color.WHITE
            data.setScale(.78f)
        }
        resize(Gdx.graphics.width, Gdx.graphics.height)
    }

    override fun resize(width: Int, height: Int) {
        camera.setToOrtho(false, width.toFloat(), height.toFloat())
        camera.update()
    }

    override fun render() {
        drainCommands()
        val dt = min(Gdx.graphics.deltaTime, .05f)
        update(dt)
        Gdx.gl.glClearColor(.025f, .055f, .045f, 1f)
        Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT)
        drawScene()
    }

    private fun update(dt: Float) {
        elapsed += dt
        crowdPulse = max(.12f, crowdPulse - dt * .22f)
        val movementAlpha = min(1f, dt * if (replayActive) 3.2f else 5.2f)
        homePlayers.forEach { it.position.lerp(it.target, movementAlpha) }
        awayPlayers.forEach { it.position.lerp(it.target, movementAlpha) }

        if (ballProgress < 1f) {
            ballProgress = min(1f, ballProgress + dt / ballDuration)
            val eased = ballProgress * ballProgress * (3f - 2f * ballProgress)
            ball.set(ballStart).lerp(ballTarget, eased)
        }

        if (eventRemaining > 0f) {
            eventRemaining -= dt
            if (eventRemaining <= 0f) resetDelay = .34f
        } else if (resetDelay > 0f) {
            resetDelay -= dt
            if (resetDelay <= 0f && !replayActive) resetTargets()
        }
    }

    private fun drainCommands() {
        while (true) {
            val command = commands.poll() ?: break
            when (command.method) {
                "playCue" -> handleCue(asMap(command.arguments))
                "updateLineups" -> updateLineups(asMap(command.arguments))
                "skipReplay" -> {
                    replayActive = false
                    resetTargets()
                }
                "clearPresentation" -> {
                    replayActive = false
                    currentType = ""
                    eventRemaining = 0f
                    resetDelay = 0f
                    resetTargets()
                }
                "setReplayActive" -> replayActive = command.arguments as? Boolean ?: false
            }
        }
    }

    private fun handleCue(payload: Map<String, Any?>) {
        val startsReplay = payload["startsReplay"] as? Boolean ?: false
        val endsReplay = payload["endsReplay"] as? Boolean ?: false
        if (startsReplay) {
            replayActive = true
            resetTargets()
        }
        if (endsReplay) replayActive = false
        val duration = (payload["duration"] as? Number)?.toFloat() ?: .3f
        ballDuration = max(.16f, duration)
        eventRemaining = duration
        resetDelay = 0f
        val event = asMap(payload["event"])
        if (event.isNotEmpty()) prepareEvent(event, duration)
    }

    private fun prepareEvent(event: Map<String, Any?>, duration: Float) {
        currentType = event["type"]?.toString().orEmpty()
        crowdPulse = when (currentType) {
            "goal", "ownGoal" -> 1f
            "woodwork", "penaltySaved" -> .84f
            "shot", "save", "penalty" -> .68f
            "red" -> .62f
            else -> .32f
        }
        val start = pointFromMap(asMap(event["start"]))
        val end = pointFromMap(asMap(event["end"]))
        if (start != null) {
            ball.set(start)
            ballStart.set(start)
        } else {
            ballStart.set(ball)
        }
        if (end != null) {
            ballTarget.set(end)
            ballProgress = 0f
        }

        val teamId = event["teamId"]?.toString()
        val homeEvent = when (teamId) {
            homeClubId -> true
            awayClubId -> false
            else -> null
        }
        activeHome = homeEvent
        if (homeEvent == null) return
        val ids = if (homeEvent) homeIds else awayIds
        val players = if (homeEvent) homePlayers else awayPlayers
        val opposite = if (homeEvent) awayPlayers else homePlayers
        val dismissed = if (homeEvent) dismissedHome else dismissedAway
        val playerId = event["playerId"]?.toString()
        var index = ids.indexOf(playerId).takeIf { it in players.indices && it !in dismissed }
        if (index == null && start != null) index = nearestIndex(players, start, dismissed)
        if (currentType == "save" || currentType == "penaltySaved") {
            index = if (0 !in dismissed) 0 else firstVisibleIndex(players.size, dismissed)
        }
        activeIndex = index

        if (currentType == "red" && index != null) {
            dismissed.add(index)
            return
        }

        if (index != null && start != null) players[index].target.set(start)
        when (currentType) {
            "pass" -> if (end != null) {
                val receiver = nearestIndex(players, end, dismissed + listOfNotNull(index))
                players[receiver].target.set(end)
                spreadSupport(players, end, setOfNotNull(index, receiver), homeEvent)
            }
            "shot", "goal", "ownGoal", "woodwork" -> if (end != null) {
                attackBox(players, end, setOfNotNull(index), homeEvent)
                defendBox(opposite, end, !homeEvent)
            }
            "save", "penaltySaved" -> if (end != null) {
                val keeper = firstVisibleIndex(players.size, dismissed)
                players[keeper].target.set(end)
            }
            "penalty" -> if (start != null) {
                penaltySetup(players, opposite, index ?: 0, start, homeEvent)
            }
        }
        eventRemaining = duration
    }

    private fun drawScene() {
        val width = Gdx.graphics.width.toFloat()
        val height = Gdx.graphics.height.toFloat()
        val marginX = max(12f, width * .018f)
        val marginY = max(10f, height * .045f)
        val fieldLeft = marginX
        val fieldBottom = marginY
        val fieldWidth = width - marginX * 2f
        val fieldHeight = height - marginY * 2f

        shapes.projectionMatrix = camera.combined
        shapes.begin(ShapeRenderer.ShapeType.Filled)
        shapes.color = Color(.035f, .09f, .07f, 1f)
        shapes.rect(0f, 0f, width, height)
        drawCrowd(width, height, fieldLeft, fieldBottom, fieldWidth, fieldHeight)
        shapes.color = Color(.055f, .31f, .16f, 1f)
        shapes.rect(fieldLeft, fieldBottom, fieldWidth, fieldHeight)
        val stripeWidth = fieldWidth / 10f
        for (i in 0 until 10) {
            shapes.color = if (i % 2 == 0) Color(.06f, .35f, .18f, 1f) else Color(.05f, .30f, .15f, 1f)
            shapes.rect(fieldLeft + stripeWidth * i, fieldBottom, stripeWidth, fieldHeight)
        }
        shapes.end()

        drawPitchLines(fieldLeft, fieldBottom, fieldWidth, fieldHeight)
        drawGoals(fieldLeft, fieldBottom, fieldWidth, fieldHeight)
        drawPlayers(fieldLeft, fieldBottom, fieldWidth, fieldHeight)
        drawBall(fieldLeft, fieldBottom, fieldWidth, fieldHeight)
        drawLabels(fieldLeft, fieldBottom, fieldWidth, fieldHeight)
    }

    private fun drawCrowd(width: Float, height: Float, left: Float, bottom: Float, fw: Float, fh: Float) {
        val pulse = .55f + crowdPulse * .45f
        for (i in 0 until 42) {
            val x = (i * 37f + 11f) % width
            val topY = bottom + fh + 3f + (i % 4) * 2.2f
            val bottomY = bottom - 3f - (i % 3) * 2.4f
            shapes.color = if (i % 2 == 0) Color(homeTeamColor).mul(pulse) else Color(awayTeamColor).mul(pulse)
            shapes.circle(x, topY, 1.2f + (i % 3) * .3f)
            shapes.circle(width - x, bottomY, 1.1f + (i % 2) * .35f)
        }
    }

    private fun drawPitchLines(left: Float, bottom: Float, fw: Float, fh: Float) {
        Gdx.gl.glLineWidth(1.4f)
        shapes.begin(ShapeRenderer.ShapeType.Line)
        shapes.color = Color(1f, 1f, 1f, .88f)
        shapes.rect(left, bottom, fw, fh)
        shapes.line(left + fw / 2f, bottom, left + fw / 2f, bottom + fh)
        shapes.circle(left + fw / 2f, bottom + fh / 2f, fh * .16f, 40)
        val boxW = fw * .16f
        val boxH = fh * .58f
        val boxY = bottom + (fh - boxH) / 2f
        shapes.rect(left, boxY, boxW, boxH)
        shapes.rect(left + fw - boxW, boxY, boxW, boxH)
        val sixW = fw * .065f
        val sixH = fh * .30f
        val sixY = bottom + (fh - sixH) / 2f
        shapes.rect(left, sixY, sixW, sixH)
        shapes.rect(left + fw - sixW, sixY, sixW, sixH)
        shapes.end()
    }

    private fun drawGoals(left: Float, bottom: Float, fw: Float, fh: Float) {
        val goalH = fh * .26f
        val goalY = bottom + (fh - goalH) / 2f
        val depth = max(8f, fw * .018f)
        shapes.begin(ShapeRenderer.ShapeType.Line)
        shapes.color = Color(1f, 1f, 1f, .92f)
        shapes.rect(left - depth, goalY, depth, goalH)
        shapes.rect(left + fw, goalY, depth, goalH)
        for (row in 1 until 6) {
            val y = goalY + goalH * row / 6f
            shapes.line(left - depth, y, left, y)
            shapes.line(left + fw, y, left + fw + depth, y)
        }
        for (col in 1 until 4) {
            val x = depth * col / 4f
            shapes.line(left - x, goalY, left - x, goalY + goalH)
            shapes.line(left + fw + x, goalY, left + fw + x, goalY + goalH)
        }
        shapes.end()
    }

    private fun drawPlayers(left: Float, bottom: Float, fw: Float, fh: Float) {
        val entries = mutableListOf<Triple<Boolean, Int, PlayerState>>()
        homePlayers.forEachIndexed { index, player -> if (index !in dismissedHome) entries += Triple(true, index, player) }
        awayPlayers.forEachIndexed { index, player -> if (index !in dismissedAway) entries += Triple(false, index, player) }
        entries.sortBy { displayPoint(it.third.position).y }

        shapes.begin(ShapeRenderer.ShapeType.Filled)
        entries.forEach { (home, index, player) ->
            val p = canvasPoint(player.position, left, bottom, fw, fh)
            val depthScale = .82f + displayPoint(player.position).y * .28f
            val radius = max(4.2f, fh * .018f) * depthScale
            val active = activeHome == home && activeIndex == index
            shapes.color = Color(0f, 0f, 0f, .28f)
            shapes.ellipse(p.x - radius * .95f, p.y - radius * 1.35f, radius * 1.9f, radius * .72f)
            val kit = if (index == 0) {
                if (home) homeGoalkeeperKit else awayGoalkeeperKit
            } else {
                if (home) homeKit else awayKit
            }
            shapes.color = kit.primary
            shapes.circle(p.x, p.y, radius, 18)
            when (kit.pattern) {
                "verticalStripes" -> {
                    shapes.color = kit.secondary
                    shapes.rect(p.x - radius * .2f, p.y - radius, radius * .4f, radius * 2f)
                }
                "horizontalStripes" -> {
                    shapes.color = kit.secondary
                    shapes.rect(p.x - radius, p.y - radius * .2f, radius * 2f, radius * .4f)
                }
                "halves" -> {
                    shapes.color = kit.secondary
                    shapes.rect(p.x, p.y - radius, radius, radius * 2f)
                }
                else -> Unit
            }
            shapes.color = kit.shorts
            shapes.rect(p.x - radius * .62f, p.y - radius * 1.05f, radius * 1.24f, radius * .48f)
            shapes.color = Color(.86f, .69f, .55f, 1f)
            shapes.circle(p.x, p.y + radius * .88f, radius * .42f, 14)
            if (index == 0) {
                shapes.color = kit.accent
                shapes.rect(p.x - radius * 1.15f, p.y - radius * .12f, radius * .34f, radius * .24f)
                shapes.rect(p.x + radius * .81f, p.y - radius * .12f, radius * .34f, radius * .24f)
            }
            if (active) {
                shapes.color = Color(1f, .84f, .20f, .78f)
                shapes.circle(p.x, p.y, radius * (1.35f + .08f * MathUtils.sin(elapsed * 8f)), 24)
                shapes.color = kit.primary
                shapes.circle(p.x, p.y, radius, 18)
            }
        }
        shapes.end()
    }

    private fun drawBall(left: Float, bottom: Float, fw: Float, fh: Float) {
        val p = canvasPoint(ball, left, bottom, fw, fh)
        val lift = if (ballProgress < 1f) MathUtils.sin(MathUtils.PI * ballProgress) * max(2.5f, fh * .025f) else 0f
        val radius = max(2.5f, fh * .011f)
        shapes.begin(ShapeRenderer.ShapeType.Filled)
        shapes.color = Color(0f, 0f, 0f, .28f)
        shapes.ellipse(p.x - radius, p.y - radius * 1.25f, radius * 2f, radius * .8f)
        shapes.color = when (ballStyle % 3) {
            1 -> Color(.95f, .90f, .12f, 1f)
            2 -> Color(.92f, .18f, .12f, 1f)
            else -> Color.WHITE
        }
        shapes.circle(p.x, p.y + lift, radius, 18)
        shapes.end()
    }

    private fun drawLabels(left: Float, bottom: Float, fw: Float, fh: Float) {
        batch.projectionMatrix = camera.combined
        batch.begin()
        drawTeamLabels(batch, homePlayers, homeIds, dismissedHome, left, bottom, fw, fh)
        drawTeamLabels(batch, awayPlayers, awayIds, dismissedAway, left, bottom, fw, fh)
        batch.end()
    }

    private fun drawTeamLabels(
        spriteBatch: SpriteBatch,
        players: List<PlayerState>,
        ids: List<String>,
        dismissed: Set<Int>,
        left: Float,
        bottom: Float,
        fw: Float,
        fh: Float,
    ) {
        players.forEachIndexed { index, player ->
            if (index in dismissed) return@forEachIndexed
            val id = ids.getOrNull(index) ?: return@forEachIndexed
            val raw = names[id].orEmpty().trim()
            if (raw.isEmpty()) return@forEachIndexed
            val name = compactName(raw)
            val p = canvasPoint(player.position, left, bottom, fw, fh)
            layout.setText(font, name)
            font.color = Color(1f, 1f, 1f, .92f)
            font.draw(spriteBatch, layout, p.x - layout.width / 2f, p.y - max(8f, fh * .035f))
        }
    }

    private fun updateLineups(payload: Map<String, Any?>) {
        homeIds = stringList(payload["homePlayerIds"])
        awayIds = stringList(payload["awayPlayerIds"])
    }

    private fun resetTargets() {
        homePlayers.forEachIndexed { index, player -> player.target.set(homeBase[index]) }
        awayPlayers.forEachIndexed { index, player -> player.target.set(awayBase[index]) }
        activeHome = null
        activeIndex = null
    }

    private fun spreadSupport(players: List<PlayerState>, target: Vector2, excluded: Set<Int>, attackingHome: Boolean) {
        players.indices.filter { it !in excluded }.take(3).forEachIndexed { order, index ->
            val lane = (order - 1) * .08f
            players[index].target.set(
                (target.x + lane).coerceIn(.08f, .92f),
                (target.y + if (attackingHome) -.06f else .06f).coerceIn(.08f, .92f),
            )
        }
    }

    private fun attackBox(players: List<PlayerState>, target: Vector2, excluded: Set<Int>, attackingHome: Boolean) {
        val direction = if (attackingHome) -1f else 1f
        players.indices.filter { it !in excluded }.takeLast(3).forEachIndexed { order, index ->
            players[index].target.set(
                (target.x + (order - 1) * .07f).coerceIn(.08f, .92f),
                (target.y - direction * .06f).coerceIn(.04f, .96f),
            )
        }
    }

    private fun defendBox(players: List<PlayerState>, target: Vector2, defendingHome: Boolean) {
        val direction = if (defendingHome) 1f else -1f
        players.indices.take(5).forEachIndexed { order, index ->
            players[index].target.set(
                (target.x + (order - 2) * .055f).coerceIn(.06f, .94f),
                (target.y + direction * .07f).coerceIn(.04f, .96f),
            )
        }
    }

    private fun penaltySetup(
        attackers: List<PlayerState>,
        defenders: List<PlayerState>,
        takerIndex: Int,
        spot: Vector2,
        attackingHome: Boolean,
    ) {
        attackers[takerIndex.coerceIn(0, attackers.lastIndex)].target.set(spot)
        val defendingKeeper = defenders.firstOrNull() ?: return
        defendingKeeper.target.set(.5f, if (attackingHome) .055f else .945f)
    }

    private fun nearestIndex(players: List<PlayerState>, target: Vector2, excluded: Collection<Int>): Int {
        var best = firstVisibleIndex(players.size, excluded.toSet())
        var bestDistance = Float.MAX_VALUE
        players.forEachIndexed { index, player ->
            if (index in excluded) return@forEachIndexed
            val dx = player.position.x - target.x
            val dy = player.position.y - target.y
            val distance = dx * dx + dy * dy
            if (distance < bestDistance) {
                bestDistance = distance
                best = index
            }
        }
        return best
    }

    private fun firstVisibleIndex(count: Int, dismissed: Set<Int>): Int =
        (0 until count).firstOrNull { it !in dismissed } ?: 0

    private fun displayPoint(point: Vector2) = Vector2(1f - point.y, point.x)

    private fun canvasPoint(point: Vector2, left: Float, bottom: Float, fw: Float, fh: Float): Vector2 {
        val display = displayPoint(point)
        return Vector2(left + display.x * fw, bottom + display.y * fh)
    }

    private fun compactName(value: String): String {
        if (value.length <= 13) return value
        val parts = value.split(' ').filter { it.isNotBlank() }
        val last = parts.lastOrNull().orEmpty()
        return if (last.length in 3..13) last else value.take(12) + "…"
    }

    override fun dispose() {
        shapes.dispose()
        batch.dispose()
        font.dispose()
    }

    companion object {
        private fun kitFromJson(json: JSONObject?): Kit {
            val source = json ?: JSONObject()
            return Kit(
                primary = argbToColor(source.optLong("primaryHex", 0xFF1E7A2BL)),
                secondary = argbToColor(source.optLong("secondaryHex", 0xFFFFFFFFL)),
                shorts = argbToColor(source.optLong("shortsHex", 0xFF1E7A2BL)),
                socks = argbToColor(source.optLong("socksHex", 0xFFFFFFFFL)),
                accent = argbToColor(source.optLong("accentHex", 0xFFFFFFFFL)),
                pattern = source.optString("pattern", "solid"),
            )
        }

        private fun argbToColor(value: Long): Color {
            val a = ((value shr 24) and 0xFF).toFloat() / 255f
            val r = ((value shr 16) and 0xFF).toFloat() / 255f
            val g = ((value shr 8) and 0xFF).toFloat() / 255f
            val b = (value and 0xFF).toFloat() / 255f
            return Color(r, g, b, a)
        }

        private fun jsonStringList(array: org.json.JSONArray?): List<String> {
            if (array == null) return emptyList()
            return List(array.length()) { index -> array.optString(index) }
        }

        private fun asMap(value: Any?): Map<String, Any?> =
            (value as? Map<*, *>)?.entries?.associate { it.key.toString() to it.value } ?: emptyMap()

        private fun stringList(value: Any?): List<String> =
            (value as? List<*>)?.mapNotNull { it?.toString() } ?: emptyList()

        private fun pointFromMap(map: Map<String, Any?>): Vector2? {
            if (map.isEmpty()) return null
            val x = (map["x"] as? Number)?.toFloat() ?: return null
            val y = (map["y"] as? Number)?.toFloat() ?: return null
            return Vector2(x, y)
        }

        private fun setOfNotNull(vararg values: Int?): Set<Int> = values.filterNotNull().toSet()
    }
}
