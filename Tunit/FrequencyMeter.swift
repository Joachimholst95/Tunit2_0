//
//  FrequencyMeter.swift
//  Tunit
//
//  Created by Joachim Holst on 28.06.20.
//  Copyright © 2020 Joachim Holst. All rights reserved.
//

import SwiftUI

struct FrequencyMeter: View {
    @ObservedObject var progress : FrequencyMeterAngle = FrequencyMeterAngle.init(value: 5)
    let colors = [Color("Color_Meter_red"), Color("Color_Meter_green"),
    Color.gray]
//    var meterStruct : Meter
    @ObservedObject var notes: NotesList = NotesList.init(prevNote: "prevNote", prev2Note: "prev2Note", currNote: "currNote", curr2Note: "curr2Note", nextNote: "nextNote", next2Note: "next2Note")
    
    var body: some View {
        
        VStack {
            
            Meter(progress: $progress.value, notes: $notes.values)
            
        }
        
    }
    
    func setAngle(angle: CGFloat) {
        withAnimation(Animation.default.speed(0.55)){
            progress.value = angle
        }
    }
    
    
    func getprogress() -> CGFloat {
        return self.progress.value
    }
    
    func setProgress()->CGFloat{
        
        let temp = progress.value / 2
        return temp * 0.01
    }
    
    func setArrow()->Double{
        let temp = progress.value / 100
        return Double(temp * 180)
    }
    
    func setNote( note: String, _position: Int) {
        notes.setValue(value: note, position: _position)
    }
}

struct FrequencyMeter_Previews: PreviewProvider {
    static var previews: some View {
        FrequencyMeter()
    }
}

struct Meter : View {
    
    let colors = [Color("Color_Meter_red"), Color("Color_Meter_green"),
                  Color.gray]
    @Binding var progress : CGFloat
    @Binding var notes : [String]
       
    var maskedView = UIView(frame: CGRect(x: 50, y: 50, width: 256, height: 256))
    
    
    
//    maskedView;.backgroundColor = .blue
    
//    var gradientMaskLayer = CAGradientLayer()
//    gradientMaskLayer.frame = maskedView.bounds
    
    var body: some View{
        ZStack {
            ZStack {
                
                // Circle
                ZStack {
                    Circle()
    //                    .trim(from: 0.02, to: 0.48)
                        .stroke(Color.black.opacity(0.1), lineWidth: 10)
                        .frame(width: 300, height: 300)
                    
                    Circle()
    //                    .trim(from: 0.02, to: 0.48)
    //                    .trim(from: 0.5, to: 1)
    //                    .trim(from: 0.02, to: self.setProgress())
                        /*.stroke(AngularGradient(gradient: Gradient(colors: [Color("Color_Meter_red"), Color("Color_Meter_red"), Color("Color_Meter_red"), Color("Color_Meter_green"), Color("Color_Meter_red")]), center: .center, angle: .init(degrees: 180)), lineWidth: 20)
                        */
                        .stroke(Color.black.opacity(0.2), lineWidth: 20)
                        .frame(width: 320, height: 320)
                }
    //            .rotationEffect(.init(degrees: 180))
                
                
    //            .rotationEffect(.init(degrees: -))
    //            .rotationEffect(.init(degrees: self.setArrow()))

            
                // red lines
                ZStack {
                    Path { path in
                        path.move(to: CGPoint(x: 160, y: -30))
                        path.addLine(to: CGPoint(x: 160, y: 40))
                    }
                    .stroke(Color.red, lineWidth:  2.0)
                    .rotationEffect(Angle(degrees: 30), anchor: .center)
                    
                    Path { path in
                        path.move(to: CGPoint(x: 160, y: -30))
                        path.addLine(to: CGPoint(x: 160, y: 40))
                    }
                    .stroke(Color.red, lineWidth:  2.0)
                    .rotationEffect(Angle(degrees: 90), anchor: .center)
                    
                    Path { path in
                        path.move(to: CGPoint(x: 160, y: -30))
                        path.addLine(to: CGPoint(x: 160, y: 40))
                    }
                    .stroke(Color.red, lineWidth:  2.0)
                    .rotationEffect(Angle(degrees: 150), anchor: .center)
                    
                    Path { path in
                        path.move(to: CGPoint(x: 160, y: -30))
                        path.addLine(to: CGPoint(x: 160, y: 40))
                    }
                    .stroke(Color.red, lineWidth:  2.0)
                    .rotationEffect(Angle(degrees: 210), anchor: .center)
                    
                    Path { path in
                        path.move(to: CGPoint(x: 160, y: -30))
                        path.addLine(to: CGPoint(x: 160, y: 40))
                    }
                    .stroke(Color.red, lineWidth:  2.0)
                    .rotationEffect(Angle(degrees: 270), anchor: .center)
                    
                    Path { path in
                        path.move(to: CGPoint(x: 160, y: -30))
                        path.addLine(to: CGPoint(x: 160, y: 40))
                    }
                    .stroke(Color.red, lineWidth:  2.0)
                    .rotationEffect(Angle(degrees: 330), anchor: .center)
                }
                
                // note texts
                ZStack {
                    //every second is a new note
                    //1,3,5 etc. are the second labels for Notes in case two Notes are on the same Frequency
                    Group {
                
                        Text(notes[0])
                            .position(CGPoint(x: 160, y: -30))
                            .multilineTextAlignment(.trailing)
                            .rotationEffect(Angle(degrees: 0), anchor: .center)
                        
                        Text(notes[1])
                            .position(CGPoint(x: 160, y: -50))
                            .multilineTextAlignment(.trailing)
                            .rotationEffect(Angle(degrees: 0), anchor: .center)

                        Text(notes[2])
                            .position(CGPoint(x: 160, y: -30))
                            .multilineTextAlignment(.trailing)
                            .rotationEffect(Angle(degrees: 60), anchor: .center)
                        
                        Text(notes[3])
                            .position(CGPoint(x: 160, y: -50))
                            .multilineTextAlignment(.trailing)
                            .rotationEffect(Angle(degrees: 60), anchor: .center)
                        
                        Text(notes[4])
                            .position(CGPoint(x: 160, y: -30))
                            .multilineTextAlignment(.trailing)
                            .rotationEffect(Angle(degrees: 120), anchor: .center)
                        
                        Text(notes[5])
                            .position(CGPoint(x: 160, y: -50))
                            .multilineTextAlignment(.trailing)
                            .rotationEffect(Angle(degrees: 120), anchor: .center)
                        
                        Text(notes[6])
                            .position(CGPoint(x: 160, y: -30))
                            .multilineTextAlignment(.trailing)
                            .rotationEffect(Angle(degrees: 180), anchor: .center)
                        
                        Text(notes[7])
                            .position(CGPoint(x: 160, y: -50))
                            .multilineTextAlignment(.trailing)
                            .rotationEffect(Angle(degrees: 180), anchor: .center)
                        
                        Text(notes[8])
                            .position(CGPoint(x: 160, y: -30))
                            .multilineTextAlignment(.trailing)
                            .rotationEffect(Angle(degrees: 240), anchor: .center)
                        
                        Text(notes[9])
                            .position(CGPoint(x: 160, y: -50))
                            .multilineTextAlignment(.trailing)
                            .rotationEffect(Angle(degrees: 240), anchor: .center)
                                
                    }
                    Group {
                        Text(notes[10])
                            .position(CGPoint(x: 160, y: -30))
                            .multilineTextAlignment(.trailing)
                            .rotationEffect(Angle(degrees: 300), anchor: .center)
                        
                        Text(notes[11])
                            .position(CGPoint(x: 160, y: -50))
                            .multilineTextAlignment(.trailing)
                            .rotationEffect(Angle(degrees: 300), anchor: .center)
                    }
                }
                .rotationEffect(.init(degrees: 0))
                
                    
            }
            .frame(width: 320, height: 320, alignment: .bottom)
            .rotationEffect(.init(degrees: self.setArrow()))
        
            //pointer
            ZStack(alignment: .bottom) {
                
                self.colors[2]
                .frame(width: 2, height: 120)
                
                Circle()
                    .fill(self.colors[2])
                    .frame(width: 15, height: 15)
            }
            .offset(y: -50)
        }
    }
    
    func setProgress()->CGFloat{
        
        let temp = self.progress / 2
        return temp * 0.01
    }
    
    func setArrow()->Double{
        let temp = self.progress / 100
        return Double(temp * 180)
    }
}

class FrequencyMeterAngle: ObservableObject {
    @Published var value: CGFloat = 90

    func setValue(value: CGFloat) {
        self.value = value
    }
    
    init(value: CGFloat) {
        self.value = value
    }
}

class NotesList: ObservableObject {
    @Published var values: [String] = ["first", "first2", "second", "second2", "third", "third2", "forth", "forth2", "fifth", "fifth2", "sixth", "sixth2"]
    

    func setValue(value: String, position: Int) {
        self.values[position] = value
    }
    
    init(prevNote: String, prev2Note: String, currNote: String, curr2Note: String, nextNote: String, next2Note: String) {
        self.values[0] = prevNote
        self.values[1] = prev2Note
        self.values[2] = currNote
        self.values[3] = curr2Note
        self.values[4] = nextNote
        self.values[5] = next2Note
    }
    
    func getValue(position: Int) -> String {
        return self.values[position]
    }
}
