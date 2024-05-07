//
//  ContentView.swift
//  eligius
//
//  Created by Saint on 3/14/24.
//

import HotKey
import SwiftUI
import Combine

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 08) & 0xFF) / 255,
            blue: Double((hex >> 00) & 0xFF) / 255,
            opacity: alpha
        )
    }
}

func getTime() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm"
    let dateString = formatter.string(from: Date())
    return dateString
}

func isTimeInInterval(now: Date, timer: Bool) -> [String: Bool] {
    let calendar = Calendar.current

    // Get the minute component of the current time
    let minuteComponent = calendar.component(.minute, from: now)
    let secondComponent = calendar.component(.second, from: now)

    var flash = false
    var center = false
    // flash the minute component
    if timer {
        // flash = minuteComponent % 5 == 0 && secondComponent % 2 == 0 && secondComponent > 50
        flash = minuteComponent % 5 == 0 && secondComponent > 50
        center = minuteComponent % 5 == 0 && secondComponent == 50
    } else {
        // flash = minuteComponent % 15 == 0 && secondComponent % 2 == 0 && secondComponent < 40
        flash = minuteComponent % 15 == 0
        center = minuteComponent % 15 == 0 && secondComponent == 0
    }

    return ["flash":flash,
        "center": center]
}

let winWidth = CGFloat(320)
let winHeight = CGFloat(150)
struct ContentView: View {
    @EnvironmentObject var settings: Settings
    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    @State var now = getTime()
    @State var timeColor = Color(hex: 0x6D071A)

    @State var window : NSWindow?
    @State var originalPosition : NSRect?
    @State private var cancellables = Set<AnyCancellable>()

    var hotKey = HotKey(key: .minus, modifiers: [.command, .shift])
    var hkShowTimer = HotKey(key: .equal, modifiers: [.command, .shift])
    var hkRestorePosition = HotKey(key: .equal, modifiers: [.command, .option])

    init() {}

    var body: some View {
        ZStack {
            Text("\(now)")

                .font(Font.custom("EPSON-FUTO-MINCHO", size: 120))
                // .foregroundColor(Color(hex: 0x650015))
                .foregroundColor(timeColor)
                // .font(Font.custom("Ac437_Apricot_Mono", size: 80))
                // .font(Font.custom("OPTICaslon-ExtraCondensed", size: 40))
                .dragWndWithClick()
                .onReceive(timer) { _ in

                    chromeless()

                    // now is the time that we display. So if we want to display
                    // another time, such as the countdown timer, we should change
                    // the now variable
                    var now = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "h:mm"
                    if (settings.timerDate != nil && settings.showTimer) {
                        let secondsLeft = settings.timerDate!.timeIntervalSince(Date())
                        if secondsLeft < 1 {
                            settings.timerDate = nil
                        } else {
                            ///settings.timerLeft = String(Int(secondsLeft / 60) + 1)
                            var dateComponents = DateComponents()
                            dateComponents.second = Int(secondsLeft + 60)
                            let calendar = Calendar.current
                            let midnight = calendar.startOfDay(for: Date())
                            now = calendar.date(byAdding: dateComponents, to: midnight)!
                            formatter.dateFormat = "H:mm"
                        }
                    }
                    let dateString = formatter.string(from: now)
                    self.now = dateString
                    if settings.showTimer {
                        self.now = "-\(self.now)"
                    }

                    let timeIntervalRes = isTimeInInterval(now: now, timer: settings.timerDate != nil)
                    if timeIntervalRes["flash"]! {
                        self.timeColor = Color(hex: 0xCCCCCC)
                    } else {
                        self.timeColor = Color(hex: 0x6D071A)
                    }

                    if timeIntervalRes["center"]! {
                        centerWindow()
                    }
                    // else {
                    //     restoreWindowPos()
                    // }
                }

            // Text("Jn 3:38 whoever does not")
            //    .font(Font.custom("EPSON-FUTO-MINCHO", size: 30))
            //    //.foregroundColor(Color(hex: 0x650015))
            //    .foregroundColor(Color(hex: 0x6D071A))
        }
            .frame(minWidth: winWidth, maxWidth: winWidth,
            minHeight: winHeight, maxHeight: winHeight)
            .background(Color.black.opacity(0.3))
            .cornerRadius(15)
            .dragWndWithClick()
            .overlay(AcceptingFirstMouse()) // must be on top (no confuse, it is transparent)
            .onAppear {
                print("meow")
                hotKey.keyDownHandler = {
                    print("Pressed at \(Date())")
                    settings.isMenuPresented.toggle()
                }

                hkShowTimer.keyDownHandler = {
                    settings.showTimer.toggle()
                }

                hkRestorePosition.keyDownHandler = {
                    restoreWindowPos()
                }

            }
            .onTapGesture {
                restoreWindowPos()
            }
            .background(WindowAccessor { newWindow in
                if let newWindow = newWindow {
                    monitorVisibility(window: newWindow)

                } else {
                    // window closed: release all references
                    self.window = nil
                    self.cancellables.removeAll()
                }
            })
    }

    private func monitorVisibility(window: NSWindow) {
        window.publisher(for: \.isVisible)
            .dropFirst()  // we know: the first value is not interesting
            .sink(receiveValue: { isVisible in
                if isVisible {
                    self.window = window
                    //placeWindow(window)
                }
            })
            .store(in: &cancellables)
    }

    private func centerWindow() {
        if self.window == nil {
            return
        }
        let main = NSScreen.main!
        let visibleFrame = main.visibleFrame
        let windowSize = self.window!.frame.size

        let windowX = visibleFrame.midX - windowSize.width/2
        let windowY = visibleFrame.midY - windowSize.height/2

        if self.window!.frame.origin.x != windowX &&
            self.window!.frame.origin.y != windowY {
            self.originalPosition = self.window!.frame
        }

        let desiredOrigin = CGPoint(x: windowX, y: windowY)
        self.window?.setFrameOrigin(desiredOrigin)
    }

    private func restoreWindowPos() {
        if self.window == nil {
            return
        }

        if self.originalPosition == nil {
            return
        }

        self.window!.setFrame(self.originalPosition!, display: true)
        self.originalPosition = nil
    }

}


import Cocoa

// Just mouse accepter
class MyViewView: NSView {
    override func acceptsFirstMouse(for _: NSEvent?) -> Bool {
        return true
    }
}

// Representable wrapper (bridge to SwiftUI)
struct AcceptingFirstMouse: NSViewRepresentable {
    func makeNSView(context _: NSViewRepresentableContext<AcceptingFirstMouse>) -> MyViewView {
        return MyViewView()
    }

    func updateNSView(_ nsView: MyViewView, context _: NSViewRepresentableContext<AcceptingFirstMouse>) {
        nsView.setNeedsDisplay(nsView.bounds)
    }

    typealias NSViewType = MyViewView
}

func chromeless() {
    for window in NSApp.windows {
    //if let window = NSApp.windows.first {
        // hide buttons
        if (window.title == "eligius") {
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true

            // hide title and bar
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true

            window.isOpaque = false
            window.backgroundColor = NSColor.clear
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
            window.hasShadow = false
        }
    }
}

import Foundation
import SwiftUI

@available(OSX 11.0, *)
extension View {
    func dragWndWithClick() -> some View {
        overlay(DragWndView())
    }
}

struct DragWndView: View {
    let test: Bool

    init(test: Bool = false) {
        self.test = test
    }

    var body: some View {
        (test ? Color.green : Color.clickableAlpha)
            .overlay(DragWndNSRepr())
    }
}

///////////////
/// HELPERS
///////////////

private struct DragWndNSRepr: NSViewRepresentable {
    func makeNSView(context _: Context) -> NSView {
        return DragWndNSView()
    }

    func updateNSView(_: NSView, context _: Context) {}
}

private class DragWndNSView: NSView {
    override public func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}

@available(OSX 10.15, *)
public extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 256.0,
            green: Double((hex >> 8) & 0xFF) / 256.0,
            blue: Double(hex & 0xFF) / 256.0
        )
    }

    init(rgbaHex: UInt32) {
        self.init(
            red: Double((rgbaHex >> 24) & 0xFF) / 256.0,
            green: Double((rgbaHex >> 16) & 0xFF) / 256.0,
            blue: Double((rgbaHex >> 8) & 0xFF) / 256.0,
            opacity: Double(rgbaHex & 0xFF) / 256.0
        )
    }
}

@available(OSX 10.15, *)
public extension Color {
    static var clickableAlpha: Color { return Color(rgbaHex: 0x0101_0101) }
}
