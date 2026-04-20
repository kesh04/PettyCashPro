//
//  SplashView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-20.
//


import SwiftUI
import Foundation

struct DrawInShape: Shape {
    var makePath: @Sendable () -> Path
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let originalPath = makePath()
        let trimmedPath = originalPath.trimmedPath(from: 0, to: max(0, min(1, progress)))
        return trimmedPath
    }
}

struct LogomarkMask190x40: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 180, y: 39))
        p.addLine(to: CGPoint(x: 190, y: 29))
        p.addLine(to: CGPoint(x: 190, y: 20))
        p.addLine(to: CGPoint(x: 170, y: 20))
        p.addLine(to: CGPoint(x: 170, y: 29))
        p.addLine(to: CGPoint(x: 180, y: 39))
        p.closeSubpath()
        return p
    }
}

public struct PointLogoAnimated190: View {
    // Letter segment progresses
    @State private var pStem: CGFloat = 0
    @State private var pBowl: CGFloat = 0
    @State private var oRing: CGFloat = 0
    @State private var iStem: CGFloat = 0
    @State private var nArch: CGFloat = 0
    @State private var tStem: CGFloat = 0
    @State private var tCross: CGFloat = 0

    // Logomark dash phases
    @State private var rtPhase: CGFloat = 6.02
    @State private var rbPhase: CGFloat = 5.657
    @State private var ltPhase: CGFloat = 6.02
    @State private var lbPhase: CGFloat = 5.657

    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            let scale = min(geo.size.width / 190, geo.size.height / 40)

            ZStack {
                let ink = Color.white.opacity(0.82)

                // p: stem
                DrawInShape(makePath: {
                    Path { p in
                        p.move(to: CGPoint(x: 5, y: 39))
                        p.addLine(to: CGPoint(x: 5, y: 1))
                    }
                }, progress: pStem)
                .stroke(ink, style: StrokeStyle(lineWidth: 10, lineCap: .butt))

                // p: bowl
                DrawInShape(makePath: {
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: 5.5))
                        p.addLine(to: CGPoint(x: 20, y: 5.5))
                        p.addCurve(to: CGPoint(x: 29.5, y: 15),
                                   control1: CGPoint(x: 25, y: 5.5),
                                   control2: CGPoint(x: 29.5, y: 9))
                        p.addCurve(to: CGPoint(x: 20, y: 24.5),
                                   control1: CGPoint(x: 29.5, y: 21),
                                   control2: CGPoint(x: 25, y: 24.5))
                        p.addLine(to: CGPoint(x: 0, y: 24.5))
                    }
                }, progress: pBowl)
                .stroke(ink, style: StrokeStyle(lineWidth: 9, lineCap: .butt))

                // o: ring
                DrawInShape(makePath: {
                    Path { p in
                        p.move(to: CGPoint(x: 56.5, y: 5.5))
                        p.addCurve(to: CGPoint(x: 71, y: 20),
                                   control1: CGPoint(x: 65.5, y: 5.5),
                                   control2: CGPoint(x: 71, y: 12))
                        p.addCurve(to: CGPoint(x: 56.5, y: 34.5),
                                   control1: CGPoint(x: 71, y: 28),
                                   control2: CGPoint(x: 65.5, y: 34.5))
                        p.addCurve(to: CGPoint(x: 42, y: 20),
                                   control1: CGPoint(x: 47.5, y: 34.5),
                                   control2: CGPoint(x: 42, y: 28))
                        p.addCurve(to: CGPoint(x: 56.5, y: 5.5),
                                   control1: CGPoint(x: 42, y: 12),
                                   control2: CGPoint(x: 47.5, y: 5.5))
                    }
                }, progress: oRing)
                .stroke(ink, style: StrokeStyle(lineWidth: 10, lineCap: .butt))

                // i: stem
                DrawInShape(makePath: {
                    Path { p in
                        p.move(to: CGPoint(x: 85, y: 39))
                        p.addLine(to: CGPoint(x: 85, y: 1))
                    }
                }, progress: iStem)
                .stroke(ink, style: StrokeStyle(lineWidth: 10, lineCap: .butt))

                // n: arch
                DrawInShape(makePath: {
                    Path { p in
                        p.move(to: CGPoint(x: 100.5, y: 39))
                        p.addLine(to: CGPoint(x: 100.5, y: 18))
                        p.addCurve(to: CGPoint(x: 114.25, y: 5.5),
                                   control1: CGPoint(x: 100.5, y: 12.5),
                                   control2: CGPoint(x: 104.25, y: 5.5))
                        p.addCurve(to: CGPoint(x: 128, y: 18),
                                   control1: CGPoint(x: 124.5, y: 5.5),
                                   control2: CGPoint(x: 128, y: 12.5))
                        p.addLine(to: CGPoint(x: 128, y: 39))
                    }
                }, progress: nArch)
                .stroke(ink, style: StrokeStyle(lineWidth: 10, lineCap: .butt))

                // t: stem
                DrawInShape(makePath: {
                    Path { p in
                        p.move(to: CGPoint(x: 153, y: 39))
                        p.addLine(to: CGPoint(x: 153, y: 1))
                    }
                }, progress: tStem)
                .stroke(ink, style: StrokeStyle(lineWidth: 10, lineCap: .butt))

                // t: crossbar
                DrawInShape(makePath: {
                    Path { p in
                        p.move(to: CGPoint(x: 136, y: 5.5))
                        p.addLine(to: CGPoint(x: 170, y: 5.5))
                    }
                }, progress: tCross)
                .stroke(ink, style: StrokeStyle(lineWidth: 9, lineCap: .butt))

                
                ZStack {
                    let green = Color(red: 0x4F/255.0, green: 0xD3/255.0, blue: 0x00/255.0).opacity(0.7)

                    
                    Path { p in
                        p.move(to: CGPoint(x: 180, y: 31))
                        p.addLine(to: CGPoint(x: 184.25, y: 26.75))
                    }
                    .stroke(green, style: StrokeStyle(lineWidth: 11.31, lineCap: .round, dash: [6.02, 6.02], dashPhase: rtPhase))

                    
                    Path { p in
                        p.move(to: CGPoint(x: 180, y: 31))
                        p.addLine(to: CGPoint(x: 176, y: 35))
                    }
                    .stroke(green, style: StrokeStyle(lineWidth: 11.31, lineCap: .round, dash: [5.657, 5.657], dashPhase: rbPhase))

                    
                    Path { p in
                        p.move(to: CGPoint(x: 180, y: 31))
                        p.addLine(to: CGPoint(x: 175.75, y: 26.75))
                    }
                    .stroke(green, style: StrokeStyle(lineWidth: 11.31, lineCap: .round, dash: [6.02, 6.02], dashPhase: ltPhase))

                    
                    Path { p in
                        p.move(to: CGPoint(x: 180, y: 31))
                        p.addLine(to: CGPoint(x: 184, y: 35))
                    }
                    .stroke(green, style: StrokeStyle(lineWidth: 11.31, lineCap: .round, dash: [5.657, 5.657], dashPhase: lbPhase))
                }
                .mask(
                    LogomarkMask190x40().fill(.black)
                )
            }
            .frame(width: 190, height: 40)
            .scaleEffect(scale, anchor: .center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
            .onAppear(perform: runTimeline)
            .contentShape(Rectangle())
            .onTapGesture { restart() }
        }
    }
    
    private func runTimeline() {
        restart()

        func wait(_ s: Double) async {
            try? await Task.sleep(nanoseconds: UInt64(s * 1_000_000_000))
        }

        Task {
           
            await wait(0.40)
            withAnimation(.timingCurve(0.42, 0.0, 1.0, 1.0, duration: 0.15)) { pStem = 1 }

            
            await wait(0.05)
            withAnimation(.timingCurve(0.0, 0.0, 0.58, 1.0, duration: 0.20)) { pBowl = 1 }

          
            await wait(0.15)
            withAnimation(.timingCurve(0.0, 0.0, 1.0, 1.0, duration: 0.25)) { oRing = 1 }

       
            await wait(0.20)
            withAnimation(.timingCurve(0.0, 0.0, 1.0, 1.0, duration: 0.15)) { iStem = 1 }


            await wait(0.10)
            withAnimation(.timingCurve(0.0, 0.0, 1.0, 1.0, duration: 0.25)) { nArch = 1 }

            await wait(0.20)
            withAnimation(.timingCurve(0.0, 0.0, 1.0, 1.0, duration: 0.15)) { tStem = 1 }

         
            await wait(0.10)
            withAnimation(.timingCurve(0.42, 0.0, 1.0, 1.0, duration: 0.12)) { tCross = 1.0 }
            await wait(0.12)
            let retreat2 = 1.0 - (12.0 / 38.0)
            withAnimation(.timingCurve(0.0, 0.0, 0.59, 1.0, duration: 0.06)) { tCross = retreat2 }
            await wait(0.06)
            withAnimation(.timingCurve(0.42, 0.0, 1.0, 1.0, duration: 0.42)) { tCross = 1.0 }
        }
        

        // Logomark phases (faster)
        Task {
          
            try? await Task.sleep(nanoseconds: UInt64(1.8 * 1_000_000_000))
            withAnimation(.timingCurve(0.42, 0.0, 1.0, 1.0, duration: 0.15)) { rtPhase = 0.0 }
            try? await Task.sleep(nanoseconds: UInt64(0.15 * 1_000_000_000))
            withAnimation(.timingCurve(0.0, 0.0, 0.59, 1.0, duration: 0.15)) { rtPhase = 1.0 }
            try? await Task.sleep(nanoseconds: UInt64(0.15 * 1_000_000_000))
            withAnimation(.timingCurve(0.42, 0.0, 1.0, 1.0, duration: 0.15)) { rtPhase = 0.0 }
        }
        Task {
            
            try? await Task.sleep(nanoseconds: UInt64(1.9 * 1_000_000_000))
            withAnimation(.timingCurve(0.42, 0.0, 1.0, 1.0, duration: 0.15)) { rbPhase = 0.0 }
        }
        Task {
      
            try? await Task.sleep(nanoseconds: UInt64(1.9 * 1_000_000_000))
            withAnimation(.timingCurve(0.42, 0.0, 1.0, 1.0, duration: 0.15)) { ltPhase = 0.0 }
            try? await Task.sleep(nanoseconds: UInt64(0.15 * 1_000_000_000))
            withAnimation(.timingCurve(0.0, 0.0, 0.59, 1.0, duration: 0.15)) { ltPhase = 1.0 }
            try? await Task.sleep(nanoseconds: UInt64(0.15 * 1_000_000_000))
            withAnimation(.timingCurve(0.42, 0.0, 1.0, 1.0, duration: 0.15)) { ltPhase = 0.0 }
        }
        Task {
       
            try? await Task.sleep(nanoseconds: UInt64(1.9 * 1_000_000_000))
            withAnimation(.timingCurve(0.42, 0.0, 1.0, 1.0, duration: 0.15)) { lbPhase = 0.0 }
        }
    }

    private func restart() {
        pStem = 0; pBowl = 0; oRing = 0; iStem = 0; nArch = 0; tStem = 0; tCross = 0
        rtPhase = 6.02; rbPhase = 5.657; ltPhase = 6.02; lbPhase = 5.657
    }
}


struct SplashView: View {
    @ObservedObject var appState: AppStateManager = AppStateManager.shared
    
    var body: some View {
        ZStack {
            Image("background-blurred")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    PointLogoAnimated190()
                        .frame(width: 200, height: 42)
                        .scaleEffect(0.8)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                checkAuthenticateAndNavigate()
            }
        }
    }
    
    private func checkAuthenticateAndNavigate() {
        guard !appState.isHandlingDeepLink else { return }
        
        if appState.checkAuthentication() {
            appState.navigateToMainTabs()
        } else {
            appState.navigateToLogin()
        }
    }
}

// Preview
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
