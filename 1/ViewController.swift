//
//  ViewController.swift
//  1
//
//  Created by Vladimir Em on 18.09.2022.
//
import UIKit

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import SwiftUI
import AVFAudio
import UIKit

struct TunerData {
    var pitch: Float = 0.0
    var amplitude: Float = 0.0
    var noteNameWithSharps = "-"
    var noteNameWithFlats = "-"
}
enum Synthesizer {
    case arpeggio, pad, bass
}

enum Instrument {
    case arpeggio, pad, bass, drum
}

enum Sound {
    case square, saw, pad, noisy
}



class ViewController: UIViewController {
    
   
    var engine = AudioEngine()
    var sequencer = AppleSequencer()
    var mixer = Mixer()
    var arpeggioSynthesizer = MIDISampler(name: "Arpeggio Synth")
    var padSynthesizer = MIDISampler(name: "Pad Synth")
    var bassSynthesizer = MIDISampler(name: "Bass Synth")
    var drumKit = MIDISampler(name: "Drums")
    var filter: MoogLadder?

    var bassSound: Sound = .square
    var padSound: Sound = .square
    var arpeggioSound: Sound = .square
    var length = 4
    var isPlaying: Bool = false
    var synthesizer: Synthesizer = .arpeggio
    var instrument: Instrument = .arpeggio
    var tempo: Float = 120
    var arpeggioVolume: Float = 0.8
    var padVolume: Float = 0.8
    var bassVolume: Float = 0.8
    var drumVolume: Float = 0.8
    var filterFrequency: Float = 1.0


    var musicPlayer : MusicPlayer? = nil
    var plotData = [Double]()
    var notePlotData = convertWithHalfSteps(inputFile: TestOne())
    var noteGraphPlotted = false
    var maxDataPoints = 100
    var frameRate = 600.0
    var alphaValue = 0.25
    var timer : Timer?
    var currentIndex: Int!
    var timeDuration:Double = 0.1
    var heightPrev = -1.0
    var previousConfirmedNote = "-"
    var counter = 0
    var data = TunerData()
    var initialDevice: Device!
    var mic: AudioEngine.InputNode!
    var tappableNodeA: Fader!
    var tappableNodeB: Fader!
    var tappableNodeC: Fader!
    var silence: Fader!
    var tracker: PitchTap!
    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    var sequence : MusicSequence?
    var track : MusicTrack?
    var time = MusicTimeStamp(0.0)
    var soundbank:NSURL!
    var mp:AVMIDIPlayer!
    
    @IBOutlet var dataButton: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let input = engine.input else { fatalError() }
        guard let device = engine.inputDevice else { fatalError() }
        
        initialDevice = device
        mixer = Mixer(arpeggioSynthesizer, padSynthesizer, bassSynthesizer, drumKit)
        filter = MoogLadder(mixer)
        filter?.cutoffFrequency = 20_000
        engine.output = filter
        mic = input
        tappableNodeA = Fader(mic)
        print("objects init")
        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                self.update(pitch[0], amp[0])
            }
        }
        
        start()
        self.view.isUserInteractionEnabled = true
        dataButton.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        dataButton.addGestureRecognizer(tap)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil){
       
       playMusic()
    }
    
    func update(_ pitch: AUValue, _ amp: AUValue) {
        // Reduces sensitivity to background noise to prevent random / fluctuating data.
        guard amp > 0.1 else { return }
   
            
        
        data.pitch = pitch
        data.amplitude = amp

        var frequency = pitch

        var minDistance: Float = 10000.0
        var index = 0

        for possibleIndex in 0 ..< frequencyOrder.count {
            let distance = fabsf(Float(frequencyOrder[possibleIndex]) - frequency)
            if distance < minDistance {
               // print(index)
                index = possibleIndex
                minDistance = distance
                //print(index)
            }
        }
        data.noteNameWithSharps = NotesOrder[index]
      
    }
    func start() {
      
        do {
            useSound(.square, synthesizer: .arpeggio)
            useSound(.saw, synthesizer: .pad)
            useSound(.saw, synthesizer: .bass)
            try drumKit.loadEXS24("Sounds/Sampler Instruments/drumSimp")
        } catch {
            Log("A file was not found.")
        }
        do {
            try engine.start()
            tracker.start()
        } catch {
            Log("AudioKit did not start!")
        }
        sequencer.enableLooping()

    }

    func stop() {
        sequencer.stop()
        engine.stop()
    }
    
    func filePathReturn() -> NSURL{
        let fileMang = FileManager.default
        var filePath = NSHomeDirectory()
        do {
            let appSupportDir = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            filePath = appSupportDir.appendingPathComponent("data.mid").path
        }
        catch{}
        print(filePath)
        if fileMang.fileExists(atPath: filePath) {
            do {
                try fileMang.removeItem(atPath: filePath)
            }
            catch {}
        }

        return NSURL(fileURLWithPath: filePath)
    }
    
    func playMusic(){


        NewMusicSequence(&sequence)
        MusicSequenceNewTrack(sequence!, &track)
       // let url = filePathReturn()
        let url:NSURL = Bundle.main.url(forResource: "Demo", withExtension: "mid")! as NSURL
        let track1 = sequencer.newTrack()
        
        
        for notee in TestOne().notes{
            var number = freqsScale[notee.frequency] ?? 0
           // print(number)
            //print(notee.distance)
            number += 11
            let d1 = Duration(seconds: Double(notee.distance))
            let d2 = Duration(seconds: Double(time))
            track1?.add( midiNoteData: MIDINoteData(noteNumber: UInt8(number), velocity: 64, channel: 1, duration: d1 , position: d2 ))
            
            time += Double(notee.distance)
        }
        sequencer.tracks.append(track1!)
        sequencer.tracks[1].setMIDIOutput(arpeggioSynthesizer.midiIn)
        arpeggioSound = Sound.saw
        arpeggioVolume = 1.0

        sequencer.setLength(Duration(seconds: time))
        try! sequencer.genData()!.write(to: url as URL)
        self.soundbank = Bundle.main.url(forResource: "gs_instruments", withExtension: "gls") as NSURL?
        
        // a standard MIDI file.
        var contents:NSURL = url
        do{
            try self.mp = AVMIDIPlayer(contentsOf: contents as URL, soundBankURL: soundbank as URL?)
        }
        catch{
            print("player not created")
        } 
        if self.mp == nil {
            print("nil midi player")
        }
        self.mp.prepareToPlay()
        
        self.mp.play(nil)
        
       
        var completion:AVMIDIPlayerCompletionHandler = {print("done")}
        mp.play(completion)
        url.stopAccessingSecurityScopedResource()


    }
    func startMixer() {
        mixer = Mixer(arpeggioSynthesizer, padSynthesizer, bassSynthesizer, drumKit)
        filter = MoogLadder(mixer)
        filter?.cutoffFrequency = 20_000
        engine.output = filter

    }
   

    func adjustVolume(_ volume: AUValue, instrument: Instrument) {
        switch instrument {
        case .arpeggio:
            arpeggioSynthesizer.volume = volume
        case .pad:
            padSynthesizer.volume = volume
        case .bass:
            bassSynthesizer.volume = volume
        case .drum:
            drumKit.volume = volume
        }
    }

    func adjustFilterFrequency(_ frequency: Float) {
        filter?.cutoffFrequency = frequency.denormalized(to: 30 ... 20_000, taper: 3)
    }

    func rewindSequence() {
        sequencer.rewind()
    }

    func setLength(_ length: Double) {
        guard round(sequencer.length.beats) != round(4.0 * length) else { return }
        sequencer.setLength(Duration(beats: 16))
        for track in sequencer.tracks {
            track.resetToInit()
        }
        sequencer.setLength(Duration(beats: length))
        sequencer.setLoopInfo(Duration(beats: length), loopCount: 0)
        sequencer.rewind()
    }

    func useSound(_ sound: Sound, synthesizer: Synthesizer) {
        var path = "Sounds/Sampler Instruments/"
        switch sound {
        case .square:
            path += "sqrTone1"
        case .saw:
            path += "sawPiano1"
        case .pad:
            path += "sawPad1"
        case .noisy:
            path += "noisyRez"
        }

        do {
            switch synthesizer {
            case .arpeggio:
                try arpeggioSynthesizer.loadEXS24(path)
            case .pad:
                try padSynthesizer.loadEXS24(path)
            case .bass:
                try bassSynthesizer.loadEXS24(path)
            }
        } catch {
            Log("Could not load EXS24")
        }
    }

    func adjustTempo(_ tempo: Float) {
        sequencer.setTempo(Double(tempo))
    }
    
}



