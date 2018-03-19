import Foundation

class SvgGroup: SvgChilds, SvgChildProtocol {
    public var params = [String: String]();

    func render() -> String {
        var p = [String]();
        for(k, v) in self.params {
            p.append("\(k)=\"\(v)\"");
        }

        var result = [String]();
        result.append("<g \(p.joined(separator: " "))>");
        result.append(self.renderChilds());
        result.append("</g>");

        return result.joined(separator: "\n");
    }
}
