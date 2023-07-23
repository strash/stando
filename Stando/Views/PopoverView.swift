//
//  PopoverView.swift
//  Stando
//
//  Created by Max Wo on 18/7/2023.
//

import SwiftUI

struct PopoverView: View {
    @EnvironmentObject private var movement: MovementModel
    @EnvironmentObject private var statistics: StatisticsModel

    var body: some View {
        VStack(spacing: 24) {
            HeaderView()
            ProgressView()
            StatisticsView()
            ControlsView()
        }
        .frame(width: DimensionConstants.screenWidth)
        .padding(24)
    }
}

struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        let userDefaults: UserDefaults = {
            let defaults = UserDefaults()

            defaults.set(true, forKey: PreferenceConstants.isPausingAtLaunch)

            return defaults
        }()

        PopoverView()
            .environmentObject(MovementModel(posture: Posture.sitting, durationSeconds: 123))
            .environmentObject(StatisticsModel(
                sitDurationSeconds: 396,
                standDurationSeconds: 4428,
                caloriesBurned: 195.5
            ))
            .defaultAppStorage(userDefaults)
    }
}
