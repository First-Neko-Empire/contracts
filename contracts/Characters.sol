// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Characters is ERC1155, AccessControl {

    uint256 private _characters;
    bytes32 private constant MINTER = keccak256("MINTER");

    constructor() ERC1155("") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER, msg.sender);
        _characters = 30;
    }

    function setURI(string memory _newuri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(_newuri);
    }

    function mint(address account, uint256 id, uint256 amount) external onlyRole(MINTER) {
        require(id < _characters, "unknown character");
        _mint(account, id, amount, "");
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts) external onlyRole(MINTER) {
        _mintBatch(to, ids, amounts, "");
    }

    function getBalanceByAddress(address _user) external view returns(uint256[] memory) {
        uint256[] memory _invertory = new uint256[](_characters);
        uint256 i = 0;
        while (i < _characters){
            uint256 amount = balanceOf(_user, i);
            _invertory[i] = amount;
            i++;
        }
        return _invertory;    
    }

    function updateCharacter(uint256 _addAmount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _characters += _addAmount;
    }

    function setupRoleMinter(address _minter) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setupRole(MINTER, _minter);
    }

    function revorkeRoleMinter(address _minter) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER, _minter);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
