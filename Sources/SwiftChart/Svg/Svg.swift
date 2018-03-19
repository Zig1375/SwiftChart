import Foundation

class Svg: SvgChilds {
    private let width: Int;
    private let height: Int;


    public var style : String? = "font-family:&quot;Lucida Grande&quot;, &quot;Lucida Sans Unicode&quot;, Arial, Helvetica, sans-serif;font-size:12px;";

    init(width: Int, height: Int) {
        self.width = max(width, 100);
        self.height = max(height, 100);
    }

    func render() -> String {
        var svg = [String]();
        let style = (self.style == nil) ? "" : "style=\"\(self.style!)\"";

        svg.append("<svg version=\"1.1\" \(style) xmlns=\"http://www.w3.org/2000/svg\" width=\"\(self.width)\" height=\"\(self.height)\" viewBox=\"0 0 \(self.width) \(self.height)\">");
        svg.append("<desc>Created with zCharts</desc>");

        svg.append(renderChilds());
        svg.append("</svg>");
        return svg.joined(separator: "");
    }
}
