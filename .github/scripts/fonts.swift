import CoreText
import Foundation

let families = ["Times New Roman", "Songti SC", "Heiti SC", "Kaiti SC"]
func fontList() throws -> String {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    task.arguments = ["typst", "fonts", "--variants"]
    let pipe = Pipe()
    task.standardOutput = pipe
    try task.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    task.waitUntilExit()
    guard task.terminationStatus == 0 else { fatalError("无法读取 Typst 字体列表") }
    return String(decoding: data, as: UTF8.self)
}
let installed = Set(try fontList().split(separator: "\n").map(String.init))
let names = ["TimesNewRomanPSMT", "STSongti-SC-Regular", "STHeitiSC-Light", "STKaitiSC-Regular"]
let missing = zip(families, names).filter { !installed.contains($0.0) }.map {
    CTFontDescriptorCreateWithAttributes([kCTFontNameAttribute: $0.1] as CFDictionary)
}

// Request missing macOS supplemental fonts through Apple's system API.
if !missing.isEmpty {
    let finished = DispatchSemaphore(value: 0)
    var failure: String?
    let started = CTFontDescriptorMatchFontDescriptorsWithProgressHandler(missing as CFArray, nil) { state, info in
        if state == .didFailWithError {
            failure = String(describing: (info as NSDictionary)[kCTFontDescriptorMatchingError] ?? "字体下载失败")
        }
        if state == .didFinish { finished.signal() }
        return true
    }
    guard started, finished.wait(timeout: .now() + 180) == .success, failure == nil else {
        fatalError(failure ?? "字体下载无法启动或已超时")
    }
}

// Typst also discovers downloaded font assets that CoreText has not activated.
let directory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
var family: String?
var copied = Set<String>()
for line in try fontList().split(separator: "\n").map(String.init) {
    if !line.hasPrefix(" ") {
        family = families.contains(line) ? line : nil
    } else if let family, let start = line.firstIndex(of: "/") {
        let source = URL(fileURLWithPath: String(line[start...]))
        let destination = directory.appendingPathComponent(source.lastPathComponent)
        if !FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.copyItem(at: source, to: destination)
        }
        copied.insert(family)
    }
}
guard copied == Set(families) else { fatalError("仍缺少字体：\(Set(families).subtracting(copied))") }
print("已准备全部四类字体。")
