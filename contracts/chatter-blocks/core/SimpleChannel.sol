// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/ISimpleChannel.sol";
import "../abstract/Befuddler.sol";

contract SimpleChannel is ISimpleChannel, Befuddler {
    address private alice;
    address private bob;
    Message[] private messages;

    constructor(address a, address b) {
        alice = a;
        bob = b;
        
        messages.push(Message(address(this), "init chat", block.timestamp));
    }

    modifier onlyMessanger() {
      require(alice == msg.sender || bob == msg.sender, "Channel: caller is not a messanger");
      _;
    }

    //change to bytes?
    function submitMessage(string memory text) public onlyMessanger() override returns (bool) {
        messages.push(Message(msg.sender, text, block.timestamp));
        emit MessageSubmit(messageCount() - 1, role(), text);
        
        return true;
    }

    //dummy version
    function readResponse() external view onlyMessanger() override returns(Message memory message) {
        message = Message(address(0), '', 0);
        for (uint i = messageCount() - 1; i >= 0; i--) {
            if (messages[i].sender != msg.sender) {
                return messages[i];
            }
        }
    }

    //add batching
    function readResponseAt(uint256 index) external view onlyMessanger() override returns(Message memory) {
        require(index < messageCount(), "Channel: index out of bounds");
        return messages[index];
    }

    function readThread() external view onlyMessanger() override returns (Message[] memory) {
        return messages;
    }

    function messageCount() public view override returns(uint256) {
        return messages.length;
    }

    function role() internal view returns (Actor actor) {
        if (msg.sender == bob) actor = Actor.Bob;
    }
}