// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import "forge-std/Test.sol";

import { BundleStorage } from "../../contracts/core/strategy/BundleStorage.sol";
import { AdminVault } from "../../contracts/auth/AdminAuth.sol";
import { CheatCodes } from "../CheatCodes.sol";

contract BundleBuilder {
    address internal BUNDLE_ADDR = 0x223c6aDE533851Df03219f6E3D8B763Bd47f84cf;

    function init(uint64[] memory _strategyIds) public returns (uint bundleId) {
        CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        BundleStorage bundle = BundleStorage(BUNDLE_ADDR);

        cheats.startPrank(AdminVault(bundle.adminVault()).owner());
        bundleId = bundle.createBundle(_strategyIds);
        cheats.stopPrank();
    }
}