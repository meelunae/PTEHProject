import Foundation

// A mutator that specifically targets the data structure involved in CVE-2019-5847 
// by generating inconsistent comparison functions for Array.prototype.sort()
public class ArraySortMutator: BaseInstructionMutator {
    
    // Probability of applying this mutator
    private let probability: Double
    
    public init(probability: Double = 0.5) {
        self.probability = probability
        super.init()
    }
    
    public override func mutate(_ program: Program, for fuzzer: Fuzzer) -> Program? {
        guard probability > 0 else { return nil }
        
        // Only proceed with probability
        guard Double.random(in: 0...1) < probability else { return nil }
        
        let b = fuzzer.makeBuilder()
        
        // Create an array with mixed types
        let arraySize = Int.random(in: 5...20)
        var arrayElements: [Variable] = []
        
        for _ in 0..<arraySize {
            // Randomly choose between number and string
            if Bool.random() {
                arrayElements.append(b.loadInt(Int.random(in: -1000...1000)))
            } else {
                arrayElements.append(b.loadString(String(Int.random(in: -1000...1000))))
            }
        }
        
        let array = b.createArray(with: arrayElements)
        
        // Create an inconsistent comparison function
        let compareFunc = b.defineFunction(numParameters: 2) { args in
            // Randomly return inconsistent results
            let randomValue = Int.random(in: -1...1)
            b.doReturn(value: b.loadInt(randomValue))
        }
        
        // Call sort with our inconsistent comparison function
        b.callMethod("sort", on: array, withArgs: [compareFunc])
        
        return b.finish()
    }
} 
