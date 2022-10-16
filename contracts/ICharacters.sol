// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ICharacters {
    function mint(address account, uint256 id, uint256 amount) external;

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts) external;
}