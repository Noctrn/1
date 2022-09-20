//
//  AppDelegate.swift
//  1
//
//  Created by Vladimir Em on 18.09.2022.
//

import UIKit
import AVFoundation
import AudioKit
import AudioKitUI


@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        application.isStatusBarHidden = true
        

        #if os(iOS)
        do {
            Settings.bufferLength = .short
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(Settings.bufferLength.duration)
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                            options: [.defaultToSpeaker, .mixWithOthers, .allowBluetoothA2DP])
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    // The user granted access. Present recording interface.
                } else {
                    // Present message to user indicating that recording
                    // can't be performed until they change their preference
                    // under Settings -> Privacy -> Microphone
                }
            }
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let err {
            print(err)
        }
        #endif

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }



}

