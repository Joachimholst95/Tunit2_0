//
//  FrequencyMeter.swift
//  Tunit
//
//  Created by Joachim Holst on 28.06.20.
//  Copyright © 2020 Joachim Holst. All rights reserved.
//

import SwiftUI

struct FrequencyMeter: View {
    @State var progressState : CGFloat = 0
    
    var body: some View {
        VStack {
            Meter(progress: self.$progressState)
            /*
            HStack(spacing: 25){
                
                Button(action: {
                    
                    withAnimation(Animation.default.speed(0.55)){
                        
//                        self.progressState += 10
                        
                        self.increaseAngle()
                    }
                    
                }) {
                    
                    Text("Update")
                        .padding(.vertical,10)
                        .frame(width: (UIScreen.main.bounds.width - 50) / 2)
                    
                }
                .background(Capsule().stroke(LinearGradient(gradient: Gradient(colors: [Color("Color_Meter_red"), Color("Color_Meter_red"), Color("Color_Meter_red"), Color("Color_Meter_green"), Color("Color_Meter_red")]), startPoint: .leading, endPoint: .trailing), lineWidth: 2))
                
                
                Button(action: {
                    
                    withAnimation(Animation.default.speed(0.55)){
                        
                        self.progressState = 0
                    }
                    
                }) {
                    
                    Text("Reset")
                        .padding(.vertical,10)
                        .frame(width: (UIScreen.main.bounds.width - 50) / 2)
                    
                }
                .background(Capsule().stroke(LinearGradient(gradient: Gradient(colors: [Color("Color_Meter_red"), Color("Color_Meter_red"), Color("Color_Meter_red"), Color("Color_Meter_green"), Color("Color_Meter_red")]), startPoint: .leading, endPoint: .trailing), lineWidth: 2))
            }
            .padding(.top, 55)*/
            }
        }
    

    func setAngle(angle: CGFloat) {
        withAnimation(Animation.default.speed(0.55)){
            self.progressState = angle
        }
    }
    func increaseAngle() {
        withAnimation(Animation.default.speed(0.55)){
            self.progressState += 10
        }
    }
    func getprogress() -> CGFloat {
        return progressState
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
    
    var body: some View{
        ZStack {
            ZStack {
                Circle()
                    .trim(from: 0.02, to: 0.48)
                    .stroke(Color.black.opacity(0.1), lineWidth: 10)
                    .frame(width: 300, height: 300)
                
                Circle()
//                    .trim(from: 0.02, to: 0.48)
                    .trim(from: 0.02, to: self.setProgress())
                    .stroke(AngularGradient(gradient: Gradient(colors: [Color("Color_Meter_red"), Color("Color_Meter_red"), Color("Color_Meter_red"), Color("Color_Meter_green"), Color("Color_Meter_red")]), center: .center, angle: .init(degrees: 180)), lineWidth: 20)
                    .frame(width: 320, height: 320)
            }
            .rotationEffect(.init(degrees: 180))
            
            ZStack(alignment: .bottom) {
                
                self.colors[2]
                .frame(width: 2, height: 120)
                
                Circle()
                    .fill(self.colors[2])
                    .frame(width: 15, height: 15)
            }
            .offset(y: -60)
            .rotationEffect(.init(degrees: -90))
            .rotationEffect(.init(degrees: self.setArrow()))

            ZStack(alignment: .bottom) {
                Path { path in
                    path.move(to: CGPoint(x: 44, y: 0))
                    path.addLine(to: CGPoint(x: 88, y: 60))
                }
                .stroke(Color.red, lineWidth: 2.0)
               
                Path { path in
                    path.move(to: CGPoint(x: 276, y: 0))
                    path.addLine(to: CGPoint(x: 232, y: 60))
                }
                .stroke(Color.red, lineWidth: 2.0)
            }
        }
        .frame(width: 320, height: 320, alignment: .bottom)
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
