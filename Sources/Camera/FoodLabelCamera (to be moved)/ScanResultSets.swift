import SwiftUI
import FoodLabelScanner

class ScanResultSets: ObservableObject {
    
    var array: [ScanResultSet] = []
    var mostFrequentAmounts: [Attribute: (Double, Int)] = [:]

    func bestCandidateAfterAdding(result: ScanResult) -> ScanResultSet? {
        guard result.hasNutrients else { return nil }
        
        /// If we have a `ScanResult` that matches this
//        if let index = array.firstIndex(where: { $0.scanResult.matches(result) }) {
//            let existing = array.remove(at: index)
//
//            /// Replace the scan result with the new one (so we always keep the latest copy)
//            existing.scanResult = result
//
//            /// Update the date
//            existing.date = Date()
//
//            /// Increase the count
//            existing.count += 1
//
//            array.append(existing)
//        } else {
            array.append(ScanResultSet(scanResult: result, image: nil))
        print("🥶 Array now has \(array.count)")
//        }
        return bestCandidate
    }
    
    var bestCandidate: ScanResultSet? {
        guard array.count >= 3,
              let withMostNutrients = array.sortedByNutrientsCount.first
        else {
            return nil
        }
        
        /// filter out only the results that has the same nutrient count as the one with the most
//        let filtered = filter({ $0.scanResult.nutrientsCount == withMostNutrients.scanResult.nutrientsCount })
        let filtered = array
        
        /// for each nutrient, save the modal value across all these filtered results
        for attribute in withMostNutrients.scanResult.nutrientAttributes {
            
//            print("Getting doubles for \(attribute) in \(self.count)")
            
            let doubles = filtered.map({$0.scanResult}).amounts(for: attribute)
            print("🥶 Got \(doubles.count) doubles for \(attribute) \(array.count) array elements")

            let mostFrequentWithCount = commonElementsInArrayUsingReduce(doublesArray: doubles)
            
//            guard let mostFrequentWithCount = doubles.mostFrequentWithCount else {
//                continue
//            }
            mostFrequentAmounts[attribute] = mostFrequentWithCount
            print("🥶 Most frequent amounts for \(array.count) is now:")
            for key in mostFrequentAmounts.keys {
                print("🥶     \(key): \(mostFrequentAmounts[key]?.0 ?? 0) (\(mostFrequentAmounts[key]?.1 ?? 0) times)")
            }
            print("🥶  -----------------")
            print("🥶  ")
        }
        
        /// now sort the filtered results by the count of (how many nutrients in it match the modal results) and return the first one
        let sorted = filtered
            .sortedByMostMatchesToAmountsDict(mostFrequentAmounts)
            .sorted { $0.date > $1.date }
            .sorted { $0.count > $1.count }
        
        /// return the one with the most matches
        return sorted.first
    }
    
    func set(_ image: UIImage, for scanResult: ScanResult) {
        array.first(where: { $0.scanResult.id == scanResult.id })?.image = image
    }
}

extension Array where Element == ScanResultSet {
    var sortedByNutrientsCount: [ScanResultSet] {
        sorted(by: { $0.scanResult.nutrientsCount > $1.scanResult.nutrientsCount })
    }
}
