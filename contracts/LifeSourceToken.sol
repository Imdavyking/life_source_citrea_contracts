// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LifeSourceToken is ERC20 {
    address public immutable OWNER;
    error LifeSourceToken__NotOwner();

    constructor() ERC20("LifeSourceToken", "LFT") {
        OWNER = msg.sender;
    }

    function mint(address to, uint256 amount) external {
        if (msg.sender != OWNER) {
            revert LifeSourceToken__NotOwner();
        }
        _mint(to, amount);
    }
}
