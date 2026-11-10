import SwiftUI

struct CombatCanvas: View {
    @ObservedObject var model: GameModel
    var reduceMotion: Bool

    var body: some View {
        Canvas { context, size in
            let sx = size.width / 390
            let sy = size.height / 400
            func point(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: x * sx, y: y * sy) }
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Palette.background))
            // Fixed star positions avoid flicker and allocations from randomizing each frame.
            for index in 0..<65 {
                let x = Double((index * 127 + 37) % 390)
                let offset = reduceMotion ? 0 : model.engine.elapsed * (1 + Double(index % 3))
                let y = (Double((index * 79 + 13) % 340) + offset).truncatingRemainder(dividingBy: 340)
                let p = point(x, y)
                let radius = index % 4 == 0 ? 1.5 : 0.8
                context.fill(Path(ellipseIn: CGRect(x: p.x, y: p.y, width: radius, height: radius)), with: .color(Palette.cyan.opacity(Double(index % 5 + 1) * 0.1)))
            }
            var grid = Path()
            for i in 0...12 {
                let x = Double(i) * 32.5
                grid.move(to: point(x, 0)); grid.addLine(to: point(x, 400))
            }
            for y in stride(from: 300.0, through: 400, by: 20) {
                grid.move(to: point(0, y)); grid.addLine(to: point(390, y))
            }
            context.stroke(grid, with: .color(Palette.cyan.opacity(0.06)), lineWidth: 0.5)
            if model.hints {
                var line = Path()
                line.move(to: point(0, 192)); line.addLine(to: point(390, 192))
                context.stroke(line, with: .color(Palette.red.opacity(0.2)), style: StrokeStyle(lineWidth: 0.5, dash: [4, 5]))
                context.draw(Text("GHOST ASSIST ZONE").font(.system(size: 7, weight: .medium, design: .monospaced)).foregroundColor(Palette.red.opacity(0.35)), at: point(380, 186), anchor: .trailing)
            }
            drawCities(context: &context, size: size)
            for beam in model.beams {
                var path = Path()
                path.move(to: point(beam.from, 400)); path.addLine(to: point(beam.x, beam.y))
                var glow = context
                glow.addFilter(.shadow(color: beam.color.opacity(0.6), radius: 7))
                glow.stroke(path, with: .color(beam.color.opacity(beam.life)), lineWidth: max(0.5, 2.2 * beam.life))
            }
            for target in model.engine.targets {
                drawTarget(target, context: &context, size: size)
            }
            if !reduceMotion {
                for spark in model.sparks {
                    let p = point(spark.x, spark.y)
                    context.fill(Path(CGRect(x: p.x, y: p.y, width: 2.5, height: 2.5)), with: .color(spark.color.opacity(max(0, spark.life))))
                }
            }
            if model.damageFlash > 0 && !reduceMotion {
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Palette.red.opacity(model.damageFlash * 0.22)))
            }
        }
    }

    private func drawCities(context: inout GraphicsContext, size: CGSize) {
        let spacing = size.width / 6
        let ground = size.height - 8
        for index in 0..<6 {
            let hp = model.engine.shields[index]
            let x = (Double(index) + 0.5) * spacing
            let radius = min(spacing * 0.38, 48)
            let color = hp == 3 ? Palette.cyan : hp == 2 ? Palette.amber : Palette.red
            if hp == 0 {
                var rubble = Path()
                rubble.move(to: CGPoint(x: x - radius, y: ground))
                rubble.addLine(to: CGPoint(x: x - radius * 0.3, y: ground - 5))
                rubble.addLine(to: CGPoint(x: x + radius * 0.2, y: ground - 2))
                rubble.addLine(to: CGPoint(x: x + radius, y: ground))
                context.stroke(rubble, with: .color(Palette.red.opacity(0.3)), lineWidth: 1)
                continue
            }
            var dome = Path()
            dome.addArc(center: CGPoint(x: x, y: ground), radius: radius, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            dome.closeSubpath()
            context.fill(dome, with: .color(color.opacity(0.1)))
            var glowing = context
            glowing.addFilter(.shadow(color: color.opacity(0.45), radius: 7))
            glowing.stroke(dome, with: .color(color.opacity(0.9)), lineWidth: 1.4)
            for building in 0..<3 {
                let bx = x - radius * 0.65 + Double(building) * radius * 0.46
                let height = radius * [0.55, 0.8, 0.4][building]
                let rect = CGRect(x: bx, y: ground - height, width: radius * 0.32, height: height)
                context.fill(Path(rect), with: .color(Palette.panel))
                context.stroke(Path(rect), with: .color(color.opacity(0.4)), lineWidth: 0.6)
                context.fill(Path(CGRect(x: bx + 3, y: ground - height + 5, width: 2, height: 2)), with: .color(color.opacity(0.7)))
            }
            for pip in 0..<3 {
                let rect = CGRect(x: x - 12 + Double(pip) * 9, y: ground - 3, width: 6, height: 2)
                context.fill(Path(rect), with: .color(pip < hp ? color : Palette.muted.opacity(0.2)))
            }
        }
    }

    private func drawTarget(_ target: Invader, context: inout GraphicsContext, size: CGSize) {
        let locked = model.engine.lockedID == target.id
        let fontSize = min(18.0, max(13.0, size.width / 28))
        let charWidth = fontSize * 0.61
        let width = Double(target.word.count) * charWidth + 20
        let rawX = target.x / 390 * size.width
        // Falling words remain readable even when aimed at an edge city.
        let x = target.isUFO ? rawX : max(width / 2 + 3, min(size.width - width / 2 - 3, rawX))
        let y = target.y / 400 * size.height
        let rect = CGRect(x: x - width / 2, y: y - 15, width: width, height: 30)
        let color = target.isUFO ? Palette.amber : locked ? Palette.cyan : Palette.muted.opacity(0.6)
        let shape = target.isUFO ? Path(ellipseIn: rect.insetBy(dx: -6, dy: -2)) : Path(roundedRect: rect, cornerRadius: 7)
        context.fill(shape, with: .color(target.isUFO ? Palette.amber.opacity(0.12) : Palette.panel))
        var glow = context
        if locked || target.isUFO { glow.addFilter(.shadow(color: color.opacity(0.45), radius: 6)) }
        glow.stroke(shape, with: .color(color), lineWidth: locked || target.isUFO ? 1.5 : 0.6)
        for (index, char) in target.word.enumerated() {
            let tint: Color
            if index < target.typed { tint = Palette.muted.opacity(0.35) }
            else if index == target.typed && locked { tint = Palette.green }
            else if target.isUFO { tint = Palette.amber }
            else if model.engine.mode == .thumb { tint = Palette.zone(String(char)) }
            else { tint = .white }
            context.draw(Text(String(char).uppercased()).font(.system(size: fontSize, weight: .bold, design: .monospaced)).foregroundColor(tint),
                         at: CGPoint(x: rect.minX + 10 + charWidth * (Double(index) + 0.5), y: y))
        }
        if locked {
            var bracket = Path()
            bracket.move(to: CGPoint(x: rect.minX - 4, y: rect.minY + 6))
            bracket.addLine(to: CGPoint(x: rect.minX - 4, y: rect.minY - 4))
            bracket.addLine(to: CGPoint(x: rect.minX + 6, y: rect.minY - 4))
            bracket.move(to: CGPoint(x: rect.maxX + 4, y: rect.maxY - 6))
            bracket.addLine(to: CGPoint(x: rect.maxX + 4, y: rect.maxY + 4))
            bracket.addLine(to: CGPoint(x: rect.maxX - 6, y: rect.maxY + 4))
            context.stroke(bracket, with: .color(Palette.green), lineWidth: 1.5)
        }
    }
}
