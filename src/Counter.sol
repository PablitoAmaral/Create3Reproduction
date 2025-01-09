// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console} from "forge-std/Test.sol";

contract Counter {
    uint256 public number;
    bytes32 internal constant PROXY_INITCODE_HASH =
        0x21c35dbe1b344a2488cf3321d6ce542f8e9f305544ff09e4993a62319a497c1f;

    function predictDeterministicAddress(
        bytes32 salt,
        address deployer
    ) internal pure returns (address deployed) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, deployer) // Store `deployer`.
            mstore8(0x0b, 0xff) // Store the prefix.
            mstore(0x20, salt) // Store the salt.
            mstore(0x40, PROXY_INITCODE_HASH) // Store the bytecode hash.

            mstore(0x14, keccak256(0x0b, 0x55)) // Store the proxy's address.
            mstore(0x40, m) // Restore the free memory pointer.
            // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01).
            // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex).
            mstore(0x00, 0xd694)
            mstore8(0x34, 0x01) // Nonce of the proxy contract (1).
            deployed := keccak256(0x1e, 0x17)
        }
    }

    function test() public returns (address) {
        bytes memory a = abi.encode(
            0,
            uint32(5),
            0x779877A7B0D9E8603169DdbD7836e478b4624789
        );
        console.logBytes(a);

        bytes32 wrappedTokenSalt = keccak256(a);

        address expectedAddres = predictDeterministicAddress(
            wrappedTokenSalt,
            0x7B7872fEc715C787A1BE3f062AdeDc82b3B06144
        );
        return expectedAddres;
    }
}
