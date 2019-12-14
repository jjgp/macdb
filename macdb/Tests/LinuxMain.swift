import XCTest

import ProviderTests

var tests = [XCTestCaseEntry]()
tests += WindowProviderTests.allTests()
XCTMain(tests)
