// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;
import {Test,console2} from"forge-std/Test.sol";
import {TangTokenScript,TangToken} from"../script/TangToken.s.sol";
import {TangProxyScript,TangProxy} from "../script/TangProxy.s.sol";

contract TangTokenTest is Test {

    TangProxy public proxyContract;
    
    function setUp() public {
        
    }

}