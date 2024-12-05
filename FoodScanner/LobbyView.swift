import SwiftUI
import Charts
import Foundation

struct HealthMetric: Identifiable {
    let id = UUID() // A unique ID for each metric
    let value: Double // The health value (e.g., glucose level)
    let time: String // The time associated with the metric (e.g., "8:00 AM")
}

struct LobbyView: View {
    @State private var glucoseData: [HealthMetric] = []
    @State private var exerciseData: Double = 0
    @State private var sleepData: Int = 0
    @State private var navigateToContent: Bool = false

    let healthManager = HealthManager()

    var body: some View {
        ZStack {
            // Background with calming health colors
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.2), Color.teal.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // Title Section
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        // Insulin (Syringe)
                        Image(systemName: "syringe")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)

                        // Carb (Fork/Knife)
                        Image(systemName: "fork.knife")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.green)

                        // Glucose (Drop)
                        Image(systemName: "drop.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.red)
                    }

                    Text("Insulocarb")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.green)

                    Text("Monitor your health metrics and stay on track!")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                // Glucose Graph
                VStack {
                    Text("Glucose Levels")
                        .font(.headline)
                        .foregroundColor(.green)

                    if !glucoseData.isEmpty {
                        Chart(glucoseData) {
                            LineMark(x: .value("Time", $0.time), y: .value("Glucose", $0.value))
                        }
                        .frame(height: 200)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 2)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .cornerRadius(10)
                            .overlay(
                                Text("No Data Available")
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .padding(.horizontal)

                // Exercise and Sleep Summary
                VStack {
                    Text("Activity Summary")
                        .font(.headline)
                        .foregroundColor(.green)

                    HStack {
                        VStack {
                            Image(systemName: "figure.walk")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.green)

                            Text("Exercise")
                                .font(.subheadline)
                            Text("\(Int(exerciseData)) kcal")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }

                        Spacer()

                        VStack {
                            Image(systemName: "bed.double.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)

                            Text("Sleep")
                                .font(.subheadline)
                            Text("\(sleepData / 60) hrs")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal)

                // Button to Log/Scan Meals
                NavigationLink(destination: ContentView(), isActive: $navigateToContent) {
                    EmptyView()
                }

                Button(action: {
                    navigateToContent = true
                }) {
                    Text("Log and Scan Meals")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.green)
                        .cornerRadius(10)
                        .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 20)
            .onAppear {
                loadData()
            }
        }
    }

    private func loadData() {
        healthManager.requestAuthorization { success in
            if success {
                healthManager.fetchGlucoseData { data in
                    glucoseData = data
                }
                healthManager.fetchExerciseData { data in
                    exerciseData = data
                }
                healthManager.fetchSleepData { data in
                    sleepData = data
                }
            }
        }
    }
}

