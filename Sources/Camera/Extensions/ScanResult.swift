import Foundation
import FoodLabelScanner
import VisionSugar

extension Array where Element == RecognizedText {
    var boundingBox: CGRect {
        guard !isEmpty else { return .zero }
        return reduce(.null) { partialResult, text in
            partialResult.union(text.boundingBox)
        }
    }
}

extension Array where Element == ScanResult.Nutrients.Row {
    func matches(_ other: [ScanResult.Nutrients.Row]) -> Bool {
        guard count == other.count else { return false }
        return allSatisfy { row in
            guard let otherRow = other.first(where: { $0.attribute == row.attribute }) else { return false }
            return row.matches(otherRow)
        }
    }
}

extension ScanResult.Nutrients.Row {
    func matches(_ otherRow: ScanResult.Nutrients.Row) -> Bool {
        valueText1?.value.amount == otherRow.valueText1?.value.amount
        && valueText2?.value.amount == otherRow.valueText2?.value.amount
    }
}

extension ScanResult {
    
    func matches(_ other: ScanResult) -> Bool {
        nutrients.rows.matches(other.nutrients.rows)
//        serving == other.serving
//        && headers == other.headers
//        && nutrients == other.nutrients
    }
    
    var boundingBox: CGRect {
        allTexts
            .filter { $0.boundingBox != .zero }
            .boundingBox
    }
    
    var nutrientAttributes: [Attribute] {
        nutrients.rows.map({ $0.attribute })
    }
    
    var nutrientsCount: Int {
        nutrients.rows.count
    }
    
    var hasNutrients: Bool {
        !nutrients.rows.isEmpty
    }
    
    var resultTexts: [RecognizedText] {
        nutrientAttributeTexts
    }
    
    var nutrientAttributeTexts: [RecognizedText] {
        nutrients.rows.map { $0.attributeText.text }
    }
    
    var nutrientValueTexts: [RecognizedText] {
        nutrients.rows.map { $0.attributeText.text }
    }
    
    func amount(for attribute: Attribute) -> Double? {
        nutrients.rows.first(where: { $0.attribute == attribute })?.value1?.amount
    }
    
    func countOfHowManyNutrientsMatchAmounts(in dict: [Attribute : Double]) -> Int {
        var count = 0
        for attribute in dict.keys {
            guard let amount = amount(for: attribute) else { continue }
            if amount == dict[attribute] {
                count += 1
            }
        }
        return count
    }
    
}

extension Array where Element == ScanResultSet {
    func sortedByMostMatchesToAmountsDict(_ dict: [Attribute:Double]) -> [ScanResultSet] {
        sorted(by: {
            $0.scanResult.countOfHowManyNutrientsMatchAmounts(in: dict)
            > $1.scanResult.countOfHowManyNutrientsMatchAmounts(in: dict)
        })
    }
}

extension Array where Element == ScanResult {
    func amounts(for attribute: Attribute) -> [Double] {
        compactMap { $0.amount(for: attribute) }
    }
}

//extension Array where Element == any Hashable {
extension Array where Element: Hashable {
    var mostFrequent: Element? {
        let counts = reduce(into: [:]) { $0[$1, default: 0] += 1 }

        if let (value, _) = counts.max(by: { $0.1 < $1.1 }) {
            return value
        }

        // array was empty
        return nil
    }
    
    var mostFrequentWithCount: (Element, Int)? {
        let counts = reduce(into: [:]) { $0[$1, default: 0] += 1 }

        if let (value, count) = counts.max(by: { $0.1 < $1.1 }) {
            return (value, count)
        }

        // array was empty
        return nil
    }

}
//
//func mostFrequent<T: Hashable>(array: [T]) -> (value: T, count: Int)? {
//
//    let counts = array.reduce(into: [:]) { $0[$1, default: 0] += 1 }
//
//    if let (value, count) = counts.max(by: { $0.1 < $1.1 }) {
//        return (value, count)
//    }
//
//    // array was empty
//    return nil
//}
//
//if let result = mostFrequent(array: ["a", "b", "a", "c", "a", "b"]) {
//    print("\(result.value) occurs \(result.count) times")
//}

extension ScanResult {
    var allTexts: [RecognizedText] {
        servingTexts + headerTexts + nutrientTexts
    }
    var servingTexts: [RecognizedText] {
        [
            serving?.amountText?.text,
            serving?.amountText?.attributeText,
            serving?.unitText?.text,
            serving?.unitText?.attributeText,
            serving?.unitNameText?.text,
            serving?.unitNameText?.attributeText,
            serving?.equivalentSize?.amountText.text,
            serving?.equivalentSize?.amountText.attributeText,
            serving?.equivalentSize?.unitText?.text,
            serving?.equivalentSize?.unitText?.attributeText,
            serving?.equivalentSize?.unitNameText?.text,
            serving?.equivalentSize?.unitNameText?.attributeText,
            serving?.perContainer?.amountText.text,
            serving?.perContainer?.amountText.attributeText,
            serving?.perContainer?.nameText?.text,
            serving?.perContainer?.nameText?.attributeText,
        ]
            .compactMap { $0 }
    }
    
    var headerTexts: [RecognizedText] {
        [
            headers?.headerText1?.text,
            headers?.headerText1?.attributeText,
            headers?.headerText2?.text,
            headers?.headerText2?.attributeText
        ]
            .compactMap { $0 }
    }
    
    var nutrientTexts: [RecognizedText] {
        var texts: [RecognizedText?] = []
        for row in nutrients.rows {
            texts.append(row.attributeText.text)
            texts.append(row.valueText1?.text)
            texts.append(row.valueText1?.attributeText)
            texts.append(row.valueText2?.text)
            texts.append(row.valueText2?.attributeText)
        }
        return texts.compactMap { $0 }
    }
}
