import Foundation

class SvgRect: SvgChildProtocol {
    private let x: Double;
    private let y: Double;
    private let width: Double;
    private let height: Double;
    public var params = ["fill": "none"];

    init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x;
        self.y = y;
        self.width = width;
        self.height = height;
    }

    convenience init(x: Int, y: Int, width: Int, height: Int) {
        self.init(x: Double(x), y: Double(y), width: Double(width), height: Double(height));
    }

    func render() -> String {
        var rect = [String]();
        rect.append("<rect x=\"\(self.x)\" y=\"\(self.y)\" width=\"\(self.width)\" height=\"\(self.height)\" ");

        for(k, v) in self.params {
            rect.append("\(k)=\"\(v)\" ");
        }

        rect.append("></rect>");
        return rect.joined(separator: "");
    }
}
