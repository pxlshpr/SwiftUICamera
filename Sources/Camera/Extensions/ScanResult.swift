import Foundation
import FoodLabelScanner
import VisionSugar

extension ScanResult {
    
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

extension Array where Element == ScanResult {
    func amounts(for attribute: Attribute) -> [Double] {
        compactMap { $0.amount(for: attribute) }
    }
    
    func sortedByMostMatchesToAmountsDict(_ dict: [Attribute:Double]) -> [ScanResult] {
        sorted(by: {
            $0.countOfHowManyNutrientsMatchAmounts(in: dict)
            > $1.countOfHowManyNutrientsMatchAmounts(in: dict)
        })
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
