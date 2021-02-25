//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

 
import "../github/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
contract TechInsurance is ERC721 {

  
    /** 
     * Defined two structs
     * 
     * 
     */
    struct Product {
        uint productId;
        string productName;
        uint price;
        bool offered;
    }
     
    struct Client {
        bool isValid;
        uint time;

    }
    


    
    
    mapping(uint => Product) public productIndex;
    mapping(address => mapping(uint => Client)) public client;
    
    uint productCounter;
    
    address payable insOwner;
    constructor(address payable _insOwner) public ERC721("Elite", "code"){
      insOwner = _insOwner;
   }
 
    function addProduct(uint _productId, string memory _productName, uint _price ) public {
        productCounter++;
        Product memory newProduct =Product(_productId, _productName, _price, true);
        productIndex[productCounter++] = newProduct;
       
        
 
    }
    
    
    function doNotOffer(uint _productIndex) public returns(bool) {
        require(msg.sender == insOwner, "I'm not offer it");
        return productIndex[_productIndex].offered == false;

    }
    
    function forOffer(uint _productIndex) public returns(bool) {
        require(msg.sender == insOwner, "I'm offer it");
        return productIndex[_productIndex].offered ==true;

    }

    function changePrice(uint _productIndex, uint _price) public view {
        require(productIndex[_productIndex].price >= 1, "not valid index" );
        productIndex[_productIndex].price== _price;
    }
    
    // handling the error
    function setPrice (uint _price) public {
        uint price = _price;
        require(insOwner == msg.sender, "you are not the owner");
    }
    
    function clientSelect(uint _productIndex) public payable returns(bool) {
        require(productIndex[_productIndex].price == msg.value, "Not appropriate" );
        require( productIndex[_productIndex].price == 0, "Not valid index");
        
        Client memory newClient;
        newClient.isValid = true;
        newClient.time = block.number;
        client[msg.sender][_productIndex] = newClient;
        insOwner.transfer(msg.value);
        
        }
        
     function buyInsurance(uint _productIndex) public payable {
        
    } 
        
    } 
