package com.taticamanager.tatica_manager.matchgdx

import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.graphics.OrthographicCamera
import com.badlogic.gdx.graphics.Texture
import com.badlogic.gdx.graphics.g2d.BitmapFont
import com.badlogic.gdx.graphics.g2d.GlyphLayout
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import com.badlogic.gdx.graphics.glutils.ShapeRenderer
import com.badlogic.gdx.math.Rectangle
import java.text.Normalizer
import kotlin.math.max
import kotlin.math.min

internal class LibGdxPlayerLabelPainter(
    private val names: Map<String, String>,
    private val homeTeamColor: Color,
    private val awayTeamColor: Color,
    private val homeGoalkeeperKit: GdxKit,
    private val awayGoalkeeperKit: GdxKit,
) {
    private lateinit var shapes: ShapeRenderer
    private lateinit var batch: SpriteBatch
    private lateinit var font: BitmapFont
    private val layout = GlyphLayout()
    private val placementAnchors = mutableMapOf<String, Int>()

    fun create() {
        shapes = ShapeRenderer()
        batch = SpriteBatch()
        font = BitmapFont().apply {
            color = Color.WHITE
            data.setScale(1.42f)
            region.texture.setFilter(Texture.TextureFilter.Linear, Texture.TextureFilter.Linear)
        }
    }

    fun draw(
        camera: OrthographicCamera,
        entries: List<GdxPlayerRenderEntry>,
        homeIds: List<String>,
        awayIds: List<String>,
        activeHome: Boolean?,
        activeIndex: Int?,
        left: Float,
        bottom: Float,
        fieldWidth: Float,
        fieldHeight: Float,
    ) {
        val placements = buildPlacements(
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
        if (placements.isEmpty()) return

        shapes.projectionMatrix = camera.combined
        shapes.begin(ShapeRenderer.ShapeType.Filled)
        placements.forEach { placement ->
            shapes.color = Color(.018f, .030f, .035f, if (placement.active) .88f else .72f)
            shapes.rect(
                placement.box.x,
                placement.box.y,
                placement.box.width,
                placement.box.height,
            )
            shapes.color = placement.accent
            shapes.rect(placement.box.x, placement.box.y, 3.5f, placement.box.height)
        }
        shapes.end()

        batch.projectionMatrix = camera.combined
        batch.begin()
        placements.forEach { placement ->
            layout.setText(font, placement.text)
            font.color = if (placement.active) {
                Color(1f, .94f, .70f, 1f)
            } else {
                Color.WHITE
            }
            font.draw(batch, layout, placement.x, placement.textTop)
        }
        batch.end()
    }

    private fun buildPlacements(
        entries: List<GdxPlayerRenderEntry>,
        homeIds: List<String>,
        awayIds: List<String>,
        activeHome: Boolean?,
        activeIndex: Int?,
        left: Float,
        bottom: Float,
        fieldWidth: Float,
        fieldHeight: Float,
    ): List<LabelPlacement> {
        val occupied = mutableListOf<Rectangle>()
        val placements = mutableListOf<LabelPlacement>()
        fun playerId(entry: GdxPlayerRenderEntry): String = if (entry.home) {
            homeIds.getOrNull(entry.index).orEmpty()
        } else {
            awayIds.getOrNull(entry.index).orEmpty()
        }.ifBlank { "${if (entry.home) "home" else "away"}:${entry.index}" }

        val prioritized = entries.sortedWith(
            compareByDescending<GdxPlayerRenderEntry> {
                activeHome == it.home && activeIndex == it.index
            }.thenByDescending { it.index == 0 }
                .thenBy { playerId(it) },
        )

        prioritized.forEach { entry ->
            val id = playerId(entry)
            val raw = names[id].orEmpty().trim()
            if (raw.isEmpty()) return@forEach

            val active = activeHome == entry.home && activeIndex == entry.index
            val text = supportedName(compactName(raw, active))
            layout.setText(font, text)
            val boxWidth = layout.width + LABEL_PAD_X * 2f + ACCENT_WIDTH
            val boxHeight = layout.height + LABEL_PAD_Y * 2f
            val p = GdxPitchGeometry.canvasPoint(
                entry.player.position,
                left,
                bottom,
                fieldWidth,
                fieldHeight,
            )
            val depthScale = .90f + GdxPitchGeometry.displayPoint(entry.player.position).y * .16f
            val radius = GdxPitchGeometry.PLAYER_RADIUS * depthScale

            val candidates = listOf(
                Rectangle(p.x - boxWidth / 2f, p.y + radius * 1.55f, boxWidth, boxHeight),
                Rectangle(p.x - boxWidth / 2f, p.y - radius * 1.72f - boxHeight, boxWidth, boxHeight),
                Rectangle(p.x + radius * 1.35f, p.y - boxHeight / 2f, boxWidth, boxHeight),
                Rectangle(p.x - radius * 1.35f - boxWidth, p.y - boxHeight / 2f, boxWidth, boxHeight),
                Rectangle(p.x - boxWidth * .86f, p.y + radius * 1.42f, boxWidth, boxHeight),
                Rectangle(p.x - boxWidth * .14f, p.y + radius * 1.42f, boxWidth, boxHeight),
            ).map {
                clampLabel(
                    rect = it,
                    minX = left + 3f,
                    minY = bottom + 3f,
                    maxX = left + fieldWidth - 3f,
                    maxY = bottom + fieldHeight - 3f,
                )
            }

            val preferred = placementAnchors[id]
            val anchorOrder = buildList {
                if (preferred != null && preferred in candidates.indices) add(preferred)
                candidates.indices.forEach { if (it != preferred) add(it) }
            }
            var chosenAnchor: Int? = null
            var chosen: Rectangle? = null
            var fallbackAnchor: Int? = null
            var fallback: Rectangle? = null
            var lowestOverlap = Float.MAX_VALUE
            for (anchor in anchorOrder) {
                val candidate = candidates[anchor]
                val score = overlapScore(candidate, occupied)
                if (score <= 0f) {
                    chosen = candidate
                    chosenAnchor = anchor
                    break
                }
                if (active && score < lowestOverlap) {
                    lowestOverlap = score
                    fallback = candidate
                    fallbackAnchor = anchor
                }
            }
            val finalBox = chosen ?: fallback ?: return@forEach
            val finalAnchor = chosenAnchor ?: fallbackAnchor ?: return@forEach
            placementAnchors[id] = finalAnchor
            occupied += Rectangle(
                finalBox.x - 2.5f,
                finalBox.y - 2.5f,
                finalBox.width + 5f,
                finalBox.height + 5f,
            )

            placements += LabelPlacement(
                text = text,
                x = finalBox.x + LABEL_PAD_X + ACCENT_WIDTH,
                textTop = finalBox.y + finalBox.height - LABEL_PAD_Y,
                box = finalBox,
                accent = Color(labelAccent(entry, active)),
                active = active,
            )
        }
        return placements
    }

    private fun labelAccent(entry: GdxPlayerRenderEntry, active: Boolean): Color = when {
        active -> Color(1f, .83f, .18f, .95f)
        entry.index == 0 && entry.home -> homeGoalkeeperKit.accent
        entry.index == 0 -> awayGoalkeeperKit.accent
        entry.home -> homeTeamColor
        else -> awayTeamColor
    }

    private fun clampLabel(
        rect: Rectangle,
        minX: Float,
        minY: Float,
        maxX: Float,
        maxY: Float,
    ): Rectangle {
        val upperX = max(minX, maxX - rect.width)
        val upperY = max(minY, maxY - rect.height)
        return Rectangle(
            rect.x.coerceIn(minX, upperX),
            rect.y.coerceIn(minY, upperY),
            rect.width,
            rect.height,
        )
    }

    private fun overlapScore(candidate: Rectangle, occupied: List<Rectangle>): Float {
        var score = 0f
        occupied.forEach { other ->
            val overlapW = min(candidate.x + candidate.width, other.x + other.width) -
                max(candidate.x, other.x)
            val overlapH = min(candidate.y + candidate.height, other.y + other.height) -
                max(candidate.y, other.y)
            if (overlapW > 0f && overlapH > 0f) score += overlapW * overlapH
        }
        return score
    }

    private fun compactName(value: String, active: Boolean = false): String {
        val clean = value.trim().replace(Regex("\\s+"), " ")
        val limit = if (active) 16 else 12
        if (clean.length <= limit) return clean
        val parts = clean.split(' ').filter { it.isNotBlank() }
        val last = parts.lastOrNull().orEmpty()
        if (last.length in 3..limit) return last
        if (parts.size >= 2) {
            val first = parts.first().take(if (active) 11 else 8)
            val initial = parts.last().firstOrNull()?.uppercaseChar()
            if (initial != null) return "$first $initial."
        }
        return clean.take((limit - 3).coerceAtLeast(1)) + "..."
    }

    /**
     * The built-in libGDX bitmap font does not guarantee every Unicode glyph.
     * Keep the real name whenever possible and transliterate only glyphs the
     * loaded font cannot draw, so accented names never disappear as blank boxes.
     */
    private fun supportedName(value: String): String {
        val result = StringBuilder(value.length)
        value.forEach { char ->
            if (font.data.getGlyph(char) != null) {
                result.append(char)
                return@forEach
            }
            val ascii = Normalizer.normalize(char.toString(), Normalizer.Form.NFD)
                .replace(Regex("\\p{M}+"), "")
                .firstOrNull { candidate -> font.data.getGlyph(candidate) != null }
            result.append(ascii ?: '?')
        }
        return result.toString()
    }

    fun dispose() {
        shapes.dispose()
        batch.dispose()
        font.dispose()
    }

    private data class LabelPlacement(
        val text: String,
        val x: Float,
        val textTop: Float,
        val box: Rectangle,
        val accent: Color,
        val active: Boolean,
    )

    companion object {
        private const val LABEL_PAD_X = 6f
        private const val LABEL_PAD_Y = 3f
        private const val ACCENT_WIDTH = 3.5f
    }
}
