package com.taticamanager.tatica_manager.matchgdx

import com.badlogic.gdx.math.Vector2
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * Presentation-only motion system ported from the Flame renderer refinement.
 *
 * Match Engine coordinates remain authoritative. This class only controls how
 * a visual player reaches a target: staggered starts, acceleration/braking and
 * a small deterministic curve so players do not slide in straight lines or
 * begin/finish transitions in the same frame.
 */
internal object LibGdxPlayerMotion {
    fun playerPoint(point: Vector2): Vector2 = Vector2(
        point.x.coerceIn(.08f, .92f),
        point.y.coerceIn(.07f, .93f),
    )

    fun nearestIndex(
        players: List<GdxPlayerState>,
        target: Vector2,
        excluding: Int? = null,
        excluded: Collection<Int> = emptySet(),
    ): Int {
        var bestIndex = players.indices.firstOrNull { it != excluding && it !in excluded } ?: 0
        var bestDistance = Float.MAX_VALUE
        players.forEachIndexed { index, player ->
            if (index == excluding || index in excluded) return@forEachIndexed
            val distance = player.target.dst2(target)
            if (distance < bestDistance) {
                bestDistance = distance
                bestIndex = index
            }
        }
        return bestIndex
    }

    fun supportRun(
        players: List<GdxPlayerState>,
        destination: Vector2,
        excluding: Set<Int>,
        attackingHome: Boolean,
    ) {
        val goalY = if (attackingHome) .08f else .92f
        players.indices
            .filter { it !in excluding }
            .sortedBy { players[it].target.dst2(destination) }
            .take(2)
            .forEach { index ->
                val current = players[index].target
                players[index].target.set(
                    (current.x * .65f + destination.x * .35f).coerceIn(.08f, .92f),
                    (current.y * .72f + goalY * .28f).coerceIn(.07f, .93f),
                )
            }
    }

    fun attackBox(
        players: List<GdxPlayerState>,
        start: Vector2,
        activeIndex: Int,
        attackingHome: Boolean,
    ) {
        val goalY = if (attackingHome) .06f else .94f
        players.indices
            .filter { it != activeIndex }
            .sortedBy { players[it].target.dst2(start) }
            .take(3)
            .forEach { index ->
                val current = players[index].target
                players[index].target.set(
                    (current.x * .70f + start.x * .30f).coerceIn(.10f, .90f),
                    (current.y * .58f + goalY * .42f).coerceIn(.08f, .92f),
                )
            }
    }

    fun defendShot(
        players: List<GdxPlayerState>,
        target: Vector2,
        defendingHome: Boolean,
    ) {
        if (players.isEmpty()) return
        val goalY = if (defendingHome) .90f else .10f
        players[0].target.set(target.x.coerceIn(.34f, .66f), goalY)

        players.indices
            .filter { it != 0 }
            .sortedBy { players[it].target.dst2(target) }
            .take(2)
            .forEach { index ->
                val current = players[index].target
                players[index].target.set(
                    (current.x * .62f + target.x * .38f).coerceIn(.12f, .88f),
                    (current.y * .70f + goalY * .30f).coerceIn(.08f, .92f),
                )
            }
    }

    fun penaltySetup(
        attackers: List<GdxPlayerState>,
        defenders: List<GdxPlayerState>,
        takerIndex: Int,
        spot: Vector2,
        attackingHome: Boolean,
    ): Pair<Set<Int>, Set<Int>> {
        if (attackers.isEmpty() || defenders.isEmpty()) return emptySet<Int>() to emptySet()
        val safeTaker = takerIndex.coerceIn(0, attackers.lastIndex)
        val movedAttackers = linkedSetOf(safeTaker)
        val movedDefenders = linkedSetOf(0)

        attackers[safeTaker].target.set(playerPoint(spot))
        val attackingBoundary = if (attackingHome) .29f else .71f
        val defendingBoundary = if (attackingHome) .255f else .745f

        // Preserve players already outside the penalty approach instead of
        // pulling almost all 22 athletes into one narrow line.
        for (index in 1 until attackers.size) {
            if (index == safeTaker) continue
            val current = attackers[index].target
            if (!insidePenaltyApproach(current.y, attackingHome, attackingBoundary)) continue
            attackers[index].target.set(
                penaltyWaitingPoint(
                    current = current,
                    index = index,
                    attackingHome = attackingHome,
                    boundary = attackingBoundary,
                    teamOffset = .020f,
                ),
            )
            movedAttackers += index
        }

        defenders[0].target.set(.5f, if (attackingHome) .10f else .90f)
        for (index in 1 until defenders.size) {
            val current = defenders[index].target
            if (!insidePenaltyApproach(current.y, attackingHome, defendingBoundary)) continue
            defenders[index].target.set(
                penaltyWaitingPoint(
                    current = current,
                    index = index,
                    attackingHome = attackingHome,
                    boundary = defendingBoundary,
                    teamOffset = 0f,
                ),
            )
            movedDefenders += index
        }
        return movedAttackers to movedDefenders
    }

    fun celebrationRun(
        players: List<GdxPlayerState>,
        scorerIndex: Int,
        start: Vector2,
        attackingHome: Boolean,
    ) {
        if (players.isEmpty()) return
        val safeScorer = scorerIndex.coerceIn(0, players.lastIndex)
        val celebrationY = if (attackingHome) .14f else .86f
        val celebrationX = (start.x + if (start.x < .5f) -.08f else .08f)
            .coerceIn(.15f, .85f)
        players[safeScorer].target.set(celebrationX, celebrationY)

        val partners = players.indices
            .filter { it != safeScorer }
            .sortedBy { players[it].target.dst2(start) }
            .take(4)
        partners.forEachIndexed { slot, index ->
            val side = if (slot % 2 == 0) -1f else 1f
            players[index].target.set(
                (celebrationX + side * (.035f + (slot / 2) * .025f)).coerceIn(.10f, .90f),
                (celebrationY + .035f + (slot / 2) * .025f).coerceIn(.08f, .92f),
            )
        }
    }

    fun moveTeam(players: List<GdxPlayerState>, dt: Float, replay: Boolean) {
        players.forEachIndexed { index, player ->
            val state = player.motion
            val lastTarget = state.lastTarget
            when {
                lastTarget == null && player.position.dst2(player.target) <= TARGET_EPSILON_SQUARED -> {
                    state.lastTarget = Vector2(player.target)
                    state.clearPreparedTransition()
                }
                lastTarget == null || lastTarget.dst2(player.target) > TARGET_EPSILON_SQUARED -> {
                    beginTransition(player, index)
                }
            }

            var remaining = dt.coerceIn(0f, .12f)
            while (remaining > 0f) {
                val step = min(.025f, remaining)
                advancePlayer(player, step, replay, goalkeeper = index == 0)
                remaining -= step
            }
        }
    }

    fun preparePenaltyTransitions(
        attackers: List<GdxPlayerState>,
        defenders: List<GdxPlayerState>,
        takerIndex: Int,
        attackingIndexes: Set<Int>,
        defendingIndexes: Set<Int>,
    ) {
        clearPreparedTransitions(attackers)
        clearPreparedTransitions(defenders)
        attackingIndexes.forEach { index ->
            val delay = if (index == takerIndex) 0f else .08f + (index % 4) * .035f
            attackers.getOrNull(index)?.motion?.prepareNextTransition(
                delay = delay,
                curveScale = if (index == takerIndex) .30f else .65f,
            )
        }
        defendingIndexes.forEach { index ->
            defenders.getOrNull(index)?.motion?.prepareNextTransition(
                delay = if (index == 0) .025f else .12f + (index % 4) * .035f,
                curveScale = if (index == 0) .20f else .65f,
            )
        }
    }

    fun prepareFormationReturn(
        players: List<GdxPlayerState>,
        formation: List<Vector2>,
        home: Boolean,
    ) {
        players.forEachIndexed { index, player ->
            player.motion.clearPreparedTransition()
            val target = formation.getOrNull(index) ?: return@forEachIndexed
            if (player.position.dst2(target) < TARGET_EPSILON_SQUARED) return@forEachIndexed
            val sectorDelay = when (index) {
                0 -> .12f
                in 1..4 -> .04f
                in 5..7 -> .11f
                else -> .19f
            }
            player.motion.prepareNextTransition(
                delay = sectorDelay + (index % 3) * .035f + if (home) 0f else .025f,
                curveScale = .72f,
            )
        }
    }

    fun clearPreparedTransitions(players: List<GdxPlayerState>) {
        players.forEach { it.motion.clearPreparedTransition() }
    }

    private fun insidePenaltyApproach(y: Float, attackingHome: Boolean, boundary: Float): Boolean =
        if (attackingHome) y < boundary else y > boundary

    private fun penaltyWaitingPoint(
        current: Vector2,
        index: Int,
        attackingHome: Boolean,
        boundary: Float,
        teamOffset: Float,
    ): Vector2 {
        val row = (index - 1) / 4
        val depth = teamOffset + row * .018f
        val lateral = ((index % 3) - 1) * .012f
        return Vector2(
            (current.x + lateral).coerceIn(.10f, .90f),
            (boundary + if (attackingHome) depth else -depth).coerceIn(.12f, .88f),
        )
    }

    private fun beginTransition(player: GdxPlayerState, index: Int) {
        val state = player.motion
        state.lastTarget = Vector2(player.target)
        state.transitionStart = Vector2(player.position)
        state.initialDistance = player.position.dst(player.target)
        state.transitionCount += 1
        state.delayRemaining = state.preparedDelay ?: if (index == 0) {
            .015f
        } else {
            .025f * ((state.seed + index) % 4) + .018f * (index / 4)
        }
        val sign = if ((state.seed + state.transitionCount) % 2 == 0) 1f else -1f
        state.curveStrength = if (state.initialDistance < .07f) {
            0f
        } else {
            min(.032f, state.initialDistance * .11f) * sign * state.preparedCurveScale
        }
        state.clearPreparedTransition()
    }

    private fun advancePlayer(
        player: GdxPlayerState,
        dt: Float,
        replay: Boolean,
        goalkeeper: Boolean,
    ) {
        val state = player.motion
        if (state.delayRemaining > 0f) {
            state.delayRemaining = max(0f, state.delayRemaining - dt)
            val braking = (if (replay) 1.8f else 3.0f) * dt
            state.velocityX = approach(state.velocityX, 0f, braking)
            state.velocityY = approach(state.velocityY, 0f, braking)
            return
        }

        val dx = player.target.x - player.position.x
        val dy = player.target.y - player.position.y
        val distance = sqrt(dx * dx + dy * dy)
        if (distance < .0015f && state.speed < .025f) {
            state.velocityX = 0f
            state.velocityY = 0f
            player.position.set(player.target)
            return
        }

        var guidanceX = player.target.x
        var guidanceY = player.target.y
        val start = state.transitionStart
        if (start != null && state.initialDistance > .001f && distance > .025f) {
            val routeX = player.target.x - start.x
            val routeY = player.target.y - start.y
            val routeLength = sqrt(routeX * routeX + routeY * routeY)
            if (routeLength > .001f) {
                val progress = (1f - distance / state.initialDistance).coerceIn(0f, 1f)
                val bend = sin(progress * PI.toFloat()) * state.curveStrength
                guidanceX += -routeY / routeLength * bend
                guidanceY += routeX / routeLength * bend
            }
        }

        var guideX = guidanceX - player.position.x
        var guideY = guidanceY - player.position.y
        var guideDistance = sqrt(guideX * guideX + guideY * guideY)
        if (guideDistance < .001f) {
            guideX = dx
            guideY = dy
            guideDistance = max(distance, .001f)
        }

        val maximumSpeed = (if (replay) .42f else .66f) * if (goalkeeper) .90f else 1f
        val deceleration = if (replay) 1.15f else 1.90f
        val desiredSpeed = min(maximumSpeed, sqrt(2f * deceleration * distance))
        val desiredX = guideX / guideDistance * desiredSpeed
        val desiredY = guideY / guideDistance * desiredSpeed
        val acceleration = (if (replay) 1.35f else 2.55f) * dt
        state.velocityX = approach(state.velocityX, desiredX, acceleration)
        state.velocityY = approach(state.velocityY, desiredY, acceleration)

        val nextX = (player.position.x + state.velocityX * dt).coerceIn(.04f, .96f)
        val nextY = (player.position.y + state.velocityY * dt).coerceIn(.04f, .96f)
        player.position.set(nextX, nextY)
        if (player.position.dst2(player.target) < ARRIVAL_EPSILON_SQUARED && state.speed < .05f) {
            state.velocityX = 0f
            state.velocityY = 0f
            player.position.set(player.target)
        }
    }

    private fun approach(current: Float, target: Float, maximumDelta: Float): Float {
        val difference = target - current
        if (abs(difference) <= maximumDelta) return target
        return current + if (difference > 0f) maximumDelta else -maximumDelta
    }

    private const val TARGET_EPSILON_SQUARED = .00000025f
    private const val ARRIVAL_EPSILON_SQUARED = .00000225f
}
