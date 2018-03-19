//
// Created by Alexandr Palchikov on 14.03.2018.
//

import Foundation
import Files

public class Chart {
    static let TEMP_PATH    = NSTemporaryDirectory() as String;

    private let width: Int;
    private let height: Int;

    let svg : Svg;

    public init(width: Int, height: Int) {
        self.width = max(width, 100);
        self.height = max(height, 100);

        self.svg = Svg(width: self.width, height: self.height);
    }

    public func draw(data: [Double], series: [String]) -> Data? {
        // Ищем минимальное и максимальное значение в данных
        guard let minValue = getMinValue(value: data.min()), let maxValue = data.max() else {
            print("Min or Max value not found");
            return nil;
        }

        let info = getInfo(min: (minValue == maxValue) ? minValue - 1 : minValue, max: (minValue == maxValue) ? maxValue + 1 : maxValue);

        // Рисуем координатную сетку
        drawChartCover(step: info.step, cntSteps: info.cntSteps, down: info.down, up: info.up, series: series);

        // Рисуем график
        drawChart(step: info.step, cntSteps: info.cntSteps, down: info.down, up: info.up, data: data, series: series);

        print(self.svg.render())
        return toPng(svg: self.svg.render());
    }

    func toPng(svg: String) -> Data? {
        do {
            let name = "\(UUID().uuidString).svg";
            let folder = try Folder(path: Chart.TEMP_PATH);
            let file = try folder.createFile(named: name);
            try file.write(string : svg);

            var cmd = "/usr/local/bin/rsvg-convert";

#if os(Linux)
            cmd = "/usr/bin/rsvg-convert";
#endif

            let result = shell(launchPath: cmd, arguments: ["-w", "\(self.width)", "-h", "\(self.height)", "\(Chart.TEMP_PATH)/\(name)"]);
            let _ = try? file.delete();

            return result;
        } catch {

        }

        return nil;
    }

    func drawChart(step: Double, cntSteps: Int, down: Double, up: Double, data: [Double], series: [String]) {
        let group = self.svg.addGroup();
        let path = group.addPath();
        path.params["stroke"] = "#35bddf";
        path.params["stroke-width"] = "2";
        path.params["stroke-linejoin"] = "round";
        path.params["stroke-linecap"] = "round";

        let stepXpx = (self.width - 80) / series.count;
        let startX = 70 + ((self.width - 80) / 2) - (stepXpx * (series.count / 2));

        for (i, val) in data.enumerated() {
            let y = getChartY(val: val, down: down, up: up);
            if (i == 0) {
                path.move(x: Double(startX), y: y);
            } else {
                path.lineTo(x: Double(startX + stepXpx * i), y: y);
            }
        }

    }

    func getChartY(val: Double, down: Double, up: Double) -> Double {
        let t = up - down;
        let t2 = val - down;
        let p = t2 / t;

        return Double(self.height - 20) - (Double(self.height - 30) * p);
    }

    func drawChartCover(step: Double, cntSteps: Int, down: Double, up: Double, series: [String]) {
        let rect = self.svg.addRect(x: 0, y: 0, width: self.width, height: self.height);
        rect.params["style"] = "fill:#fff;";

        let groupAxis = self.svg.addGroup();

        // Рисуем полосу снизу
        let pathH = groupAxis.addPath();
        pathH.move(x: 58, y: self.height - 30);
        pathH.lineTo(x: self.width, y: self.height - 30);
        pathH.params["stroke"] = "#e6e6e6";
        pathH.params["stroke-width"] = "1";
        pathH.params["stroke-linejoin"] = "round";
        pathH.params["stroke-linecap"] = "round";

        // Рисуем полосу слева
        let pathV = groupAxis.addPath();
        pathV.move(x: 60, y: 5);
        pathV.lineTo(x: 60, y: self.height - 10);
        pathV.params["stroke"] = "#e6e6e6";
        pathV.params["stroke-width"] = "1";
        pathV.params["stroke-linejoin"] = "round";
        pathV.params["stroke-linecap"] = "round";

        let groupAxisYText = self.svg.addGroup();
        let stepPx = (self.height - 40) / (cntSteps - 1);
        for i in 0..<cntSteps {
            let y = 10 + stepPx * i;
            let text = groupAxisYText.addText(x: 50, y: y + 5);
            text.params["style"] = "color:#666666; font-size:11px; fill:#666666;";
            text.params["text-anchor"] = "end";

            var v = up - step * Double(i);
            let t : String;
            if (step > 1000) {
                v = v / 1000;

                if (v == round(v)) {
                    t = "\(Int(v))k";
                } else {
                    t = "\(v)k";
                }
            } else {
                if (v == round(v)) {
                    t = "\(Int(v))";
                } else {
                    t = "\(v)";
                }
            }

            text.addTSpan(text: t);


            // Заодно рисуем горизонтальные полоски
            pathH.move(x: 55, y: y);
            pathH.lineTo(x: self.width - 10, y: y);
        }

        let stepXpx = (self.width - 80) / series.count;
        let startX = 70 + ((self.width - 80) / 2) - (stepXpx * (series.count / 2));
        let groupAxisXText = self.svg.addGroup();
        for (i, ser) in series.enumerated() {
            if (ser == "") {
                continue;
            }

            let x = startX + stepXpx * i;
            let text = groupAxisXText.addText(x: x, y: self.height - 15);
            text.params["style"] = "color:#666666; font-size:11px; fill:#666666;";
            text.params["text-anchor"] = (i < series.count - 1) ? "middle" : "end";
            text.addTSpan(text: ser);

            // Добавляем вертикальную полоску
            pathV.move(x: x, y: 5);
            pathV.lineTo(x: x, y: self.height - 10);
        }
    }

    func getInfo(min: Double, max: Double) -> (step: Double, cntSteps: Int, down: Double, up: Double) {
        let range = abs(max - min) * 1.1;
        var step = range / 4;
        var k : Double = 1;

        var length = 0;
        while(length <= 2) {
            if (length > 0) {
                k *= 10;
            }

            let iStep = Int(round(step * k));
            length = "\(iStep)".count;
        }

        let vals = getDoublesByLength(length: length);
        for s in vals {
            if (step * k < s) {
                step = s / k;
                break;
            }
        }

        let avgRange = (min + max) / 2;
        let temp = avgRange - (step * 2)
        let downValue = temp - (temp.truncatingRemainder(dividingBy: step));
        var upValue = downValue;
        var cntSteps = 1;
        while(upValue < max) {
            upValue += step;
            cntSteps += 1;
        }


        return (step: step, cntSteps: cntSteps, down: downValue, up: upValue);
    }

    func getDoublesByLength(length: Int) -> [Double] {
        let s1 = String(repeating: "0", count: length - 1);
        let s2 = String(repeating: "0", count: length - 2);
        return [
            Double("1\(s1)")!,
            Double("15\(s2)")!,
            Double("2\(s1)")!,
            Double("25\(s2)")!,
            Double("5\(s1)")!,
            Double("10\(s1)")!,
            Double("15\(s1)")!,
            Double("20\(s1)")!,
            Double("25\(s1)")!,
            Double("30\(s1)")!,
            Double("35\(s1)")!,
            Double("40\(s1)")!,
            Double("45\(s1)")!,
            Double("50\(s1)")!,
            Double("55\(s1)")!,
            Double("60\(s1)")!,
            Double("65\(s1)")!,
            Double("70\(s1)")!,
            Double("75\(s1)")!,
            Double("80\(s1)")!,
            Double("85\(s1)")!,
            Double("90\(s1)")!,
            Double("95\(s1)")!
        ];
    }

    func getMinValue(value: Double?) -> Double? {
        guard let val = value else {
            return nil;
        }

        if (val == 0) {
            return 0;
        }

        let tempVal = val * 0.8;
        if ((val > 0) && (tempVal <= 0)) {
            return 0;
        }

        return value;
    }

}
