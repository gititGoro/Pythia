pragma solidity ^0.4.18;
library CircularBufferLib {
    
    struct PredictionRing {
        uint bufferSize;
        uint nextIndex;
        mapping (address => uint) iterator;
        uint[] values;
        uint[] blocknumbers;
        address[] oracles;
    }

    function init (PredictionRing storage self, uint bufferSize) public {
        self.bufferSize = bufferSize;
    }

    function isEmpty(PredictionRing storage self, address caller) public view returns (bool) {
        return self.iterator[caller] >= self.values.length || self.oracles[self.iterator[caller]] == address(0);
    }

    function deleteCurrentPrediction(PredictionRing storage self, address caller) public {
        self.oracles[self.iterator[caller]] = address(0);
    }

    function insertPrediction(PredictionRing storage self, uint value, address oracle) public {
        if (self.values.length < self.bufferSize) {
            self.values.push(value);
            self.oracles.push(oracle);
            self.blocknumbers.push(block.number);
        } else {
            self.values[self.nextIndex] = value;
            self.oracles[self.nextIndex] = oracle;
            self.blocknumbers[self.nextIndex] = block.number;
        }
        self.nextIndex++;
        self.nextIndex = self.nextIndex % self.bufferSize;
    }

    function resetIterator(PredictionRing storage self, address caller) public {
        self.iterator[caller] = self.nextIndex;
    }

    function moveIterator (PredictionRing storage self, address caller) public {
        self.iterator[caller]++;
        self.iterator[caller] = self.iterator[caller] % self.values.length;
    }

    function moveIteratorBackwards(PredictionRing storage self,address caller) public {
        self.iterator[caller]--;
        self.iterator[caller] == 0 ?self.values.length:self.iterator[caller];
    }

    function getCurrentValue (PredictionRing storage self, address caller) public view returns (uint value, address oracle, uint blocknumber) {
        value = self.values[self.iterator[caller]];
        oracle = self.oracles[self.iterator[caller]];
        blocknumber = self.blocknumbers[self.iterator[caller]];
    }
}