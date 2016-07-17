--CLIENT SCRIPT

xp = 0
returnxp = 0
xpneeded = 200
level = 1

function Round(num, idp)
	local mult = 10^(idp or 0)
	local out = math.floor(num * mult + 0.5) / mult
	if out - math.floor(out) == 0 then
		for i = 1, idp - 1 do
			out = out .. ".0"
		end
	end
	return out
end

net.Receive( "xp", function()
	level = net.ReadInt(32)
	xp = net.ReadInt(32)
	xpneeded = net.ReadInt(32)
	if Round((xp / xpneeded)*200,1) < 8 then
		returnxp = 8
	else
		returnxp = (xp/xpneeded)*200
	end

end )

timer.Create("xp", 1, 0, function()
	xp = xp+1
	if xp >= xpneeded then
		level = level + 1
		xp = 0
		xpneeded = xpneeded + 100
	end
	if (xp / xpneeded)*200 < 8 then
		returnxp = 8
	else
		returnxp = Round((xp/xpneeded)*200,1)
	end
end)

function Draw()
	draw.RoundedBox(4, ScrW() / 2 - 105, ScrH()-45, 210, 35, Color(0,0,0,100)) -- BACKGROUND BLACK
	draw.RoundedBox(4, ScrW() / 2 - 102, ScrH()-42, 204, 29, Color(0,190,0,100)) -- BACKGROUND GREEN
	draw.RoundedBox(4, ScrW() / 2 - 100, ScrH()-40, returnxp, 25, Color(50,255,50,100)) -- PROGRESS BAR 200 = 100%
	draw.DrawText("Level: " .. level, "BebasNeue", ScrW() / 2, ScrH()-44, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- X, Y, Width, Height, Color 
	draw.DrawText(Round((xp/xpneeded)*100, 2) .. "%", "BebasNeue", ScrW() / 2, ScrH()-29, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- X, Y, Width, Height, Color
end

hook.Add("HUDPaint", "Draw", Draw)