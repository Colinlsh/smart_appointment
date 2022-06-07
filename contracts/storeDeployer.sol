// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./interfaces/IStoreDeployer.sol";
import "./store.sol";

contract StoreDeployer is IStoreDeployer {
    struct StoreParameters {
        address factory;
        address owner;
        address token;
        uint8 storeIndex;
    }

    StoreParameters public override storeParameters;

    function deployStore(
        address factory,
        address owner,
        address token,
        uint8 storeIndex
    ) internal returns (address store) {
        storeParameters = StoreParameters({
            factory: factory,
            owner: owner,
            token: token,
            storeIndex: storeIndex
        });
        store = address(
            new Store{
                salt: keccak256(abi.encode(factory, owner, token, storeIndex))
            }()
        );
        delete storeParameters;
    }
}
