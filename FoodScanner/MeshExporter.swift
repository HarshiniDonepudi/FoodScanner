import ARKit
import SceneKit

class MeshExporter {
    private var scene: SCNScene

    init() {
        scene = SCNScene()
    }

    func addMesh(anchor: ARMeshAnchor) {
        let node = createNode(from: anchor)
        scene.rootNode.addChildNode(node)
    }

    func exportUSDZ(completion: @escaping (URL?) -> Void) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("MeshExport.usdz")
        scene.write(to: tempURL, delegate: nil, progressHandler: nil)
        print("USDZ file exported to: \(tempURL)")
        completion(tempURL)
    }

    func exportOBJ(completion: @escaping (URL?) -> Void) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("MeshExport.obj")
        scene.write(to: tempURL, delegate: nil, progressHandler: nil)
        print("OBJ file exported to: \(tempURL)")
        completion(tempURL)
    }

    private func createNode(from meshAnchor: ARMeshAnchor) -> SCNNode {
        let node = SCNNode()
        let geometry = createMeshGeometry(from: meshAnchor.geometry)
        node.geometry = geometry
        node.simdTransform = meshAnchor.transform
        return node
    }

    private func createMeshGeometry(from meshGeometry: ARMeshGeometry) -> SCNGeometry {
        let vertexBuffer = meshGeometry.vertices.buffer
        let normalBuffer = meshGeometry.normals.buffer
        let faceBuffer = meshGeometry.faces.buffer

        let vertexSource = SCNGeometrySource(
            buffer: vertexBuffer,
            vertexFormat: .float3,
            semantic: .vertex,
            vertexCount: meshGeometry.vertices.count,
            dataOffset: 0,
            dataStride: meshGeometry.vertices.stride
        )

        let normalSource = SCNGeometrySource(
            buffer: normalBuffer,
            vertexFormat: .float3,
            semantic: .normal,
            vertexCount: meshGeometry.normals.count,
            dataOffset: 0,
            dataStride: meshGeometry.normals.stride
        )

        let faceData = Data(bytes: faceBuffer.contents(), count: faceBuffer.length)
        let faceElement = SCNGeometryElement(
            data: faceData,
            primitiveType: .triangles,
            primitiveCount: meshGeometry.faces.count,
            bytesPerIndex: MemoryLayout<UInt32>.stride
        )

        let geometry = SCNGeometry(sources: [vertexSource, normalSource], elements: [faceElement])
        geometry.firstMaterial?.diffuse.contents = UIColor.green.withAlphaComponent(0.5)
        geometry.firstMaterial?.isDoubleSided = true
        return geometry
    }
}
