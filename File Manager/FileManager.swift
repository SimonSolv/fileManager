import Foundation
import UIKit

func getFiles(sortedBy: SortType) -> [ImageData] {
    var files: [ImageData] = []
    var index = 0
    let documentsURL: URL
    do {
        documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            for file in contents {
                let imageName = documentsURL.appendingPathComponent(file.path).lastPathComponent
                let image = getSavedImage(named: imageName)!
                let item = ImageData(image: image, imageName: imageName)
                files.append(item)
                index += 1
            }
        } catch {
            print(error.localizedDescription)
        }
    } catch {
        print(error.localizedDescription)
    }
    switch sortedBy {
    case .AZ:
        sortPhotos(data: files, sorting: .AZ) { data in
            files = data
        }
    case .ZA:
        sortPhotos(data: files, sorting: .ZA) { data in
            files = data
        }
    }
    return files
}

var imageSaveName: String {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd_hh:mm:ss"
    let now = df.string(from: Date())
    return "/Image_\(now)" + ".jpeg"
}

func saveImage(image: UIImage) -> Bool {
    guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
        return false
    }
    guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
        return false
    }
    do {
        try data.write(to: directory.appendingPathComponent(imageSaveName)!)
        print("Image Saved")
        return true
    } catch {
        print(error.localizedDescription)
        return false
    }
}

func getSavedImage(named: String) -> UIImage? {
    if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
        return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
    }
    return nil
}

func deleteImage(name: String) -> Bool {
    guard let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
        return false
    }
    let deletingURL = URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(name).path
    do {
        try FileManager.default.removeItem(atPath: deletingURL)
        print("Image deleted")
        return true
    } catch {
        print(error.localizedDescription)
        return false
    }
}

enum SortType {
    case AZ, ZA
}

func sortPhotos(data: [ImageData],sorting: SortType, completion: (_ data: [ImageData]) -> Void) {
    switch sorting {
    case .AZ:
        let output: [ImageData] = data.sorted(by: { $0.imageName < $1.imageName })
        return completion(output)
    case .ZA:
        let output: [ImageData] = data.sorted(by: { $0.imageName > $1.imageName })
        return completion(output)
    }
}
