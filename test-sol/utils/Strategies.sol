// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { StrategyBuilder } from "./StrategyBuilder.sol";

contract Strategies {

    function createCompV3Repay() internal returns (uint256) {
        StrategyBuilder repayStrategy = new StrategyBuilder("CompV3Repay", true);
        repayStrategy.addSubMapping("&market");
        repayStrategy.addSubMapping("&baseToken");
        repayStrategy.addSubMapping("&ratioState");
        repayStrategy.addSubMapping("&targetRatio");

        repayStrategy.addTrigger("CompV3RatioTrigger");

        string[] memory withdrawParams = new string[](4);
        withdrawParams[0] = "&market";
        withdrawParams[1] = "&proxy";
        repayStrategy.addAction("CompV3Withdraw", withdrawParams);

        string[] memory sellParams = new string[](5);
        sellParams[1] = "&baseToken";
        sellParams[2] = "$1";
        sellParams[3] = "&proxy";
        sellParams[4] = "&proxy";
        repayStrategy.addAction("DFSSell", sellParams);

        string[] memory gasFeeParams = new string[](3);
        gasFeeParams[0] = "&baseToken";
        gasFeeParams[1] = "$2";
        repayStrategy.addAction("GasFeeTaker", gasFeeParams);

        string[] memory paybackParams = new string[](4);
        paybackParams[0] = "&market";
        paybackParams[1] = "$3";
        paybackParams[2] = "&proxy";
        paybackParams[3] = "&proxy";
        repayStrategy.addAction("CompV3Payback", paybackParams);

        string[] memory checkerParams = new string[](3);
        checkerParams[0] = "&ratioState";
        checkerParams[1] = "&targetRatio";
        checkerParams[2] = "&market";
        repayStrategy.addAction("CompV3RatioCheck", checkerParams);

        return repayStrategy.createStrategy();
    }

    function createCompV3EOARepay() internal returns (uint256) {
        StrategyBuilder repayStrategy = new StrategyBuilder("CompV3EOARepay", true);
        repayStrategy.addSubMapping("&market");
        repayStrategy.addSubMapping("&baseToken");
        repayStrategy.addSubMapping("&ratioState");
        repayStrategy.addSubMapping("&targetRatio");

        repayStrategy.addTrigger("CompV3RatioTrigger");

        string[] memory withdrawParams = new string[](5);
        withdrawParams[0] = "&market";
        withdrawParams[1] = "&proxy";
        withdrawParams[4] = "&eoa";
        repayStrategy.addAction("CompV3Withdraw", withdrawParams);

        string[] memory sellParams = new string[](5);
        sellParams[1] = "&baseToken";
        sellParams[2] = "$1";
        sellParams[3] = "&proxy";
        sellParams[4] = "&proxy";
        repayStrategy.addAction("DFSSell", sellParams);

        string[] memory gasFeeParams = new string[](3);
        gasFeeParams[0] = "&baseToken";
        gasFeeParams[1] = "$2";
        repayStrategy.addAction("GasFeeTaker", gasFeeParams);

        string[] memory paybackParams = new string[](4);
        paybackParams[0] = "&market";
        paybackParams[1] = "$3";
        paybackParams[2] = "&proxy";
        paybackParams[3] = "&eoa";
        repayStrategy.addAction("CompV3Payback", paybackParams);

        string[] memory checkerParams = new string[](4);
        checkerParams[0] = "&ratioState";
        checkerParams[1] = "&targetRatio";
        checkerParams[2] = "&market";
        checkerParams[3] = "&eoa";
        repayStrategy.addAction("CompV3RatioCheck", checkerParams);

        return repayStrategy.createStrategy();
    }

    function createCompV3FLEOARepay() internal returns (uint256) {
        StrategyBuilder repayStrategy = new StrategyBuilder("CompV3FLEOARepay", true);
        repayStrategy.addSubMapping("&market");
        repayStrategy.addSubMapping("&baseToken");
        repayStrategy.addSubMapping("&ratioState");
        repayStrategy.addSubMapping("&targetRatio");

        repayStrategy.addTrigger("CompV3RatioTrigger");

        string[] memory flParams = new string[](1);
        repayStrategy.addAction("FLAction", flParams);

        string[] memory sellParams = new string[](5);
        sellParams[1] = "&baseToken";
        sellParams[3] = "&proxy";
        sellParams[4] = "&proxy";
        repayStrategy.addAction("DFSSell", sellParams);

        string[] memory gasFeeParams = new string[](3);
        gasFeeParams[0] = "&baseToken";
        gasFeeParams[1] = "$2";
        repayStrategy.addAction("GasFeeTaker", gasFeeParams);

        string[] memory paybackParams = new string[](4);
        paybackParams[0] = "&market";
        paybackParams[1] = "$3";
        paybackParams[2] = "&proxy";
        paybackParams[3] = "&eoa";
        repayStrategy.addAction("CompV3Payback", paybackParams);

        string[] memory withdrawParams = new string[](5);
        withdrawParams[0] = "&market";
        withdrawParams[3] = "$1";
        withdrawParams[4] = "&eoa";
        repayStrategy.addAction("CompV3Withdraw", withdrawParams);

        string[] memory checkerParams = new string[](4);
        checkerParams[0] = "&ratioState";
        checkerParams[1] = "&targetRatio";
        checkerParams[2] = "&market";
        checkerParams[3] = "&eoa";
        repayStrategy.addAction("CompV3RatioCheck", checkerParams);

        return repayStrategy.createStrategy();
    }

    function createCompV3FLRepay() internal returns (uint256) {
        StrategyBuilder repayStrategy = new StrategyBuilder("CompV3FLRepay", true);
        repayStrategy.addSubMapping("&market");
        repayStrategy.addSubMapping("&baseToken");
        repayStrategy.addSubMapping("&ratioState");
        repayStrategy.addSubMapping("&targetRatio");

        repayStrategy.addTrigger("CompV3RatioTrigger");

        string[] memory flParams = new string[](1);
        repayStrategy.addAction("FLAction", flParams);

        string[] memory sellParams = new string[](5);
        sellParams[1] = "&baseToken";
        sellParams[3] = "&proxy";
        sellParams[4] = "&proxy";
        repayStrategy.addAction("DFSSell", sellParams);

        string[] memory gasFeeParams = new string[](3);
        gasFeeParams[0] = "&baseToken";
        gasFeeParams[1] = "$2";
        repayStrategy.addAction("GasFeeTaker", gasFeeParams);

        string[] memory paybackParams = new string[](4);
        paybackParams[0] = "&market";
        paybackParams[1] = "$3";
        paybackParams[2] = "&proxy";
        paybackParams[3] = "&proxy";
        repayStrategy.addAction("CompV3Payback", paybackParams);

        string[] memory withdrawParams = new string[](4);
        withdrawParams[0] = "&market";
        withdrawParams[3] = "$1";
        repayStrategy.addAction("CompV3Withdraw", withdrawParams);

        string[] memory checkerParams = new string[](3);
        checkerParams[0] = "&ratioState";
        checkerParams[1] = "&targetRatio";
        checkerParams[2] = "&market";
        repayStrategy.addAction("CompV3RatioCheck", checkerParams);

        return repayStrategy.createStrategy();
    }

    function createCompV3Boost() internal returns (uint256) {
        StrategyBuilder boostStrategy = new StrategyBuilder("CompV3Boost", true);
        boostStrategy.addSubMapping("&market");
        boostStrategy.addSubMapping("&baseToken");
        boostStrategy.addSubMapping("&ratioState");
        boostStrategy.addSubMapping("&targetRatio");

        boostStrategy.addTrigger("CompV3RatioTrigger");

        string[] memory borrowParams = new string[](3);
        borrowParams[0] = "&market";
        borrowParams[2] = "&proxy";
        boostStrategy.addAction("CompV3Borrow", borrowParams);

        string[] memory sellParams = new string[](5);
        sellParams[0] = "&baseToken";
        sellParams[2] = "$1";
        sellParams[3] = "&proxy";
        sellParams[4] = "&proxy";
        boostStrategy.addAction("DFSSell", sellParams);

        string[] memory gasFeeParams = new string[](3);
        gasFeeParams[1] = "$2";
        boostStrategy.addAction("GasFeeTaker", gasFeeParams);

        string[] memory supplyParams = new string[](4);
        supplyParams[0] = "&market";
        supplyParams[2] = "$3";
        supplyParams[3] = "&proxy";
        boostStrategy.addAction("CompV3Supply", supplyParams);

        string[] memory checkerParams = new string[](3);
        checkerParams[0] = "&ratioState";
        checkerParams[1] = "&targetRatio";
        checkerParams[2] = "&market";
        boostStrategy.addAction("CompV3RatioCheck", checkerParams);

        return boostStrategy.createStrategy();
    }

    function createCompV3EOABoost() internal returns (uint256) {
        StrategyBuilder boostStrategy = new StrategyBuilder("CompV3EOABoost", true);
        boostStrategy.addSubMapping("&market");
        boostStrategy.addSubMapping("&baseToken");
        boostStrategy.addSubMapping("&ratioState");
        boostStrategy.addSubMapping("&targetRatio");

        boostStrategy.addTrigger("CompV3RatioTrigger");

        string[] memory borrowParams = new string[](4);
        borrowParams[0] = "&market";
        borrowParams[3] = "&eoa";
        boostStrategy.addAction("CompV3Borrow", borrowParams);

        string[] memory sellParams = new string[](5);
        sellParams[0] = "&baseToken";
        sellParams[2] = "$1";
        sellParams[3] = "&proxy";
        sellParams[4] = "&proxy";
        boostStrategy.addAction("DFSSell", sellParams);

        string[] memory gasFeeParams = new string[](3);
        gasFeeParams[1] = "$2";
        boostStrategy.addAction("GasFeeTaker", gasFeeParams);

        string[] memory supplyParams = new string[](5);
        supplyParams[0] = "&market";
        supplyParams[2] = "$3";
        supplyParams[3] = "&proxy";
        supplyParams[4] = "&eoa";
        boostStrategy.addAction("CompV3Supply", supplyParams);

        string[] memory checkerParams = new string[](4);
        checkerParams[0] = "&ratioState";
        checkerParams[1] = "&targetRatio";
        checkerParams[2] = "&market";
        checkerParams[3] = "&eoa";
        boostStrategy.addAction("CompV3RatioCheck", checkerParams);

        return boostStrategy.createStrategy();
    }

    function createCompV3FLBoost() internal returns (uint256) {
        StrategyBuilder boostStrategy = new StrategyBuilder("CompV3FLBoost", true);
        boostStrategy.addSubMapping("&market");
        boostStrategy.addSubMapping("&baseToken");
        boostStrategy.addSubMapping("&ratioState");
        boostStrategy.addSubMapping("&targetRatio");

        boostStrategy.addTrigger("CompV3RatioTrigger");

        string[] memory flParams = new string[](1);
        boostStrategy.addAction("FLAction", flParams);

        string[] memory sellParams = new string[](5);
        sellParams[0] = "&baseToken";
        sellParams[3] = "&proxy";
        sellParams[4] = "&proxy";
        boostStrategy.addAction("DFSSell", sellParams);

        string[] memory gasFeeParams = new string[](3);
        gasFeeParams[1] = "$2";
        boostStrategy.addAction("GasFeeTaker", gasFeeParams);

        string[] memory supplyParams = new string[](4);
        supplyParams[0] = "&market";
        supplyParams[2] = "$3";
        supplyParams[3] = "&proxy";
        boostStrategy.addAction("CompV3Supply", supplyParams);

        string[] memory borrowParams = new string[](4);
        borrowParams[0] = "&market";
        borrowParams[1] = "$1";
        boostStrategy.addAction("CompV3Borrow", borrowParams);

        string[] memory checkerParams = new string[](3);
        checkerParams[0] = "&ratioState";
        checkerParams[1] = "&targetRatio";
        checkerParams[2] = "&market";
        boostStrategy.addAction("CompV3RatioCheck", checkerParams);

        return boostStrategy.createStrategy();
    }

    function createCompV3FLEOABoost() internal returns (uint256) {
        StrategyBuilder boostStrategy = new StrategyBuilder("CompV3FLEOABoost", true);
        boostStrategy.addSubMapping("&market");
        boostStrategy.addSubMapping("&baseToken");
        boostStrategy.addSubMapping("&ratioState");
        boostStrategy.addSubMapping("&targetRatio");

        boostStrategy.addTrigger("CompV3RatioTrigger");

        string[] memory flParams = new string[](1);
        boostStrategy.addAction("FLAction", flParams);

        string[] memory sellParams = new string[](5);
        sellParams[0] = "&baseToken";
        sellParams[3] = "&proxy";
        sellParams[4] = "&proxy";
        boostStrategy.addAction("DFSSell", sellParams);

        string[] memory gasFeeParams = new string[](3);
        gasFeeParams[1] = "$2";
        boostStrategy.addAction("GasFeeTaker", gasFeeParams);

        string[] memory supplyParams = new string[](5);
        supplyParams[0] = "&market";
        supplyParams[2] = "$3";
        supplyParams[3] = "&proxy";
        supplyParams[4] = "&eoa";
        boostStrategy.addAction("CompV3Supply", supplyParams);

        string[] memory borrowParams = new string[](4);
        borrowParams[0] = "&market";
        borrowParams[1] = "$1";
        borrowParams[3] = "&eoa";
        boostStrategy.addAction("CompV3Borrow", borrowParams);

        string[] memory checkerParams = new string[](4);
        checkerParams[0] = "&ratioState";
        checkerParams[1] = "&targetRatio";
        checkerParams[2] = "&market";
        checkerParams[3] = "&eoa";
        boostStrategy.addAction("CompV3RatioCheck", checkerParams);

        return boostStrategy.createStrategy();
    }
}