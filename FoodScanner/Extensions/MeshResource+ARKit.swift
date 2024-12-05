import RealityKit
import ARKit

extension MeshResource {
    static func generate(from geometry: ARMeshGeometry) -> MeshResource {
        let vertexBuffer = geometry.vertices.buffer
        let faceBuffer = geometry.faces.buffer

        let vertexStride = geometry.vertices.stride
        let vertexPointer = vertexBuffer.contents().bindMemory(to: Float.self, capacity: geometry.vertices.count * 3)
        let facePointer = faceBuffer.contents().bindMemory(to: UInt32.self, capacity: geometry.faces.count * 3)

        var vertices: [SIMD3<Float>] = []
        for i in 0..<geometry.vertices.count {
            let offset = i * vertexStride / MemoryLayout<Float>.stride
            let x = vertexPointer[offset]
            let y = vertexPointer[offset + 1]
            let z = vertexPointer[offset + 2]
            vertices.append(SIMD3(x, y, z))
        }

        var indices: [UInt32] = []
        for i in 0..<geometry.faces.count * 3 {
            indices.append(facePointer[i])
        }

        return MeshResource.generate(from: vertices, indices: indices)
    }

    static func generate(from vertices: [SIMD3<Float>], indices: [UInt32]) -> MeshResource {
        var descriptor = MeshDescriptor(name: "ARMesh")
        descriptor.positions = MeshBuffer(vertices)
        descriptor.primitives = .triangles(indices)

        return try! MeshResource.generate(from: [descriptor])
    }
}
