//SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

contract Insurance {
    
//###########################################################################
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    mapping (uint256 => address) private _owners;
    mapping (address => uint256) private _balances;
    mapping (uint256 => address) private _tokenApprovals;

    function beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

    function approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }
    
    function ownerOf(uint256 tokenId) public view virtual  returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }
    
    function transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    
    function mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!exists(tokenId), "ERC721: token already minted");

        beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }
    
    function exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }
//###########################################################################
//---------------------------------------------------------------------------
    //insOwner
    address payable insOwner;
    
    constructor() public {
        insOwner = msg.sender;
        addAuth(insOwner);
    }
    modifier onlyiOwner {
        require(msg.sender == insOwner, "You are not authorized!");
        _;
    }
    
    uint M = 2;
    uint N = 2; // plus the Owner;
    uint uTX = 0;
    
    //Auths
    mapping (address => authenticator) private Authenticators ;
    address[] auths;
    struct authenticator{
        address authAddress; 
        bool authorized;
    }
    
    modifier onlyAuthorized {
        require(Authenticators[msg.sender].authorized == true, "You are not authorized!");
        _;
    }

    
    //Tx
    
    mapping (uint => transaction) private TX ;
    
    struct transaction{
        uint id;
        //status
        //confs{type:#n}
        uint confirmations;
        bool processed;
    }
    
    //verified
    mapping(uint => mapping(address => bool)) verfiedTX; 
//---------------------------------------------------------------------------
    //Product + Client
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
    
    modifier prodOwner(uint _prodID) {
         require(msg.sender == ownerOf(_prodID),"You don not own this product");
         _;
    }
    
    modifier validClient(address _address, uint _id){
        require(client[_address][_id].isValid == true,"you already have done a refund");
        _;
    }
    
    modifier Timecheck(address _address, uint _id) {
        require(block.timestamp < client[_address][_id].time + 7 days, "you cannot get a refund after 7 days of purchasing the item.");
        _;
    }
    
    modifier getUTX{
        require(uTX !=0, "There is no transaction you must verify!");
        _;
    }
    modifier checkVerifications(address _address, uint _id){
        require (TX[_id].id != 0, "This product is not exist");
        require (TX[_id].processed != true, "This product is already verified");
        require (verfiedTX[_id][_address] != true, "you already verified this transaction");
        _;
    }
    
    mapping(uint => Product) public productIndex;
    mapping(address => mapping(uint => Client)) public client;
    uint256 timeLocked = block.timestamp;
    uint productCounter=0;
    
    
    function addProduct(uint _productId, string memory _productName, uint _price) public onlyiOwner {
        // make the contract owner who add products + product is not exist not = 0
       productCounter++;
       productIndex[productCounter]= Product(_productId, _productName, _price, false);
       TX[productCounter] = transaction(productCounter, 0, false);
       // Tx needed to be verified ++ 
       uTX++;

    }
    
    
    function doNotOffer(uint _productIndex) public prodOwner(_productIndex) {
        productIndex[_productIndex].offered = false;
    }
    
    function forOffer(uint _productIndex) public onlyiOwner {
        productIndex[_productIndex].offered = true;
    }
    
    function changePrice(uint _productIndex, uint _price) public onlyiOwner {
        productIndex[_productIndex].price = _price;
    }
    
    function buyInsurance(uint _productIndex) public payable  {
        require(productIndex[_productIndex].offered == true, "This item is sold out!");
        require(msg.value <= productIndex[_productIndex].price, "You don't have enough tokens!");       
        
        transfer(ownerOf(_productIndex), msg.sender,_productIndex);
        client[msg.sender][_productIndex] = Client(true, block.timestamp); // save payment details
        doNotOffer(_productIndex);   
    } 
    

    function refund(uint _id) public prodOwner(_id) Timecheck(msg.sender, _id) validClient(msg.sender, _id) {

        transfer(msg.sender, insOwner, _id);
        client[msg.sender][_id].isValid = false;
    }
//--------------------------------------------------------------------------- 

    function verifyTX (uint _id) public onlyAuthorized getUTX checkVerifications(msg.sender, _id){
        TX[_id].confirmations = TX[_id].confirmations +1;
        verfiedTX[_id][msg.sender] = true ;
        
        if  (TX[_id].confirmations == M){
            proceedTX(_id);
            }

    }
    
    function proceedTX(uint _id) private onlyAuthorized{
        // mint
        productIndex[_id].offered = true;
        TX[_id].processed = true;
        mint(insOwner, _id);
        uTX--;
    }
    
    function addAuth (address _address) public onlyiOwner {
        require(Authenticators[_address].authAddress == address(0), "This address is already exist");
        require(auths.length < N + 1,"You cannot add more authorizers");
         Authenticators[_address]= authenticator(_address, true);
         auths.push(_address);
    }
    
    function modifyAuth(address _address, bool auth) public onlyiOwner{
        require(Authenticators[_address].authAddress != address(0));
        Authenticators[_address].authorized= auth;
        
    }

    function unconfirmedTX() public onlyAuthorized view returns(uint unconfirmedTx) {
        return uTX;
    }
    
}
