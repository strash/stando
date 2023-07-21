//
//  StandoApp.swift
//  Stando
//
//  Created by Max Wo on 14/7/2023.
//

import SwiftUI

@main
struct StandoApp: App {
    @StateObject private var posture = PostureModel()
    @StateObject private var metrics = MetricsModel()
    @StateObject private var timer = TimerModel()

    var body: some Scene {
        Settings {
            PreferencesView()
        }

        MenuBarExtra("Stando", image: posture.isSitting ? "figure.seated.side" : "figure.stand") {
            PopoverView()
                .environmentObject(posture)
                .environmentObject(metrics)
                .environmentObject(timer)
                .onAppear {
                    timer.startTimer()
                }
        }
        .menuBarExtraStyle(.window)
    }
}
