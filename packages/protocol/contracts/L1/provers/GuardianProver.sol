// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.20;

import "../tiers/ITierProvider.sol";
import "./Guardians.sol";

/// @title GuardianProver
contract GuardianProver is Guardians {
    error PROVING_FAILED();

    /// @notice Initializes the contract with the provided address manager.
    /// @param _addressManager The address of the address manager contract.
    function init(address _addressManager) external initializer {
        _Essential_init(_addressManager);
    }

    /// @dev Called by guardians to approve a guardian proof
    function approve(
        TaikoData.BlockMetadata calldata meta,
        TaikoData.Transition calldata tran,
        TaikoData.TierProof calldata proof
    )
        external
        whenNotPaused
        nonReentrant
        returns (bool approved)
    {
        if (proof.tier != LibTiers.TIER_GUARDIAN) revert INVALID_PROOF();
        approved = approve(meta.id, keccak256(abi.encode(meta, tran)));

        if (approved) {
            bytes memory data = abi.encodeWithSignature(
                "proveBlock(uint64,bytes)", meta.id, abi.encode(meta, tran, proof)
            );

            (bool success,) = resolve("taiko", false).call(data);
            if (!success) revert PROVING_FAILED();
        }
    }
}
