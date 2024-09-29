//
//  BetterRest.swift
//  LearnSwiftUI
//
//  Created by Irtaza Fiaz on 29/09/2024.
//

import SwiftUI
import CoreML

struct BetterRest: View {
    @State private var wakeUp = Date.now
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("When do you want to wake up?")
                    .font(.headline)
                
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                Text("Desired Amount of Sleep")
                    .font(.headline)
                
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                
                Text("Daily Coffee intake")
                    .font(.headline)
                
                Stepper("\(coffeeAmount) cup(s)", value: $coffeeAmount, in: 1...20)
            }
            .padding()
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func calculateBedTime() {
        do {
            let configuration = MLModelConfiguration()
            let sleepCalculator = try SleepCalculator(configuration: configuration)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hourInSeconds = (components.hour ?? 0) * 60 * 60
            let minutesInSeconds = (components.minute ?? 0) * 60
            
            let prediction = try sleepCalculator.prediction(wake: Double(hourInSeconds + minutesInSeconds), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepRequired = wakeUp - prediction.actualSleep
            alertTitle = "You should go to bed at..."
            alertMessage = sleepRequired.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Oops, couldn't find the sleep time required."
        }
        showAlert.toggle()
    }
}

#Preview {
    BetterRest()
}
