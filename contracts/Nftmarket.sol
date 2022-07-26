// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

//import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721URIStorage.sol';


//import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol';

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';





contract Nftmarket is ERC721URIStorage {

    address payable owner;

    uint id = 0;

    uint public price;
    
    struct Market{
        uint itemId;
        IERC721 nft;
        uint tokenId;
        uint itemPrice;
        address payable seller;
        uint time;
        uint solTime;
        bool sold;
    }


    struct AvailablePro{
        uint itemId;
        IERC721 nft;
        uint tokenId;
        uint itemPrice;
        address payable seller;
        uint time;
        uint solTime;
        bool sold;

    }

    event mintToken(
        address owner,
        uint token_id
    );

    event marketPro(
        address seller,
        uint price,
        uint tokenId,
        uint time,
        uint solTime
    );

    event purchaseMarket(
        address from,
        address to,
        address middleContract,
        uint tokenId
    );

    event due(
        address owner,
        address from,
        uint tokenId,
        uint itemId
    );

    mapping(uint => Market) public companyMarket;

   

    uint public itemCount;


    constructor () ERC721('Omo Akin', 'OMO'){

        owner = payable(msg.sender);
        price = 10000000000;

    }


    function mint (string memory _url) public payable {
        require(msg.value >= price);

        id++;

        owner.transfer(msg.value);

        _mint(msg.sender, id);
        _setTokenURI(id, _url);

        emit mintToken(msg.sender, id);


    }



    function marketProduct (IERC721 _nft, uint _tokenId, uint _amount, uint _time) public{

        require(_amount > 0);
        
        itemCount++;

        //_nft.setApprovalForAll(address(this), true);

        _nft.transferFrom(msg.sender, address(this), _tokenId);

        uint solTime = _time/1000;

        companyMarket[itemCount] = Market(
            itemCount,
            _nft,
            _tokenId,
            _amount,
            payable(msg.sender),
            _time,
            solTime,
            false
        );

        
        emit marketPro(msg.sender, _amount, _tokenId, _time, solTime);


    }


    function purchase (uint _itemId) public payable {

        uint _tokenFullPrice = getTokenFullPrice(_itemId);
        Market storage market = companyMarket[_itemId];

        require(msg.value >= _tokenFullPrice, 'no enough money to prochase the token');
        require(_itemId > 0 && _itemId <= itemCount, 'item dose no exit');

        require(!market.sold, 'product already sold');

        require(market.solTime > block.timestamp, 'time for nft is due');
        require(msg.sender != market.seller, 'you can purchase your own token');

        market.seller.transfer(market.itemPrice);
        //owner.transfer(_tokenFullPrice - market.itemPrice);
        owner.transfer(msg.value - market.itemPrice);

        market.sold = true;

        market.nft.transferFrom(address(this), msg.sender, market.tokenId);

        emit purchaseMarket(market.seller, msg.sender, address(this), market.tokenId);


    }


    function getTokenFullPrice (uint _itemId) public view returns(uint) {
        return (companyMarket[_itemId].itemPrice + (companyMarket[_itemId].itemPrice)/10);
    }

    function dueNft (uint _itemId) public {

        Market storage market = companyMarket[_itemId];
        require(msg.sender == market.seller, 'you not the owner of nft');
        require(block.timestamp > market.solTime, 'time has not expired');
        market.nft.transferFrom(address(this), msg.sender, market.tokenId);

        emit due(msg.sender, address(this), market.tokenId, market.itemId);

    }


    

   

    






}