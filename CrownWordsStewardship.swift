
// CrownWordsStewardship.swift
// Drop this file into your app target. Call StewardshipDashboard() from your navigation.

import SwiftUI
import Combine

enum CWCategory: String, CaseIterable, Codable, Identifiable {
    case income, tithe, taxes, savings, investments, expenses, giving
    var id: String { rawValue }
    var isIncome: Bool { self == .income }
    var isOutflow: Bool { self != .income }
}

struct CWTransaction: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var date: Date = Date()
    var note: String = ""
    var category: CWCategory = .income
    var amount: Double = 0
}

struct CWPolicy: Codable {
    var titheRate: Double = 0.10
    var taxRate: Double = 0.20
    var savingsRate: Double = 0.10
    var investRate: Double = 0.10
    var givingRate: Double = 0.02
}

struct CWSnapshot: Codable {
    var netIncome: Double
    var tithe: Double
    var taxes: Double
    var savings: Double
    var investments: Double
    var giving: Double
    var expenses: Double
}

enum CWError: Error { case io, decode, encode }

@MainActor
final class CWStore: ObservableObject {
    @Published private(set) var txs: [CWTransaction] = []
    @Published var policy = CWPolicy()
    private let file = "crownwords_ledger.json"
    private let policyFile = "crownwords_policy.json"

    init() { Task { await load() } }

    func add(_ t: CWTransaction) { txs.append(t); txs.sort { $0.date > $1.date }; save() }
    func delete(at offsets: IndexSet) { txs.remove(atOffsets: offsets); save() }

    func allocateIncome(amount: Double, note: String) {
        let r = policy
        let tithe = amount * r.titheRate
        let taxes = amount * r.taxRate
        let savings = amount * r.savingsRate
        let invest = amount * r.investRate
        let giving = amount * r.givingRate
        let reserved = tithe + taxes + savings + invest + giving
        let toExpenses = max(amount - reserved, 0)

        let now = Date()
        let entries: [CWTransaction] = [
            CWTransaction(date: now, note: note, category: .income, amount: amount),
            CWTransaction(date: now, note: "Tithe", category: .tithe, amount: tithe),
            CWTransaction(date: now, note: "Taxes", category: .taxes, amount: taxes),
            CWTransaction(date: now, note: "Savings", category: .savings, amount: savings),
            CWTransaction(date: now, note: "Investments", category: .investments, amount: invest),
            CWTransaction(date: now, note: "Giving", category: .giving, amount: giving),
            CWTransaction(date: now, note: "Expenses available", category: .expenses, amount: toExpenses)
        ]
        entries.forEach { add($0) }
    }

    func snapshot() -> CWSnapshot {
        func sum(_ cat: CWCategory) -> Double { txs.filter { $0.category == cat }.map(\.mount).reduce(0,+) }
        return CWSnapshot(netIncome: sum(.income), tithe: sum(.tithe), taxes: sum(.taxes),
                          savings: sum(.savings), investments: sum(.investments),
                          giving: sum(.giving), expenses: sum(.expenses))
    }

    private func save() { _ = writeJSON(txs, named: file); _ = writeJSON(policy, named: policyFile) }
    private func load() async {
        if let arr: [CWTransaction] = readJSON(named: file) { txs = arr }
        if let pol: CWPolicy = readJSON(named: policyFile) { policy = pol }
    }

    private func docs() -> URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] }

    private func writeJSON<T: Encodable>(_ value: T, named: String) -> URL? {
        do { let url = docs().appendingPathComponent(named)
            let data = try JSONEncoder().encode(value)
            try data.write(to: url, options: .atomic); return url } catch { return nil }
    }
    private func readJSON<T: Decodable>(named: String) -> T? {
        do { let url = docs().appendingPathComponent(named)
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data) } catch { return nil }
    }
}

struct StewardshipDashboard: View {
    @StateObject private var store = CWStore()
    @State private var amount = ""
    @State private var note = ""

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Add Income") {
                        TextField("Amount", text: $amount).keyboardType(.decimalPad)
                        TextField("Note", text: $note)
                        Button("Allocate") {
                            if let v = Double(amount.replacingOccurrences(of: ",", with: ".")), v > 0 {
                                store.allocateIncome(amount: v, note: note)
                                amount = ""; note = ""
                            }
                        }
                    }
                    Section("Snapshot") {
                        let s = store.snapshot()
                        Text("Net: \(s.netIncome, format: .currency(code: "EUR"))")
                        Text("Tithe: \(s.tithe, format: .currency(code: "EUR"))")
                        Text("Savings: \(s.savings, format: .currency(code: "EUR"))")
                        Text("Investments: \(s.investments, format: .currency(code: "EUR"))")
                        Text("Giving: \(s.giving, format: .currency(code: "EUR"))")
                        Text("Expenses: \(s.expenses, format: .currency(code: "EUR"))")
                    }
                }
            }
            .navigationTitle("CrownWords Stewardship")
        }
    }
}
