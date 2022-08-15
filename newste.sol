// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.7.3/token/ERC20/ERC20.sol";

/*owner has the adminstrative power,by creating contract owner we can make
 sure that no outsiders can make any changes to any function.owner has control over every function 
 and its implementation*/
contract owned{
    address public owner;
    constructor(){
        owner = msg.sender;
    }
    modifier onlyOwner{
        require(msg.sender == owner);//modifier can be used in the function.it checks a specific condition.
        _;
    }
    /*if owner wises he/she can transfer ownership to the another person specifing their address.
    using onlyOwner in the function makes sure that only owner can call the function or 
    make changes to the function*/
    function transferOwnership (address newOwner) public onlyOwner {
        owner = newOwner;
    }

}
 //we inheret erc20,owned contracts to our newste contract.
contract newste is ERC20 ,owned{
    uint256 public sellPrice;
    uint256 public buyPrice;
    uint256 public minBalanceForAccounts;
    

//constructor is executed only once. so the person who is deploying the contract is the address of msg.sender which is a global variable.
    contract newste is ERC20 {
    constructor() ERC20("newste", "NST") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }

    

   //here,mapping maps addreses of the frozenAccount to true or false.
    mapping(address => bool ) public frozenAccount;
    //event tells the application current state of the contract.
    event frozenFunds(address target,bool frozen);


    /* mints token when called adds minted tokens to the targed address and 
    increases the total supply amount by the minted value. */
    function mintToken(address target,uint256 mintedAmount) public {
        _balances[target] += mintedAmount;
        totalSupply += mintedAmount;
    }
 /* i have overriden _transfer method.here,this methos checks that it does 
  not allow any frozen account to make any trasactions. */
    function _transfer(address recipient, uint256 amount) public virtual override returns (bool){
        require(!frozenAccount[msg.sender]);
    }

/* freezeAccount freezes address of the account .this can only be implementes by the owner of the 
contract.here emit keyword gives or emits information regarding the address of the frozenAccount etc
to the frontend application. */
    function freezeAccount(address target,bool freeze) public onlyOwner{
        frozenAccount[target] = freeze;
        emit frozenFunds(target,freeze);
    }

    // here, through setPrice function owner can set new price for the token.
    function setPrices(uint256 newSellPrice,uint256 newBuyPrice) public onlyOwner{
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }
    
    /* through buy function u can sell/buy using another tokens.
    msg.value is the value for the another token say for example ethereum.
    msg.value divided by our tokens buyPrice gives us the no of tokens i.e amount of our token. */
    function buy() payable public returns (uint amount){
         amount = msg.value/buyPrice;
         _transfer(this,msg.sender,amount);
         return amount;

    }

 /*function sell sells the another token for example say ethereum to the msg.sender 
 and sends the equivalent newste tokens to the address how ever is buying the token.*/
    function sell(uint amount) public  returns (uint revenue){
        require(_balances[msg.sender]>=amount);
        _balances[this]+=amount;
        _balances[msg.sender]-=amount;
        revenue = amount*sellPrice;
        msg.sender.transfer(revenue);
        return revenue;

    }

    /* this function checks for the minbalance.finney is an unit of ether 
    here,minBalanceForAccounts is defined as equal to minimumBalanceInFinney*1Finney*/
    function setMinBalance(uint256 minimumBalanceInFinney) onlyOwner{
        minBalanceForAccounts = minimumBalanceInFinney*1finney;
    }
    /* if minbalance is less that even the gas amount could not be paid then 
    this function automatically sells some amount of newste tokens and uses it to pay 
    the gas fee.*/
    function transfer(address recipient, uint256 amount) virtual override returns (bool) {
      if(msg.sender.balance < minBalanceForAccounts){
          sell((minBalanceForAccounts - msg.sender.balance)/sellPrice );
      }
      return true;

}

}