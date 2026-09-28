import SwiftUI

// MARK: - Palette

enum MuscleHeatPalette {
    /// Low load = yellow, medium = orange, high = red.
    private static let stops: [(position: Double, red: Double, green: Double, blue: Double)] = [
        (0.00, 1.000, 0.878, 0.200),
        (0.50, 1.000, 0.545, 0.090),
        (1.00, 0.945, 0.160, 0.110)
    ]

    static func components(for rawValue: Double) -> (red: Double, green: Double, blue: Double) {
        let value = max(0, min(1, rawValue))
        for index in 1..<stops.count where value <= stops[index].position {
            let low = stops[index - 1]
            let high = stops[index]
            let t = (value - low.position) / (high.position - low.position)
            return (
                low.red + (high.red - low.red) * t,
                low.green + (high.green - low.green) * t,
                low.blue + (high.blue - low.blue) * t
            )
        }
        let last = stops[stops.count - 1]
        return (last.red, last.green, last.blue)
    }

    static func color(for rawValue: Double) -> Color {
        guard rawValue > 0 else { return inactive }
        let c = components(for: rawValue)
        return Color(red: c.red, green: c.green, blue: c.blue)
    }

    /// Slightly brighter tint used at the top of each muscle for a rounded look.
    static func highlight(for rawValue: Double) -> Color {
        let c = components(for: rawValue)
        return Color(red: min(1, c.red + 0.06), green: min(1, c.green + 0.16), blue: min(1, c.blue + 0.10))
    }

    /// Darker shade used at the bottom of each muscle.
    static func shade(for rawValue: Double) -> Color {
        let c = components(for: rawValue)
        return Color(red: c.red * 0.78, green: c.green * 0.62, blue: c.blue * 0.62)
    }

    static func glow(for rawValue: Double) -> Color {
        guard rawValue > 0 else { return .clear }
        return color(for: rawValue).opacity(0.35 + (0.30 * min(1, rawValue)))
    }

    static let inactive = Color(white: 0.105)
    static let legendGradient = Gradient(colors: [color(for: 0.001), color(for: 0.5), color(for: 1)])
}

// MARK: - Anatomy data

/// Muscle and silhouette outlines in a 200 x 440 design space (SVG path syntax,
/// absolute M/L/C/Q/Z commands). Shapes are drawn for the viewer's left half and
/// mirrored around x = 100.
private enum MuscleAnatomy {
    static let size = CGSize(width: 200, height: 440)

    struct Outline {
        let muscle: String
        let path: Path
    }

    // Silhouette ------------------------------------------------------------

    static let head = SVGPath.parse(
        "M100,8 C112,8 119,18 119,32 C119,44 113,53 100,57 C87,53 81,44 81,32 C81,18 88,8 100,8 Z"
    )

    static let bodyHalves: [Path] = mirrored([
        // Neck, torso and leg.
        """
        M101,50 L91,52 C90,58 90,62 89,66 C80,70 66,73 54,78 C48,82 50,100 56,112
        C60,130 62,150 66,168 C69,182 68,196 64,208 C58,226 55,250 57,280
        C58,300 62,312 64,322 C60,340 60,360 64,384 C66,396 70,404 72,412
        C66,420 62,428 66,433 L94,434 C96,428 95,420 94,412 C95,396 95,370 93,350
        C92,338 92,330 93,322 C96,300 98,268 99,240 L101,230 Z
        """,
        // Arm.
        """
        M62,76 C48,75 39,82 35,94 C31,108 30,130 28,150 C26,162 22,178 19,195
        C16,212 13,226 12,240 L24,242 C27,226 32,212 36,198 C40,184 43,172 45,160
        C49,142 54,126 60,110 Z
        """,
        // Hand.
        """
        M12,236 C8,246 4,256 5,266 C6,274 11,280 17,278 C22,275 25,264 26,254
        C26,248 25,244 24,240 Z
        """
    ])

    // Front -----------------------------------------------------------------

    static let front: [Outline] = shapes([
        ("Neck", "M91,56 C92,62 95,68 99,74 L97,76 C93,71 90,64 89,58 Z"),
        ("Traps", "M88,64 C80,68 70,72 61,76 C70,78 80,77 89,72 C90,69 89,66 88,64 Z"),

        ("Side Delts", "M58,78 C47,77 39,84 36,96 C35,104 37,110 40,114 C42,104 45,95 49,89 C52,84 55,80 58,78 Z"),
        ("Front Delts", "M61,80 C55,84 50,91 47,99 C45,106 45,112 47,117 C52,111 57,104 61,98 C63,92 64,86 63,81 Z"),

        ("Upper Chest", "M98,80 C88,79 76,80 66,83 C64,87 64,91 65,95 C76,93 88,93 98,94 Z"),
        ("Mid Chest", "M98,97 C88,96 76,96 65,98 C61,104 61,110 63,114 C74,116 86,116 98,116 Z"),
        ("Lower Chest", "M98,119 C87,119 75,119 64,117 C69,125 77,130 86,132 C91,133 96,132 98,130 Z"),

        ("Biceps", "M47,120 C43,127 39,138 38,149 C38,157 41,162 44,164 C48,156 51,145 52,133 C52,125 50,120 47,120 Z"),
        ("Brachialis", "M35,126 C32,138 30,151 31,161 C33,164 35,162 37,158 C36,148 36,137 35,126 Z"),
        ("Forearms", "M43,168 C37,173 31,183 27,196 C23,210 20,223 19,233 L23,234 C27,222 31,210 35,198 C38,188 42,178 43,168 Z"),
        ("Forearms", "M29,168 C25,178 21,192 18,206 C16,216 15,225 14,232 L17,233 C19,220 22,207 26,195 C28,185 30,176 29,168 Z"),

        ("Obliques", "M63,121 C66,140 68,160 70,178 C72,189 74,197 78,204 C82,196 84,184 84,170 C84,152 80,136 74,126 C70,122 66,120 63,121 Z"),
        ("Abs", "M89,134 Q87,134 87,136 L87,147 Q87,149 89,149 L98,149 L98,134 Z"),
        ("Abs", "M88,152 Q86,152 86,154 L86,165 Q86,167 88,167 L98,167 L98,152 Z"),
        ("Abs", "M88,170 Q86,170 86,172 L86,183 Q86,185 88,185 L98,185 L98,170 Z"),
        ("Abs", "M88,188 Q86,188 86,190 C86,200 90,211 98,221 L98,188 Z"),

        ("Hip Flexors", "M80,208 C84,213 88,219 92,227 C89,232 85,235 81,234 C79,226 78,217 80,208 Z"),
        ("Abductors", "M67,203 C63,209 61,215 61,223 C63,227 65,225 67,221 C69,215 69,209 67,203 Z"),
        ("Adductors", "M97,233 C91,239 87,249 87,263 C89,265 91,263 93,259 C96,251 98,243 99,237 Z"),

        ("Quadriceps", "M65,215 C59,233 57,256 59,280 C61,296 63,306 67,314 C71,300 73,280 73,260 C73,242 71,227 65,215 Z"),
        ("Quadriceps", "M77,222 C73,240 73,262 75,284 C76,296 78,304 81,310 C85,300 87,286 87,266 C87,248 83,232 77,222 Z"),
        ("Quadriceps", "M89,266 C85,279 83,293 83,306 C85,314 89,316 92,312 C94,300 94,287 92,274 C91,269 90,267 89,266 Z"),

        ("Shins", "M68,332 C64,347 64,365 67,384 C68,392 70,398 72,402 C74,390 76,372 76,354 C76,343 73,335 68,332 Z"),
        ("Calves", "M87,333 C83,346 82,362 84,378 C88,372 91,361 92,349 C92,341 90,336 87,333 Z")
    ])

    // Back ------------------------------------------------------------------

    static let back: [Outline] = shapes([
        ("Neck", "M91,54 C90,59 90,63 90,66 C93,65 95,61 96,56 Z"),
        ("Traps", "M99,56 C96,62 92,66 88,68 C78,72 67,74 59,78 C69,84 80,92 89,103 C94,112 97,122 99,134 Z"),

        ("Rear Delts", "M57,78 C46,77 38,84 35,96 C34,104 36,110 40,114 C46,104 52,96 60,90 C60,85 59,81 57,78 Z"),
        ("Upper Back", "M61,89 C67,93 77,99 86,107 C90,113 92,119 92,125 C80,123 68,119 58,113 C56,105 57,95 61,89 Z"),
        ("Lats", "M58,117 C70,121 81,125 90,129 C91,141 90,153 88,165 C85,177 81,187 76,195 C70,180 66,160 62,140 C60,132 58,124 58,117 Z"),
        ("Spinal Erectors", "M94,137 C96,151 98,171 98,196 L98,207 L91,207 C89,195 89,179 90,162 C91,152 92,144 94,137 Z"),

        ("Triceps", "M51,113 C45,119 41,129 39,141 C37,153 39,161 43,167 C47,161 51,151 53,139 C55,129 55,119 51,113 Z"),
        ("Triceps", "M36,114 C32,126 30,141 30,155 C32,161 34,161 36,157 C36,143 37,127 38,115 Z"),
        ("Forearms", "M43,168 C37,173 31,183 27,196 C23,210 20,223 19,233 L23,234 C27,222 31,210 35,198 C38,188 42,178 43,168 Z"),
        ("Forearms", "M29,168 C25,178 21,192 18,206 C16,216 15,225 14,232 L17,233 C19,220 22,207 26,195 C28,185 30,176 29,168 Z"),

        ("Abductors", "M70,197 C66,204 64,212 64,220 C72,218 81,214 90,210 C86,204 80,199 70,197 Z"),
        ("Glutes", "M64,223 C62,237 64,251 72,259 C80,265 92,263 99,257 L99,213 C88,215 76,219 64,223 Z"),

        ("Hamstrings", "M62,265 C58,281 58,299 62,313 C64,318 66,320 68,320 C70,304 72,286 72,268 Z"),
        ("Hamstrings", "M76,268 C74,286 76,304 80,318 C84,316 88,312 90,306 C92,292 94,278 94,266 C88,268 82,268 76,268 Z"),
        ("Adductors", "M97,262 C95,272 93,284 93,296 C95,290 97,280 98,270 Z"),

        ("Calves", "M66,330 C62,342 62,356 66,368 C68,374 72,376 76,374 C78,360 78,344 76,332 C72,328 68,328 66,330 Z"),
        ("Calves", "M80,330 C78,344 78,360 80,374 C84,378 90,374 92,366 C94,354 92,340 88,332 C86,328 82,328 80,330 Z"),
        ("Calves", "M68,379 C68,390 70,399 73,405 L78,405 C80,397 84,388 88,379 C82,383 74,383 68,379 Z")
    ])

    // Helpers ---------------------------------------------------------------

    private static let mirror = CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: size.width, ty: 0)

    private static func mirrored(_ data: [String]) -> [Path] {
        data.flatMap { string -> [Path] in
            let path = SVGPath.parse(string)
            return [path, path.applying(mirror)]
        }
    }

    private static func shapes(_ data: [(String, String)]) -> [Outline] {
        data.flatMap { entry -> [Outline] in
            let path = SVGPath.parse(entry.1)
            return [Outline(muscle: entry.0, path: path), Outline(muscle: entry.0, path: path.applying(mirror))]
        }
    }
}

/// Minimal parser for absolute SVG path data (M, L, Q, C, Z).
private enum SVGPath {
    static func parse(_ data: String) -> Path {
        var tokens: [String] = []
        var number = ""

        func flush() {
            if !number.isEmpty { tokens.append(number) }
            number = ""
        }

        for character in data {
            if character.isLetter {
                flush()
                tokens.append(String(character))
            } else if character == "-" {
                flush()
                number = "-"
            } else if character.isNumber || character == "." {
                number.append(character)
            } else {
                flush()
            }
        }
        flush()

        var path = Path()
        var index = 0
        var command: Character = "M"

        func point() -> CGPoint? {
            guard index + 1 < tokens.count,
                  let x = Double(tokens[index]),
                  let y = Double(tokens[index + 1]) else { return nil }
            index += 2
            return CGPoint(x: x, y: y)
        }

        while index < tokens.count {
            if let letter = tokens[index].first, letter.isLetter {
                command = letter
                index += 1
                if command == "Z" || command == "z" {
                    path.closeSubpath()
                }
                continue
            }

            switch command {
            case "M":
                guard let p = point() else { return path }
                path.move(to: p)
                command = "L"
            case "L":
                guard let p = point() else { return path }
                path.addLine(to: p)
            case "Q":
                guard let control = point(), let p = point() else { return path }
                path.addQuadCurve(to: p, control: control)
            case "C":
                guard let c1 = point(), let c2 = point(), let p = point() else { return path }
                path.addCurve(to: p, control1: c1, control2: c2)
            default:
                index += 1
            }
        }
        return path
    }
}

// MARK: - Figure

struct BodyMuscleFigure: View {
    let side: MuscleContribution.BodySide
    let intensity: [String: Double]

    var body: some View {
        VStack(spacing: 6) {
            Canvas { context, size in
                draw(in: &context, size: size)
            }
            .aspectRatio(MuscleAnatomy.size.width / MuscleAnatomy.size.height, contentMode: .fit)

            Text(side == .front ? L10n.text("FRONT", "VOOR") : L10n.text("BACK", "ACHTER"))
                .font(.caption2.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(Color.white.opacity(0.55))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            side == .front
                ? L10n.text("Front muscle heatmap", "Spierkaart voorkant")
                : L10n.text("Back muscle heatmap", "Spierkaart achterkant")
        )
    }

    private func draw(in context: inout GraphicsContext, size: CGSize) {
        let design = MuscleAnatomy.size
        let scale = min(size.width / design.width, size.height / design.height)
        let transform = CGAffineTransform(
            translationX: (size.width - design.width * scale) / 2,
            y: (size.height - design.height * scale) / 2
        ).scaledBy(x: scale, y: scale)

        let silhouette = ([MuscleAnatomy.head] + MuscleAnatomy.bodyHalves).map { $0.applying(transform) }
        let shapes = side == .front ? MuscleAnatomy.front : MuscleAnatomy.back

        // Soft white rim light around the body.
        context.drawLayer { layer in
            layer.addFilter(.blur(radius: 3 * scale))
            for part in silhouette {
                layer.stroke(part, with: .color(.white.opacity(0.28)), lineWidth: 3 * scale)
            }
        }
        // Crisp outline. Drawn before the fill so the overlapping halves merge
        // into one outer contour.
        for part in silhouette {
            context.stroke(part, with: .color(Color(white: 0.78)), lineWidth: 2.2 * scale)
        }
        for part in silhouette {
            context.fill(part, with: .color(Color(white: 0.03)))
        }

        // Glow behind trained muscles.
        context.drawLayer { layer in
            layer.addFilter(.blur(radius: 5 * scale))
            for shape in shapes {
                let value = intensity[shape.muscle] ?? 0
                guard value > 0 else { continue }
                layer.fill(shape.path.applying(transform), with: .color(MuscleHeatPalette.glow(for: value)))
            }
        }

        for shape in shapes {
            let value = intensity[shape.muscle] ?? 0
            let path = shape.path.applying(transform)
            let bounds = path.boundingRect

            if value > 0 {
                context.fill(
                    path,
                    with: .linearGradient(
                        Gradient(stops: [
                            .init(color: MuscleHeatPalette.highlight(for: value), location: 0),
                            .init(color: MuscleHeatPalette.color(for: value), location: 0.45),
                            .init(color: MuscleHeatPalette.shade(for: value), location: 1)
                        ]),
                        startPoint: CGPoint(x: bounds.minX, y: bounds.minY),
                        endPoint: CGPoint(x: bounds.maxX, y: bounds.maxY)
                    )
                )
                drawFibers(in: &context, path: path, bounds: bounds, scale: scale)
            } else {
                context.fill(path, with: .color(MuscleHeatPalette.inactive))
            }

            // Thin dark seam keeps neighbouring muscles visually separate.
            context.stroke(path, with: .color(.black.opacity(0.85)), lineWidth: 0.9 * scale)
        }
    }

    /// Subtle striations that give filled muscles a fibrous texture.
    private func drawFibers(in context: inout GraphicsContext, path: Path, bounds: CGRect, scale: CGFloat) {
        context.drawLayer { layer in
            layer.clip(to: path)
            var lines = Path()
            let spacing = 2.6 * scale
            var x = bounds.minX - bounds.height
            while x < bounds.maxX + bounds.height {
                lines.move(to: CGPoint(x: x, y: bounds.minY))
                lines.addLine(to: CGPoint(x: x + bounds.height * 0.18, y: bounds.maxY))
                x += spacing
            }
            layer.stroke(lines, with: .color(.black.opacity(0.10)), lineWidth: 0.5 * scale)
        }
    }
}

// MARK: - Legend

struct MuscleHeatLegend: View {
    var body: some View {
        HStack(spacing: 8) {
            Text(L10n.text("Low", "Laag"))
            Capsule()
                .fill(LinearGradient(gradient: MuscleHeatPalette.legendGradient, startPoint: .leading, endPoint: .trailing))
                .frame(height: 6)
            Text(L10n.text("High", "Hoog"))
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(Color.white.opacity(0.55))
    }
}
