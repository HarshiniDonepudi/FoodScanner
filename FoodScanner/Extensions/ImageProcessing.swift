import UIKit
import CoreImage

class ImageProcessing {
    func segmentImage(_ image: UIImage?, targetColors: [UIColor], tolerance: CGFloat = 0.2) -> UIImage? {
        guard let image = image, let ciImage = CIImage(image: image) else { return nil }
        let context = CIContext()

        let masks = targetColors.compactMap { color -> CIImage? in
            createColorMask(ciImage: ciImage, color: color, tolerance: tolerance)
        }

        guard let combinedMask = masks.reduce(nil, { $0?.applyingFilter("CISourceOverCompositing", parameters: ["inputBackgroundImage": $1]) ?? $1 }) else { return nil }

        let result = ciImage.applyingFilter("CIBlendWithMask", parameters: ["inputMaskImage": combinedMask])
        if let cgImage = context.createCGImage(result, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }

    private func createColorMask(ciImage: CIImage, color: UIColor, tolerance: CGFloat) -> CIImage? {
        guard let components = color.cgColor.components, components.count >= 3 else { return nil }
        let red = CGFloat(components[0])
        let green = CGFloat(components[1])
        let blue = CGFloat(components[2])

        let minVector = CIVector(x: red - tolerance, y: green - tolerance, z: blue - tolerance, w: 1)
        let maxVector = CIVector(x: red + tolerance, y: green + tolerance, z: blue + tolerance, w: 1)

        let clampFilter = CIFilter(name: "CIColorClamp")!
        clampFilter.setValue(ciImage, forKey: kCIInputImageKey)
        clampFilter.setValue(minVector, forKey: "inputMinComponents")
        clampFilter.setValue(maxVector, forKey: "inputMaxComponents")

        let clampedImage = clampFilter.outputImage

        let monochromeFilter = CIFilter(name: "CIColorMonochrome")!
        monochromeFilter.setValue(clampedImage, forKey: kCIInputImageKey)
        monochromeFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor")
        monochromeFilter.setValue(1.0, forKey: "inputIntensity")

        return monochromeFilter.outputImage
    }
}
