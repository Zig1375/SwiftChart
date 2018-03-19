import Foundation

class SvgPath: SvgChildProtocol {
    private var d = [String]();
    public var params = ["fill": "none"];


//<path fill="none" d="M 10 270 L500 270" stroke="#35bddf" stroke-width="2" stroke-linejoin="round" stroke-linecap="round"></path>
    func move(x: Double, y: Double) {
        self.d.append("M\(x) \(y)");
    }

    func move(x: Int, y: Int) {
        self.move(x: Double(x), y: Double(y));
    }

    func lineTo(x: Double, y: Double) {
        self.d.append("L\(x) \(y)");
    }

    func lineTo(x: Int, y: Int) {
        self.lineTo(x: Double(x), y: Double(y));
    }

    func render() -> String {
        var path = [String]();
        path.append("<path d=\"\(self.d.joined(separator: " "))\" ");

        for(k, v) in self.params {
            path.append("\(k)=\"\(v)\" ");
        }

        path.append("></path>");
        return path.joined(separator: "");
    }
}
