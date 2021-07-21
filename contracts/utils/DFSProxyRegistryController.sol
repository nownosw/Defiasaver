// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

import "./DFSProxyRegistry.sol";
import "../interfaces/IDSProxy.sol";
import "../DS/DSProxyFactoryInterface.sol";

/// @title User facing contract to manage new proxies (is owner of DFSProxyRegistry)
contract DFSProxyRegistryController is AdminAuth {

    address constant PROXY_FACTORY_ADDR = 0xA26e15C895EFc0616177B7c1e7270A4C7D51C997;
    address constant DFS_PROXY_REGISTRY_ADDR = 0x29474FdaC7142f9aB7773B8e38264FA15E3805ed;

    /// @dev List of prebuild proxies the users can claim to save gas
    address[] public proxyPool;

    event NewProxy(address, address);
    event ChangedOwner(address, address);

    /// @notice User calls from EOA to build a new DFS registred proxy
    function addNewProxy() public {
        address newProxy = getFromPoolOrBuild(msg.sender);
        DFSProxyRegistry(DFS_PROXY_REGISTRY_ADDR).addAdditionalProxy(msg.sender, address(newProxy));

        emit NewProxy(msg.sender, newProxy);
    }

    /// @notice Will change owner of proxy in DFSRegistry
    /// @dev Still need to .setOwner() in DSProxy first
    /// @dev msg.sender == DSProxy which calls this method
    function changeOwnerInDFSRegistry(address _newOwner) public {
        DFSProxyRegistry(DFS_PROXY_REGISTRY_ADDR).changeMcdOwner(_newOwner, msg.sender);

        emit ChangedOwner(_newOwner, msg.sender);
    }

    /// @notice Adds proxies to pool for users to later claim and save on gas
    function addToPool(uint _numNewProxies) public {
        for (uint256 i = 0; i < _numNewProxies; ++i) {
            DSProxy newProxy = DSProxyFactoryInterface(PROXY_FACTORY_ADDR).build();
            proxyPool.push(address(newProxy));
        }
    }

    /// @notice Created a new DSProxy or grabs a prebuilt one
    function getFromPoolOrBuild(address _user) internal returns (address) {
        if (proxyPool.length > 0) {
            address newProxy = proxyPool[proxyPool.length - 1];
            proxyPool.pop();

            DSAuth(newProxy).setOwner(_user);

            return newProxy;
        } else {
            DSProxy newProxy = DSProxyFactoryInterface(PROXY_FACTORY_ADDR).build(_user);
            return address(newProxy);
        }
    }


}