package com.taticamanager.tatica_manager.matchgdx

import com.badlogic.gdx.ApplicationAdapter
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.graphics.GL20
import com.badlogic.gdx.graphics.OrthographicCamera
import com.badlogic.gdx.math.Vector2
import com.badlogic.gdx.utils.viewport.FitViewport
import com.badlogic.gdx.utils.viewport.Viewport
import org.json.JSONObject
import java.util.concurrent.ConcurrentLinkedQueue
import kotlin.math.exp
import kotlin.math.max
import kotlin.math.min

/**
 * Presentation-only renderer for the Android match pitch.
 *
 * Match rules, results, statistics and event coordinates stay in Dart. This
 * class only consumes those presentation commands, interpolates them and asks
 * the visual painters to draw the current state.
 */
class LibGdxMatchRenderer(
    config: JSONObject,
    private val commands: ConcurrentLinkedQueue<RendererCommand>,
) : ApplicationAdapter() {
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
    private val homePlayers = homeBase.map { GdxPlayerState(Vector2(it), Vector2(it)) }
    private val awayPlayers = awayBase.map { GdxPlayerState(Vector2(it), Vector2(it)) }
    private val dismissedHome = mutableSetOf<Int>()
    private val dismissedAway = mutableSetOf<Int>()

    private lateinit var camera: OrthographicCamera
    private lateinit var viewport: Viewport
    private lateinit var painter: LibGdxPitchPainter

    private val ball = Vector2(.5f, .5f)
    private val ballStart = Vector2(.5f, .5f)
    private val ballTarget = Vector2(.5f, .5f)
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
        viewport = FitViewport(
            GdxPitchGeometry.WORLD_WIDTH,
            GdxPitchGeometry.WORLD_HEIGHT,
            camera,
        )
        painter = LibGdxPitchPainter(
            homeKit = homeKit,
            awayKit = awayKit,
            homeGoalkeeperKit = homeGoalkeeperKit,
            awayGoalkeeperKit = awayGoalkeeperKit,
            homeTeamColor = homeTeamColor,
            awayTeamColor = awayTeamColor,
            ballStyle = ballStyle,
            names = names,
        ).also { it.create() }
        resize(Gdx.graphics.width, Gdx.graphics.height)
    }

    override fun resize(width: Int, height: Int) {
        if (width <= 0 || height <= 0) return
        viewport.update(width, height, true)
    }

    override fun render() {
        drainCommands()
        val dt = min(Gdx.graphics.deltaTime, .05f)
        update(dt)

        // PlatformViews can be resized by Flutter after the GL surface exists.
        // Applying the viewport every frame keeps glViewport synchronized.
        viewport.apply(true)
        Gdx.gl.glDisable(GL20.GL_DEPTH_TEST)
        Gdx.gl.glEnable(GL20.GL_BLEND)
        Gdx.gl.glBlendFunc(GL20.GL_SRC_ALPHA, GL20.GL_ONE_MINUS_SRC_ALPHA)
        Gdx.gl.glClearColor(.025f, .055f, .045f, 1f)
        Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT)
        painter.draw(
            camera = camera,
            homePlayers = homePlayers,
            awayPlayers = awayPlayers,
            dismissedHome = dismissedHome,
            dismissedAway = dismissedAway,
            homeIds = homeIds,
            awayIds = awayIds,
            ball = ball,
            ballStart = ballStart,
            ballProgress = ballProgress,
            elapsed = elapsed,
            crowdPulse = crowdPulse,
            activeHome = activeHome,
            activeIndex = activeIndex,
        )
    }

    private fun update(dt: Float) {
        elapsed += dt
        crowdPulse = max(.12f, crowdPulse - dt * .22f)

        // Presentation smoothing only. Targets still come from Match Engine
        // coordinates delivered by Dart.
        val response = if (replayActive) 4.4f else 7.4f
        val movementAlpha = (1f - exp((-response * dt).toDouble()))
            .toFloat()
            .coerceIn(0f, 1f)
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
        ballDuration = (duration * .68f).coerceIn(.18f, 1.1f)
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

    private fun spreadSupport(
        players: List<GdxPlayerState>,
        target: Vector2,
        excluded: Set<Int>,
        attackingHome: Boolean,
    ) {
        players.indices.filter { it !in excluded && it != 0 }.take(3).forEachIndexed { order, index ->
            val lane = (order - 1) * .08f
            players[index].target.set(
                (target.x + lane).coerceIn(.08f, .92f),
                (target.y + if (attackingHome) -.06f else .06f).coerceIn(.08f, .92f),
            )
        }
    }

    private fun attackBox(
        players: List<GdxPlayerState>,
        target: Vector2,
        excluded: Set<Int>,
        attackingHome: Boolean,
    ) {
        val direction = if (attackingHome) -1f else 1f
        players.indices.filter { it !in excluded && it != 0 }.takeLast(3).forEachIndexed { order, index ->
            players[index].target.set(
                (target.x + (order - 1) * .07f).coerceIn(.08f, .92f),
                (target.y - direction * .06f).coerceIn(.04f, .96f),
            )
        }
    }

    private fun defendBox(
        players: List<GdxPlayerState>,
        target: Vector2,
        defendingHome: Boolean,
    ) {
        val direction = if (defendingHome) 1f else -1f
        players.indices.filter { it != 0 }.take(4).forEachIndexed { order, index ->
            players[index].target.set(
                (target.x + (order - 1.5f) * .055f).coerceIn(.06f, .94f),
                (target.y + direction * .07f).coerceIn(.04f, .96f),
            )
        }
    }

    private fun penaltySetup(
        attackers: List<GdxPlayerState>,
        defenders: List<GdxPlayerState>,
        takerIndex: Int,
        spot: Vector2,
        attackingHome: Boolean,
    ) {
        attackers[takerIndex.coerceIn(0, attackers.lastIndex)].target.set(spot)
        val defendingKeeper = defenders.firstOrNull() ?: return
        defendingKeeper.target.set(.5f, if (attackingHome) .055f else .945f)
    }

    private fun nearestIndex(
        players: List<GdxPlayerState>,
        target: Vector2,
        excluded: Collection<Int>,
    ): Int {
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

    override fun dispose() {
        painter.dispose()
    }

    companion object {
        private fun kitFromJson(json: JSONObject?): GdxKit {
            val source = json ?: JSONObject()
            return GdxKit(
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
