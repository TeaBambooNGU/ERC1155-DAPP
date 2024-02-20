// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {ERC1967Utils} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IERC1967} from "openzeppelin-contracts/contracts/interfaces/IERC1967.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {VRFCoordinatorV2Interface} from "chainlink-brownie-contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";


interface ITransparentUpgradeableProxy is IERC1967 {
    function upgradeToAndCall(address, bytes calldata) external payable;
}


contract TangProxy is ERC1967Proxy {

    /**
     * @dev The proxy caller is the current admin, and can't fallback to the proxy target.
     */
    error ProxyDeniedAdminAccess();

    //保证 逻辑合约和代理合约 状态变量存储结构一致

    // Token名称
    string public name;
    // Token代号
    string public symbol;

    // An immutable address for the admin to avoid unnecessary SLOADs before each call
    // at the expense of removing the ability to change the admin once it's set.
    // This is acceptable if the admin is always a ProxyAdmin instance or similar contract
    // with its own ability to transfer the permissions to another account.
    address private immutable _admin;

    bytes private wish;

    mapping(uint256 id => mapping(address account => uint256)) private _balances;

    mapping(address account => mapping(address operator => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;
    // 铸币种类数量限制
    uint256 private constant MAX_ID = 1314;
    // 总铸币个数(包含NFT)
    uint256 public totalSupply;
    // 总铸币个数(不包含NFT)
    uint256 public totalSupplyNotNFT;
    // 已铸造的NFT个数
    uint256 public NFTCount;
    // 持有者列表
    address[] public totalPeople;
    // 是否是小糖人
    mapping(address => bool) isTangPeople;


    // 这2个变量来源于 ConfirmedOwnerWithProposal.sol
    address private s_owner;
    address private s_pendingOwner;
    
    // chainlink dataFeed 货币交易对价格
    address[] public chainLinkDataFeeds;
    
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
    // 返回多少个随机数
    uint32 immutable i_numWords;
    
    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */
    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;



    event TangContractUpdateLogicSuccess(address indexed implementation, bytes wish);

    /**
     * @dev Initializes an upgradeable proxy managed by an instance of a {ProxyAdmin} with an `initialOwner`,
     * backed by the implementation at `_logic`, and optionally initialized with `_data` as explained in
     * {ERC1967Proxy-constructor}.
     */
    constructor(
        address _logic, 
        bytes memory _data, 
        string memory _wish,
        address[] memory _chainLinkDataFeeds,
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint64 _subscriptionId,
        uint16 _requestConfirmations,
        uint32 _callbackGasLimit,
        uint32 _numWords
        ) payable ERC1967Proxy(_logic, _data) {
        _admin = address(new ProxyAdmin(msg.sender));
        // Set the storage value and emit an event for ERC-1967 compatibility
        ERC1967Utils.changeAdmin(_proxyAdmin());
        wish = bytes(_wish);
        chainLinkDataFeeds = _chainLinkDataFeeds;
        vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        s_keyHash = _keyHash;
        s_subscriptionId = _subscriptionId;
        s_requestConfirmations = _requestConfirmations;
        s_callbackGasLimit = _callbackGasLimit;
        i_numWords = _numWords;
    }
    // 添加receive函数去掉警告
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Returns the admin of this proxy.
     */
    function _proxyAdmin() internal virtual returns (address) {
        return _admin;
    }

    /**
     * @dev If caller is the admin process the call internally, otherwise transparently fallback to the proxy behavior.
     */
    function _fallback() internal virtual override {
        if (msg.sender == _proxyAdmin()) {
            if (msg.sig != ITransparentUpgradeableProxy.upgradeToAndCall.selector) {
                revert ProxyDeniedAdminAccess();
            } else {
                _dispatchUpgradeToAndCall();
            }
        } else {
            super._fallback();
        }
    }

    /**
     * @dev Upgrade the implementation of the proxy. See {ERC1967Utils-upgradeToAndCall}.
     *
     * Requirements:
     *
     * - If `data` is empty, `msg.value` must be zero.
     */
    function _dispatchUpgradeToAndCall() private {
        (address newImplementation, bytes memory data) = abi.decode(msg.data[4:], (address, bytes));
        ERC1967Utils.upgradeToAndCall(newImplementation, data);
        emit TangContractUpdateLogicSuccess(newImplementation, wish);
    }
}
