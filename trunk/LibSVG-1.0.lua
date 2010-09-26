	--[[
Name: LibSVG-1.0
Revision: $Rev: @project-revision@ $
Author(s): Humbedooh
Description: SVG rendering library
Dependencies: LibStub, LibXML-1.0
License: MIT License
]]

-----------------------------------------------------------------------
if ( dofile ) then
    dofile([[..\LibStub\LibStub.lua]]);
	dofile([[..\LibXML-1.0\LibXML-1.0.lua]]);
end


local LIBSVG = "LibSVG-1.0"
local LIBSVG_MINOR = tonumber(("$Rev: 0@project-revision@ $"):match("(%d+)")) or 10000;
if not LibStub then error(LIBSVG .. " requires LibStub.") end
local LibSVG = LibStub:NewLibrary(LIBSVG, LIBSVG_MINOR)
local LibXML = LibStub("LibXML-1.0");
if not LibXML then error(LIBSVG .. " requires LibXML-1.0.") end

LibSVG.colors = {
        red       = {1,0,0,1},
        green     = {0,1,0,1},
        blue      = {0,0,1,1},
        yellow    = {1,1,0,1},
        white     = {1,1,1,1},
        black     = {0,0,0,1},
        purple    = {1,0,1,1},
        maroon    = {0.5,0,0,1},
    };

function LibSVG:New()
	local svg = {};
	svg.Parse = LibSVG.Parse;
	svg.Compile = LibSVG.Compile;
	svg.Render = LibSVG.Render;
	svg.RenderReal = LibSVG.RenderReal;
	svg.canvas = CreateFrame("Frame", nil);
	return svg;
end

function LibSVG:Parse(xml)
	local svg = self;
	local xml = xml;
	if ( type(xml) == "string" ) then xml = LibXML:Import(xml); end
	svg.xml = nil;
	if ( xml.class and xml.class:lower() == "svg" ) then
		svg.canvas:SetWidth( tonumber(xml.args.width) or 100);
		svg.canvas:SetHeight( tonumber(xml.args.height) or 100);
		svg.canvas:Show();
		svg.xml = xml;
	else
		for k, v in pairs(xml) do
			if ( type(v) == "table" and v.class:lower() == "svg" ) then
				svg.canvas:SetWidth( tonumber(v.args.width) or 100);
				svg.canvas:SetHeight( tonumber(v.args.height) or 100);
				svg.canvas:Show();
				svg.xml = v;
				break;
			end
		end
	end
end

function LibSVG:Compile(xml, group)
	local svg = self;
	if ( xml == nil ) then
		svg.CompiledData = { canvas = svg.canvas };
		svg.canvas:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
	end
	local xml = xml or svg.xml;
	svg.CompiledArgs = svg.CompiledArgs or 0;
	local group = group or svg.CompiledData;
	group.children = {};

	for i = 1, #xml do
		local el = xml[i];
        if ( type(el) == "table" ) then
			print(el, el.class, el.empty);
			local object = { };
            el.args = el.args or {};
            object.fillMatrix = {};
			object.lines = {};
            object.transformations = object.transformations or {};
			table.insert(group.children, object);
            if ( group.transformations ) then
                for k, v in pairs(group.transformations) do
                    table.insert(object.transformations, 1, v);
                end
            end
            if ( el.args.transform ) then
                local x, y = el.args.transform:match("translate%(([%d%.%-]+),([%d%.%-]+)%)");
                if ( x ) then
                    table.insert(object.transformations, 1, {'t', tonumber(x) or 0, tonumber(y) or 0});
                end
                local a,b,c,d,e,f = el.args.transform:match("matrix%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)%)");
                if ( a ) then
                    table.insert(object.transformations, 1, {'m', tonumber(a),tonumber(b),tonumber(c),tonumber(d),tonumber(e),tonumber(f)});
                end
            end
            object.stroke = (tonumber((el.args['stroke-width'] or ""):match("([%d%.%-]+)")) or 2)*20
            if ( el.args['stroke-width'] == "none" ) then object.stroke = 0; end
            object.color = LibSVG.ParseColor(el.args.stroke);
            object.fill = LibSVG.ParseColor(el.args.fill);
            if ( el.args.style ) then
                local style = el.args.style;
                if ( style:match("fill:([^;]+)") ) then
                    object.fill = LibSVG.ParseColor(style:match("fill:([^;]+)"));
                end
                if ( style:match("fill%-opacity:([^;]+)") ) then
                    if ( object.fill ) then
                        object.fill[4] = style:match("fill%-opacity:([^;]+)");
                    end
                end
                if ( style:match("stroke:([^;]+)") ) then
                    object.color = LibSVG.ParseColor(style:match("stroke:([^;]+)"));
                end
				if ( style:match("stroke%-opacity:([^;]+)") ) then
                    if ( object.color ) then
                        object.color[4] = style:match("stroke%-opacity:([^;]+)");
                    end
                end
                if ( style:match("stroke%-width:([%d%.%-]+)") ) then
                    if ( style:match("stroke%-width:(none)") ) then stroke = 0;
                    else
                        object.stroke = (tonumber(style:match("stroke%-width:([%d%.%-]+)")) or 2)*20
                    end
                end
            end
			object.color = object.color or group.color;
			object.stroke = object.stroke or group.stroke;
			object.fill = object.fill or group.fill;

			-- This is just debug stuff I use --
            --fill = nil;
            --object.color = LibSVG.colors.black;
            --object.stroke = 20;

            object.canvas = CreateFrame("Frame", svg.canvas);
            object.canvas:SetParent(svg.canvas);
            object.canvas:SetAllPoints();

            if ( el.class == "g" ) then
				print("entering group..");
                svg:Compile(el, object);
				print("exiting group..");
            elseif ( el.class == "circle" ) then
                local sX, sY = nil, nil;
                local radius = tonumber(el.args.r) or 10;
                local cX = tonumber(el.args.cx) or 0;
                local cY = tonumber(el.args.cy) or 0;

                for x = 0, radius do
                    local y = (x/radius) * math.pi * 2;
                    local eX = (math.sin(y) * radius) + cX;
                    local eY = (math.cos(y) * radius) + cY;
                    if ( sX and sY ) then
						table.insert(object.lines, {sX, sY, eX, eY});
						svg.CompiledArgs = svg.CompiledArgs + 1;
                    end
                    sX = eX;
                    sY = eY;
                end
            elseif ( el.class == "ellipse" ) then
                local sX, sY = nil, nil;
                local rX = tonumber(el.args.rx) or 10;
                local rY = tonumber(el.args.ry) or 10;
                local cX = tonumber(el.args.cx) or 0;
                local cY = tonumber(el.args.cy) or 0;
                local m = math.max(rX, rY);
                for n = 0, m do
                    local y = (n/m) * math.pi * 2;
                    local x = (n/m) * math.pi * 2;
                    local eX = (math.sin(y) * rX) + cX;
                    local eY = (math.cos(y) * rY) + cY;
                    if ( sX and sY ) then
						table.insert(object.lines, {sX, sY, eX, eY});
						svg.CompiledArgs = svg.CompiledArgs + 1;
                    end
                    sX = eX;
                    sY = eY;
                end
            elseif ( el.class == "rect" ) then
                local x = tonumber(el.args.x) or 0;
                local y = tonumber(el.args.y) or 0;
                local width = tonumber(el.args.width) or 1;
                local height = tonumber(el.args.height) or 1;
				table.insert(object.lines, {x, y, x+width, y});
				table.insert(object.lines, {x, y, x, y+height});
				table.insert(object.lines, {x+width, y, x+width, y+height});
				table.insert(object.lines, {x, y+height, x+width, y+height});
				svg.CompiledArgs = svg.CompiledArgs + 4;
            elseif ( el.class == "polygon" ) then
                local sX, sY = nil,nil;
                local fX, fY = nil, nil;
                local eX, eY = nil, nil;
                for x,y in (el.args.points or ""):gmatch("([%d%-%.]+),([%d%-%.]+)") do
                    eX = tonumber(x) or 0;
                    eY = tonumber(y) or 0;
                    if ( sX ~= nil ) then
						table.insert(object.lines, {sX, sY, eX, eY});
						svg.CompiledArgs = svg.CompiledArgs + 1;
                    end
                    sX = eX;
                    sY = eY;
                    if ( fX == nil ) then
                        fX = eX;
                        fY = eY;
                    end
                end
                if ( fX ~= nil and eX ~= nil ) then
                    LibSVG.DrawLine(canvas, fX, fY, eX, eY, stroke, color, el.transformations, el.fillMatrix);
                end

            elseif ( el.class == "polyline" ) then
                local sX, sY = nil,nil;
                local eX, eY = nil, nil;
                for x,y in (el.args.points or ""):gmatch("([%d%-%.]+),([%d%-%.]+)") do
                    eX = tonumber(x) or 0;
                    eY = tonumber(y) or 0;
                    if ( sX ~= nil ) then
						table.insert(object.lines, {sX, sY, eX, eY});
						svg.CompiledArgs = svg.CompiledArgs + 1;
                    end
                    sX = eX;
                    sY = eY;
                end
--[[            elseif ( el.class == "text" ) then
				sX = tonumber(el.args.x) or 0;
                sY = tonumber(el.args.y) or 0;
                if ( type(el.transformations) == "table" and #el.transformations ) then
                    for k, v in pairs(el.transformations) do
                        if ( v[1] == 't' ) then
                            sX, sY = sX + v[2], sY + v[3];
                        elseif ( v[1] == 'm' ) then
                            sX, sY = unpack(LibSVG.matrix(sX,sY, {v[2],v[3],v[4],v[5],v[6],v[7]}));
                        end
                    end
                end
                local caption = canvas:CreateFontString(nil, "DIALOG");
                caption:SetFontObject("SystemFont_Med1");
                caption:SetText("abcdABCD");
                local h = caption:GetStringHeight();
                caption:SetPoint("TOPLEFT", canvas, "TOPLEFT", sX, -(sY-h));
                local text = "";
                for k, v in pairs(el) do
                    if ( type(v) == "table" and v.class == "tspan" ) then
                        text = text .. LibSVG.renderText(v);
                    end
                end
                caption:SetText(text);
                caption:SetWidth(caption:GetStringWidth());
                caption:SetHeight(caption:GetStringHeight());
                print(caption:GetWidth(), caption:GetHeight(), sX, sY);
                caption:SetTextColor(unpack(fill));

                print("mooo");
      ]]    elseif ( el.class == "path" ) then
                el.args.d = (el.args.d or "y") .. " 0y0"; -- kludge
                local sX, sY = 0,0;
				local xX, xY = nil,nil;
                local fX, fY = nil,nil;
                for c, v in (el.args.d or ""):gmatch("(%a)([^%a]+)") do
                    local coords = {}; print(c);
                    local rel = false;
                    if ( c == string.lower(c) ) then    -- If relative coords are sent, translate them
                        rel = true;
                        c = string.upper(c);
                    end
                    v:gsub("([%d%-%.]+)([^%d%-%.]+)([%d%-%.]+)", function (x, _, y)
                        table.insert(coords, {tonumber(x),tonumber(y)});
                    end);

                    if ( c == "M" ) then
                        if ( rel ) then
                            sX = coords[1][1] + sX;
                            sY = coords[1][2] + sY;
                        else
                            sX = coords[1][1];
                            sY = coords[1][2];
                        end
                        fX = sX;
                        fY = sY;
						eX,eY = sX,sY;
						xX, xY = sX, sY;
						table.insert(object.lines, {sX-2,sY-2,sX+2,sY+2});
                        if ( #coords > 1 ) then
                            table.remove(coords, 1);
                            c = "L";
                        end
                    end
                    if ( c == "L" ) then
                        for k, v in pairs(coords) do
                            eX = v[1];
                            eY = v[2];
                            if ( rel ) then eX = sX + eX; eY = sY + eY;
                            end
							table.insert(object.lines, {sX, sY, eX, eY});
							svg.CompiledArgs = svg.CompiledArgs + 1;
                            sX = eX;
                            sY = eY;
                        end
					elseif ( c == "S" ) then
						c = "C";
						local dX, dY = 0, 0
						if ( xX and xY ) then
							dX, dY = sX-xX,sY-xY;
						end
						print("old point", xX, xY, "current", sX, sY, "reflected", sX+dX, sY+dY);
						if ( not rel ) then
							table.insert(coords, 1, {sX+dX, sY+dY});
						else
							table.insert(coords, 1, {dX, dY});
						end
					end
                    if ( c == "C" ) then
						print("coords", #coords);
                        for i = 0, math.floor((#coords/3)-1) do
                            local p = (i*3)+1;
                            local p0 = {sX,sY};
                            local p1 = coords[p];
                            local p2 = coords[p+1];
                            local p3 = coords[p+2];
                            if ( rel ) then
                                p1[1] = p1[1] + sX;
                                p1[2] = p1[2] + sY;
                                p2[1] = p2[1] + sX;
                                p2[2] = p2[2] + sY;
                                p3[1] = p3[1] + sX;
                                p3[2] = p3[2] + sY;
                            end



                            -- Number of traces equals the shortest distance between the farthest points.
                            local trace = 2 + math.min(
                                math.abs(math.max(p0[1],p1[1],p2[1],p3[1]) - math.min(p0[1],p1[1],p2[1],p3[1])),
                                math.abs(math.max(p0[2],p1[2],p2[2],p3[2]) - math.min(p0[2],p1[2],p2[2],p3[2]))
                            )/2;
                            for n = 1, trace do
                                local t = n / trace;
                                eX =
                                    ( math.pow(1-t, 3) * p0[1] ) +
                                    ( 3 * math.pow(1-t, 2) * t * p1[1] ) +
                                    ( 3 * (1-t) * math.pow(t,2) * p2[1] ) +
                                    ( math.pow(t, 3) * p3[1] )
                                    ;
                                eY =
                                    ( math.pow(1-t, 3) * p0[2] ) +
                                    ( 3 * math.pow(1-t, 2) * t * p1[2] ) +
                                    ( 3 * (1-t) * math.pow(t,2) * p2[2] ) +
                                    ( math.pow(t, 3) * p3[2] )
                                    ;
								table.insert(object.lines, {sX, sY, eX, eY});
								svg.CompiledArgs = svg.CompiledArgs + 1;
                                sX = eX;
                                sY = eY;
                            end
							xX, xY = p2[1], p2[2]; -- Set control points for shorthand bezier curves.
							sX, sY = p3[1], p3[2]
                        end
                    elseif ( c == "Q" ) then
                        for i = 0, math.floor((#coords/3)-1) do
                            local p = (i*4)+1;
                            local p0 = coords[p];
                            local p1 = coords[p+1];
                            local p2 = coords[p+2];
                            local trace = 10;
                            for n = 1, trace do
                                local t = n / trace;
                                eX = ( ( math.sqrt(1-t) * p0[1] ) + ( 2* (1-t) * t * p1[1] ) + (math.pow(t, 2)*p2[1]) );
                                eY = ( ( math.sqrt(1-t) * p0[2] ) + ( 2* (1-t) * t * p1[2] ) + (math.pow(t, 2)*p2[2]) );
								table.insert(object.lines, {sX, sY, eX, eY});
								svg.CompiledArgs = svg.CompiledArgs + 1;
                                sX = eX;
                                sY = eY;
                            end
                        end
                    elseif ( c == "A" ) then
                        for rX, rY, angle, large_arc_flag, sweep_flag, x, y in v:gmatch("([%d%-%.]+)[^%d%-%.]([%d%-%.]+)[^%d%-%.]+([%d%-%.]+)[^%d%-%.]+([%d%-%.]+)[^%d%-%.]+([%d%-%.]+)[^%d%-%.]+([%d%-%.]+)[^%d%-%.]+([%d%-%.]+)[^%d%-%.]+") do
                            if ( rel ) then
                                x = x + sX;
                                y = y + sY;
                            end
                            large_arc_flag = math.floor(large_arc_flag);
                            sweep_flag = math.floor(sweep_flag);
                            local x0,y0 = sX, sY;
                            local dx2, dy2 = (x0-x)/2, (y0-y)/2;
                            local theta = math.rad(angle);

                            -- Find x1,y1
                            local x1 = (math.cos(theta) * dx2 + math.sin(theta) * dy2);
                            local y1 = (-math.sin(theta) * dx2 + math.cos(theta) * dy2);

                            -- Radii check
                            local rx = math.abs(rX);
                            local ry = math.abs(rY);
                            local Prx = rx * rx;
                            local Pry = ry * ry;
                            local Px1 = x1 * x1;
                            local Py1 = y1 * y1;
                            local d = Px1 / Prx + Py1 / Pry;
                            if (d > 1) then
                                rx = math.abs((math.sqrt(d) * rx));
                                ry = math.abs((math.sqrt(d) * ry));
                                Prx = rx * rx;
                                Pry = ry * ry;
                            end

                            -- Find cx1, cy1
                            local sign = 1;
                            if (large_arc_flag == sweep_flag) then sign = -1; end
                            local coef = (sign * math.sqrt(((Prx * Pry) - (Prx * Py1) - (Pry * Px1)) / ((Prx * Py1) + (Pry * Px1))));
                            local cx1 = coef * ((rx * y1) / ry);
                            local cy1 = coef * -((ry * x1) / rx);

                            -- Find (cx, cy) from (cx1, cy1)
                            local sx2 = (x0 + x) / 2;
                            local sy2 = (y0 + y) / 2;
                            local cx = sx2 + (math.cos(theta) * cx1 - math.sin(theta) * cy1);
                            local cy = sy2 + (math.sin(theta) * cx1 + math.cos(theta) * cy1);

                            -- Compute the angleStart (theta1) and the angleExtent (dtheta)
                            local ux = (x1 - cx1) / rx;
                            local uy = (y1 - cy1) / ry;
                            local vx = (-x1 - cx1) / rx;
                            local vy = (-y1 - cy1) / ry;
                            local p, n;

                            n =  math.sqrt((ux * ux) + (uy * uy));
                            p = ux; -- (1 * ux) + (0 * uy)
                            sign = 1;
                            if (uy < 0) then sign = -1; end

                            local angleStart = math.deg(sign * math.acos(p / n));

                            n = math.sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy));
                            p = ux * vx + uy * vy;
                            sign = 1;
                            if (ux * vy - uy * vx < 0) then sign = -1; end

                            local angleExtent = math.deg(sign * math.acos(p / n));
                            if (sweep_flag == 0 and angleExtent > 0) then
                                angleExtent = angleExtent - 360;
                            elseif (sweep_flag == 1 and angleExtent < 0) then
                                    angleExtent = angleExtent + 360;
                            end
                            angleExtent = math.fmod(angleExtent, 360);
                            angleStart = math.fmod(angleStart, 360);
                            local m = math.max(rX, rY)/2;
                            for n = 1, m do
                                local a = math.rad(-angleStart - (angleExtent * (n/m)));
                                local eX = (math.cos(a) * rX) + cx;
                                local eY = -(math.sin(a) * rY) + cy;
                                if ( sX and sY ) then
									table.insert(object.lines, {sX, sY, eX, eY});
									svg.CompiledArgs = svg.CompiledArgs + 1;
                                end
                                sX = eX;
                                sY = eY;
                            end
                            sX = x;
                            sY = y;
                            eX = x;
                            eY = y;
                        end
                    elseif ( c == "Z" ) then
                        if ( fX and fY and eX and eY ) then
							table.insert(object.lines, {eX,eY,fX,fY});
							svg.CompiledArgs = svg.CompiledArgs + 1;
							print("Closing", eX,eY,fX,fY);
                        end

                        sX = eX;
                        sY = eY;
                        fX = sX;
                        fY = sY;
                    elseif ( c == "Y" ) then
                        sX = eX;
                        sY = eY;
                        fX = sX;
                        fY = sY;
						xX = nil;
						xY = nil;
                        break;
                    end
                end
            end
        end
    end
	return svg.CompiledArgs;
end

function LibSVG:Render()
	local svg = self;
	svg.ts = GetTime();
	svg.X = 1;
	local co = coroutine.create(function() svg:RenderReal(); end);
	svg.canvas:SetScript("OnUpdate",
		function()
			local ret = coroutine.resume(co);
			if ( ret == false ) then
				svg.canvas:SetScript("OnUpdate", nil);
			end
		end);
	return svg.canvas;
end

function LibSVG:RenderReal(object)
	local svg = self;
	local now = GetTime();
	svg.X = svg.X + 1;
	--svg.CompiledData = svg.CompiledData or {};
	local object = object or svg.CompiledData;
	object.canvas:SetFrameLevel(svg.X);
	if ( object.fill ) then
		object.fillMatrix = {};
	else
		object.fillMatrix = nil;
	end
	if ( object.lines ) then
		for key, line in pairs(object.lines) do
			LibSVG.DrawLine(object.canvas, tonumber(line[1]), tonumber(line[2]), tonumber(line[3]), tonumber(line[4]), object.stroke, object.color, object.transformations, object.fillMatrix);
		end
	end
	if ( object.fill ) then
		for k, v in pairs(object.fillMatrix) do
			if ( #v > 1 ) then
				table.sort(v);
				local prev = v[1];
				local n = 1;
				for i = 2, #v do
					if ( v[i] ~= prev ) then
						n = n + 1;
						if ( math.fmod(n,2) == 0 ) then
							LibSVG.DrawVLine(object.canvas,k,prev-1,v[i]+1,24, object.fill, "BACKGROUND");
						end
					end
					prev = v[i];
				end
			end
		end
	end
	if ( object.children ) then
		for key, child in pairs(object.children) do
			self:RenderReal(child);
		end
	end
	coroutine.yield();
end


function LibSVG.MatrixTransform(x,y,matrix)
    local nX = (x*matrix[1]) + (y*matrix[3]) + matrix[5];
    local nY = (x*matrix[2]) + (y*matrix[4]) + matrix[6];
    return {nX, nY};
end



-- Borrowed from LibGraph et al. (and heavilly modified)
local TAXIROUTE_LINEFACTOR = 128/126; -- Multiplying factor for texture coordinates
local TAXIROUTE_LINEFACTOR_2 = TAXIROUTE_LINEFACTOR / 2; -- Half of that

function LibSVG.DrawLine(C, sx, sy, ex, ey, w, color, transforms, fmatrix)
    if ( type(transforms) == "table" and #transforms ) then
        for k, v in pairs(transforms) do
            if ( v[1] == 't' ) then
                sx,sy,ex,ey = sx + v[2], sy + v[3], ex + v[2], ey + v[3];
            elseif ( v[1] == 'm' ) then
                sx, sy = unpack(LibSVG.MatrixTransform(sx,sy, {v[2],v[3],v[4],v[5],v[6],v[7]}));
                ex, ey = unpack(LibSVG.MatrixTransform(ex,ey, {v[2],v[3],v[4],v[5],v[6],v[7]}));
            end
        end
    end
    sy = C:GetHeight() - sy;
    ey = C:GetHeight() - ey;

    if ( sx < 0 ) then sx = math.floor(sx - 0.5); else sx = math.floor(sx + 0.5); end
    if ( ex < 0 ) then ex = math.floor(ex - 0.5); else ex = math.floor(ex + 0.5); end

    local relPoint = "BOTTOMLEFT"

    if sx==ex then
        return LibSVG.DrawVLine(C,sx,sy,ey,w, color)
    end
    local steps = math.abs(sx-ex);

	if ( fmatrix) then
		local py,px = nil, nil;
		for i = 0, steps do
			local x = sx + ((ex-sx) * (i / steps));
			local y = sy + ((ey-sy) * ( i / steps));
			if ( y < 0 ) then y = math.floor(y + 0.5); else y = math.floor(y - 0.5); end
			if ( not fmatrix[x] ) then fmatrix[x] = {}; end
			table.insert(fmatrix[x], y);
		end
	end
	if ( math.abs( sx - ex) < 1 and math.abs(sy - ey) < 1 ) then -- lines that don't go anywhere makes me a sad panda.
        return;
    end
    if not C.SVG then
        C.SVG={}
        C.SVG_Used={}
    end
    if not color or w == 0 then
        return;
    end

    -- Determine dimensions and center point of line
    local dx,dy = ex - sx, ey - sy;
    local cx,cy = (sx + ex) / 2, (sy + ey) / 2;

    -- Normalize direction if necessary
    if (dx < 0) then
        dx,dy = -dx,-dy;
    end

    -- Calculate actual length of line
    local l = sqrt((dx * dx) + (dy * dy));

    -- Sin and Cosine of rotation, and combination (for later)
    local s,c = -dy / l, dx / l;
    local sc = s * c;

    -- Calculate bounding box size and texture coordinates
    local Bwid, Bhgt, BLx, BLy, TLx, TLy, TRx, TRy, BRx, BRy;
	w = w/2;
    if (dy >= 0) then
        Bwid = ((l * c) - (w * s)) * TAXIROUTE_LINEFACTOR_2;
        Bhgt = ((w * c) - (l * s)) * TAXIROUTE_LINEFACTOR_2;
        BLx, BLy, BRy = (w / l) * sc, s * s, (l / w) * sc;
        BRx, TLx, TLy, TRx = 1 - BLy, BLy, 1 - BRy, 1 - BLx;
        TRy = BRx;
    else
        Bwid = ((l * c) + (w * s)) * TAXIROUTE_LINEFACTOR_2;
        Bhgt = ((w * c) + (l * s)) * TAXIROUTE_LINEFACTOR_2;
        BLx, BLy, BRx = s * s, -(l / w) * sc, 1 + (w / l) * sc;
        BRy, TLx, TLy, TRy = BLx, 1 - BRx, 1 - BLx, 1 - BLy;
        TRx = TLy;
    end

    -- Thanks Blizzard for adding (-)10000 as a hard-cap and throwing errors!
    -- The cap was added in 3.1.0 and I think it was upped in 3.1.1
    --  (way less chance to get the error)
    if TLx > 10000 then TLx = 10000 elseif TLx < -10000 then TLx = -10000 end
    if TLy > 10000 then TLy = 10000 elseif TLy < -10000 then TLy = -10000 end
    if BLx > 10000 then BLx = 10000 elseif BLx < -10000 then BLx = -10000 end
    if BLy > 10000 then BLy = 10000 elseif BLy < -10000 then BLy = -10000 end
    if TRx > 10000 then TRx = 10000 elseif TRx < -10000 then TRx = -10000 end
    if TRy > 10000 then TRy = 10000 elseif TRy < -10000 then TRy = -10000 end
    if BRx > 10000 then BRx = 10000 elseif BRx < -10000 then BRx = -10000 end
    if BRy > 10000 then BRy = 10000 elseif BRy < -10000 then BRy = -10000 end


    local T = tremove(C.SVG) or C:CreateTexture(nil, layer or "ARTWORK")
    T:SetTexture([[Interface\AddOns\l2r\Textures\line]]);
    tinsert(C.SVG_Used,T)

    T:SetDrawLayer(layer or "ARTWORK")

    T:SetVertexColor(color[1],color[2],color[3],color[4]);

    -- Set texture coordinates and anchors
    T:SetPoint("BOTTOMLEFT", C, relPoint, cx - Bwid, cy - Bhgt);
    T:SetPoint("TOPRIGHT",   C, relPoint, cx + Bwid, cy + Bhgt);
    T:SetTexCoord(TLx, TLy, BLx, BLy, TRx, TRy, BRx, BRy);
    T:Show()
    return T
end

function LibSVG.DrawVLine(C, x, sy, ey, w, color, layer)
	local relPoint = "BOTTOMLEFT"

	if not C.SVG_Lines then
		C.SVG_Lines={}
		C.SVG_Lines_Used={}
	end
    if not color then
        return;
    end

	local T = tremove(C.SVG_Lines) or C:CreateTexture(nil, layer or "ARTWORK")
    T:SetTexture([[Interface\AddOns\l2r\Textures\line]]);
    tinsert(C.SVG_Lines_Used,T)

	T:SetDrawLayer(layer or "ARTWORK")

	T:SetVertexColor(color[1],color[2],color[3],color[4]);

	if sy>ey then
		sy, ey = ey, sy
	end

	-- Set texture coordinates and anchors
	T:ClearAllPoints();
	T:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1);
	T:SetPoint("BOTTOMLEFT", C, relPoint, x-w/2, sy);
	T:SetPoint("TOPRIGHT",   C, relPoint, x+w/2, ey);
	T:Show()
	return T
end

function LibSVG.DrawHLine(C, x, sy, ey, w, color, layer)
	local relPoint = "BOTTOMLEFT"

	if not C.SVG_Lines then
		C.SVG_Lines={}
		C.SVG_Lines_Used={}
	end
    if not color then
        return;
    end

	local T = tremove(C.SVG_Lines) or C:CreateTexture(nil, layer or "ARTWORK")
    T:SetTexture([[Interface\AddOns\l2r\Textures\line]]);
    tinsert(C.SVG_Lines_Used,T)


	T:SetDrawLayer(layer or "ARTWORK")

	T:SetVertexColor(color[1],color[2],color[3],color[4]);

	if sx>ex then
		sx, ex = ex, sx
	end

	-- Set texture coordinates and anchors
	T:ClearAllPoints();
	T:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1);
	T:SetPoint("BOTTOMLEFT", C, relPoint, sx, y-w/2);
	T:SetPoint("TOPRIGHT",   C, relPoint, ex, y+w/2);
	T:Show()
	return T
end

function LibSVG.ParseColor(color)
    if ( type(color) == "string" ) then
		print(color);
		color = color:gsub("%s", "");
        if ( color:sub(1,1) == "#" ) then
            local ret = {};
            if ( color:len() == 4 ) then
                string.gsub(color, "([0-9a-f])", function (x) table.insert(ret, tonumber(x, 16) / 15); end);
            else
                string.gsub(color, "([0-9a-fA-F][0-9a-fA-F])", function (x) table.insert(ret, tonumber(x, 16) / 255); end);
            end
            table.insert(ret, 1);
            return ret;
        elseif ( color:match("%((%d+),(%d+),(%d+)%)") ) then
            local ret = {color:match("%((%d+),(%d+),(%d+)%)")};
            table.insert(ret,1);
            return ret;
        elseif ( LibSVG.colors[color] ) then
            return LibSVG.colors[color];
        end
    end
    return nil;
end
