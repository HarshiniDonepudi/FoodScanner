import ARKit
import RealityKit
import SwiftUI
import simd

struct SegmentedMeshDetails: Identifiable {
    let id: Int
    let vertices: Int
    let faces: Int
    let volume: Float
}

class Coordinator: NSObject, ARSessionDelegate {
    private weak var arView: ARView?
    private var meshDetailsBinding: Binding<[SegmentedMeshDetails]>
    private var isScanningBinding: Binding<Bool>
    private var remainingTimeBinding: Binding<TimeInterval>
    private var distanceMessageBinding: Binding<String>
    private var readyToScanBinding: Binding<Bool>
    private let minVolumeThreshold: Float
    private let scanDuration: TimeInterval
    private var scanTimer: Timer?
    private var optimalDistance: Float = 0.5
    private var scannedMeshes: Set<UUID> = []

    init(
        meshDetails: Binding<[SegmentedMeshDetails]>,
        isScanning: Binding<Bool>,
        remainingTime: Binding<TimeInterval>,
        distanceMessage: Binding<String>,
        readyToScan: Binding<Bool>,
        minVolumeThreshold: Float,
        scanDuration: TimeInterval
    ) {
        self.meshDetailsBinding = meshDetails
        self.isScanningBinding = isScanning
        self.remainingTimeBinding = remainingTime
        self.distanceMessageBinding = distanceMessage
        self.readyToScanBinding = readyToScan
        self.minVolumeThreshold = minVolumeThreshold
        self.scanDuration = scanDuration
    }

    func setARView(_ arView: ARView) {
        self.arView = arView
    }

    func setOptimalDistance(_ distance: Float) {
        self.optimalDistance = distance
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let arView = arView else { return }

        // Calculate distance from the camera to the world origin
        let translation = frame.camera.transform.columns.3
        let distance = sqrt(translation.x * translation.x + translation.y * translation.y + translation.z * translation.z)

        DispatchQueue.main.async {
            if distance > self.optimalDistance + 0.1 {
                self.isScanningBinding.wrappedValue = false
                self.readyToScanBinding.wrappedValue = false
                self.distanceMessageBinding.wrappedValue = "Move closer to the object."
            } else if distance < self.optimalDistance - 0.1 {
                self.isScanningBinding.wrappedValue = false
                self.readyToScanBinding.wrappedValue = false
                self.distanceMessageBinding.wrappedValue = "Move further away from the object."
            } else {
                self.distanceMessageBinding.wrappedValue = "Distance is optimal."
                self.readyToScanBinding.wrappedValue = true
            }
        }
    }

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard isScanningBinding.wrappedValue else { return }

        for anchor in anchors {
            if let meshAnchor = anchor as? ARMeshAnchor {
                if scannedMeshes.contains(meshAnchor.identifier) { continue }
                processMeshAnchor(meshAnchor)
                scannedMeshes.insert(meshAnchor.identifier)
            }
        }
    }
    private func processMeshAnchor(_ meshAnchor: ARMeshAnchor) {
        let geometry = meshAnchor.geometry
        let boundingBox = geometry.boundingBox()

        // Plate dimensions (adjust thresholds based on your environment)
        let plateHeightThreshold: Float = 0.05 // Height below which objects are considered the plate
        let plateWidthThreshold: Float = 0.15   // Minimum width of the plate
        let plateDepthThreshold: Float = 0.3  // Minimum depth of the plate

        let width = boundingBox.max.x - boundingBox.min.x
        let height = boundingBox.max.y - boundingBox.min.y
        let depth = boundingBox.max.z - boundingBox.min.z

        // Check if the mesh corresponds to the plate
        let isPlate = width > plateWidthThreshold && height < plateHeightThreshold && depth > plateDepthThreshold
        if isPlate {
            print("Excluded: Plate detected")
            return
        }

        // Filter vertices manually (exclude vertices below the plateHeightThreshold)
        let vertexBuffer = geometry.vertices.buffer
        let vertexCount = geometry.vertices.count
        let vertexStride = geometry.vertices.stride
        let vertexPointer = vertexBuffer.contents().bindMemory(to: Float.self, capacity: vertexCount * 3)

        var filteredVertices: [SIMD3<Float>] = []
        for i in 0..<vertexCount {
            let vertex = geometry.loadVertex(at: i, pointer: vertexPointer, stride: vertexStride)
            if vertex.y > boundingBox.min.y + plateHeightThreshold {
                filteredVertices.append(vertex)
            }
        }

        // Recalculate volume and other metrics for the filtered mesh
        let filteredVolume = geometry.calculateVolume(filteredVertices: filteredVertices)
        guard filteredVolume >= minVolumeThreshold else { return }

        DispatchQueue.main.async {
            var details = self.meshDetailsBinding.wrappedValue
            details.append(
                SegmentedMeshDetails(
                    id: details.count + 1,
                    vertices: filteredVertices.count,
                    faces: geometry.faces.count, // Adjust if you filter faces too
                    volume: filteredVolume
                )
            )
            self.meshDetailsBinding.wrappedValue = details
        }

        print("Mesh Anchor Processed - Bounding Box: \(boundingBox), Filtered Volume: \(filteredVolume)")
    }





    func startScanning() {
        var remainingTime = scanDuration
        isScanningBinding.wrappedValue = true
        remainingTimeBinding.wrappedValue = scanDuration

        scanTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            remainingTime -= 1
            DispatchQueue.main.async {
                self.remainingTimeBinding.wrappedValue = remainingTime
                if remainingTime <= 0 {
                    timer.invalidate()
                    self.scanTimer = nil
                    self.isScanningBinding.wrappedValue = false
                    print("Scanning completed.")
                }
            }
        }
    }
}
