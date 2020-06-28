//
//  MainViewController.swift
//  Tunit
//
//  Created by Joachim Holst on 21.06.20.
//  Copyright © 2020 Joachim Holst. All rights reserved.
//

import AudioKit
import AudioKitUI
import AVFoundation
import SoundAnalysis
import CoreML

class MainViewController : UIViewController {

    var mic: AKMicrophone!
    var audioEngine: AVAudioEngine!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    var instrumentClassifier = Tunit2_1()
    var model: MLModel! = nil
    var inputBus: AVAudioNodeBus!
    var inputFormat: AVAudioFormat!
    var streamAnalyzer: SNAudioStreamAnalyzer!
    // Serial dispatch queue used to analyze incoming audio buffers.
    let analysisQueue = DispatchQueue(label: "fhooe.at.mc.holst")
    var resultsObserver: ResultsObserver!
    var metronome: Metronome! = nil
    var metronomeSpeedLabel: UILabel!

    
    @IBOutlet weak var higher_lower_button: UIButton!
    @IBOutlet weak var metronomeTickLabel: UILabel!
    @IBOutlet weak var metronomeSlider: UISlider!
    @IBOutlet public weak var instrumentLabel: UILabel!
    @IBOutlet weak var audioWaveView: AKNodeOutputPlot!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var amplitudeLabel: UILabel!
    @IBOutlet weak var noteLabelSharp: UILabel!
    @IBOutlet weak var noteLabelFlat: UILabel!
    @IBOutlet weak var noteFrequencyLabel: UILabel!
    
    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]

    fileprivate func setupSoundClasifier() {
        /*
         switch (AVAudioSession.sharedInstance().recordPermission) {
         case .granted: // The user has previously granted access to the microphone.
         print("")
         //                  self.startAudio()
         case .undetermined: // The user has not yet been asked for recording access.
         print("")
         case .denied: // The user has previously denied access.
         print("recording acces denied")
         }
         */
        
        model = instrumentClassifier.model
        
        // Create a new audio engine.
        audioEngine = AVAudioEngine()
        
        startAudioEngine()
        
        instrumentClassifier = Tunit2_1()
        // Do any additional setup after loading the view.
        
        // Get the native audio format of the engine's input bus.
        inputBus = AVAudioNodeBus(0)
        inputFormat = audioEngine.inputNode.inputFormat(forBus: inputBus)
        
        // Create a new stream analyzer.
        streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
        
        // Create a new observer that will be notified of analysis results.
        // Keep a strong reference to this object.
        resultsObserver = ResultsObserver()
        
        do {
            // Prepare a new request for the trained model.
            let request = try SNClassifySoundRequest(mlModel: model)
            try streamAnalyzer.add(request, withObserver: resultsObserver)
        } catch {
            print("Unable to prepare request: \(error.localizedDescription)")
            return
        }
        
        // Install an audio tap on the audio engine's input node.
        audioEngine.inputNode.installTap(onBus: inputBus,
                                         bufferSize: 8192, // 8k buffer
        format: inputFormat) { buffer, time in
            
            // Analyze the current audio buffer.
            self.analysisQueue.async {
                if (self.tracker.amplitude > 0.05) {
                    self.streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        metronome = Metronome()
        AKSettings.audioInputEnabled = true
        AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
        
        setupSoundClasifier()
    }

    fileprivate func setupMetronomeSpeedSliderLabel() {
        if let handleView = metronomeSlider.subviews.last as? UIImageView {
            let label = UILabel(frame: handleView.bounds)
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 10)
            metronomeSlider.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
            handleView.addSubview(label)
            
            self.metronomeSpeedLabel = label
            //set label font, size, color, etc.
            label.text = "100"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {

        AudioKit.output = silence
        startAudiokit()
        setupPlot()
        
        setupMetronomeSpeedSliderLabel()
        metronome.onTick = { (nextTick) in
            self.animateTick()
        }
        
        Timer.scheduledTimer(timeInterval: 0.1,
                             target: self,
                             selector: #selector(MainViewController.updateUI),
                             userInfo: nil,
                             repeats: true)
    }
    
    // MARK: - AudioEngine
    
    func startAudioEngine() {
        // Create a new audio engine.
        audioEngine = AVAudioEngine()

        // Get the native audio format of the engine's input bus.
        inputBus = AVAudioNodeBus(0)
        inputFormat = audioEngine.inputNode.inputFormat(forBus: inputBus)
        
        do {
            // Start the stream of audio data.
            try audioEngine.start()
        } catch {
            print("Unable to start AVAudioEngine: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Metronome
    
    @IBAction func toggleMetronome(_ sender: Any) {
        if metronome.enabled == true {
            metronome.enabled = false
        } else {
            metronome.enabled = true
        }
        
    }
    
    private func animateTick() {
        metronomeTickLabel.alpha = 1.0
        UIView.animate(withDuration: 0.35) {
            self.metronomeTickLabel.alpha = 0.0
        }
    }
    
    // MARK: - Audiokit
    func stopAudiokit() {
        do {
            try AudioKit.stop()
        } catch {
            print("unable to stop audiokit")
        }
    }
    
    func startAudiokit() {
        do {
            try AudioKit.start()
        } catch {
            print("unable to start audiokit")
        }
    }
    
    func restartAudiokit() {
        AKSettings.audioInputEnabled = true
        AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
        AudioKit.output = silence
        startAudiokit()
    }
    
    
    @IBAction func metronomeSpeedChanged(_ sender: Any) {
        metronome.bpm = metronomeSlider.value
        let temp: Int = Int(metronomeSlider.value)
        metronomeSpeedLabel.text = temp.description
    }
    
    // MARK: - Plot
 
    func setupPlot() {
        let plot = AKNodeOutputPlot(mic, frame: audioWaveView.bounds)
        plot.translatesAutoresizingMaskIntoConstraints = false
        plot.plotType = .rolling
        plot.shouldFill = false
        plot.shouldMirror = true
        plot.color = UIColor.gray
        
        audioWaveView.addSubview(plot)

        // Pin the AKNodeOutputPlot to the audioInputPlot
        var constraints = [plot.leadingAnchor.constraint(equalTo: audioWaveView.leadingAnchor)]
        constraints.append(plot.trailingAnchor.constraint(equalTo: audioWaveView.trailingAnchor))
        constraints.append(plot.topAnchor.constraint(equalTo: audioWaveView.topAnchor))
        constraints.append(plot.bottomAnchor.constraint(equalTo: audioWaveView.bottomAnchor))
        constraints.forEach { $0.isActive = true }
    }
    
    
    
    // MARK: - Actions

    @IBAction func didTapInputDevicesButton(_ sender: UIBarButtonItem) {
        let inputDevices = InputDeviceTableViewController()
        inputDevices.settingsDelegate = self
        let navigationController = UINavigationController(rootViewController: inputDevices)
        navigationController.preferredContentSize = CGSize(width: 300, height: 180)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController!.delegate = self
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func updateUI() {
        if tracker.amplitude > 0.01 {
            
            let trackerFrequency = Float(tracker.frequency)

            guard trackerFrequency < 7_000 else {
                // This is a bit of hack because of modern Macbooks giving super high frequencies
                return
            }

            frequencyLabel.text = String(format: "%0.1f", tracker.frequency)

            var frequency = trackerFrequency
            while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
                frequency /= 2.0
            }
            while frequency < Float(noteFrequencies[0]) {
                frequency *= 2.0
            }

            var minDistance: Float = 10_000.0
            var index = 0

            let octave = Int(log2f(trackerFrequency / frequency))
            for i in 0..<noteFrequencies.count {
                //distance between the note and the frequency in percent
                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
                //when correct note found
                let temp = octave * noteFrequencies[i] * 4
                if distance < minDistance{
                    index = i
                    minDistance = distance
                    noteFrequencyLabel.text = temp.description
                    if temp < tracker.frequency {
                        higher_lower_button.setImage(UIImage.init(systemName: "arrow.down"), for: .normal)
                    } else {
                        higher_lower_button.setImage(UIImage.init(systemName: "arrow.up"), for: .normal)
                    }
                }
                if temp - tracker.frequency < -200 || temp - tracker.frequency > 200 {
                    noteFrequencyLabel.text = ""
                }


            }

            noteLabelSharp.text = "\(noteNamesWithSharps[index])\(octave)"
            noteLabelFlat.text = "\(noteNamesWithFlats[index])\(octave)"
        }
        amplitudeLabel.text = String(format: "%0.2f", tracker.amplitude)
        instrumentLabel.text = resultsObserver.lastInstrumentDetection
    }
    
    func setInstrument(instrument : String) {
        instrumentLabel.text = instrument
    }
}


// Observer object that is called as analysis results are found.
class ResultsObserver : NSObject, SNResultsObserving {
    //current assumption
    var lastInstrumentDetection: String
    //holds recent and current results
    var resultList: [String] = Array(repeating: "", count: 10)
    //which result to replace next
    var lastInserted: Int = 1
    let arr = ["Trumpet", "Trombone", "Contrabass", "Basson", "Horn", "Tuba", "Viola", "Violin", "Sax_Alto", "Flute", "Cello", "Contrabass", "Clarinet", "Oboe"]
    
    override init() {
        lastInstrumentDetection = ""
    }
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        // Get the top classification.
        guard let result = result as? SNClassificationResult,
            let classification = result.classifications.first else { return }
        
//        let formattedTime = String(format: "%.2f", result.timeRange.start.seconds)
//        print("Analysis result for audio at time: \(formattedTime)")
        
//        let confidence = classification.confidence * 100.0
//        let percent = String(format: "%.2f%%", confidence)

//        Print the result as Instrument: percentage confidence.
//        print("\(classification.identifier): \(percent) confidence.\n")
        
        let counts = resultList.reduce(into: [:]) { counts, word in counts[word, default: 0] += 1 }
        for i in counts {
            //if more than half the results are the same instrument
            if i.value > 5 {
                lastInstrumentDetection = i.key
            } else {
                lastInstrumentDetection = ""
            }
        }
        
        //replacing the values in the array and increasing the counter
        resultList[lastInserted] = classification.identifier
        lastInserted = lastInserted + 1
        lastInserted = lastInserted % 10
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The the analysis failed: \(error.localizedDescription)")
    }
    
    func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension MainViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = .up
        popoverPresentationController.barButtonItem = navigationItem.rightBarButtonItem
    }
}

// MARK: - InputDeviceDelegate

extension MainViewController: InputDeviceDelegate {

    func didSelectInputDevice(_ device: AKDevice) {
        do {
            try mic.setDevice(device)
        } catch {
            AKLog("Error setting input device")
        }
    }
}
