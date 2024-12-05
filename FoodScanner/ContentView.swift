import SwiftUI
import RealityKit
import ARKit
import simd

struct ContentView: View {
    @State private var meshDetails: [SegmentedMeshDetails] = []
    @State private var isScanning = false
    @State private var remainingTime: TimeInterval = 5 // Scan duration in seconds
    @State private var distanceMessage: String = "Position yourself closer to the object."
    @State private var readyToScan = false

    let scanDuration: TimeInterval = 5
    let minVolumeThreshold: Float = 0.001
    let optimalDistance: Float = 0.1 // Optimal distance in meters (50 cm)

    var body: some View {
        VStack {
            // ARView container
            ARViewContainer(
                meshDetails: $meshDetails,
                isScanning: $isScanning,
                remainingTime: $remainingTime,
                distanceMessage: $distanceMessage,
                readyToScan: $readyToScan,
                scanDuration: scanDuration,
                minVolumeThreshold: minVolumeThreshold,
                optimalDistance: optimalDistance
            )
            .edgesIgnoringSafeArea(.all)

            // Proximity and scan status
            VStack(spacing: 10) {
                Text(distanceMessage)
                    .foregroundColor(readyToScan ? .green : .red)
                    .font(.headline)
                    .padding()

                if readyToScan && !isScanning {
                    Button(action: {
                        isScanning = true
                        remainingTime = scanDuration
                    }) {
                        Text("Start Scanning")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(readyToScan ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!readyToScan)
                }

                if isScanning {
                    Text("Scanning in progress...")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text("Time Remaining: \(Int(remainingTime)) seconds")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()

            // Filtered mesh details list
            List(meshDetails) { detail in
                VStack(alignment: .leading) {
                    Text("Mesh Segment \(detail.id)")
                        .font(.headline)
                    Text("Vertices: \(detail.vertices)")
                    Text("Faces: \(detail.faces)")
                    Text("Volume: \(detail.volume, specifier: "%.4f") m³")
                }
                .padding()
            }
        }
    }

    struct ARViewContainer: UIViewRepresentable {
        @Binding var meshDetails: [SegmentedMeshDetails]
        @Binding var isScanning: Bool
        @Binding var remainingTime: TimeInterval
        @Binding var distanceMessage: String
        @Binding var readyToScan: Bool
        let scanDuration: TimeInterval
        let minVolumeThreshold: Float
        let optimalDistance: Float

        func makeUIView(context: Context) -> ARView {
            let arView = ARView(frame: .zero)
            let configuration = ARWorldTrackingConfiguration()
            configuration.sceneReconstruction = .mesh
            configuration.planeDetection = [.horizontal, .vertical]
            arView.session.run(configuration)

            context.coordinator.setARView(arView)
            context.coordinator.setOptimalDistance(optimalDistance)
            arView.session.delegate = context.coordinator

            return arView
        }

        func updateUIView(_ uiView: ARView, context: Context) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(
                meshDetails: $meshDetails,
                isScanning: $isScanning,
                remainingTime: $remainingTime,
                distanceMessage: $distanceMessage,
                readyToScan: $readyToScan,
                minVolumeThreshold: minVolumeThreshold,
                scanDuration: scanDuration
            )
        }
    }
}
