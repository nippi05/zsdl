const std = @import("std");
const testing = std.testing;
const zsdl = @import("zsdl");
const Guid = zsdl.Guid;

test "Guid.toString formats GUID correctly" {
    // Create a known GUID
    var guid = Guid{ .data = [_]u8{
        0x01, 0x23, 0x45, 0x67,
        0x89, 0xAB, 0xCD, 0xEF,
        0xFE, 0xDC, 0xBA, 0x98,
        0x76, 0x54, 0x32, 0x10,
    } };

    // Convert to string
    const str = try guid.toString();

    // Verify the string format (should be 32 hex characters)
    try testing.expectEqualStrings("0123456789abcdeffedcba9876543210", str[0..32]);
}

test "Guid.fromString parses string correctly" {
    // Create a GUID from a string
    const guid_str: [:0]const u8 = "0123456789abcdeffedcba9876543210";
    const guid = Guid.fromString(guid_str);

    // Create the expected GUID data
    const expected_data = [_]u8{
        0x01, 0x23, 0x45, 0x67,
        0x89, 0xAB, 0xCD, 0xEF,
        0xFE, 0xDC, 0xBA, 0x98,
        0x76, 0x54, 0x32, 0x10,
    };

    // Verify the GUID data matches
    try testing.expectEqualSlices(u8, &expected_data, &guid.data);
}

test "Guid round-trip conversion" {
    // Start with a GUID
    var original_guid = Guid{ .data = [_]u8{
        0x12, 0x34, 0x56, 0x78,
        0x9A, 0xBC, 0xDE, 0xF0,
        0x0F, 0xED, 0xCB, 0xA9,
        0x87, 0x65, 0x43, 0x21,
    } };

    // Convert to string
    const str = try original_guid.toString();

    // Parse back to GUID
    const parsed_guid = Guid.fromString(str[0..32] ++ "\x00");

    // Verify the data matches
    try testing.expectEqualSlices(u8, &original_guid.data, &parsed_guid.data);
}

test "Guid equality" {
    const guid1 = Guid{ .data = [_]u8{
        0x01, 0x23, 0x45, 0x67,
        0x89, 0xAB, 0xCD, 0xEF,
        0xFE, 0xDC, 0xBA, 0x98,
        0x76, 0x54, 0x32, 0x10,
    } };

    const guid2 = Guid{ .data = [_]u8{
        0x01, 0x23, 0x45, 0x67,
        0x89, 0xAB, 0xCD, 0xEF,
        0xFE, 0xDC, 0xBA, 0x98,
        0x76, 0x54, 0x32, 0x10,
    } };

    const guid3 = Guid{ .data = [_]u8{
        0x01, 0x23, 0x45, 0x67,
        0x89, 0xAB, 0xCD, 0xEF,
        0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08,
    } };

    try testing.expectEqual(true, std.mem.eql(u8, &guid1.data, &guid2.data));
    try testing.expectEqual(false, std.mem.eql(u8, &guid1.data, &guid3.data));
}

test "Create random GUID" {
    // This test shows how to generate a random GUID
    var random = std.Random.DefaultPrng.init(0);
    var data: [16]u8 = undefined;
    random.random().bytes(&data);

    const guid = Guid{ .data = data };
    const str = try guid.toString();

    try testing.expect(str.len == 33);
    try testing.expect(str[32] == 0); // Null terminator
}
