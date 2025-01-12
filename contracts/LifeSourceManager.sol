// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./LifeSourceToken.sol";

contract LifeSourceManager {
    mapping(address => PointData) public userPoints;
    LifeSourceToken public immutable lifeSourceToken;
    uint256 public constant POINT_BASIS = 35;
    error LifeSourceManager__InsufficientPoints();

    struct PointData {
        uint256 points;
        uint256 updatedTimeStamp;
        uint256 createdTimeStamp;
        address user;
    }

    constructor() {
        lifeSourceToken = new LifeSourceToken();
    }

    /**
     * @dev Add points to the user based on the weight of the waste
     * @param weightInGrams weight in grams of the waste
     */
    function addPointFromWeight(uint256 weightInGrams) public {
        // accumulate points for the user based on the weight of the waste (calculate with 0.35)
        uint256 points = weightInGrams * POINT_BASIS;

        PointData memory userPointData = userPoints[msg.sender];

        // check if the user already has points
        if (userPointData.points > 0) {
            userPointData.points += points;
            userPointData.updatedTimeStamp = block.timestamp;
        } else {
            PointData memory pointData = PointData(
                points,
                block.timestamp,
                block.timestamp,
                msg.sender
            );
            userPoints[msg.sender] = pointData;
        }
    }

    /**
     * @dev Redeem points to get ERC20 token
     * @param point points to redeem
     * @return success true if the point is redeemed successfully
     */
    function redeemCode(uint256 point) public returns (bool success) {
        // withdraw points from the user
        if (userPoints[msg.sender].points == 0) {
            revert LifeSourceManager__InsufficientPoints();
        }
        if (userPoints[msg.sender].points < point) {
            revert LifeSourceManager__InsufficientPoints();
        }
        userPoints[msg.sender].points -= point;
        // convert to ERC20 token
        lifeSourceToken.mint(msg.sender, point * 10 ** lifeSourceToken.decimals());
        return true;
    }
}
