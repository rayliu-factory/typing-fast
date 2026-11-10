import SwiftUI

struct GameView: View {
    @StateObject private var model = GameModel()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showingSettings = false
    @State private var confirmingRestart = false

    var body: some View {
        GeometryReader { geometry in
            let wide = geometry.size.width > geometry.size.height
            VStack(spacing: 0) {
                header(compact: wide)
                if wide {
                    HStack(spacing: 0) {
                        arena
                        VStack(spacing: 0) {
                            targetHUD
                            SoftKeyboard(model: model)
                        }
                        .frame(width: min(geometry.size.width * 0.52, 580))
                    }
                } else {
                    arena
                    targetHUD
                    SoftKeyboard(model: model)
                        .frame(height: min(300, max(228, geometry.size.height * 0.32)))
                }
            }
            .overlay {
                if model.engine.phase != .playing { missionOverlay(wide: wide) }
            }
        }
        .background(Palette.background.ignoresSafeArea())
        .background(HardwareKeyboard(active: scenePhase == .active && !showingSettings && !confirmingRestart) { model.key($0, hardware: true) }.frame(width: 0, height: 0))
        .foregroundStyle(.white)
        .onAppear { model.connect() }
        .onDisappear { model.pause(); model.disconnect() }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { model.pause() }
        }
        .sheet(isPresented: $showingSettings) { settings }
        .confirmationDialog("End this run? Your best score is saved.", isPresented: $confirmingRestart, titleVisibility: .visible) {
            Button("Return to mode selection", role: .destructive) { model.returnToMenu() }
        }
    }

    private func header(compact: Bool) -> some View {
        VStack(spacing: compact ? 4 : 12) {
            HStack {
                HStack(spacing: 7) {
                    Image(systemName: "scope").foregroundStyle(Palette.cyan)
                    Text("LETTER INVADERS").font(.system(size: compact ? 13 : 15, weight: .black, design: .rounded)).tracking(1.3)
                }
                Spacer(minLength: 4)
                Button { model.pause(); showingSettings = true } label: {
                    Image(systemName: "slider.horizontal.3").frame(width: 38, height: 34)
                }.accessibilityLabel("Settings")
                Button { model.pause() } label: {
                    Image(systemName: "pause.fill").frame(width: 34, height: 34)
                }.accessibilityLabel("Pause game").disabled(model.engine.phase != .playing)
            }
            HStack {
                telemetry("SCORE", String(format: "%05d", model.engine.score), Palette.cyan)
                Spacer()
                telemetry("WAVE", String(format: "%02d", model.engine.wave), Palette.pink)
                Spacer()
                telemetry("WPM", "\(model.engine.wpm)", Palette.green)
                Spacer()
                telemetry("ACCURACY", "\(model.engine.accuracy)%", .white)
            }
        }
        .padding(.horizontal, 18).padding(.top, 4).padding(.bottom, compact ? 8 : 14)
        .background(Palette.panel)
        .overlay(alignment: .bottom) { Rectangle().fill(Palette.cyan.opacity(0.2)).frame(height: 1) }
    }

    private func telemetry(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.system(size: 8, weight: .semibold, design: .monospaced)).tracking(1.5).foregroundStyle(Palette.muted)
            Text(value).font(.system(size: 20, weight: .bold, design: .monospaced)).foregroundStyle(color).monospacedDigit()
        }.accessibilityElement(children: .combine)
    }

    private var arena: some View {
        ZStack(alignment: .top) {
            CombatCanvas(model: model, reduceMotion: reduceMotion)
            HStack(spacing: 5) {
                Circle().fill(Palette.green).frame(width: 4, height: 4)
                Text(model.engine.mode.title.uppercased()).tracking(1.6)
                Spacer()
                Image(systemName: "shield.lefthalf.filled")
                Text("\(model.engine.shields.reduce(0, +))/18")
            }
            .font(.system(size: 8, weight: .medium, design: .monospaced))
            .foregroundStyle(Palette.muted).padding(14)
            if model.engine.ufo != nil {
                Text("UFO BONUS  ·  TYPE TO REPAIR")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundStyle(Palette.amber).padding(6)
                    .background(Palette.amber.opacity(0.1), in: Capsule()).padding(.top, 33)
            }
            if model.messageLife > 0 {
                VStack { Spacer(); Text(model.message)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(model.errorKey == nil ? Palette.green : Palette.amber)
                    .padding(10).background(Palette.background.opacity(0.95), in: Capsule())
                    .padding(.bottom, 54)
                }.allowsHitTesting(false)
            }
        }
        .clipped()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Defense field")
        .accessibilityValue("\(model.engine.shields.filter { $0 > 0 }.count) cities standing. \(model.engine.targets.count) incoming targets.")
    }

    private var targetHUD: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "scope").foregroundStyle(Palette.cyan)
                Text(model.engine.locked == nil ? "TARGET SCAN" : "TARGET LOCK")
                    .tracking(1.4).foregroundStyle(Palette.muted)
                Spacer()
                Text("\(model.engine.combo)× COMBO").foregroundStyle(Palette.pink)
            }.font(.system(size: 9, weight: .bold, design: .monospaced))
            HStack {
                if let target = model.engine.preview {
                    HStack(spacing: 2) {
                        ForEach(Array(target.word.enumerated()), id: \.offset) { index, char in
                            Text(String(char).uppercased())
                                .foregroundStyle(index < target.typed ? Palette.muted.opacity(0.5) : index == target.typed ? Palette.background : .white)
                                .padding(.horizontal, index == target.typed ? 4 : 0)
                                .background(index == target.typed ? Palette.green : .clear, in: RoundedRectangle(cornerRadius: 3))
                        }
                    }.font(.system(size: 19, weight: .bold, design: .monospaced))
                    Spacer(minLength: 3)
                    let zone = KeyboardLayout.zone(target.next)
                    Text(zone == .left ? "← LEFT" : zone == .right ? "RIGHT →" : "SYMBOL")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Palette.zone(target.next))
                } else {
                    Text("Type a falling first letter…")
                        .font(.system(size: 12, design: .monospaced)).foregroundStyle(Palette.muted)
                    Spacer()
                }
            }.frame(height: 24)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(Palette.panel)
        .overlay(alignment: .top) { Rectangle().fill(Palette.cyan.opacity(0.5)).frame(height: 1) }
        .accessibilityElement(children: .combine)
    }

    private func missionOverlay(wide: Bool) -> some View {
        ZStack {
            Palette.background.opacity(0.94).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: wide ? 14 : 22) {
                    HStack {
                        Label("LETTER INVADERS", systemImage: "sparkle").tracking(1.6)
                        Spacer()
                        Button { showingSettings = true } label: {
                            Image(systemName: "slider.horizontal.3").frame(width: 44, height: 44)
                        }.accessibilityLabel("Settings")
                    }.font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundStyle(Palette.cyan)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(overlayTitle)
                            .font(.system(size: wide ? 32 : 43, weight: .black, design: .rounded))
                            .tracking(-1.8).lineSpacing(-6).fixedSize(horizontal: false, vertical: true)
                        Text(overlaySubtitle)
                            .font(.system(size: 14)).foregroundStyle(Palette.muted).lineSpacing(4)
                    }
                    if model.engine.phase == .ready {
                        VStack(spacing: 8) {
                            ForEach(TrainingMode.allCases) { mode in modeCard(mode) }
                        }
                        HStack(spacing: 10) {
                            Image(systemName: "shield.lefthalf.filled").font(.title2).foregroundStyle(Palette.cyan)
                            Text("Type words before they hit your six cities. Clear UFOs to repair shields. Cyan keys: left thumb. Pink keys: right thumb.")
                                .font(.system(size: 11)).foregroundStyle(Palette.muted).lineSpacing(3)
                        }
                    } else {
                        HStack {
                            telemetry("SCORE", "\(model.engine.score)", Palette.cyan)
                            Spacer()
                            telemetry("PEAK WPM", "\(model.engine.peakWPM)", Palette.green)
                            Spacer()
                            telemetry("ACCURACY", "\(model.engine.accuracy)%", Palette.pink)
                        }.padding(18).background(Palette.panel, in: RoundedRectangle(cornerRadius: 16))
                    }
                    VStack(spacing: 12) {
                        Button { model.engine.phase == .paused ? model.resume() : model.start() } label: {
                            HStack {
                                Text(model.engine.phase == .paused ? "RESUME DEFENSE" : model.engine.phase == .gameOver ? "PLAY AGAIN" : "LAUNCH DEFENSE")
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 13, weight: .black, design: .monospaced))
                            .foregroundStyle(Palette.background).padding(20)
                            .background(LinearGradient(colors: [Palette.cyan, Palette.green], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 14))
                        }.buttonStyle(.plain)
                        .accessibilityIdentifier("launchDefense")
                        if model.engine.phase != .ready {
                            Button("CHOOSE TRAINING MODE") {
                                if model.engine.phase == .paused { confirmingRestart = true }
                                else { model.returnToMenu() }
                            }.font(.system(size: 11, weight: .bold, design: .monospaced)).foregroundStyle(Palette.muted).padding(8)
                        }
                        HStack {
                            Text("BEST  \(String(format: "%05d", model.bestScore))")
                            Spacer()
                            Text("6 CITIES  /  1 MISSION")
                        }.font(.system(size: 8, weight: .semibold, design: .monospaced)).tracking(1).foregroundStyle(Palette.muted)
                    }
                }.padding(28).frame(maxWidth: wide ? 700 : 500)
                    .frame(maxWidth: .infinity)
            }.defaultScrollAnchor(.center)
        }
    }
    private var overlayTitle: String {
        switch model.engine.phase {
        case .ready, .playing: return "WORDS FALL.\nTHUMBS FLY."
        case .paused: return "DEFENSE\nON HOLD."
        case .gameOver: return "SKYLINE\nBREACHED."
        }
    }
    private var overlaySubtitle: String {
        switch model.engine.phase {
        case .ready, .playing: return "A neon typing arcade. Find your rhythm. Defend the skyline."
        case .paused: return "Take a breath. Your cities and your progress are safe while paused."
        case .gameOver: return "All six cities have fallen. Reset the grid and find your next high score."
        }
    }
    private func modeCard(_ mode: TrainingMode) -> some View {
        let selected = model.engine.mode == mode
        return Button { model.selectMode(mode) } label: {
            HStack(spacing: 14) {
                Image(systemName: mode.symbol).font(.system(size: 21)).frame(width: 28).foregroundStyle(selected ? Palette.cyan : Palette.muted)
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.title).font(.system(size: 14, weight: .bold))
                    Text(mode.detail).font(.system(size: 11)).foregroundStyle(Palette.muted).multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
                Image(systemName: selected ? "checkmark.circle.fill" : "circle").foregroundStyle(selected ? Palette.cyan : Palette.muted.opacity(0.4))
            }.padding(15)
                .background(selected ? Palette.cyan.opacity(0.08) : Palette.panel, in: RoundedRectangle(cornerRadius: 13))
                .overlay(RoundedRectangle(cornerRadius: 13).stroke(selected ? Palette.cyan.opacity(0.6) : Palette.muted.opacity(0.15), lineWidth: 1))
        }.buttonStyle(.plain).accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var settings: some View {
        NavigationStack {
            Form {
                Section("Assistance & feedback") {
                    Toggle("Ghost key hints", isOn: Binding(get: { model.hints }, set: { model.hints = $0 }))
                    Toggle("Synth sound effects", isOn: Binding(get: { model.sound }, set: { model.sound = $0 }))
                    Toggle("Haptic feedback", isOn: Binding(get: { model.haptics }, set: { model.haptics = $0 }))
                }
                Section("How to play") {
                    Text("Type the first letter to lock a target. Finish its word to destroy it. Mistakes reset your combo but keep your word progress.")
                    Text("SPACE, ⌫ and LOCK NEXT cycle targets. ?123 and ABC switch keyboard layers. UFOs award bonus points and restore one shield point, even to a fallen city.")
                    Text("Hints light the next key when a word reaches the danger line. Layer Drills show hints immediately.")
                }
                Section("External keyboard") {
                    Text("Type normally. Space, Tab and Backspace switch targets. Escape pauses or resumes; Enter starts or resumes a run.")
                }
                Section {
                    Text("Inspired by your Letter Invaders · Cyber Softkey Edition prototype. Built for offline play.")
                }
            }
            .navigationTitle("Flight controls").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showingSettings = false } } }
        }.tint(Palette.cyan)
    }
}

struct SoftKeyboard: View {
    @ObservedObject var model: GameModel
    var body: some View {
        VStack(spacing: 7) {
            HStack {
                Text("● LEFT").foregroundStyle(Palette.cyan)
                Spacer()
                Text(model.layer == .letters ? "ABC / QWERTY" : "?123 / SYMBOLS").foregroundStyle(Palette.muted)
                Spacer()
                Text("RIGHT ●").foregroundStyle(Palette.pink)
            }.font(.system(size: 8, weight: .bold, design: .monospaced)).tracking(0.6).padding(.horizontal, 7).padding(.bottom, 3)
            ForEach(Array(KeyboardLayout.rows(model.layer).enumerated()), id: \.offset) { rowIndex, row in
                HStack(spacing: 5) {
                    ForEach(row, id: \.self) { key in
                        KeyCap(key: key, model: model)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .layoutPriority(key == "SPACE" ? 1 : 0)
                    }
                }.padding(.horizontal, rowIndex == 1 && model.layer == .letters ? 10 : 0)
            }
        }
        .padding(.horizontal, 6).padding(.top, 12).padding(.bottom, 9)
        .frame(maxWidth: 850).frame(maxWidth: .infinity)
        .background(Palette.background)
    }
}

private struct KeyCap: View {
    let key: String
    @ObservedObject var model: GameModel
    @State private var down = false
    private var hint: Bool { model.engine.hintKey(layer: model.layer, enabled: model.hints) == key }
    private var color: Color {
        if model.errorKey == key { return Palette.red }
        if model.intendedKey == key { return Palette.amber }
        if hint { return Palette.green }
        if ["?123", "ABC"].contains(key) { return Palette.amber }
        return key.count == 1 && key != "⌫" ? Palette.zone(key) : Palette.muted
    }
    var body: some View {
        Text(key.uppercased())
            .font(.system(size: key.count > 1 ? 9 : 18, weight: .bold, design: .monospaced))
            .minimumScaleFactor(0.65).lineLimit(1)
            .foregroundStyle(down || hint ? .white : color.opacity(0.95))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(LinearGradient(colors: [color.opacity(down ? 0.55 : hint ? 0.27 : 0.15), color.opacity(0.07)], startPoint: .top, endPoint: .bottom), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(color.opacity(hint || down ? 1 : 0.35), lineWidth: hint ? 1.5 : 0.7))
            .shadow(color: hint ? Palette.green.opacity(0.35) : .clear, radius: 6)
            .scaleEffect(down ? 0.96 : 1)
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in if !down { down = true; model.key(key) } }
                .onEnded { _ in down = false })
            .accessibilityElement()
            .accessibilityLabel(key == "⌫" ? "Next target, backspace" : key)
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { model.key(key) }
            .accessibilityIdentifier("key_\(key)")
    }
}
