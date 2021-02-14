from flask import Flask, jsonify, request
# from flask_cors import CORS
from blockchain import Blockchain
from argparse import ArgumentParser
import copy

app = Flask(__name__)
# CORS(app)


@app.route('/', methods=['GET'])
def chian():
    chain = test.chain
    print('Getting chain values')
    dictChain = [block.__dict__.copy() for block in chain]
    print('chain values are {}'.format(dictChain))
    for dictBlock in dictChain:
        dictBlock['transactions'] = [tx.__dict__ for tx in dictBlock['transactions']]
    return jsonify(dictChain), 200


@app.route('/mine', methods=['POST'])
def mine():
    """ mine a block """
    
    newBlock = test.addBlcok
    if newBlock !=None :
        values = copy.deepcopy(newBlock())
        print(values)
        res={
            'Message': 'New Block has been added successfully', 'Details': {
                'index': values.index,
                'previousHash': values.previousHash,
                'timestamp': values.timestamp,
                'proof': values.proof,
                'hash': values.hash}
        }
        return jsonify(res), 200
    
    else:
        res={
            'Message': 'The Block has been rejected!'
        }
        return jsonify(res), 500


@app.route('/opentxs', methods=['GET'])
def opentxs():
    """ get the unconfirmed transactions or any transaction has not been included in a block """
    print("Get unconfirmed Transactions")
    txs=test.unconfirmed
    print(txs)
    if txs!= None:
        dictTx = [tx.__dict__ for tx in txs]
        res={
            'Transactions': dictTx
        }
        return jsonify(res), 200 #200
    else:
        res={
            'Message': 'There is no transaction'
        }
        return jsonify(res), 500



@app.route('/sendtx', methods=['POST'])
def sendtx():
    """ send a transaction"""
    values = request.get_json()
    if not values:
        res={
            'Message': 'There is no input'
        }
        return jsonify(res), 400
    regKeys = ['sender', 'receiver', 'amount']
    if not all(key in values for key in regKeys):
    
        res={
            'Message': 'There is a missing value'
        }
        return jsonify(res), 400
    sender = values['sender']
    receiver = values['receiver']
    amount = values['amount']
    
    addTx= test.addTransaction(sender, receiver, amount)
    if addTx !=None:
        res={
            'Transaction': {
                'sender': values['sender'],
                'receiver': values['receiver'],
                'amount': values['amount']
            }

        }
        return jsonify(res), 200
        



if __name__ == '__main__':
    ser = ArgumentParser()
    ser.add_argument('-p', '--port', default=8020)
    args = ser.parse_args()
    port = args.port
    test = Blockchain()
    app.run(debug=True, port=port)

