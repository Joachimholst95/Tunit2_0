//
//  FrequencyMeter.swift
//  Tunit
//
//  Created by Joachim Holst on 28.06.20.
//  Copyright © 2020 Joachim Holst. All rights reserved.
//

import SwiftUI

struct FrequencyMeter: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct FrequencyMeter_Previews: PreviewProvider {
    static var previews: some View {
        FrequencyMeter()
    }
}

struct Home : View {
    var body: some View{
        VStack {
            
            Spacer()
        }
    }
}

struct Meter : View {
    
    let colors = [Color("Color_Meter_green"), Color("Color_Meter_red")]
    
    var body: some View{
        ZStack {
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.5)
                    .stroke(Color.black.opacity(0.1), lineWidth: 55)
                    .frame(width: 280, height: 280)
                
                Circle()
                    .trim(from: 0, to: 0.5)
                    .stroke(AngularGradient(gradient: .init(colors: self.colors), center: .center, angle: .init(degrees: 180)), lineWidth: 55)
                    .frame(width: 280, height: 280)
            }
            .rotationEffect(.init(degrees: 180))
        }
    }
}
