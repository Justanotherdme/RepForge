import SwiftUI

enum MuscleHeatPalette {
    static func color(for rawValue: Double) -> Color {
        let value = max(0, min(1, rawValue))
        guard value > 0 else { return Color.white.opacity(0.045) }

        // Low volume = deep amber, high volume = bright red-orange.
        let hue = 0.105 - (0.095 * value)
        let brightness = 0.58 + (0.42 * value)
        return Color(
            hue: hue,
            saturation: 0.96,
            brightness: brightness,
            opacity: 0.68 + (0.32 * value)
        )
    }

    static func glow(for rawValue: Double) -> Color {
        let value = max(0, min(1, rawValue))
        guard value > 0 else { return .clear }
        return color(for: value).opacity(0.18 + (0.32 * value))
    }
}

struct BodyMuscleFigure: View {
    let side: MuscleContribution.BodySide
    let intensity: [String: Double]

    private struct Region: Identifiable {
        let id: String
        let muscle: String
        let points: [CGPoint]

        init(_ id: String, _ muscle: String, _ points: [CGPoint]) {
            self.id = id
            self.muscle = muscle
            self.points = points
        }
    }

    private struct BasePart: Identifiable {
        let id: String
        let points: [CGPoint]

        init(_ id: String, _ points: [CGPoint]) {
            self.id = id
            self.points = points
        }
    }

    private var regions: [Region] {
        side == .front ? frontRegions : backRegions
    }

    private var frontRegions: [Region] {
        [
            Region("front-neck", "Neck", [
                p(0.465, 0.165), p(0.535, 0.165), p(0.558, 0.215), p(0.500, 0.226), p(0.442, 0.215)
            ]),

            Region("front-side-delt-l", "Side Delts", [
                p(0.318, 0.225), p(0.273, 0.235), p(0.245, 0.270), p(0.268, 0.304), p(0.318, 0.292), p(0.344, 0.254)
            ]),
            Region("front-side-delt-r", "Side Delts", mirror([
                p(0.318, 0.225), p(0.273, 0.235), p(0.245, 0.270), p(0.268, 0.304), p(0.318, 0.292), p(0.344, 0.254)
            ])),
            Region("front-delt-l", "Front Delts", [
                p(0.345, 0.218), p(0.402, 0.223), p(0.417, 0.260), p(0.388, 0.294), p(0.330, 0.286), p(0.316, 0.248)
            ]),
            Region("front-delt-r", "Front Delts", mirror([
                p(0.345, 0.218), p(0.402, 0.223), p(0.417, 0.260), p(0.388, 0.294), p(0.330, 0.286), p(0.316, 0.248)
            ])),

            Region("upper-chest-l", "Upper Chest", [
                p(0.405, 0.237), p(0.485, 0.238), p(0.492, 0.290), p(0.421, 0.287), p(0.370, 0.270)
            ]),
            Region("upper-chest-r", "Upper Chest", mirror([
                p(0.405, 0.237), p(0.485, 0.238), p(0.492, 0.290), p(0.421, 0.287), p(0.370, 0.270)
            ])),
            Region("mid-chest-l", "Mid Chest", [
                p(0.369, 0.277), p(0.421, 0.290), p(0.492, 0.293), p(0.490, 0.356), p(0.408, 0.354), p(0.362, 0.325)
            ]),
            Region("mid-chest-r", "Mid Chest", mirror([
                p(0.369, 0.277), p(0.421, 0.290), p(0.492, 0.293), p(0.490, 0.356), p(0.408, 0.354), p(0.362, 0.325)
            ])),
            Region("lower-chest-l", "Lower Chest", [
                p(0.374, 0.334), p(0.410, 0.354), p(0.490, 0.358), p(0.488, 0.390), p(0.425, 0.399), p(0.380, 0.380)
            ]),
            Region("lower-chest-r", "Lower Chest", mirror([
                p(0.374, 0.334), p(0.410, 0.354), p(0.490, 0.358), p(0.488, 0.390), p(0.425, 0.399), p(0.380, 0.380)
            ])),

            Region("biceps-l", "Biceps", [
                p(0.256, 0.310), p(0.302, 0.304), p(0.323, 0.346), p(0.306, 0.423), p(0.267, 0.433), p(0.243, 0.386)
            ]),
            Region("biceps-r", "Biceps", mirror([
                p(0.256, 0.310), p(0.302, 0.304), p(0.323, 0.346), p(0.306, 0.423), p(0.267, 0.433), p(0.243, 0.386)
            ])),
            Region("brachialis-l", "Brachialis", [
                p(0.236, 0.346), p(0.258, 0.325), p(0.265, 0.410), p(0.244, 0.447), p(0.225, 0.415)
            ]),
            Region("brachialis-r", "Brachialis", mirror([
                p(0.236, 0.346), p(0.258, 0.325), p(0.265, 0.410), p(0.244, 0.447), p(0.225, 0.415)
            ])),
            Region("forearm-l", "Forearms", [
                p(0.224, 0.435), p(0.260, 0.438), p(0.268, 0.500), p(0.239, 0.578), p(0.203, 0.566), p(0.194, 0.512)
            ]),
            Region("forearm-r", "Forearms", mirror([
                p(0.224, 0.435), p(0.260, 0.438), p(0.268, 0.500), p(0.239, 0.578), p(0.203, 0.566), p(0.194, 0.512)
            ])),

            Region("oblique-l", "Obliques", [
                p(0.373, 0.388), p(0.413, 0.403), p(0.405, 0.520), p(0.370, 0.574), p(0.342, 0.520), p(0.350, 0.431)
            ]),
            Region("oblique-r", "Obliques", mirror([
                p(0.373, 0.388), p(0.413, 0.403), p(0.405, 0.520), p(0.370, 0.574), p(0.342, 0.520), p(0.350, 0.431)
            ])),

            Region("abs-upper-l", "Abs", [p(0.423,0.397), p(0.489,0.397), p(0.489,0.443), p(0.426,0.444)]),
            Region("abs-upper-r", "Abs", mirror([p(0.423,0.397), p(0.489,0.397), p(0.489,0.443), p(0.426,0.444)])),
            Region("abs-mid-l", "Abs", [p(0.421,0.449), p(0.489,0.449), p(0.489,0.498), p(0.421,0.500)]),
            Region("abs-mid-r", "Abs", mirror([p(0.421,0.449), p(0.489,0.449), p(0.489,0.498), p(0.421,0.500)])),
            Region("abs-low-l", "Abs", [p(0.417,0.505), p(0.489,0.505), p(0.489,0.557), p(0.425,0.565)]),
            Region("abs-low-r", "Abs", mirror([p(0.417,0.505), p(0.489,0.505), p(0.489,0.557), p(0.425,0.565)])),
            Region("abs-pelvic-l", "Abs", [p(0.426,0.568), p(0.489,0.562), p(0.489,0.602), p(0.445,0.606)]),
            Region("abs-pelvic-r", "Abs", mirror([p(0.426,0.568), p(0.489,0.562), p(0.489,0.602), p(0.445,0.606)])),

            Region("hip-flex-l", "Hip Flexors", [
                p(0.399, 0.574), p(0.443, 0.604), p(0.445, 0.651), p(0.401, 0.635), p(0.376, 0.606)
            ]),
            Region("hip-flex-r", "Hip Flexors", mirror([
                p(0.399, 0.574), p(0.443, 0.604), p(0.445, 0.651), p(0.401, 0.635), p(0.376, 0.606)
            ])),
            Region("abductor-l", "Abductors", [
                p(0.348, 0.586), p(0.399, 0.574), p(0.399, 0.651), p(0.368, 0.694), p(0.337, 0.663)
            ]),
            Region("abductor-r", "Abductors", mirror([
                p(0.348, 0.586), p(0.399, 0.574), p(0.399, 0.651), p(0.368, 0.694), p(0.337, 0.663)
            ])),
            Region("adductor-l", "Adductors", [
                p(0.445, 0.630), p(0.487, 0.620), p(0.474, 0.778), p(0.438, 0.735)
            ]),
            Region("adductor-r", "Adductors", mirror([
                p(0.445, 0.630), p(0.487, 0.620), p(0.474, 0.778), p(0.438, 0.735)
            ])),

            Region("quad-outer-l", "Quadriceps", [
                p(0.350, 0.649), p(0.403, 0.640), p(0.416, 0.775), p(0.390, 0.833), p(0.347, 0.804), p(0.330, 0.713)
            ]),
            Region("quad-outer-r", "Quadriceps", mirror([
                p(0.350, 0.649), p(0.403, 0.640), p(0.416, 0.775), p(0.390, 0.833), p(0.347, 0.804), p(0.330, 0.713)
            ])),
            Region("quad-center-l", "Quadriceps", [
                p(0.402, 0.646), p(0.441, 0.650), p(0.444, 0.805), p(0.414, 0.842), p(0.392, 0.797)
            ]),
            Region("quad-center-r", "Quadriceps", mirror([
                p(0.402, 0.646), p(0.441, 0.650), p(0.444, 0.805), p(0.414, 0.842), p(0.392, 0.797)
            ])),
            Region("quad-inner-l", "Quadriceps", [
                p(0.437, 0.648), p(0.470, 0.681), p(0.465, 0.786), p(0.443, 0.831), p(0.421, 0.790)
            ]),
            Region("quad-inner-r", "Quadriceps", mirror([
                p(0.437, 0.648), p(0.470, 0.681), p(0.465, 0.786), p(0.443, 0.831), p(0.421, 0.790)
            ])),
            Region("shin-l", "Shins", [
                p(0.365, 0.842), p(0.420, 0.846), p(0.414, 0.955), p(0.379, 0.959), p(0.356, 0.909)
            ]),
            Region("shin-r", "Shins", mirror([
                p(0.365, 0.842), p(0.420, 0.846), p(0.414, 0.955), p(0.379, 0.959), p(0.356, 0.909)
            ]))
        ]
    }

    private var backRegions: [Region] {
        [
            Region("back-neck", "Neck", [
                p(0.466, 0.165), p(0.534, 0.165), p(0.556, 0.216), p(0.500, 0.231), p(0.444, 0.216)
            ]),
            Region("trap-l", "Traps", [
                p(0.445,0.206), p(0.495,0.224), p(0.493,0.340), p(0.416,0.303), p(0.353,0.248)
            ]),
            Region("trap-r", "Traps", mirror([
                p(0.445,0.206), p(0.495,0.224), p(0.493,0.340), p(0.416,0.303), p(0.353,0.248)
            ])),
            Region("rear-delt-l", "Rear Delts", [
                p(0.338,0.226), p(0.283,0.235), p(0.248,0.270), p(0.274,0.307), p(0.331,0.294), p(0.361,0.254)
            ]),
            Region("rear-delt-r", "Rear Delts", mirror([
                p(0.338,0.226), p(0.283,0.235), p(0.248,0.270), p(0.274,0.307), p(0.331,0.294), p(0.361,0.254)
            ])),
            Region("upper-back-l", "Upper Back", [
                p(0.365,0.266), p(0.421,0.292), p(0.491,0.342), p(0.453,0.390), p(0.376,0.352), p(0.344,0.303)
            ]),
            Region("upper-back-r", "Upper Back", mirror([
                p(0.365,0.266), p(0.421,0.292), p(0.491,0.342), p(0.453,0.390), p(0.376,0.352), p(0.344,0.303)
            ])),
            Region("lat-l", "Lats", [
                p(0.342,0.327), p(0.404,0.363), p(0.451,0.397), p(0.425,0.514), p(0.375,0.556), p(0.337,0.488), p(0.322,0.394)
            ]),
            Region("lat-r", "Lats", mirror([
                p(0.342,0.327), p(0.404,0.363), p(0.451,0.397), p(0.425,0.514), p(0.375,0.556), p(0.337,0.488), p(0.322,0.394)
            ])),
            Region("triceps-l", "Triceps", [
                p(0.257,0.310), p(0.301,0.306), p(0.320,0.350), p(0.303,0.427), p(0.264,0.435), p(0.243,0.382)
            ]),
            Region("triceps-r", "Triceps", mirror([
                p(0.257,0.310), p(0.301,0.306), p(0.320,0.350), p(0.303,0.427), p(0.264,0.435), p(0.243,0.382)
            ])),
            Region("back-forearm-l", "Forearms", [
                p(0.224,0.436), p(0.260,0.439), p(0.267,0.502), p(0.238,0.579), p(0.203,0.567), p(0.194,0.512)
            ]),
            Region("back-forearm-r", "Forearms", mirror([
                p(0.224,0.436), p(0.260,0.439), p(0.267,0.502), p(0.238,0.579), p(0.203,0.567), p(0.194,0.512)
            ])),
            Region("erector-l", "Spinal Erectors", [
                p(0.455,0.384), p(0.487,0.354), p(0.486,0.567), p(0.463,0.603), p(0.444,0.532)
            ]),
            Region("erector-r", "Spinal Erectors", mirror([
                p(0.455,0.384), p(0.487,0.354), p(0.486,0.567), p(0.463,0.603), p(0.444,0.532)
            ])),
            Region("glute-med-l", "Abductors", [
                p(0.366,0.574), p(0.425,0.565), p(0.438,0.622), p(0.402,0.649), p(0.351,0.625)
            ]),
            Region("glute-med-r", "Abductors", mirror([
                p(0.366,0.574), p(0.425,0.565), p(0.438,0.622), p(0.402,0.649), p(0.351,0.625)
            ])),
            Region("glute-l", "Glutes", [
                p(0.354,0.616), p(0.432,0.610), p(0.485,0.642), p(0.469,0.706), p(0.408,0.728), p(0.350,0.695)
            ]),
            Region("glute-r", "Glutes", mirror([
                p(0.354,0.616), p(0.432,0.610), p(0.485,0.642), p(0.469,0.706), p(0.408,0.728), p(0.350,0.695)
            ])),
            Region("ham-outer-l", "Hamstrings", [
                p(0.350,0.711), p(0.405,0.722), p(0.418,0.830), p(0.391,0.858), p(0.349,0.823), p(0.333,0.752)
            ]),
            Region("ham-outer-r", "Hamstrings", mirror([
                p(0.350,0.711), p(0.405,0.722), p(0.418,0.830), p(0.391,0.858), p(0.349,0.823), p(0.333,0.752)
            ])),
            Region("ham-inner-l", "Hamstrings", [
                p(0.404,0.718), p(0.460,0.711), p(0.454,0.822), p(0.421,0.857), p(0.397,0.821)
            ]),
            Region("ham-inner-r", "Hamstrings", mirror([
                p(0.404,0.718), p(0.460,0.711), p(0.454,0.822), p(0.421,0.857), p(0.397,0.821)
            ])),
            Region("calf-outer-l", "Calves", [
                p(0.352,0.845), p(0.394,0.842), p(0.414,0.893), p(0.399,0.956), p(0.367,0.959), p(0.347,0.909)
            ]),
            Region("calf-outer-r", "Calves", mirror([
                p(0.352,0.845), p(0.394,0.842), p(0.414,0.893), p(0.399,0.956), p(0.367,0.959), p(0.347,0.909)
            ])),
            Region("calf-inner-l", "Calves", [
                p(0.392,0.844), p(0.424,0.852), p(0.429,0.910), p(0.408,0.961), p(0.391,0.946), p(0.406,0.891)
            ]),
            Region("calf-inner-r", "Calves", mirror([
                p(0.392,0.844), p(0.424,0.852), p(0.429,0.910), p(0.408,0.961), p(0.391,0.946), p(0.406,0.891)
            ]))
        ]
    }

    private var baseParts: [BasePart] {
        [
            BasePart("torso", [
                p(0.500,0.194), p(0.397,0.211), p(0.314,0.249), p(0.332,0.355),
                p(0.353,0.483), p(0.385,0.583), p(0.438,0.622), p(0.500,0.634),
                p(0.562,0.622), p(0.615,0.583), p(0.647,0.483), p(0.668,0.355),
                p(0.686,0.249), p(0.603,0.211)
            ]),
            BasePart("left-arm", [
                p(0.313,0.248), p(0.265,0.260), p(0.235,0.315), p(0.220,0.398),
                p(0.197,0.486), p(0.173,0.565), p(0.198,0.593), p(0.236,0.575),
                p(0.266,0.491), p(0.292,0.410), p(0.325,0.309)
            ]),
            BasePart("right-arm", mirror([
                p(0.313,0.248), p(0.265,0.260), p(0.235,0.315), p(0.220,0.398),
                p(0.197,0.486), p(0.173,0.565), p(0.198,0.593), p(0.236,0.575),
                p(0.266,0.491), p(0.292,0.410), p(0.325,0.309)
            ])),
            BasePart("left-leg", [
                p(0.386,0.598), p(0.335,0.650), p(0.326,0.755), p(0.344,0.838),
                p(0.343,0.931), p(0.363,0.978), p(0.410,0.976), p(0.429,0.930),
                p(0.428,0.836), p(0.455,0.714), p(0.463,0.629)
            ]),
            BasePart("right-leg", mirror([
                p(0.386,0.598), p(0.335,0.650), p(0.326,0.755), p(0.344,0.838),
                p(0.343,0.931), p(0.363,0.978), p(0.410,0.976), p(0.429,0.930),
                p(0.428,0.836), p(0.455,0.714), p(0.463,0.629)
            ]))
        ]
    }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(RFTheme.raised.opacity(0.44))

                VStack(spacing: 0) {
                    Text(side == .front ? L10n.text("Front", "Voor") : L10n.text("Back", "Achter"))
                        .font(.caption.bold())
                        .foregroundStyle(RFTheme.muted)
                        .padding(.top, 8)
                    Spacer()
                }

                ZStack {
                    // Head.
                    Ellipse()
                        .fill(Color.black.opacity(0.62))
                        .overlay(
                            Ellipse()
                                .stroke(Color.white.opacity(0.30), lineWidth: 1.1)
                        )
                        .frame(width: w * 0.145, height: h * 0.116)
                        .position(x: w * 0.50, y: h * 0.108)

                    // Detailed dark silhouette under the muscle layers.
                    ForEach(baseParts) { part in
                        SmoothNormalizedShape(points: part.points)
                            .fill(Color.black.opacity(0.61))
                            .overlay(
                                SmoothNormalizedShape(points: part.points)
                                    .stroke(Color.white.opacity(0.28), lineWidth: 1.0)
                            )
                    }

                    // Every muscle stays visible as a dark anatomical region.
                    ForEach(regions) { region in
                        let value = intensity[region.muscle] ?? 0
                        SmoothNormalizedShape(points: region.points)
                            .fill(value > 0 ? MuscleHeatPalette.color(for: value) : Color.white.opacity(0.055))
                            .overlay(
                                SmoothNormalizedShape(points: region.points)
                                    .stroke(
                                        value > 0
                                            ? Color.white.opacity(0.34 + (0.18 * value))
                                            : Color.white.opacity(0.13),
                                        lineWidth: value > 0 ? 0.95 : 0.65
                                    )
                            )
                            .shadow(
                                color: MuscleHeatPalette.glow(for: value),
                                radius: value > 0 ? 2.5 + (5.5 * value) : 0
                            )
                    }

                    // Small anatomical guide lines.
                    anatomicalGuideLines(size: proxy.size)
                }
                .padding(.top, 21)
                .padding(.horizontal, 2)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            side == .front
                ? L10n.text("Front muscle heatmap", "Spierkaart voorkant")
                : L10n.text("Back muscle heatmap", "Spierkaart achterkant")
        )
    }

    @ViewBuilder
    private func anatomicalGuideLines(size: CGSize) -> some View {
        Path { path in
            let w = size.width
            let h = size.height

            // Sternum/spine.
            path.move(to: CGPoint(x: w * 0.50, y: h * 0.235))
            path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.605))

            // Pelvis line.
            path.move(to: CGPoint(x: w * 0.405, y: h * 0.620))
            path.addQuadCurve(
                to: CGPoint(x: w * 0.595, y: h * 0.620),
                control: CGPoint(x: w * 0.50, y: h * 0.650)
            )

            // Knees.
            path.move(to: CGPoint(x: w * 0.350, y: h * 0.835))
            path.addLine(to: CGPoint(x: w * 0.430, y: h * 0.835))
            path.move(to: CGPoint(x: w * 0.570, y: h * 0.835))
            path.addLine(to: CGPoint(x: w * 0.650, y: h * 0.835))
        }
        .stroke(Color.white.opacity(0.11), style: StrokeStyle(lineWidth: 0.75, lineCap: .round))
    }

    private func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: y)
    }

    private func mirror(_ points: [CGPoint]) -> [CGPoint] {
        points.map { CGPoint(x: 1 - $0.x, y: $0.y) }
    }
}

private struct SmoothNormalizedShape: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        guard points.count >= 3 else { return Path() }

        let scaled = points.map {
            CGPoint(
                x: rect.minX + ($0.x * rect.width),
                y: rect.minY + ($0.y * rect.height)
            )
        }

        func midpoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
            CGPoint(x: (a.x + b.x) * 0.5, y: (a.y + b.y) * 0.5)
        }

        var path = Path()
        let first = scaled[0]
        let last = scaled[scaled.count - 1]
        path.move(to: midpoint(last, first))

        for index in scaled.indices {
            let current = scaled[index]
            let next = scaled[(index + 1) % scaled.count]
            path.addQuadCurve(to: midpoint(current, next), control: current)
        }

        path.closeSubpath()
        return path
    }
}
