// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {ERC1155Custom} from "./ERC1155Custom.sol";
import {AggregatorV3Interface} from "chainlink-brownie-contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {ChainLinkEnum} from "./ChainLinkEnum.sol";
import {VRFCoordinatorV2Interface} from "chainlink-brownie-contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {ConfirmedOwner} from "chainlink-brownie-contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {AutomationCompatible} from "chainlink-brownie-contracts/src/v0.8/automation/AutomationCompatible.sol";

contract TangToken is ERC1155Custom,ConfirmedOwner,AutomationCompatible{
    error OnlyCoordinatorCanFulfill(address have, address want);
    error TangToken_AwardedNotInTime(address sender, uint256 currentTimestamp);
    error RequestNotFound(uint256 requestId);


    // 保证 逻辑合约和代理合约 状态变量存储结构一致
    /**
     * @notice chainlink dataFeed 货币交易对价格
     * 数组中的地址顺序为ChainLinkEnum枚举顺序 对应不同的token交易对
     * see src/ChainLinkEnum.sol
     * 0: ETH / USD
     * 1: BTC / USD
     */
    address[] public chainLinkDataFeeds;
    // storage 和 immutable 不会占用状态变量存储空间
    // VRFCoordinator合约
    VRFCoordinatorV2Interface private immutable vrfCoordinator;
    // ChainLink订阅ID
    uint64 s_subscriptionId;
    // ChainLink费率哈希
    bytes32 s_keyHash;
    // 请求被确认的区块数
    uint16 s_requestConfirmations;
    // 回调接口限制的最大Gas
    uint32 s_callbackGasLimit;
    // 返回多少个随机数 storage 和 immutable 不会占用状态变量存储空间
    uint32 immutable i_numWords;

    uint48 public constant AWARD_INTERVAL = 2 days;
    
    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) private s_requests; /* requestId --> requestStatus */
    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    event VRF_RequestSent(uint256 indexed requestId, uint32 indexed numWords);
    event VRF_RequestFulfilled(uint256 indexed requestId, uint256[] randomWords);
    event TangToken_Awarded(address indexed tangPeople);

    constructor(
        string memory _name, 
        string memory _symbol, 
        string memory _uri,
        address _vrfCoordinator,
        uint32 _numWords
        ) ERC1155Custom(_name,_symbol,_uri) ConfirmedOwner(msg.sender) {
            vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
            i_numWords = _numWords;
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

    function burn(address from, uint256 id, uint256 value) external OnlyMySelf(from) {
        _burn(from,id,value);
    }

    function getETH2USDLatestAnswer() external view returns (int) {
        AggregatorV3Interface dataFeedETH2USD = AggregatorV3Interface(chainLinkDataFeeds[uint256(ChainLinkEnum.dataFeedType.ETH_USD)]);
                // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeedETH2USD.latestRoundData();
        uint8 decimals = dataFeedETH2USD.decimals();
        int decimal = int(10**decimals);
        int result = answer / decimal;
        return result;
    }

    function getETH2USDVersion() external view returns (uint256) {
        AggregatorV3Interface dataFeedETH2USD = AggregatorV3Interface(chainLinkDataFeeds[uint256(ChainLinkEnum.dataFeedType.ETH_USD)]);
        return dataFeedETH2USD.version();
    }

    function getBTC2USDLatestAnswer() external view returns (int) {
        AggregatorV3Interface dataFeedETH2USD = AggregatorV3Interface(chainLinkDataFeeds[uint256(ChainLinkEnum.dataFeedType.BTC_USD)]);
                // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeedETH2USD.latestRoundData();
        return answer;
    }

    function checkUpkeep(bytes calldata /*checkData8*/) external view override cannotExecute  returns (bool upkeepNeeded, bytes memory performData) {
        if(s_lastAwardTime + AWARD_INTERVAL < block.timestamp){
            upkeepNeeded = true;
        }

        performData = "";
        
    }
    function performUpkeep(bytes calldata /*performData*/) external override{
        awardPeopleTokens();
    }


    function awardPeopleTokens() private {

        if(s_lastAwardTime + AWARD_INTERVAL >= block.timestamp){
            revert TangToken_AwardedNotInTime(msg.sender, block.timestamp);
        }

       // Will revert if subscription is not set and funded.
        uint256 requestId = vrfCoordinator.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            s_requestConfirmations,
            s_callbackGasLimit,
            i_numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit VRF_RequestSent(requestId, i_numWords);
    }

    function rawFulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) external  {
        if(!s_requests[_requestId].exists){
            revert RequestNotFound(_requestId);
        }
        if(msg.sender != address(vrfCoordinator)){
            revert OnlyCoordinatorCanFulfill(msg.sender, address(vrfCoordinator));
        }
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit VRF_RequestFulfilled(_requestId, _randomWords);

        address[] memory totalPeople = s_totalPeople;
        for(uint i = 0; i < _randomWords.length; i++){
            uint awardIndex = _randomWords[i] % totalPeople.length;
            address awardPeople = totalPeople[awardIndex];
            if(!s_peopleAwarded[awardPeople]){
                s_peopleAwarded[awardPeople] = true;
                _mint(awardPeople, 1, 520,"");
                emit TangToken_Awarded(awardPeople);
            }
        }
        
    }



}