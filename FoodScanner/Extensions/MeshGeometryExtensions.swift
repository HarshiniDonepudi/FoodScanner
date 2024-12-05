import ARKit
import simd

extension ARMeshGeometry {
        func calculateVolume(filteredVertices: [SIMD3<Float>]) -> Float {
            let faceBuffer = faces.buffer
            let faceCount = faces.count

            var volume: Float = 0.0
            let facePointer = faceBuffer.contents().bindMemory(to: UInt32.self, capacity: faceCount * 3)

            for i in 0..<faceCount {
                let faceIndex = i * 3
                let index1 = Int(facePointer[faceIndex])
                let index2 = Int(facePointer[faceIndex + 1])
                let index3 = Int(facePointer[faceIndex + 2])

                // Skip faces if any of the vertices are not in the filtered list
                guard index1 < filteredVertices.count,
                      index2 < filteredVertices.count,
                      index3 < filteredVertices.count else {
                    continue
                }

                let vertex1 = filteredVertices[index1]
                let vertex2 = filteredVertices[index2]
                let vertex3 = filteredVertices[index3]

                let tetrahedronVolume = abs(simd_dot(vertex1, simd_cross(vertex2, vertex3))) / 6.0
                volume += tetrahedronVolume
            }

            return volume
        }

        func boundingBox() -> (min: SIMD3<Float>, max: SIMD3<Float>) {
            let vertexBuffer = vertices.buffer
            let vertexCount = vertices.count
            let vertexStride = vertices.stride
            let vertexPointer = vertexBuffer.contents().bindMemory(to: Float.self, capacity: vertexCount * 3)

            var minBounds = SIMD3<Float>(Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude)
            var maxBounds = SIMD3<Float>(-Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude)

            for i in 0..<vertexCount {
                let vertex = loadVertex(at: i, pointer: vertexPointer, stride: vertexStride)
                minBounds = min(minBounds, vertex)
                maxBounds = max(maxBounds, vertex)
            }

            return (min: minBounds, max: maxBounds)
        }

        func filterVertices(predicate: (SIMD3<Float>) -> Bool) -> [SIMD3<Float>] {
            let vertexBuffer = vertices.buffer
            let vertexCount = vertices.count
            let vertexStride = vertices.stride

            let vertexPointer = vertexBuffer.contents().bindMemory(to: Float.self, capacity: vertexCount * 3)

            var filteredVertices: [SIMD3<Float>] = []
            for i in 0..<vertexCount {
                let vertex = loadVertex(at: i, pointer: vertexPointer, stride: vertexStride)
                if predicate(vertex) {
                    filteredVertices.append(vertex)
                }
            }
            return filteredVertices
        }

         func loadVertex(at index: Int, pointer: UnsafePointer<Float>, stride: Int) -> SIMD3<Float> {
            let offset = index * stride / MemoryLayout<Float>.stride
            return SIMD3<Float>(
                pointer[offset],
                pointer[offset + 1],
                pointer[offset + 2]
            )
        }
    }
