// SPDX-License-Identifier: MIT
pragma solidity =0.8.10;

import "../../../auth/AdminAuth.sol";
import "../helpers/LlamaLendHelper.sol";
import "../../../actions/fee/helpers/GasFeeHelper.sol";
import "../../../exchangeV3/DFSExchangeCore.sol";

/// @title CurveUsdSwapper Callback contract for CurveUsd extended actions, swaps directly on curve
contract LlamaLendSwapper is LlamaLendHelper, DFSExchangeCore, GasFeeHelper, AdminAuth {
    using SafeERC20 for IERC20;
    using TokenUtils for address;

    /// @dev Divider for automation fee, 5 bps
    uint256 internal constant AUTOMATION_DFS_FEE = 2000;

    struct CallbackData {
        uint256 stablecoins;
        uint256 collateral;
    }


    ///@dev Called by curve controller from repay_extended method, sends collateral tokens to this contract
    function callback_repay(
        address _user,
        uint256,
        uint256,
        uint256,
        uint256[] memory info
    ) external returns (CallbackData memory cb) {
        uint256 gasUsed = info[0];

        ExchangeData memory exData = abi.decode(transientStorage.getBytesTransiently(), (DFSExchangeData.ExchangeData));
        address collToken = exData.srcAddr;
        address debtToken = exData.destAddr;

        (, uint256 receivedAmount, bool hasFee) = _sell(exData, _user);
        // need to take automation fee somehow
        if (gasUsed > 0){
            receivedAmount -= takeAutomationFee(receivedAmount, debtToken, gasUsed, hasFee);
        }

        cb.stablecoins = receivedAmount;
        cb.collateral = collToken.getBalance(address(this));

        // approve the controller to create new position
        IERC20(collToken).safeApprove(msg.sender, cb.collateral);
        IERC20(debtToken).safeApprove(msg.sender, cb.stablecoins);
    }

    function callback_deposit(
        address _user,
        uint256,
        uint256,
        uint256,
        uint256[] memory info
    ) external returns (CallbackData memory cb) {
        uint256 gasUsed = info[0];
        ExchangeData memory exData = abi.decode(transientStorage.getBytesTransiently(), (DFSExchangeData.ExchangeData));

        address collToken = exData.destAddr;

        (, uint256 receivedAmount, bool hasFee) = _sell(exData, _user);
        // need to take automation fee somehow
        if (gasUsed > 0){
            receivedAmount -= takeAutomationFee(receivedAmount, collToken, gasUsed, hasFee);
        }

        cb.collateral = receivedAmount;

        // approve the controller to create new position
        IERC20(collToken).safeApprove(msg.sender, cb.collateral);
    }

    function callback_liquidate(
        address _user,
        uint256,
        uint256,
        uint256,
        uint256[] memory info
    ) external returns (CallbackData memory cb) {
        uint256 gasUsed = info[0];
        bool sellMax = info[1] > 0;

        ExchangeData memory exData = abi.decode(transientStorage.getBytesTransiently(), (DFSExchangeData.ExchangeData));
        
        address collToken = exData.srcAddr;
        address debtToken = exData.destAddr;
        if (sellMax) {
            exData.srcAmount = collToken.getBalance(address(this));
        }
        (, uint256 receivedAmount, bool hasFee) = _sell(exData, _user);
        // need to take automation fee somehow
        if (gasUsed > 0){
            receivedAmount -= takeAutomationFee(receivedAmount, debtToken, gasUsed, hasFee);
        }
        cb.stablecoins = receivedAmount;
        cb.collateral = collToken.getBalance(address(this));

        IERC20(collToken).safeApprove(msg.sender, cb.collateral);
        IERC20(debtToken).safeApprove(msg.sender, cb.stablecoins);

    }

    /// @dev No funds should be stored on this contract, but if anything is left send back to the user
    function withdrawAll(address _controllerAddress) external {
        address collToken = ILlamaLendController(_controllerAddress).collateral_token();
        address debtToken = ILlamaLendController(_controllerAddress).borrowed_token();

        debtToken.withdrawTokens(msg.sender, type(uint256).max);
        collToken.withdrawTokens(msg.sender, type(uint256).max);
    }

    function takeAutomationFee(
        uint256 _destTokenAmount,
        address _token,
        uint256 _gasUsed,
        bool hasFee
    ) internal returns (uint256 feeAmount) {
        // we need to take the fee for tx cost as well, as it's in a strategy
        feeAmount += calcGasCost(_gasUsed, _token, 0);
        
        // gas fee can't go over 20% of the whole amount
        if (feeAmount > (_destTokenAmount / 5)) {
            feeAmount = _destTokenAmount / 5;
        }
        // if user has been whitelisted we don't take 0.05% fee
        if (hasFee) {
            feeAmount += _destTokenAmount / AUTOMATION_DFS_FEE;
        }

        address walletAddr = FeeRecipient(FEE_RECIPIENT_ADDRESS).getFeeAddr();
        _token.withdrawTokens(walletAddr, feeAmount);
    }

}
