//
//  DiceGameView.swift
//  Kniffel App
//
import SwiftUI

struct DiceGameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dice = Array(repeating: 1, count: 6)
    @State private var held = Array(repeating: false, count: 6)
    @State private var rollCount = 0
    
    var body: some View {
        VStack {
            // Titel analog ContentView
            Text("Mein Kniffel")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 50)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color(UIColor.systemBackground))
            // Zwei Reihen à drei Würfel
            ForEach(0..<2) { row in
                HStack(spacing: 36) {
                    ForEach(0..<3) { col in
                        let index = row * 3 + col
                        Button(action: { held[index].toggle() }) {
                            Image(systemName: "die.face.\(dice[index]).fill")
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 70)
                                .padding(6)
                                .background(held[index] ? Color.green.opacity(0.3) : Color.clear)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .disabled(rollCount == 0)
                    }
                }
            }
            Text("Klicke auf den Würfel, um ihn für den nächsten Wurf zu speichern.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 80)
            HStack(spacing: 24) {
                Button("Reset") {
                    reset()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 24)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Text("\(rollCount)/3")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Button("Würfeln") {
                    roll()
                }
                .disabled(rollCount >= 3)
                .padding(.vertical, 8)
                .padding(.horizontal, 24)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.bottom)
            
            Spacer()
            
            
        }
        .padding()
    }
    
    // MARK: - Aktionen
    private func roll() {
        guard rollCount < 3 else { return }
        for i in dice.indices where !held[i] {
            dice[i] = Int.random(in: 1...6)
        }
        rollCount += 1
    }
    
    private func reset() {
        dice = Array(repeating: 1, count: 6)
        held = Array(repeating: false, count: 6)
        rollCount = 0
    }
}

#Preview {
    DiceGameView()
}
//  Created by Iordanis Kardogeros on 04.07.25.
//

