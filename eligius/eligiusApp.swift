//
//  eligiusApp.swift
//  eligius
//
//  Created by Saint on 3/14/24.
//

import MenuBarExtraAccess
import SwiftUI
import Combine

let appSize = CGFloat(200)

class Settings: ObservableObject {
    @Published var isMenuPresented: Bool = false
    @Published var timerString = ""
    @Published var timerDate: Date?
    @Published var showTimer: Bool = false
}

@main
struct eligiusApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var settings = Settings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(
                    minWidth: 350, maxWidth: 350,
                    minHeight: 200, maxHeight: 200
                )
                .environmentObject(settings)
        }
        .windowResizability(.contentSize)

        MenuBarExtra("MyApp Menu", systemImage: "folder") {
            MyMenu()
                .introspectMenuBarExtraWindow { window in // <-- the magic ✨
                    window.animationBehavior = .alertPanel

                }
                .environmentObject(settings)
        }

        .menuBarExtraStyle(.window)
        .menuBarExtraAccess(isPresented: $settings.isMenuPresented) { _ in // <-- the magic ✨
            // access status item or store it in a @State var
        }
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

struct MyMenu: View {
    @EnvironmentObject var settings: Settings

    var body: some View {
        VStack {
            Text("Timer:")
                .font(Font.custom("EPSON-FUTO-MINCHO", size: 50))
            TextField("hint", text: $settings.timerString)
                .font(Font.custom("EPSON-FUTO-MINCHO", size: 50))
                .onReceive(Just(settings.timerString)) { newValue in
                    let value = newValue.replacingOccurrences(of: "[^0-9:]", with: "", options: .regularExpression)
                    if value != newValue {
                        self.settings.timerString = value
                    }
                }
                .onSubmit() {
                    settings.isMenuPresented.toggle()

                    var moreMinutes = Int(self.settings.timerString)
                    if self.settings.timerString.range(of: "[0-9]{1,2}:[0-9]{1,2}",
                        options: .regularExpression, range: nil, locale: nil) != nil {

                        print("time found")
                        let timeArr = self.settings.timerString.components(separatedBy: ":")
                        var inputHour = Int(timeArr[0])!
                        let inputMin = Int(timeArr[1])!

                        let curCalendar = Calendar.current
                        var now = Date()
                        // Get the minute component of the current time
                        let currentHour = curCalendar.component(.hour, from: now)

                        self.settings.timerDate = Calendar.current.date(bySettingHour: inputHour,
                            minute: inputMin,
                            second: 0, of: Date())!

                        print(self.settings.timerDate)

                        // add 12 hours if roll over
                        if inputHour < Int(currentHour) {
                            var dateComponents = DateComponents()
                            let calendar = Calendar.current
                            dateComponents.hour = 12
                            self.settings.timerDate =  calendar.date(byAdding: dateComponents,
                                                                     to: self.settings.timerDate!)
                        }

                    } else {
                        var dateComponents = DateComponents()
                        let calendar = Calendar.current
                        dateComponents.minute = moreMinutes
                        self.settings.timerDate =  calendar.date(byAdding: dateComponents, to: Date())
                    }


                    let formatter = DateFormatter()
                    formatter.dateFormat = "h:mm"
                    let dateString = formatter.string(from: self.settings.timerDate!)
                    self.settings.timerString = dateString
                    print("\(self.settings.timerDate)")
                }
        }
        .frame(
            minWidth: 350, maxWidth: 350,
            minHeight: 200, maxHeight: 200
        )

            .onAppear() {
                chromeless()
            }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        chromeless()

    }
    func applicationWillUpdate(_ notification: Notification) {

        DispatchQueue.main.async {
            if let menu = NSApplication.shared.mainMenu {
                menu.items.removeAll()
            }
        }
    }
}
