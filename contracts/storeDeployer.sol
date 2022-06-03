// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./interfaces/IStoreDeployer.sol";
import "./store.sol";
import "./libraries/sharedStructs.sol";

contract StoreDeployer is IStoreDeployer {
    struct StoreParameters {
        address controller;
        address owner;
    }

    StoreParameters public override storeParameters;

    function deployStore(address controller, address owner)
        internal
        returns (address store)
    {
        storeParameters = StoreParameters({
            controller: controller,
            owner: owner
        });
        store = address(
            new Store{salt: keccak256(abi.encode(controller, owner))}()
        );
        delete storeParameters;
    }
}
