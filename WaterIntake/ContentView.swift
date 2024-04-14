//
//  ContentView.swift
//  WaterIntake
//
//  Created by magrawa7 on 4/9/24.
//

import SwiftUI
import HealthKit
import SwiftUICharts

struct ContentView: View {
    @State private var waterAmount: Double = 0.0
    @State private var totalWaterConsumed: Double = 0.0
    @State private var history: [(date: Date, amount: Double)] = []
    @State private var selectedTimeRange: TimeRange = .week
    

    var body: some View {
        TabView {
            // First Tab: Add Water
            VStack {
                Text("Water Consumption")
                    .font(.title)
                    .padding()

                Text("Total Water Consumed: \(totalWaterConsumed, specifier: "%.1f") oz")
                    .font(.headline)
                    .padding()

                Slider(value: $waterAmount, in: 0...100, step: 0.1)
                    .padding()

                Button(action: {
                    addWater()
                }) {
                    Text("Add \(waterAmount, specifier: "%.1f") oz")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .tabItem {
                Label("Add Water", systemImage: "drop.fill")
            }

            // Second Tab: History with Chart
            NavigationView {
                VStack {
                    Picker("Time Range", selection: $selectedTimeRange) {
                        Text("Day").tag(TimeRange.day)
                        Text("Week").tag(TimeRange.week)
                        Text("Month").tag(TimeRange.month)
                        Text("Year").tag(TimeRange.year)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    if !history.isEmpty {
                        LineChartView(data: chartData, title: "Water Consumption", legend: "Ounces")
                            .padding()
                    } else {
                        Text("No data available")
                            .padding()
                    }

                    List {
                        ForEach(history, id: \.date) { entry in
                            HStack {
                                Text("\(entry.date, formatter: dateFormatter)")
                                Spacer()
                                Text("\(entry.amount, specifier: "%.1f") oz")
                            }
                        }
                    }
                }
                .navigationTitle("Trends")
            }
            .tabItem {
                Label("Trends", systemImage: "chart.bar.fill")
            }
        }
    }

    private var chartData: [Double] {
        switch selectedTimeRange {
        case .day:
            return getChartData(for: .day)
        case .week:
            return getChartData(for: .week)
        case .month:
            return getChartData(for: .month)
        case .year:
            return getChartData(for: .year)
        }
    }

    private func getChartData(for timeRange: TimeRange) -> [Double] {
        let currentDate = Date()
        let calendar = Calendar.current
        let startDate: Date

        switch timeRange {
        case .day:
            startDate = calendar.startOfDay(for: currentDate)
        case .week:
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: currentDate)!
        }

        var data: [Double] = []

        for dayOffset in 0..<timeRange.rawValue {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: startDate)!
            let amount = history.filter { calendar.isDate($0.date, inSameDayAs: date) }
                                .reduce(0) { $0 + $1.amount }
            data.insert(amount, at: 0) // Insert at beginning for chronological order
        }

        return data
    }

    func addWater() {
        totalWaterConsumed += waterAmount
        let entry = (date: Date(), amount: waterAmount)
        history.append(entry)
        waterAmount = 0.0 // Reset the slider after adding water
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

enum TimeRange: Int {
    case day = 1
    case week = 7
    case month = 30
    case year = 365
}
