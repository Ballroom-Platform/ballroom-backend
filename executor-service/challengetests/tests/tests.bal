import ballerina/test;

@test:Config {
    dataProvider: data,
    groups: ["sample"]
}
function allocateCubiclesTest(int[] input, int[] expected) returns error? {
    test:assertTrue(allocateCubicles(input) == expected);
}
