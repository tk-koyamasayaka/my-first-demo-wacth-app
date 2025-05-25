import SwiftUI
import HealthKit

class HeartRateManager: NSObject, ObservableObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    private var healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    @Published var heartRate: Double = 0.0

    override init() {
        super.init()
        requestAuthorization()
    }

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let types: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: types) { success, error in
            if success {
                self.startWorkout()
            }
        }
    }

    func startWorkout() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }

        let config = HKWorkoutConfiguration()
        config.activityType = .other
        config.locationType = .indoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            builder = session?.associatedWorkoutBuilder()

            session?.delegate = self
            builder?.delegate = self

            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)

            session?.startActivity(with: Date())
            builder?.beginCollection(withStart: Date()) { success, error in }
        } catch {
            print("WorkoutSession start error: \(error)")
        }
    }

    // MARK: - Delegate Methods

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf types: Set<HKSampleType>) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate),
              types.contains(heartRateType),
              let statistics = workoutBuilder.statistics(for: heartRateType) else { return }

        let value = statistics.mostRecentQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0.0
        DispatchQueue.main.async {
            self.heartRate = value
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {}
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {}
}

struct ContentView: View {
    @StateObject private var manager = HeartRateManager()

    var body: some View {
        VStack(spacing: 10) {
            Text("❤️ 心拍数")
                .font(.headline)
            Text("\(Int(manager.heartRate)) BPM")
                .font(.largeTitle)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

