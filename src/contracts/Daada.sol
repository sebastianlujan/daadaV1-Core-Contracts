// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAavePool} from "../interfaces/IAavePool.sol";
import {Types} from "../libraries/Types.sol";
import {IERC20} from "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IMorpho,MarketParams} from "node_modules/@morpho-org/morpho-blue/src/interfaces/IMorpho.sol";
import {IMorphoFlashLoanCallback} from "node_modules/@morpho-org/morpho-blue/src/interfaces/IMorphoCallbacks.sol";

contract Daada {
    address public immutable AAVE_POOL_ADDRESS;
    address public immutable STAKED_TOKEN_ADDRESS;
    address public immutable ATOKEN_ADDRESS;
    address public immutable OWNER;
    mapping(address account => uint amount) public stakeByAccount;
    uint public totalStake;

    constructor(address aavePoolAddress, address stakedTokenAddress, address aeroFactory) {
        AAVE_POOL_ADDRESS = aavePoolAddress;
        STAKED_TOKEN_ADDRESS = stakedTokenAddress;
        OWNER = msg.sender;
        ATOKEN_ADDRESS = IPool(aavePoolAddress).getReserveData(stakedTokenAddress).aTokenAddress;
    }

    function stake(uint amount) public {
        totalStake += amount;
        stakeByAccount[msg.sender] += amount;
        IERC20(STAKED_TOKEN_ADDRESS).transferFrom(msg.sender, address(this), amount);
        IERC20(STAKED_TOKEN_ADDRESS).approve(AAVE_POOL_ADDRESS, amount);
        IPool(AAVE_POOL_ADDRESS).supply(
            STAKED_TOKEN_ADDRESS,
            amount,
            address(this),
            0);
    }

    function unstake(uint amount) public {
        require(amount <= stakeByAccount[msg.sender], "Not enough stake");
        totalStake -= amount;
        stakeByAccount[msg.sender] -= amount;
        IPool(AAVE_POOL_ADDRESS).withdraw(
          STAKED_TOKEN_ADDRESS,
          amount,
          msg.sender
        );
    }

    function yieldEarned() public view returns(uint){
        return IERC20(ATOKEN_ADDRESS).balanceOf(address(this)) - totalStake;
    }

    function withdraw(uint amount) public {
        require(msg.sender == OWNER, "Sender is not owner");
        require(amount <= yieldEarned(), "Maximum withdraw exceeded");
        IPool(AAVE_POOL_ADDRESS).withdraw(
          STAKED_TOKEN_ADDRESS,
          amount,
          msg.sender
        );
    }

    /// @notice internal function to swap tokens using morpho
    function _flashLoan(address token, uint256 assets, bytes memory  data) internal {
        morpho.flashLoan(token, assets, data);
    }

    /// incomplete

}