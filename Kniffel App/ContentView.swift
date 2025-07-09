import SwiftUI

#if canImport(UIKit)
extension View {
    /// Dismisses the software keyboard in any currently active UIApplication scene.
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
#endif

struct ContentView: View {
    // MARK: - State Variablen
    @State private var players: [String] = ["Spieler 1", "Spieler 2", "Spieler 3"]
    @State private var scores: [[Int?]] = Array(repeating: Array(repeating: nil, count: 3), count: 15)
    @State private var showResetAlert: Bool = false
    @State private var bonusChecked: [Bool] = [false, false, false]

    
    let tasks = [
        ("1er", "nur Einser zählen"),
        ("2er", "nur Zweier zählen"),
        ("3er", "nur Dreier zählen"),
        ("4er", "nur Vierer zählen"),
        ("5er", "nur Fünfer zählen"),
        ("6er", "nur Sechser zählen"),
        ("Bonus bei 63 oder mehr", "plus 35"),
        ("Obere Punkte", ""),
        ("Dreierpasch", "alle Augen zählen"),
        ("Viererpasch", "alle Augen zählen"),
        ("Full House", "25 Punkte"),
        ("Kleine Straße", "30 Punkte"),
        ("Große Straße", "40 Punkte"),
        ("Kniffel", "50 Punkte"),
        ("Chance", "alle Augen zählen"),
    ]

    // MARK: - View
    var body: some View {
        TabView {
            VStack {
            // Titel
            Text("Mein Kniffel")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, -10)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color(UIColor.systemBackground))

            HStack {
                Button(action: { showResetAlert = true }) {
                    Image(systemName: "arrow.counterclockwise")
                        .padding()
                }
                Spacer()
                Button(action: addPlayer) {
                    Image(systemName: "plus")
                        .padding()
                }
                Button(action: removeLastPlayer) {
                    Image(systemName: "minus")
                        .padding()
                }
            }

            ScrollView(.horizontal) {
                VStack(alignment: .leading, spacing: 0) {
                    // Kopfzeile mit "Namen"
                    HStack {
                        Text("Namen")
                            .font(.headline)
                            .frame(width: 130, alignment: .leading)
                            .padding(.leading, 8)

                        ForEach(players.indices, id: \.self) { playerIndex in
                            TextField("Spieler \(playerIndex + 1)", text: $players[playerIndex])
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 80, alignment: .center)
                        }
                    }
                    Divider()

                    ScrollView(.vertical) {
                        VStack(alignment: .leading, spacing: 12) {
                            // Aufgaben und Beschreibungen und Punkte der Spieler
                            ForEach(tasks.indices, id: \.self) { taskIndex in
                                HStack {
                                    // Aufgaben und Beschreibungen
                                    VStack(alignment: .leading) {
                                        Text(tasks[taskIndex].0)
                                            .font(.subheadline)
                                            .bold()
                                        if !tasks[taskIndex].1.isEmpty {
                                            Text(tasks[taskIndex].1)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .frame(width: 130, alignment: .leading)
                                    .padding(.leading, 8)

                                    // Punkte der Spieler
                                    ForEach(players.indices, id: \.self) { playerIndex in
                                        if taskIndex < scores.count && playerIndex < scores[taskIndex].count {
                                            if taskIndex == 6 { // Bonus Checkbox
                                                Toggle("", isOn: Binding(
                                                    get: {
                                                        playerIndex < bonusChecked.count ? bonusChecked[playerIndex] : false
                                                    },
                                                    set: { newValue in
                                                        if playerIndex < bonusChecked.count {
                                                            bonusChecked[playerIndex] = newValue
                                                        }
                                                        calculateScores()
                                                    }
                                                ))
                                                .labelsHidden()
                                                .disabled(true) // Automatische Checkbox
                                                .frame(width: 80, alignment: .center)
                                            } else if taskIndex == 7 { // Obere Punkte
                                                Text("\(calculateUpperTotal(for: playerIndex))")
                                                    .frame(width: 80, alignment: .center)
                                                    .foregroundColor(.blue)
                                                    .fontWeight(.bold)
                                            } else if [10, 11, 12, 13].contains(taskIndex) {
                                                // Drei‑Zustände‑Button für Full House, Kleine/Große Straße, Kniffel
                                                let fixedScore = (taskIndex == 10 ? 25 :
                                                                  taskIndex == 11 ? 30 :
                                                                  taskIndex == 12 ? 40 : 50)
                                                
                                                Button(action: {
                                                    let current = scores[taskIndex][playerIndex]
                                                    if current == nil {
                                                        // Zustand 1 → Zustand 2 (gestrichen, 0 Punkte)
                                                        scores[taskIndex][playerIndex] = 0
                                                    } else if current == 0 {
                                                        // Zustand 2 → Zustand 3 (Punkte erzielt)
                                                        scores[taskIndex][playerIndex] = fixedScore
                                                    } else {
                                                        // Zustand 3 → zurück zu Zustand 1 (unbenutzt)
                                                        scores[taskIndex][playerIndex] = nil
                                                    }
                                                    calculateScores()
                                                }) {
                                                    Image(systemName:
                                                        scores[taskIndex][playerIndex] == nil ? "square" :
                                                        (scores[taskIndex][playerIndex] == 0 ? "xmark.square" : "checkmark.square")
                                                    )
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 24, height: 24)
                                                }
                                                .frame(width: 80, alignment: .center)
                                            } else {
                                                TextField("-", value: $scores[taskIndex][playerIndex], formatter: NumberFormatter())
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                                    .keyboardType(.numberPad)
                                                    .frame(width: 80, alignment: .center)
                                                    .onChange(of: scores[taskIndex][playerIndex]) {
                                                        calculateScores()
                                                    }
                                            }
                                        }
                                    }
                                }
                                .padding(.bottom, taskIndex == 7 || taskIndex == 14 ? 10 : 0)
                            }

                            // Gesamtwerte berechnen
                            HStack {
                                Text("Untere Punkte")
                                    .frame(width: 130, alignment: .leading)
                                    .padding(.leading, 7)
                                    .fontWeight(.bold)
                                ForEach(players.indices, id: \.self) { playerIndex in
                                    let lowerTotal = calculateLowerTotal(for: playerIndex)
                                    Text("\(lowerTotal)")
                                        .frame(width: 80, alignment: .center)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.top, 10)

                            HStack {
                                Text("Gesamt")
                                    .frame(width: 130, alignment: .leading)
                                    .padding(.leading, 7)
                                    .fontWeight(.bold)
                                ForEach(players.indices, id: \.self) { playerIndex in
                                    let upperTotal = calculateUpperTotal(for: playerIndex)
                                    let lowerTotal = calculateLowerTotal(for: playerIndex)
                                    Text("\(upperTotal + lowerTotal)")
                                        .frame(width: 80, alignment: .center)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.top, 10)
                        }
                        .padding(.bottom, 32) // zusätzlicher Platz am Ende
                    }
                }
            }

            Spacer()

        }
        .onTapGesture {
            hideKeyboard()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Fertig") {
                    hideKeyboard()
                }
            }
        }
        .tabItem {
            Label("Kniffelblock", systemImage: "list.dash")
        }

        DiceGameView()
            .tabItem {
                Label("Würfeln", systemImage: "die.face.5")
            }
    }
    .alert(isPresented: $showResetAlert) {
        Alert(
            title: Text("Spiel wirklich zurücksetzen?"),
            primaryButton: .destructive(Text("Ja")) {
                resetGame()
            },
            secondaryButton: .cancel(Text("Abbrechen"))
        )
    }
    }

    // MARK: - Funktionen

    private func addPlayer() {
        players.append("Spieler \(players.count + 1)")
        bonusChecked.append(false)
        for i in 0..<scores.count {
            if i < scores.count {
                scores[i].append(nil)
            }
        }
    }

    private func removeLastPlayer() {
        guard !players.isEmpty else { return }
        
        // 1. Array‑Längen synchron halten:
        //    Zuerst die Spalten in scores und bonusChecked entfernen …
        for row in scores.indices {
            if !scores[row].isEmpty {
                scores[row].removeLast()
            }
        }
        if !bonusChecked.isEmpty {
            bonusChecked.removeLast()
        }
        
        // 2. … dann erst den Spieler selbst entfernen.
        players.removeLast()
    }


    private func resetGame() {
        players = ["Spieler 1", "Spieler 2", "Spieler 3"]
        bonusChecked = [false, false, false]
        scores = Array(
            repeating: Array(repeating: nil, count: 3),
            count: 15
        )
    }

    private func calculateScores() {
        for playerIndex in players.indices {
            if playerIndex < bonusChecked.count {
                let upperTotal = scores.prefix(6).compactMap { row in
                    playerIndex < row.count ? row[playerIndex] : nil
                }.reduce(0, +)
                bonusChecked[playerIndex] = upperTotal >= 63
            }
        }
    }

    private func calculateUpperTotal(for playerIndex: Int) -> Int {
        let upperTotal = scores.prefix(6).compactMap { $0[playerIndex] }.reduce(0, +)
        let bonus = bonusChecked[playerIndex] ? 35 : 0
        return upperTotal + bonus
    }

    private func calculateLowerTotal(for playerIndex: Int) -> Int {
        return scores.suffix(from: 8).compactMap { $0[playerIndex] }.reduce(0, +)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
