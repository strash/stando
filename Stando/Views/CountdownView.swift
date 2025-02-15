//
//  CountdownView.swift
//  Stando
//
//  Created by Max Wo on 20/7/2023.
//

import SwiftUI

struct CountdownView: View {
    @AppStorage(SettingConstants.sitDurationSeconds) private var sitDurationSeconds = 900
    @AppStorage(SettingConstants.standDurationSeconds) private var standDurationSeconds = 2700

    @EnvironmentObject private var movement: MovementModel

    private var postureIcon: String {
        movement.isSitting ? "figure.seated.side" : "figure.stand"
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(movement.formattedRemainingTime)
                .font(.largeTitle)
                .monospacedDigit()
            Text("\(Image(postureIcon)) \(movement.isSitting ? "Sitting" : "Standing")")
        }
    }
}

struct CountdownView_Previews: PreviewProvider {
    static var previews: some View {
        let userDefaults: UserDefaults = {
            let defaults = UserDefaults()

            defaults.set(true, forKey: SettingConstants.isPausingAtLaunch)

            return defaults
        }()

        CountdownView()
            .environmentObject(MovementModel(posture: Posture.sitting, durationElapsedSeconds: 123))
            .defaultAppStorage(userDefaults)
    }
}
