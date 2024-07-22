// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library GaussianCDF {
    int256 constant X_BOUNDARY_LOW = -1e5 * 1e18;
    int256 constant X_BOUNDARY_HIGH = 1e5 * 1e18;
    int256 constant MU_BOUNDARY_LOW = -1e2 * 1e18;
    int256 constant MU_BOUNDARY_HIGH = 1e2 * 1e18;
    int256 constant SIGMA_BOUNDARY_LOW = 0;
    int256 constant SIGMA_BOUNDARY_HIGH = 1 * 1e18;
    int256 constant T_BOUNDARY_LOW = -4 * 1e18;
    int256 constant T_BOUNDARY_HIGH = 4 * 1e18;

    int256 constant ONE = 1e18;
    int256 constant TWO = 2e18;
    int256 constant SQRT_TWO = 1414213562373095049;

    int256 constant A1 = 705230784e7;
    int256 constant A2 = 422820123e7;
    int256 constant A3 = 92705272e7;
    int256 constant A4 = 1520143e7;
    int256 constant A5 = 2765672e7;
    int256 constant A6 = 430638e7;

    function gaussianCDF(int256 x, int256 mu, int256 sigma) public pure returns (int256) {
        assembly {
            if or(slt(x, X_BOUNDARY_LOW), sgt(x, X_BOUNDARY_HIGH)) {
                revert(0, 0)
            }
            if or(slt(mu, MU_BOUNDARY_LOW), sgt(mu, MU_BOUNDARY_HIGH)) {
                revert(0, 0)
            }
            if or(iszero(sgt(sigma, SIGMA_BOUNDARY_LOW)), sgt(sigma, SIGMA_BOUNDARY_HIGH)) {
                revert(0, 0)
            }

            let z := sdiv(mul(sdiv(mul(sub(x, mu), ONE), sigma), ONE), SQRT_TWO)

            if slt(z, T_BOUNDARY_LOW) {
                mstore(0x40, 0)
                return(0x40, 32)
            }
            if sgt(z, T_BOUNDARY_HIGH) {
                mstore(0x40, ONE)
                return(0x40, 32)
            }

            let absZ := z
            if slt(z, 0) { absZ := sub(0, z) }

            let absZ2 := sdiv(mul(absZ, absZ), ONE)
            let absZ3 := sdiv(mul(absZ2, absZ), ONE)
            let absZ4 := sdiv(mul(absZ3, absZ), ONE)
            let absZ5 := sdiv(mul(absZ4, absZ), ONE)
            let absZ6 := sdiv(mul(absZ5, absZ), ONE)

            let sum := add(ONE, sdiv(mul(A1, absZ), ONE))
            sum := add(sum, sdiv(mul(A2, absZ2), ONE))
            sum := add(sum, sdiv(mul(A3, absZ3), ONE))
            sum := add(sum, sdiv(mul(A4, absZ4), ONE))
            sum := add(sum, sdiv(mul(A5, absZ5), ONE))
            sum := add(sum, sdiv(mul(A6, absZ6), ONE))

            let sum16 := sum
            for { let i := 0 } lt(i, 15) { i := add(i, 1) } {
                sum16 := sdiv(mul(sum16, sum), ONE)
            }

            let erfApprox := sub(ONE, sdiv(ONE, sum16))
            
            if slt(z, 0) {
                erfApprox := sub(0, erfApprox)
            }

            let cdf := sdiv(add(ONE, erfApprox), 2)

            mstore(0x40, cdf)
            return(0x40, 32)
        }
    }
}
