import Foundation

class SvgText: SvgChildProtocol {
    private let x: Double;
    private let y: Double;
    public var params = [String: String]();
    private var childs = [String]();


    init(x: Double, y: Double) {
        self.x = x;
        self.y = y;
    }

    convenience init(x: Int, y: Int) {
        self.init(x: Double(x), y: Double(y));
    }

    func addTSpan(text: String) {
        self.childs.append("<tspan>\(text)</tspan>");
    }

    func render() -> String {
        var result = [String]();
        result.append("<text x=\"\(self.x)\" y=\"\(self.y)\" ");

        for(k, v) in self.params {
            result.append("\(k)=\"\(v)\" ");
        }

        result.append(">\n");

        for child in self.childs {
            result.append(child + "\n");
        }

        result.append("</text>");

        return result.joined(separator: "");
    }
}
