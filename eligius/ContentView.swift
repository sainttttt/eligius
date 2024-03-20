//
//  ContentView.swift
//  eligius
//
//  Created by Saint on 3/14/24.
//

import HotKey
import SwiftUI

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

func isTimeInInterval(now: Date, timer: Bool) -> Bool {
    let calendar = Calendar.current

    // Get the minute component of the current time
    let minuteComponent = calendar.component(.minute, from: now)
    let secondComponent = calendar.component(.second, from: now)

    // flash the minute component
    if timer {
        return minuteComponent % 5 == 0 && secondComponent % 2 == 0 && secondComponent > 50
    } else {
        return minuteComponent % 15 == 0 && secondComponent % 2 == 0 && secondComponent < 40
    }
}

let winWidth = CGFloat(320)
let winHeight = CGFloat(150)
struct ContentView: View {
    @EnvironmentObject var settings: Settings
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var now = getTime()
    @State var timeColor = Color(hex: 0x6D071A)

    var hotKey = HotKey(key: .l, modifiers: [.command, .option])

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
                    // if settings.timerLeft != "" {
                    //     let calendar = Calendar.current
                    //     // Define the date components
                    //     var dateComponents = DateComponents()
                    //     // Set the minute component to 54
                    //     dateComponents.minute = Int(timerLeft)
                    //     let dDate =  calendar.date(byAdding: dateComponents, to: Date()
                    // }


                  chromeless()
                   var now = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "h:mm"
                    print("receive")
                    print(settings.timerDate)
                    if (settings.timerDate != nil) {
                        let secondsLeft = settings.timerDate!.timeIntervalSince(Date())
                        if (secondsLeft < 1) {
                            settings.timerDate = nil
                            settings.timerLeft = ""
                        } else {
                            settings.timerLeft = String(Int(secondsLeft / 60))
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

                   if isTimeInInterval(now: now, timer: settings.timerDate != nil) {
                        self.timeColor = Color(hex: 0xCCCCCC)
                    } else {
                        self.timeColor = Color(hex: 0x6D071A)
                    }
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
        }
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
    if let window = NSApp.windows.first {
        // hide buttons
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        // hide title and bar
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true

        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.level = .floating
        window.collectionBehavior = .canJoinAllSpaces
        window.hasShadow = false
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
