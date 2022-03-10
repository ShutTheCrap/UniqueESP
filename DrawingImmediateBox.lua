local client = game.Players.LocalPlayer;
local character = client.Character;

local parts = { client.Character.Head, client.Character.HumanoidRootPart, client.Character['Left Arm'], client.Character['Left Leg'], client.Character['Right Arm'], client.Character['Right Leg'], }

DrawingImmediate.GetPaint(1):Connect(function()
    for i = #parts, 1, -1 do
        local obj = parts[i]
        if (not obj:IsDescendantOf(workspace)) then
            table.remove(parts, i)
        end
    end

    local box, size = getboundingbox(parts, workspace.CurrentCamera.CFrame)
    size /= 1.75

    local screenPoints = worldtoscreen({
        (box * CFrame.new(-size.X, size.Y, 0)).p,
        (box * CFrame.new(size.X, -size.Y, 0)).p
    })

    local top, bottom = screenPoints[1], screenPoints[2]
    local tX, tY = math.floor(top.X), math.floor(top.Y);
    local bX, bY = math.floor(bottom.X), math.floor(bottom.Y);

    local size = Vector2.new(math.floor(bX - tX), math.floor(bY - tY))
    local top = Vector2.new(top.X, top.Y)

    local hpBar = top - Vector2.new(7, 1)

    DrawingImmediate.Rectangle(top, size, Color3.new(1, 1, 1), 1, 0, 1)
    DrawingImmediate.Rectangle(top - Vector2.new(1, 1), size + Vector2.new(2, 2), Color3.new(), 1, 0, 1)
    DrawingImmediate.Rectangle(top + Vector2.new(1, 1), size - Vector2.new(2, 2), Color3.new(), 1, 0, 1)

    DrawingImmediate.Rectangle(hpBar, Vector2.new(4, (bY - tY) + 2), Color3.new(0, 0, 0), 1, 0, 1)
    DrawingImmediate.FilledRectangle(hpBar + Vector2.new(1, 1), (Vector2.new(4, (bY - tY) + 2) - Vector2.new(2, 2)), Color3.fromRGB(0,255,140), 1, 0)
end)
