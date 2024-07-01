// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAavePool {
    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf) external;

    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode) external;

    function withdraw(
        address asset,
        uint256 amount,
        address to) external returns (uint256);

    function getReserveData(
        address asset) external view returns (DataTypes.ReserveData memory);
}