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

    function resetIterator(PredictionRing storage self) public {
        self.iterator[msg.sender] = self.nextIndex;
    }

    function moveIterator (PredictionRing storage self) public {
        self.iterator[msg.sender]++;
        self.iterator[msg.sender] = self.iterator[msg.sender] % self.bufferSize;
    }

    function getCurrentValue (PredictionRing storage self) public view returns (uint value, address oracle, uint blocknumber) {
        value = self.values[self.iterator[msg.sender]];
        oracle = self.oracles[self.iterator[msg.sender]];
        blocknumber = self.blocknumbers[self.iterator[msg.sender]];
    }
}