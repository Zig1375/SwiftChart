import Foundation

func shell(launchPath: String, arguments: [String]) -> Data {
    let process = Process()
    process.launchPath = launchPath;
    process.arguments = arguments;

    let pipe = Pipe();
    process.standardOutput = pipe;
    process.launch();

    let output_from_command = pipe.fileHandleForReading.readDataToEndOfFile();
    return output_from_command;
}