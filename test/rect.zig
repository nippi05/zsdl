const std = @import("std");
const testing = std.testing;
const zsdl = @import("zsdl");
const rect = zsdl.rect;

test "Rect.toFRect" {
    const rectangle = rect.Rect{ .x = 10, .y = 20, .w = 30, .h = 40 };
    const frect = rectangle.toFRect();

    try testing.expectEqual(@as(f32, 10.0), frect.x);
    try testing.expectEqual(@as(f32, 20.0), frect.y);
    try testing.expectEqual(@as(f32, 30.0), frect.w);
    try testing.expectEqual(@as(f32, 40.0), frect.h);
}

test "Rect.empty" {
    const empty_rect = rect.Rect{ .x = 0, .y = 0, .w = 0, .h = 0 };
    const valid_rect = rect.Rect{ .x = 10, .y = 10, .w = 10, .h = 10 };
    const negative_rect = rect.Rect{ .x = 10, .y = 10, .w = -5, .h = 10 };

    try testing.expect(empty_rect.empty());
    try testing.expect(!valid_rect.empty());
    try testing.expect(negative_rect.empty());
}

test "Rect.equals" {
    const rect1 = rect.Rect{ .x = 10, .y = 20, .w = 30, .h = 40 };
    const rect2 = rect.Rect{ .x = 10, .y = 20, .w = 30, .h = 40 };
    const rect3 = rect.Rect{ .x = 10, .y = 20, .w = 30, .h = 50 };

    try testing.expect(rect1.equals(&rect2));
    try testing.expect(!rect1.equals(&rect3));
}

test "Rect.hasIntersection" {
    const rect1 = rect.Rect{ .x = 0, .y = 0, .w = 10, .h = 10 };
    const rect2 = rect.Rect{ .x = 5, .y = 5, .w = 10, .h = 10 };
    const rect3 = rect.Rect{ .x = 20, .y = 20, .w = 10, .h = 10 };
    const rect4 = rect.Rect{ .x = 10, .y = 10, .w = 10, .h = 10 }; // Touches at a corner

    try testing.expect(rect1.hasIntersection(&rect2));
    try testing.expect(!rect1.hasIntersection(&rect3));
    try testing.expect(!rect1.hasIntersection(&rect4)); // SDL considers touching points not an intersection
}

test "Rect.getIntersection" {
    const rect1 = rect.Rect{ .x = 0, .y = 0, .w = 10, .h = 10 };
    const rect2 = rect.Rect{ .x = 5, .y = 5, .w = 10, .h = 10 };
    const rect3 = rect.Rect{ .x = 20, .y = 20, .w = 10, .h = 10 };

    // Intersecting rectangles should return a value
    if (rect1.getIntersection(&rect2)) |intersection| {
        try testing.expectEqual(@as(c_int, 5), intersection.x);
        try testing.expectEqual(@as(c_int, 5), intersection.y);
        try testing.expectEqual(@as(c_int, 5), intersection.w);
        try testing.expectEqual(@as(c_int, 5), intersection.h);
    } else {
        try testing.expect(false);
    }

    // Non-intersecting rectangles should return null
    const non_intersection = rect1.getIntersection(&rect3);
    try testing.expect(non_intersection == null);
}

test "Rect.getUnion" {
    const rect1 = rect.Rect{ .x = 0, .y = 0, .w = 10, .h = 10 };
    const rect2 = rect.Rect{ .x = 5, .y = 5, .w = 10, .h = 10 };

    const union_rect = try rect1.getUnion(&rect2);
    try testing.expectEqual(@as(c_int, 0), union_rect.x);
    try testing.expectEqual(@as(c_int, 0), union_rect.y);
    try testing.expectEqual(@as(c_int, 15), union_rect.w);
    try testing.expectEqual(@as(c_int, 15), union_rect.h);
}

test "Rect.getLineIntersection" {
    const rectangle = rect.Rect{ .x = 0, .y = 0, .w = 10, .h = 10 };

    // Line completely inside the rectangle - just test intersection
    var x1: c_int = 2;
    var y1: c_int = 2;
    var x2: c_int = 8;
    var y2: c_int = 8;
    try testing.expect(rectangle.getLineIntersection(&x1, &y1, &x2, &y2));
    // SDL may modify coordinates even for internal lines, so don't test specific values

    // Line completely outside the rectangle
    x1 = 20;
    y1 = 20;
    x2 = 30;
    y2 = 30;
    try testing.expect(!rectangle.getLineIntersection(&x1, &y1, &x2, &y2));

    // Line that crosses the rectangle
    x1 = -5;
    y1 = 5;
    x2 = 15;
    y2 = 5;
    try testing.expect(rectangle.getLineIntersection(&x1, &y1, &x2, &y2));

    // Check if coordinates are modified for the crossing line
    try testing.expectEqual(@as(c_int, 0), x1); // Clipped to rectangle boundary
    try testing.expectEqual(@as(c_int, 5), y1);
    try testing.expectEqual(@as(c_int, 10), x2); // Clipped to rectangle boundary
    try testing.expectEqual(@as(c_int, 5), y2);
}

test "FRect.empty" {
    const empty_rect = rect.FRect{ .x = 0, .y = 0, .w = 0, .h = 0 };
    const valid_rect = rect.FRect{ .x = 10, .y = 10, .w = 10, .h = 10 };
    const negative_rect = rect.FRect{ .x = 10, .y = 10, .w = -5, .h = 10 };

    try testing.expect(empty_rect.empty());
    try testing.expect(!valid_rect.empty());
    try testing.expect(negative_rect.empty());
}

test "FRect.equalsEpsilon" {
    const rect1 = rect.FRect{ .x = 10.0, .y = 20.0, .w = 30.0, .h = 40.0 };
    const rect2 = rect.FRect{ .x = 10.001, .y = 20.001, .w = 30.001, .h = 40.001 };
    const rect3 = rect.FRect{ .x = 10.1, .y = 20.0, .w = 30.0, .h = 40.0 };

    try testing.expect(rect1.equalsEpsilon(&rect2, 0.01));
    try testing.expect(!rect1.equalsEpsilon(&rect3, 0.01));
}

test "FRect.equals" {
    const rect1 = rect.FRect{ .x = 10.0, .y = 20.0, .w = 30.0, .h = 40.0 };
    const rect2 = rect.FRect{ .x = 10.0, .y = 20.0, .w = 30.0, .h = 40.0 };
    const rect3 = rect.FRect{ .x = 10.0, .y = 20.0, .w = 30.0, .h = 40.1 };

    try testing.expect(rect1.equals(&rect2));
    try testing.expect(!rect1.equals(&rect3));
}

test "FRect.hasIntersection" {
    const rect1 = rect.FRect{ .x = 0, .y = 0, .w = 10, .h = 10 };
    const rect2 = rect.FRect{ .x = 5, .y = 5, .w = 10, .h = 10 };
    const rect3 = rect.FRect{ .x = 20, .y = 20, .w = 10, .h = 10 };

    try testing.expect(rect1.hasIntersection(&rect2));
    try testing.expect(!rect1.hasIntersection(&rect3));
}

test "FRect.getIntersection" {
    const rect1 = rect.FRect{ .x = 0, .y = 0, .w = 10, .h = 10 };
    const rect2 = rect.FRect{ .x = 5, .y = 5, .w = 10, .h = 10 };
    const rect3 = rect.FRect{ .x = 20, .y = 20, .w = 10, .h = 10 };

    // Intersecting rectangles should return a value
    if (rect1.getIntersection(&rect2)) |intersection| {
        try testing.expectEqual(@as(f32, 5), intersection.x);
        try testing.expectEqual(@as(f32, 5), intersection.y);
        try testing.expectEqual(@as(f32, 5), intersection.w);
        try testing.expectEqual(@as(f32, 5), intersection.h);
    } else {
        try testing.expect(false);
    }

    // Non-intersecting rectangles should return null
    const non_intersection = rect1.getIntersection(&rect3);
    try testing.expect(non_intersection == null);
}

test "FRect.getUnion" {
    const rect1 = rect.FRect{ .x = 0, .y = 0, .w = 10, .h = 10 };
    const rect2 = rect.FRect{ .x = 5, .y = 5, .w = 10, .h = 10 };

    const union_rect = try rect1.getUnion(&rect2);
    try testing.expectEqual(@as(f32, 0), union_rect.x);
    try testing.expectEqual(@as(f32, 0), union_rect.y);
    try testing.expectEqual(@as(f32, 15), union_rect.w);
    try testing.expectEqual(@as(f32, 15), union_rect.h);
}

test "FRect.getLineIntersection" {
    const rectangle = rect.FRect{ .x = 0, .y = 0, .w = 10, .h = 10 };

    // Line completely inside the rectangle - just test intersection
    var x1: f32 = 2;
    var y1: f32 = 2;
    var x2: f32 = 8;
    var y2: f32 = 8;
    try testing.expect(rectangle.getLineIntersection(&x1, &y1, &x2, &y2));
    // SDL may modify coordinates even for internal lines, so don't test specific values

    // Line completely outside the rectangle
    x1 = 20;
    y1 = 20;
    x2 = 30;
    y2 = 30;
    try testing.expect(!rectangle.getLineIntersection(&x1, &y1, &x2, &y2));

    // Line that crosses the rectangle
    x1 = -5;
    y1 = 5;
    x2 = 15;
    y2 = 5;
    try testing.expect(rectangle.getLineIntersection(&x1, &y1, &x2, &y2));

    // Check if coordinates are modified for the crossing line
    try testing.expectEqual(@as(f32, 0), x1); // Clipped to rectangle boundary
    try testing.expectEqual(@as(f32, 5), y1);
    try testing.expectEqual(@as(f32, 10), x2); // Clipped to rectangle boundary
    try testing.expectEqual(@as(f32, 5), y2);
}

test "Point.inRect" {
    const rectangle = rect.Rect{ .x = 10, .y = 10, .w = 20, .h = 20 };
    const inside_point = rect.Point{ .x = 15, .y = 15 };
    const outside_point = rect.Point{ .x = 5, .y = 5 };
    const edge_point = rect.Point{ .x = 10, .y = 15 }; // On the edge

    try testing.expect(inside_point.inRect(&rectangle));
    try testing.expect(!outside_point.inRect(&rectangle));
    try testing.expect(edge_point.inRect(&rectangle)); // SDL considers points on edge to be inside
}

test "FPoint.inRect" {
    const rectangle = rect.FRect{ .x = 10, .y = 10, .w = 20, .h = 20 };
    const inside_point = rect.FPoint{ .x = 15, .y = 15 };
    const outside_point = rect.FPoint{ .x = 5, .y = 5 };
    const edge_point = rect.FPoint{ .x = 10, .y = 15 }; // On the edge

    try testing.expect(inside_point.inRect(&rectangle));
    try testing.expect(!outside_point.inRect(&rectangle));
    try testing.expect(edge_point.inRect(&rectangle)); // SDL considers points on edge to be inside
}

test "getRectEnclosingPoints" {
    const points = [_]rect.Point{
        .{ .x = 0, .y = 0 },
        .{ .x = 10, .y = 0 },
        .{ .x = 0, .y = 10 },
        .{ .x = 10, .y = 10 },
    };

    // Without clip
    const no_clip_rect = try rect.getRectEnclosingPoints(&points, null);
    try testing.expectEqual(@as(c_int, 0), no_clip_rect.x);
    try testing.expectEqual(@as(c_int, 0), no_clip_rect.y);
    try testing.expectEqual(@as(c_int, 11), no_clip_rect.w); // Width includes the point at x=10
    try testing.expectEqual(@as(c_int, 11), no_clip_rect.h); // Height includes the point at y=10

    // With clip
    const clip_rect = rect.Rect{ .x = 5, .y = 5, .w = 10, .h = 10 };
    const clipped_rect = try rect.getRectEnclosingPoints(&points, &clip_rect);
    try testing.expectEqual(@as(c_int, 5), clipped_rect.x);
    try testing.expectEqual(@as(c_int, 5), clipped_rect.y);
    try testing.expectEqual(@as(c_int, 6), clipped_rect.w); // Only covers 5-10
    try testing.expectEqual(@as(c_int, 6), clipped_rect.h); // Only covers 5-10
}

test "getRectEnclosingPointsFloat" {
    const points = [_]rect.FPoint{
        .{ .x = 0, .y = 0 },
        .{ .x = 10, .y = 0 },
        .{ .x = 0, .y = 10 },
        .{ .x = 10, .y = 10 },
    };

    // Without clip
    const no_clip_rect = try rect.getRectEnclosingPointsFloat(&points, null);
    try testing.expectEqual(@as(f32, 0), no_clip_rect.x);
    try testing.expectEqual(@as(f32, 0), no_clip_rect.y);
    try testing.expectEqual(@as(f32, 10), no_clip_rect.w);
    try testing.expectEqual(@as(f32, 10), no_clip_rect.h);

    // With clip
    const clip_rect = rect.FRect{ .x = 5, .y = 5, .w = 10, .h = 10 };
    const clipped_rect = try rect.getRectEnclosingPointsFloat(&points, &clip_rect);
    try testing.expectEqual(@as(f32, 5), clipped_rect.x);
    try testing.expectEqual(@as(f32, 5), clipped_rect.y);
    try testing.expectEqual(@as(f32, 5), clipped_rect.w); // Only covers 5-10
    try testing.expectEqual(@as(f32, 5), clipped_rect.h); // Only covers 5-10
}
