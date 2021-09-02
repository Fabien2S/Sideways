local m = {}

function m.moveTowards(x, y, targetX, targetY, maxSpeed)
    local dX = targetX - x;
    local dY = targetY - y;
    local d = (dX * dX + dY * dY);
    if (d == 0 or maxSpeed >= 0 and d <= maxSpeed * maxSpeed) then
        return targetX, targetY, true;
    end

    local distance = math.sqrt(d);
    local resultX = x + dX / distance * maxSpeed;
    local resultY = y + dY / distance * maxSpeed;
    return resultX, resultY, false;
end

return m;