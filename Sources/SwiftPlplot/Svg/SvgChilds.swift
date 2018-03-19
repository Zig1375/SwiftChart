import Foundation

class SvgChilds {
    private var childs = [SvgChildProtocol]();

    func append(child: SvgChildProtocol) {
        self.childs.append(child);
    }

    /// Group
    func addGroup() -> SvgGroup {
        let group = SvgGroup();
        append(child: group);
        return group;
    }


    /// Text
    func addText(x: Double, y: Double) -> SvgText {
        let text = SvgText(x: x, y: y);
        append(child: text);
        return text;
    }

    func addText(x: Int, y: Int) -> SvgText {
        return addText(x: Double(x), y: Double(y));
    }


    /// Path
    func addPath() -> SvgPath {
        let path = SvgPath();
        append(child: path);
        return path;
    }


    /// Rect
    func addRect(x: Double, y: Double, width: Double, height: Double) -> SvgRect {
        let rect = SvgRect(x: x, y: y, width: width, height: height);
        append(child: rect);
        return rect;
    }

    func addRect(x: Int, y: Int, width: Int, height: Int) -> SvgRect {
        return addRect(x: Double(x), y: Double(y), width: Double(width), height: Double(height));
    }

    func renderChilds() -> String {
        var result = [String]();

        for child in self.childs {
            result.append(child.render());
        }

        return result.joined(separator: "\n");
    }
}
