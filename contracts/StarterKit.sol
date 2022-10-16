// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./ICharacters.sol";

contract StarterKit is Ownable, Pausable {
    ICharacters private immutable _characters;

    uint256[] private _startCharacters = [25, 26, 27];
    uint256[] private _startAmount = [1, 1, 1];

    mapping (address => bool) private _isDraw;

    constructor(address _char) {
        _characters = ICharacters(_char);
    }

    function openStarterKit() external whenNotPaused {
        require(!_isDraw[msg.sender]);

        _characters.mintBatch(msg.sender, _startCharacters, _startAmount);
        _isDraw[msg.sender] = true;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function isMinted(address _player) external view returns (bool) {
        return _isDraw[_player];
    }
}
