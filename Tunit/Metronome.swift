//
//  Metronome.swift
//  Tunit
//
//  Created by Joachim Holst on 24.06.20.
//  Copyright © 2020 Joachim Holst. All rights reserved.
//


import AVFoundation


class Metronome {
    
    var bpm: Float = 60.0 { didSet {
        bpm = min(300.0,max(30.0,bpm))
        }}
    var enabled: Bool = false { didSet {
        if enabled {
            start()
        } else {
            stop()
        }
        }}
    var onTick: ((_ nextTick: DispatchTime) -> Void)?
    var nextTick: DispatchTime = DispatchTime.distantFuture
    var player: AVAudioPlayer!
    
    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            let soundURL = Bundle.main.path(forResource: "around_the_world-atc", ofType: "wav")!
            print(soundURL)
//            let soundFile = try AVAudioFile(forReading: soundURL)
//            let player = try AVAudioPlayer(contentsOf: soundURL)
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundURL))
        } catch {
            print("Oops, unable to initialize metronome audio buffer: \(error)")
        }
    }

    private func start() {
        print("Starting metronome, BPM: \(bpm)")
        nextTick = DispatchTime.now()
        player.prepareToPlay()
        nextTick = DispatchTime.now()
        tick()
    }

    private func stop() {
        player.stop()
        print("Stoping metronome")
    }

    private func tick() {
        guard
            enabled,
            nextTick <= DispatchTime.now()
            else { return }

        let interval: TimeInterval = 60.0 / TimeInterval(bpm)
        nextTick = nextTick + interval
        DispatchQueue.main.asyncAfter(deadline: nextTick) { [weak self] in
            self?.tick()
        }
        player.prepareToPlay()
//        player.delegate = self
        player.play(atTime: interval)
        onTick?(nextTick)
    }
}
