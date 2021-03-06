
//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.1;

/**
 * @title Tech Insurance tor
 * @dev 
 * Step1: Complete the functions in the insurance smart contract
 * Step2:Add any required methods that are needed to check if the function are called correctly, 
 * and also add a modifier function that allows only the owner can run the changePrice function.
 * Step3: Add any error handling that may occur in any function
 * Step4: Add a modifer function to check the time if the client insurance is valid.
 * Step5 (opcional): Add a refund function that refunds money back to the client after one week. Guaranteed Money Back Plan.  
 * Step6: implement ERC 721 Token to this contract and change what it needs to be changed. 
 * 
 */
 
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "github/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
contract TechInsurance is ERC721("test","TST"){
    
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
    
    

    
     modifier OnlyinsOwner(uint _prodID) {
         require(msg.sender == ownerOf(_prodID));
         _;
    }
         modifier TimeCheck {
         require(block.timestamp <= timeLocked + 15 minutes );
         _;
     }
    
    mapping(uint => Product) public productIndex;
    mapping(address => mapping(uint => Client)) public client;
    uint256 timeLocked = block.timestamp;
    uint productCounter;
    
     address payable insOwner;
    // constructor(address payable _insOwner) public{
    //     insOwner = _insOwner;
    // }
 
    function addProduct(uint _productId, string memory _productName, uint _price ) public  {
        
       productCounter++;
       address  prodOwner = msg.sender;
       productIndex[productCounter]= Product(_productId, _productName, _price, true);
       _mint(prodOwner, productCounter);
    }
    
    
    function doNotOffer(uint _productIndex) public  {

        productIndex[_productIndex].offered = false;
    }
    
    function forOffer(uint _productIndex) public OnlyinsOwner(_productIndex) {
        
        productIndex[_productIndex].offered = true;
    }
    
    function changePrice(uint _productIndex, uint _price) public OnlyinsOwner(_productIndex) {

        productIndex[_productIndex].price = _price;
        
    }
    
    /**
    * @dev 
    * Every client buys an insurance, 
    * you need to map the client's address to the id of product to struct client, using (client map)
    */
    
    function buyInsurance(uint _productIndex) public payable  {
        require(productIndex[_productIndex].offered == true, "This item is sold out!");
        require(msg.value <= productIndex[_productIndex].price, "You don't have enough tokens!");
        doNotOffer(_productIndex);        
        Client(true, block.timestamp);
        _transfer(ownerOf(_productIndex), msg.sender,_productIndex);   
        doNotOffer(_productIndex);    
    } 
    
}
