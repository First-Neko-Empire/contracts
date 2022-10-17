// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./ICharacters.sol";

contract Roll is VRFConsumerBaseV2, Ownable, Pausable {
    VRFCoordinatorV2Interface private immutable _COORDINATOR;
    ICharacters private immutable _CHARACTERS;

    address public constant _VRFCOORDINATOR = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
    bytes32 private constant _KEYHASH = 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;

    uint64 private immutable _SUBSCRIPTIONID;
    uint32 private constant _CALLBACK_GAS_LIMIT = 500000;

    mapping (address => uint8) private _rolls;
    mapping (uint256 => address) private _requestToAddress;

    constructor(uint64 _subId, address _chars) VRFConsumerBaseV2(_VRFCOORDINATOR) {
        _COORDINATOR = VRFCoordinatorV2Interface(_VRFCOORDINATOR);
        _CHARACTERS = ICharacters(_chars);
        _SUBSCRIPTIONID = _subId;
    }

    // PUBLIC

    function requestRandomCharacter() external payable whenNotPaused {
        require(msg.value >= 0.1 ether, "The cost of this action is higher");
        uint256 requestId = _COORDINATOR.requestRandomWords(
            _KEYHASH, _SUBSCRIPTIONID, 3, _CALLBACK_GAS_LIMIT, 1
        );
        _requestToAddress[requestId] = msg.sender;
    }

    // OWNER

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // OVERRIDE

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        address _player = _requestToAddress[_requestId];
        uint256 _random = _randomWords[0];
        _rolls[_player]++;

        if (_rolls[_player] == 10) {

            _rolls[_player] = 0;
            uint256 _randomCharacter = 20 + (_random % 5);
            _CHARACTERS.mint(_player, _randomCharacter, 1);

        } else {
            uint256 _randomCharacter = _random % 20;
            _CHARACTERS.mint(_player, _randomCharacter, 1);
        }
    }
}