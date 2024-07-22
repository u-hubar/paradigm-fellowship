// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {GaussianCDF} from "../src/GaussianCDF.sol";

contract GaussianCDFTest is Test {
    struct TestCase {
        int256 estimatedCDF;
        int256 expectedCDF;
        int256 mu;
        int256 sigma;
        int256 x;
    }

    function readTestData() internal view returns (TestCase[] memory) {
        string memory path = "data/test_data.json";
        string memory jsonData = vm.readFile(path);
        bytes memory rawJson = vm.parseJson(jsonData);
        return abi.decode(rawJson, (TestCase[]));
    }

    function testGaussianCDF() public view {
        TestCase[] memory testCases = readTestData();

        for (uint256 i = 0; i < testCases.length; i++) {
            int256 result = GaussianCDF.gaussianCDF(testCases[i].x, testCases[i].mu, testCases[i].sigma);

            uint256 tolerance = 1e10; // 1e-8 in 18 decimal fixed-point
            assertApproxEqAbs(
                result,
                testCases[i].expectedCDF,
                tolerance,
                "Gaussian CDF result is not within the expected tolerance"
            );
        }
    }

    function testOutOfBounds() public {
        vm.expectRevert();
        GaussianCDF.gaussianCDF(-1e24 * 1e18, 0, 1e19 * 1e18);

        vm.expectRevert();
        GaussianCDF.gaussianCDF(1e24 * 1e18, 0, 1e19 * 1e18);

        vm.expectRevert();
        GaussianCDF.gaussianCDF(0, -1e21 * 1e18, 1e19 * 1e18);

        vm.expectRevert();
        GaussianCDF.gaussianCDF(0, 1e21 * 1e18, 1e19 * 1e18);

        vm.expectRevert();
        GaussianCDF.gaussianCDF(0, 0, 0);

        vm.expectRevert();
        GaussianCDF.gaussianCDF(0, 0, 1e20 * 1e18);
    }
}
