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

extension ScanResult {
    
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
    
    func countOfHowManyNutrientsMatchAmounts(in dict: [Attribute : (Double, Int)]) -> Int {
        var count = 0
        for attribute in dict.keys {
            guard let amount = amount(for: attribute) else { continue }
            if amount == dict[attribute]?.0 {
                count += 1
            }
        }
        return count
    }
    
}

extension Array where Element == ScanResult {
    
    func sortedByMostMatchesToAmountsDict(_ dict: [Attribute : (Double, Int)]) -> [ScanResult] {
        sorted(by: {
            $0.countOfHowManyNutrientsMatchAmounts(in: dict)
            > $1.countOfHowManyNutrientsMatchAmounts(in: dict)
        })
    }
    
    var sortedByNutrientsCount: [ScanResult] {
        sorted(by: { $0.nutrientsCount > $1.nutrientsCount })
    }
    
    func amounts(for attribute: Attribute) -> [Double] {
        compactMap { $0.amount(for: attribute) }
    }
}
