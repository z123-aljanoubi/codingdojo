#hashUtility
import hashlib
from time import time
import json

def hashString(string):
    return hashlib.sha256(string).hexdigest()

def hashBlock(block):
    hashingBlock = block.__dict__.copy()
    hashingBlock['transactions'] = [tx.to_ordered_dict() for tx in hashingBlock['transactions']]
    return hashString(json.dumps(hashingBlock, sort_keys=True).encode())



#printed
class Printed:
    """A base class"""
    def __repr__(self):
        return str(self.__dict__)


#vification
class Verification:
    @staticmethod
    def validProof(transactions, lastHash, proof):
        guess = (str([tx.to_ordered_dict() for tx in transactions]) + str(lastHash) + str(proof)).encode()
        _hash = hashString(guess)
        return _hash[0:2] == '00'
        
    @classmethod
    def verifyChain(cls, blockchain):
        """ Verify all blocks in the chain and return True if proof is valid, and False otherwise."""

        for (index, block) in enumerate(blockchain):
            if index == 0:
                continue
            if block.previousHash != hashBlock(blockchain[index - 1]):
                return False
            if not cls.validProof(block.transactions[:-1], block.previousHash, block.proof):
                print('Invalid proof of work')
                return False


#block
class Block(Printed):
    """When a block is added to the chain..."""
    def __init__(self, index, previousHash, transactions, proof, time=time()):
        self.index = index
        self.previousHash = previousHash
        self.timestamp = time
        self.transactions = transactions
        self.proof = proof


#transaction
class Transaction(Printed):
    """When a transaction is added to a block"""
    def __init__(self, sender, receiver, amount):
        self.sender = sender
        self.receiver = receiver
        self.amount = amount

    def to_ordered_dict(self):
        """Converts into (hash) dict"""
        return OrderedDict([('sender', self.sender), ('receiver', self.receiver), ('amount', self.amount)])


#blockchain
class Blockchain:
    def __init__(self):
        genesis_block = Block(0, '', [], 0, 0)
        self.chain = [genesis_block]
        self.unconfirmedTransaction = []
        self.REWAED = 10

    @property
    def chain(self):
        return self.__chain[:]

    # The setter
    @chain.setter
    def chain(self, data):
        self.__chain = data


    def proofOfWork(self):

        """proof of work:  works on
        for adding the unconfirmed transactions,
        hashing the previous block and guessing a proof number """

        
        last_block = self.__chain[-1]
        lastHash = hashBlock(last_block)
        proof = 0
        # Try different PoW numbers and return the first valid one
        while not Verification.validProof(self.unconfirmedTransaction, lastHash, proof):
            proof += 1
        return proof

    @property
    def unconfirmed(self):
        """A list of unconfirmed transactions."""
        return self.unconfirmedTransaction[:]

    def lastChain(self):
        """last block. """
        if len(self.__chain) < 1:
            return None
        return self.__chain[-1]

    def addTransaction(self, sender, receiver, amount=0.90):
        """ Append a new transactions"""
        transaction = Transaction(sender, receiver, amount)
        self.unconfirmedTransaction.append(transaction)


    def addBlcok(self):
        """Add a new block and append unconfirmed transactions similar to a mining block"""

        last_block = self.__chain[-1]
        hashed_block = hashBlock(last_block)
        proof = self.proofOfWork()

        reward_transaction = Transaction(
            'MINING', 'receiverAddress', self.REWAED)

        copied_transactions = self.unconfirmedTransaction[:]

        copied_transactions.append(reward_transaction)

        block = Block(len(self.__chain), hashed_block,
                      copied_transactions, proof)

        block.hash = hashBlock(block)

        self.__chain.append(block)
        self.unconfirmedTransaction = []

        return block

test = Blockchain()

print(test.chain)




