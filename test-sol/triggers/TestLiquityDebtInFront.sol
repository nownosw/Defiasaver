// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import { LiquityDebtInFrontTrigger } from "../../contracts/triggers/LiquityDebtInFrontTrigger.sol";
import { LiquityHelper } from "../../contracts/actions/liquity/helpers/LiquityHelper.sol";

/// @dev Fetching lastTrove is really slow, so we ignore these tests by adding '_' as prefix to remove delay when running all tests
/// @dev For running these two tests, just remove '_' from the function name
contract TestLiquityDebtInFront is Test, LiquityHelper {

    LiquityDebtInFrontTrigger trigger;

    function setUp() public {
        trigger = new LiquityDebtInFrontTrigger();
    }

    function _testDebtInFrontTriggerForLargestTrove() public  view{
        console.log("Test debt in front trigger for largest trove. This can take a while...");
        // fetch head of list, largest TCR
        address lastTrove = SortedTroves.getFirst();

        bytes memory subData = abi.encode(LiquityDebtInFrontTrigger.SubParams({
            troveOwner: lastTrove,
            debtInFrontMin: 500_000 * 1e18
        }));

        bool isTriggered = trigger.isTriggered("", subData);

        console.log(isTriggered);

        assert(isTriggered == false);
    }

    function _testDebtInFrontTriggerForLargestTroveToBeTrue() public view {
        console.log("Test debt in front trigger for largest trove. This can take a while...");
        // fetch head of list, largest TCR
        address lastTrove = SortedTroves.getFirst();

        bytes memory subData = abi.encode(LiquityDebtInFrontTrigger.SubParams({
            troveOwner: lastTrove,
            debtInFrontMin: 500_000_000 * 1e18
        }));

        bool isTriggered = trigger.isTriggered("", subData);

        assert(isTriggered == true);
    }

}