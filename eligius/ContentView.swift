//
//  ContentView.swift
//  eligius
//
//  Created by Saint on 3/14/24.
//

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
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


let winWidth = CGFloat(200)
let winHeight = CGFloat(100)
struct ContentView: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var now = getTime()

    var body: some View {
        ZStack {
            Text("\(now)")

                .font(Font.custom("EPSON-FUTO-MINCHO", size: 80))
                //.foregroundColor(Color(hex: 0x650015))
                .foregroundColor(Color(hex: 0x6D071A))
                //.font(Font.custom("Ac437_Apricot_Mono", size: 80))
                //.font(Font.custom("OPTICaslon-ExtraCondensed", size: 40))
                .dragWndWithClick()
                .onReceive(timer) { input in
                    self.now = getTime()
                }

            //Text("Jn 3:38 whoever does not")
            //    .font(Font.custom("EPSON-FUTO-MINCHO", size: 30))
            //    //.foregroundColor(Color(hex: 0x650015))
            //    .foregroundColor(Color(hex: 0x6D071A))

        }
            .frame( minWidth: winWidth, maxWidth: winWidth,
            minHeight: winHeight, maxHeight: winHeight)
            .background(Color.black.opacity(0.3))
            .overlay(AcceptingFirstMouse()) // must be on top (no confuse, it is transparent)

    }
}

import Cocoa

// Just mouse accepter
class MyViewView : NSView {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
}

// Representable wrapper (bridge to SwiftUI)
struct AcceptingFirstMouse : NSViewRepresentable {
    func makeNSView(context: NSViewRepresentableContext<AcceptingFirstMouse>) -> MyViewView {
        return MyViewView()
    }

    func updateNSView(_ nsView: MyViewView, context: NSViewRepresentableContext<AcceptingFirstMouse>) {
        nsView.setNeedsDisplay(nsView.bounds)
    }

    typealias NSViewType = MyViewView
}

func chromeless() {
    if let window = NSApp.windows.first {
        //hide buttons
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
        self.overlay(DragWndView())
    }
}

struct DragWndView: View {
    let test: Bool

    init(test: Bool = false) {
        self.test = test
    }

    var body: some View {
        ( test ? Color.green : Color.clickableAlpha )
            .overlay( DragWndNSRepr() )
    }
}

///////////////
///HELPERS
///////////////

fileprivate struct DragWndNSRepr: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        return DragWndNSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) { }
}

fileprivate class DragWndNSView: NSView {
    override public func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}

@available(OSX 10.15, *)
public extension Color {
    init(hex: UInt32) {
        self.init(
            red:       Double((hex >> 16) & 0xFF) / 256.0,
            green:     Double((hex >> 8) & 0xFF) / 256.0,
            blue:      Double(hex & 0xFF) / 256.0
        )
    }

    init(rgbaHex: UInt32) {
        self.init(
            red:      Double((rgbaHex >> 24) & 0xFF) / 256.0,
            green:    Double((rgbaHex >> 16) & 0xFF) / 256.0,
            blue:     Double((rgbaHex >> 8) & 0xFF) / 256.0,
            opacity:  Double(rgbaHex & 0xFF) / 256.0
        )
    }
}

@available(OSX 10.15, *)
public extension Color {
    static var clickableAlpha: Color { get { return Color(rgbaHex: 0x01010101) } }
}
