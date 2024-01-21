// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract TangProxy is TransparentUpgradeableProxy {
    address public logicContract;
    bytes private wish;

    event TangContractUpdateLogicSuccess(address indexed implementation, bytes wish);

    constructor(address _logic, bytes memory _data) payable TransparentUpgradeableProxy(_logic, msg.sender, _data) {
        logicContract = _logic;
        wish = _data;
    }

    fallback() external payable override {
        super._fallback();
        // 在透明代理下 如果是管理员执行成功的函数 那一定是升级函数
        if (msg.sender == _proxyAdmin()) {
            (address newImplementation, bytes memory data) = abi.decode(msg.data[4:], (address, bytes));
            emit TangContractUpdateLogicSuccess(newImplementation, wish);
        }
    }
}
