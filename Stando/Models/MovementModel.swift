//
//  PostureModel.swift
//  Stando
//
//  Created by Max Wo on 19/7/2023.
//

import SwiftUI
import Combine
import UserNotifications

enum Posture {
    case sitting, standing
}

class MovementModel: ObservableObject {
    @AppStorage(SettingConstants.isSittingAtLaunch) private var isSittingAtLaunch = true
    @AppStorage(SettingConstants.isPausingAtLaunch) private var isPausingAtLaunch = false
    @AppStorage(SettingConstants.isPausingAtEndOfMovement) private var isPausingAtEndOfMovement = false
    @AppStorage(SettingConstants.isSendingMovementNotifications) private var isSendingMovementNotifications = true
    @AppStorage(SettingConstants.sitDurationSeconds) private var sitDurationSeconds = 900
    @AppStorage(SettingConstants.standDurationSeconds) private var standDurationSeconds = 2700
    @AppStorage(SettingConstants.notificationSoundPath) private var notificationSoundPath = "Default"

    @Published var posture: Posture
    @Published var durationElapsedSeconds: Int
    @Published var isPaused: Bool
    @Published var totalSitDurationElapsedSeconds: Int
    @Published var totalStandDurationElapsedSeconds: Int

    private var timer: AnyCancellable?

    var isSitting: Bool {
        posture == Posture.sitting
    }

    var formattedRemainingTime: String {
        let durationSeconds = isSitting ? sitDurationSeconds : standDurationSeconds

        let remainingDurationSeconds = durationSeconds - durationElapsedSeconds

        return String(format: "%02d:%02d", remainingDurationSeconds / 60, remainingDurationSeconds % 60)
    }

    init(
        posture: Posture = Posture.sitting,
        durationElapsedSeconds: Int = 0,
        isPaused: Bool = true,
        timer: AnyCancellable? = nil,
        totalSitDurationElapsedSeconds: Int = 0,
        totalStandDurationElapsedSeconds: Int = 0
    ) {
        self.posture = posture
        self.durationElapsedSeconds = durationElapsedSeconds
        self.isPaused = isPaused
        self.timer = timer
        self.totalSitDurationElapsedSeconds = totalSitDurationElapsedSeconds
        self.totalStandDurationElapsedSeconds = totalStandDurationElapsedSeconds

        self.posture = isSittingAtLaunch ? Posture.sitting : Posture.standing

        if !isPausingAtLaunch {
            start()

            if isSendingMovementNotifications {
                sendMovementNotification()
            }
        }
    }

    deinit {
        pause()
    }

    func sendMovementNotification() {
        let content = UNMutableNotificationContent()

        content.title = "It's time to \(isSitting ? "sit down" : "stand up")!"

        if isSitting {
            if let message = MessageConstants.sitMessages.randomElement() {
                content.subtitle = message
            }
        } else {
            if let message = MessageConstants.standMessages.randomElement() {
                content.subtitle = message
            }
        }

        content.sound = notificationSoundPath == "Default" ?
        UNNotificationSound.default :
        UNNotificationSound(named: UNNotificationSoundName(rawValue: notificationSoundPath))

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func start() {
        guard isPaused else {
            return
        }

        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.durationElapsedSeconds += 1

                if self.isSitting {
                    self.totalSitDurationElapsedSeconds += 1
                } else {
                    self.totalStandDurationElapsedSeconds += 1
                }

                if self.durationElapsedSeconds >= (self.isSitting ?
                                                   self.sitDurationSeconds :
                                                    self.standDurationSeconds
                ) {
                    self.next()
                }
            }

        isPaused = false
    }

    func pause() {
        timer?.cancel()

        timer = nil

        isPaused = true
    }

    func resume() {
        start()
    }

    func restart(isPausing: Bool = false) {
        pause()

        durationElapsedSeconds = 0

        if !isPausing {
            start()
        }
    }

    func next() {
        posture = isSitting ? Posture.standing : Posture.sitting

        restart(isPausing: isPausingAtEndOfMovement)

        if isSendingMovementNotifications {
            sendMovementNotification()
        }
    }
}
