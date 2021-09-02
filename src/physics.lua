local m = {}

function m.testRectangle(x1, y1, x2, y2, w2, h2)
    return x1 <= x2 + w2 and x1 >= x2 and y1 <= y2 + h2 and y1 >= y2;
end

function m.testCircle(x1, y1, r1, x2, y2, r2)
    local dX = x1 - x2;
    local dY = y1 - y2;
    return dX * dX + dY * dY <= (r1 + r2) * (r1 + r2);
end

return m;