import Foundation
import HealthKit

class HealthManager {
    let healthStore = HKHealthStore()

    // Request authorization to access HealthKit data
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        // Data types to read from HealthKit
        guard let glucoseType = HKObjectType.quantityType(forIdentifier: .bloodGlucose),
              let exerciseType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
              let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(false)
            return
        }

        let typesToRead: Set<HKObjectType> = [glucoseType, exerciseType, sleepType]

        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            if let error = error {
                print("HealthKit Authorization Error: \(error.localizedDescription)")
            }
            completion(success)
        }
    }

    // Fetch Glucose Data
    func fetchGlucoseData(completion: @escaping ([HealthMetric]) -> Void) {
        guard let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose) else { return }

        let query = HKSampleQuery(sampleType: glucoseType, predicate: nil, limit: 10, sortDescriptors: nil) { _, results, _ in
            var metrics: [HealthMetric] = []
            if let samples = results as? [HKQuantitySample] {
                for sample in samples {
                    let value = sample.quantity.doubleValue(for: HKUnit(from: "mg/dL"))
                    let time = DateFormatter.localizedString(from: sample.startDate, dateStyle: .none, timeStyle: .short)
                    metrics.append(HealthMetric(value: value, time: time))
                }
            }
            completion(metrics)
        }

        healthStore.execute(query)
    }

    // Fetch today's Exercise Data (Active Energy Burned)
    func fetchExerciseData(completion: @escaping (Double) -> Void) {
        guard let exerciseType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: exerciseType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, _ in
            let totalEnergy = statistics?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
            completion(totalEnergy)
        }

        healthStore.execute(query)
    }

    // Fetch today's Sleep Data
    func fetchSleepData(completion: @escaping (Int) -> Void) {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 0, sortDescriptors: nil) { _, results, _ in
            var totalSleepMinutes = 0
            if let samples = results as? [HKCategorySample] {
                for sample in samples {
                    if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                        let sleepDuration = Int(sample.endDate.timeIntervalSince(sample.startDate) / 60)
                        totalSleepMinutes += sleepDuration
                    }
                }
            }
            completion(totalSleepMinutes)
        }

        healthStore.execute(query)
    }
}
