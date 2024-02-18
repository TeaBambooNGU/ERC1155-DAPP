// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {ERC1155Custom} from "./ERC1155Custom.sol";
import {DataFeedConsumerV3Factory} from "./DataFeedConsumerV3Factory.sol";
import {ChainLinkEnum} from "./ChainLinkEnum.sol";

contract TangToken is ERC1155Custom {

    constructor(string memory _name, string memory _symbol, string memory _uri, address[] memory _chainLinkDataFeeds) ERC1155Custom(_name,_symbol,_uri) {
        chainLinkDataFeeds = _chainLinkDataFeeds;
    }

    function mint(address to, uint256 id, uint256 amount) external  {
        require(to != address(0),"can not mint to zero address");
        require(id < MAX_ID,"id overflow");
        bytes memory reason = abi.encodePacked("the reason of this mint");
        _mint(to,id,amount,reason);
    }

    function mintBatch(address to, uint256[] calldata ids, uint256[] calldata amounts) external  {
        require(to != address(0),"can not mint to zero address");
        require(ids.length == amounts.length, "ids.length not equal amounts.lengtg");
        for (uint i = 0; i < ids.length; i++) {
            require(ids[i] < MAX_ID,"id overflow");
        }
        _mintBatch(to,ids,amounts,"");
        
    }

    function burn(address from, uint256 id, uint256 value) external OnlyAdmin {
        _burn(from,id,value);
    }

    function getETH2USDLatestAnswer () external view returns (int) {
        DataFeedConsumerV3Factory dataFeedETH2USD = DataFeedConsumerV3Factory(chainLinkDataFeeds[uint256(ChainLinkEnum.dataFeedType.ETH_USD)]);
        return dataFeedETH2USD.getChainlinkDataFeedLatestAnswer();
    }

    function getBTC2USDLatestAnswer () external view returns (int) {
        DataFeedConsumerV3Factory dataFeedETH2USD = DataFeedConsumerV3Factory(chainLinkDataFeeds[uint256(ChainLinkEnum.dataFeedType.BTC_USD)]);
        return dataFeedETH2USD.getChainlinkDataFeedLatestAnswer();
    }

}