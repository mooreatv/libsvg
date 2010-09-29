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
    _G.debugstack = function() return "AddOns\\Moo\\LibSVG-1.0.lua" end;
end

local TextureDirectory = "";
local LIBSVG = "LibSVG-1.0"
local LIBSVG_MINOR = tonumber(("$Rev: 0@project-revision@ $"):match("(%d+)")) or 10000;
if not LibStub then error(LIBSVG .. " requires LibStub.") end
local LibSVG = LibStub:NewLibrary(LIBSVG, LIBSVG_MINOR)
local LibXML = LibStub("LibXML-1.0");
if not LibXML then error(LIBSVG .. " requires LibXML-1.0.") end
LibSVG.line = "";
LibSVG.circle = "";
LibSVG.diamond = "";
do
    local path = string.match(debugstack(1,1,0), "AddOns\\(.+)LibSVG%-1%.0%.lua");
    if path then
        LibSVG.line = [[Interface\AddOns\]] .. path .. [[line]];
        LibSVG.circle = [[Interface\AddOns\]] .. path .. [[circle]];
        LibSVG.diamond = [[Interface\AddOns\]] .. path .. [[rect]];
    else
        error(LIBSVG.." cannot determine the folder it is located in because the path is too long and got truncated in the debugstack(1,1,0) function call")
    end
end


LibSVG.colors = {
        red       = {1,0,0,1},
        green     = {0,1,0,1},
        blue      = {0,0,1,1},
        orange    = {1,0.5,0,1},
        yellow    = {1,1,0,1},
        white     = {1,1,1,1},
        gray      = {0.5,0.5,0.5,1},
        black     = {0,0,0,1},
        purple    = {1,0,1,1},
        maroon    = {0.5,0,0,1},
        teal      = {0,1,1,1}
    };


function LibSVG:New()
    local svg = {};
    svg.detail = 1;
    svg.fill = true;
    svg.Parse = LibSVG.Parse;
    svg.Compile = LibSVG.Compile;
    svg.Render = LibSVG.Render;
    svg.RenderReal = LibSVG.RenderReal;
    svg.CompileDefs = LibSVG.CompileDefs;
    svg.DrawLine = LibSVG.DrawLine;
    svg.DrawVLine = LibSVG.DrawVLine;
    svg.DrawHLine = LibSVG.DrawHLine;
    svg.canvas = CreateFrame("Frame", nil);
    svg.SetDetail = LibSVG.SetDetail;
    return svg;
end

function LibSVG:Parse(xml)
    local svg = self;
    local xml = xml;
    if ( type(xml) == "string" ) then xml = LibXML:Import(xml); end
    svg.xml = nil;
    if ( xml.class and xml.class:lower() == "svg" ) then
        local x,p = (xml.args.width or "100px"):match("([%d%.%-]+)([%a]*)");
        if ( p == "cm" ) then x = x * 36; end
        svg.canvas:SetWidth(x);
        x,p = (xml.args.height or "100px"):match("([%d%.%-]+)([%a]*)");
        if ( p == "cm" ) then x = x * 36; end
        svg.canvas:SetHeight(x);
        svg.canvas:Show();
        svg.xml = xml;
    else
        for k, v in pairs(xml) do
            if ( type(v) == "table" and v.class:lower() == "svg" ) then
                local x,p = (v.args.width or "100px"):match("([%d%.%-]+)([%a]*)");
                if ( p == "cm" ) then x = x * 36; end
                svg.canvas:SetWidth(x);
                x,p = (v.args.height or "100px"):match("([%d%.%-]+)([%a]*)");
                if ( p == "cm" ) then x = x * 36; end
                svg.canvas:SetHeight(x);
                svg.canvas:Show();
                svg.xml = v;
                break;
            end
        end
    end
end

function LibSVG:CompileDefs(xml)
    local svg = self;
    svg.defs = svg.defs or {};
    for i = 1, #xml do
        local el = xml[i];
        local c = el.class:lower();
        if ( c == "lineargradient" or c == "radialgradient" ) then
            local def = { type = c, id = el.args.id, points = {} };
            for j = 1, #el do
                local arg = el[j];
                if ( arg.class == "stop" ) then
                    local x = {};
                    x.offset = tonumber(arg.args.offset) or 0;
                    if ( arg.args.style ) then
                        x.color = LibSVG.ParseColor(arg.args.style:match("stop%-color:([^;]+)"));
                        x.opacity = tonumber(arg.args.style:match("stop%-opacity:([^;]+)")) or 1;
                    end
                    table.insert(def.points, x);
                end
            end
            if ( el.args['xlink:href'] and el.args['xlink:href']:sub(1,1) == "#" ) then
                for n = 1, #svg.defs do
                    local link = svg.defs[n];
                    if ( link.id == el.args['xlink:href']:sub(2) ) then
                        def.points = link.points;
                        --print(def.id, "points to", link.id);
                        break;
                    end
                end
            end
            def.x1, def.y1, def.x2, def.y2 = tonumber(el.args.x1) or 0,tonumber(el.args.y1) or 0,tonumber(el.args.x2) or 0,tonumber(el.args.y2) or 0;
            table.insert(svg.defs, def);
            --print("Added definition:", def.id);
        end
    end
end

function LibSVG:SetDetail(detail, fill)
    self.detail = 100 / (tonumber(detail) or 100);
    if ( fill ~= nil ) then
        self.fill = fill;
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
            local object = { };
            el.args = el.args or {};
            object.tracePaths = {};
            object.lines = {};
            object.strings = {};
            object.transformations = object.transformations or {};
            table.insert(group.children, object);
            if ( group.transformations ) then
                for k, v in pairs(group.transformations) do
                    table.insert(object.transformations, v);
                end
            end
            if ( el.args.transform ) then
                for method, args in el.args.transform:gmatch("(%a+)%(([^%)]+)%)") do
                    local n = {};
                    for x in args:gmatch("([%d%.%-]+)") do
                        n[#n+1] = tonumber(x);
                    end
                    method = method:lower();
                    if ( method == "matrix" ) then
                        table.insert(object.transformations, { (n[1] or 0), (n[2] or 0), (n[3] or 0), (n[4] or 0), (n[5] or 0), (n[6] or 0)});
                    elseif ( method == "translate" ) then
                        table.insert(object.transformations, {1, 0, 0, 1, n[1] or 0, n[2] or 0});
                    elseif ( method == "scale" ) then
                        table.insert(object.transformations, {n[1], 0, 0, n[2], 0, 0});
                    elseif ( method == "rotate" ) then
                        local a, x, y = math.rad(n[1] or 0), n[2], n[3];
                        if ( not x or not y ) then
                            table.insert(object.transformations, {math.cos(a),math.sin(a),-math.sin(a),math.cos(a),0,0});
                        else
                            table.insert(object.transformations, {1, 0, 0, 1, (x or 0), (y or 0)});
                            table.insert(object.transformations, {math.cos(a),math.sin(a),-math.sin(a),math.cos(a),0,0});
                            table.insert(object.transformations, {1, 0, 0, 1, -(x or 0), -(y or 0)});
                        end
                    elseif ( method == "skewx" ) then
                        local a = math.rad(n[1] or 0);
                        table.insert(object.transformations, {1, 0, math.tan(a), 1, 0, 0});
                    elseif ( method == "skewy" ) then
                        local a = math.rad(n[1] or 0);
                        table.insert(object.transformations, {1, math.tan(a), 0, 1, 0, 0});
                    end
                end
            end
            object.stroke = (tonumber((el.args['stroke-width'] or ""):match("([%d%.%-]+)")) or 1)*1
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
                        object.stroke = (tonumber(style:match("stroke%-width:([%d%.%-]+)")) or 1)*1
                    end
                end
            end
            object.color = object.color or group.color;
            object.stroke = object.stroke or group.stroke;
            object.fill = object.fill or group.fill;

            -- This is just debug stuff I use --
            --object.fill = nil;
            --object.color = LibSVG.colors.black;
            --object.stroke = 2;

            object.canvas = CreateFrame("Frame", svg.canvas);
            object.canvas:SetParent(svg.canvas);
            object.canvas:SetAllPoints();

            if ( el.class == "defs" ) then
                self:CompileDefs(el);
            elseif ( el.class == "g" ) then
                svg:Compile(el, object);
            elseif ( el.class == "circle" ) then
                local sX, sY = nil, nil;
                local radius = tonumber(el.args.r) or 10;
                local cX = tonumber(el.args.cx) or 0;
                local cY = tonumber(el.args.cy) or 0;
                object.fillPath = {'c', cX, cY, radius};

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
                object.fillPath = {'e', cX, cY, rX, rY};
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
                object.fillPath = {'r', x, y, x+width, y+height};

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
                    table.insert(object.lines, {fX, fY, eX, eY});
                    svg.CompiledArgs = svg.CompiledArgs + 1;
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
            elseif ( el.class == "text" or el.class == "tspan" ) then
                local ax = (tonumber(el.args.x or object.x) or 0) + (tonumber(el.args.dx) or 0);
                local ay = (tonumber(el.args.y or object.y) or 0) + (tonumber(el.args.dy) or 0);
                local size = (tonumber(el.args['font-size']) or 12);
                local text = "";
                for n = 0, #el do
                    if ( type(el[n]) == "string" ) then
                        text = text .. el[n];
                        print(el[n]);
                    end
                end
                object.x = ax;
                object.y = ay;
                table.insert(object.strings, {ax, ay, size, text});
                svg:Compile(el, object); -- in case we have tspans inside
          elseif ( el.class == "path" ) then
                el.args.d = (el.args.d or "y") .. " 0y0"; -- kludge
                local sX, sY = 0,0;
                local xX, xY = nil,nil;
                local fX, fY = nil,nil;
                for c, v in (el.args.d or ""):gmatch("(%a)([^%a]+)") do
                    local coords = {};
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
                        --print("old point", xX, xY, "current", sX, sY, "reflected", sX+dX, sY+dY);
                        if ( not rel ) then
                            table.insert(coords, 1, {sX+dX, sY+dY});
                        else
                            table.insert(coords, 1, {dX, dY});
                        end
                    end
                    if ( c == "C" ) then
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
                            local trace = math.floor(2 + math.min(
                                math.abs(math.max(p0[1],p1[1],p2[1],p3[1]) - math.min(p0[1],p1[1],p2[1],p3[1])),
                                math.abs(math.max(p0[2],p1[2],p2[2],p3[2]) - math.min(p0[2],p1[2],p2[2],p3[2]))
                            )/svg.detail);
                            local pangle = nil;
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
                                local cangle = math.deg(math.atan((eY-sY)/(eX-sX)));
                                if ( pangle == nil or math.abs(pangle-cangle) > svg.detail or n == trace ) then
                                    table.insert(object.lines, {sX, sY, eX, eY});
                                    svg.CompiledArgs = svg.CompiledArgs + 1;
                                    sX = eX;
                                    sY = eY;
                                    pangle = cangle;
                                end
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
                            large_arc_flag = math.floor(tonumber(large_arc_flag));
                            sweep_flag = math.floor(tonumber(sweep_flag));
                            local x0,y0 = sX, sY;
                            local dx2, dy2 = (x0-x)/2, (y0-y)/2;
                            local theta = math.rad(tonumber(angle));

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

                            local angleStart = (sign * math.acos(p / n));

                            n = math.sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy));
                            p = ux * vx + uy * vy;
                            sign = 1;
                            if (ux * vy - uy * vx < 0) then sign = -1; end

                            local angleExtent = (sign * math.acos(p / n));
                            if (sweep_flag == 0 and angleExtent > 0) then
                                angleExtent = angleExtent - (math.pi*2);
                            elseif (sweep_flag == 1 and angleExtent < 0) then
                                    angleExtent = angleExtent + (math.pi*2);
                            end
                            angleExtent = math.fmod(angleExtent, math.pi*2);
                            angleStart = math.fmod(angleStart, math.pi*2);
                            local m = math.floor(math.max(rX, rY)/svg.detail)+1;
                            local pangle = nil;
                            for n = 1, m do
                                local a = (-angleStart - (angleExtent * n / m));
                                local eX = (math.cos(a) * rX) + cx;
                                local eY = -(math.sin(a) * rY) + cy;
                                local cangle = math.deg(math.atan((eY-sY)/(eX-sX)));
                                if ( pangle == nil or math.abs(pangle-cangle) > svg.detail or n == m ) then
                                    --if ( sX and sY ) then
                                        table.insert(object.lines, {sX, sY, eX, eY});
                                        svg.CompiledArgs = svg.CompiledArgs + 1;
                                    --end
                                    sX = eX;
                                    sY = eY;
                                    pangle = cangle;
                                end
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
                        --	print("Closing", eX,eY,fX,fY);
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

function LibSVG:Render(object)
    local svg = self;
    svg.ts = GetTime();
    svg.X = 1;
    local co = coroutine.create(function() svg:RenderReal(object); end);
    svg.canvas:SetScript("OnUpdate",
        function()
            local ret,err = coroutine.resume(co);
            --if ( err ) then print(ret, err); end
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
        object.tracePaths = {};
    else
        object.tracePaths = nil;
    end
    object.bbox = {0,0,1,1};
    if ( object.lines ) then
        local bbox = {0,0,0,0};
        for key, line in pairs(object.lines) do
            local ax,ay,bx,by = tonumber(line[1]), tonumber(line[2]), tonumber(line[3]), tonumber(line[4]);
            if ( ax < bbox[1] ) then bbox[1] = ax; end if ( ax > bbox[3] ) then bbox[3] = ax; end
            if ( bx < bbox[1] ) then bbox[1] = bx; end if ( bx > bbox[3] ) then bbox[3] = bx; end
            if ( ay < bbox[2] ) then bbox[2] = ay; end if ( ay > bbox[4] ) then bbox[4] = ay; end
            if ( by < bbox[2] ) then bbox[2] = by; end if ( by > bbox[4] ) then bbox[4] = by; end
            self:DrawLine(object.canvas, ax,ay,bx,by, object.stroke, object.color, object.transformations, object.tracePaths);
        end
        object.bbox = bbox;
    end
    if ( object.fill and svg.fill ) then
        local s = false;
        if ( object.fillPath ) then
            local f = object.fillPath;
            local C = object.canvas;
            local color = object.fill;
            if ( f[1] == 'r' ) then
                local ax,ay = LibSVG.transform(object.transformations, f[2], f[3]);
                local bx,by = LibSVG.transform(object.transformations, f[4], f[5]);
                local rotation = math.tan( ( bx-ax) / (by-ay) );
                if not C.SVG_Lines then C.SVG_Lines={} C.SVG_Lines_Used={} end
                local T = tremove(C.SVG_Lines) or C:CreateTexture(nil, "BACKGROUND");
                if ( math.abs(rotation) == 0 or math.abs(rotation) == ( math.pi/2) ) then
                    T:SetTexture([[Interface\BUTTONS\WHITE8X8]]);
                    tinsert(C.SVG_Lines_Used,T)
                    T:SetDrawLayer("BACKGROUND");
                    if ( not color.def ) then
                        T:SetVertexColor(color[1],color[2],color[3],color[4]);
                    else
                    end
                    T:ClearAllPoints();
                    T:SetTexCoord(0,1,0,1);
                    s = true;
                end
                T:SetPoint("TOPLEFT", C, "TOPLEFT", math.min(ax,bx), math.max(-ay,-by));
                T:SetPoint("BOTTOMRIGHT",   C, "TOPLEFT", math.max(ax,bx), math.min(-ay,-by));

                T:Show();
            elseif ( f[1] == 'c' ) then
                local cx, cy = f[2], f[3];
                local r = f[4];
                local ax,ay = LibSVG.transform(object.transformations, cx-r, cy-r);
                local bx,by = LibSVG.transform(object.transformations, cx+r, cy+r);
                if not C.SVG_Lines then C.SVG_Lines={} C.SVG_Lines_Used={} end
                local T = tremove(C.SVG_Lines) or C:CreateTexture(nil, "BACKGROUND");
                T:SetTexture(LibSVG.circle);
                tinsert(C.SVG_Lines_Used,T)
                T:SetDrawLayer("BACKGROUND");
                if ( not color.def ) then
                    T:SetVertexColor(color[1],color[2],color[3],color[4]);
                else
                end
                T:ClearAllPoints();
                T:SetTexCoord(0,1,0,1);
                T:SetPoint("TOPLEFT", C, "TOPLEFT", ax, -ay);
                T:SetPoint("BOTTOMRIGHT",   C, "TOPLEFT", bx, -by);
                T:Show();
                s = true;
            end
        end
        if ( s == false ) then
            for k, v in pairs(object.tracePaths) do
                if ( #v > 1 ) then
                    table.sort(v);
                    local prev = v[#v];
                    local n = 1;
                    for i = 1, #v-1 do
                        local Y = v[#v-i];
                    --    if ( Y ~= prev ) then
                            n = n + 1;
                            if ( math.fmod(n,2) == 0 ) then
                                self:DrawVLine(object.canvas,k,prev,Y,2, object.fill, "BACKGROUND", object.bbox);
                            end
                    --    end
                        prev = Y;
                    end
                end
            end
        end
    end
    if ( object.strings ) then
        for n = 1, #object.strings do
            local color = object.fill or object.color;
            local str = object.strings[n];
            local C = object.canvas;
            local ax,ay = LibSVG.transform(object.transformations, str[1], str[2]);
            local garble = string.format("%8x", math.random(time()));
            local stringFont = CreateFont("LibSVG-1.0_StringFont"..garble);
            stringFont:SetFont([[Fonts\FRIZQT__.TTF]],   str[3]);
            local caption = C:CreateFontString(nil, "DIALOG");
            caption:SetFontObject(stringFont);
            caption:SetText(str[4]);
            local h = caption:GetStringHeight();
            caption:SetPoint("TOPLEFT", C, "TOPLEFT", ax, -(ay-h));
            caption:SetWidth(caption:GetStringWidth());
            caption:SetHeight(caption:GetStringHeight());
            if ( color ) then
                caption:SetTextColor(color[1],color[2],color[3],color[4]);
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

function LibSVG.transform(t, x, y)
    if ( type(t) == "table" and #t ) then
        for n = 0, #t-1 do
            local v = t[#t-n];
            local nx = (x*v[1]) + (y*v[3]) + v[5];
            local ny = (x*v[2]) + (y*v[4]) + v[6];
            x,y = nx,ny;
        end
    end
    return x,y;
end


-- Borrowed from LibGraph et al. (and heavilly modified)

function LibSVG:DrawLine(C, sx, sy, ex, ey, w, color, transforms, tracePaths)
    sx,sy = LibSVG.transform(transforms, sx, sy);
    ex,ey = LibSVG.transform(transforms, ex, ey);

    sy = C:GetHeight() - sy;
    ey = C:GetHeight() - ey;

    if ( sx < 0 ) then sx = math.floor(sx - 0.5); else sx = math.floor(sx + 0.5); end
    if ( ex < 0 ) then ex = math.floor(ex - 0.5); else ex = math.floor(ex + 0.5); end

    local relPoint = "BOTTOMLEFT"
    local steps = math.abs(sx-ex);

    if ( tracePaths) then
        local py,px = nil, nil;
        for i = 1, steps do
            local x = sx + ((ex-sx) * (i / steps));
            local y = sy + ((ey-sy) * ( i / steps));
            --if ( y < 0 ) then y = math.floor(y + 0.5); else y = math.floor(y - 0.5); end
            if ( not tracePaths[x] ) then tracePaths[x] = {}; end
            table.insert(tracePaths[x], y);
        end
    end
--[[
    if ( sy < 0 ) then sy = math.floor(sy - 0.5); else sy = math.floor(sy + 0.5); end
    if ( ey < 0 ) then ey = math.floor(ey - 0.5); else ey = math.floor(ey + 0.5); end

    local relPoint = "BOTTOMLEFT"
    local steps = math.abs(sy-ey);

    if ( tracePaths) then
        for i = 1, steps do
            local x = sx + ((ex-sx) * (i / steps));
            local y = sy + ((ey-sy) * ( i / steps));
            --if ( y < 0 ) then y = math.floor(y + 0.5); else y = math.floor(y - 0.5); end
            if ( not tracePaths[y] ) then tracePaths[y] = {}; end
            table.insert(tracePaths[y], x);
        end
    end
]]
    if sx==ex then
        return self:DrawVLine(C,sx,sy,ey,w, color)
    end
    if sy==ey then
        return self:DrawHLine(C,sy,sx,ex,w, color, "ARTWORK", tracePaths)
    end
    w = w * 32 * (256/254);

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

    local Z = (256/255) / 2;
    -- Calculate actual length of line
    local l = sqrt((dx * dx) + (dy * dy));

    -- Sin and Cosine of rotation, and combination (for later)
    local s,c = -dy / l, dx / l;
    local sc = s * c;


    local Bwid, Bhgt, BLx, BLy, TLx, TLy, TRx, TRy, BRx, BRy;
    if (dy >= 0) then
        Bwid = ((l * c) - (w * s)) * Z;
        Bhgt = ((w * c) - (l * s)) * Z;
        BLx, BLy, BRy = (w / l) * sc, s * s, (l / w) * sc;
        BRx, TLx, TLy, TRx = 1 - BLy, BLy, 1 - BRy, 1 - BLx;
        TRy = BRx;
    else
        Bwid = ((l * c) + (w * s)) * Z;
        Bhgt = ((w * c) + (l * s)) * Z;
        BLx, BLy, BRx = s * s, -(l / w) * sc, 1 + (w / l) * sc;
        BRy, TLx, TLy, TRy = BLx, 1 - BRx, 1 - BLx, 1 - BLy;
        TRx = TLy;
    end


    local T = tremove(C.SVG) or C:CreateTexture(nil, "ARTWORK")
    T:SetTexture(LibSVG.line);
    tinsert(C.SVG_Used,T)

    T:SetDrawLayer(layer or "ARTWORK")
    T:SetVertexColor(color[1],color[2],color[3],color[4]);

    -- Set texture coordinates and anchors

    T:SetTexCoord(TLx, TLy, BLx, BLy, TRx, TRy, BRx, BRy);
    --local h = 128 / w;
    --T:SetTexCoord(1, 1, 0.5 - h, 0.5 + h);
    --T:SetRotation(math.tan(dy/dx));
    T:SetPoint("BOTTOMLEFT", C, relPoint, cx - Bwid, cy - Bhgt);
    T:SetPoint("TOPRIGHT",   C, relPoint, cx + Bwid, cy + Bhgt);

    T:Show()
    return T
end



function LibSVG:DrawVLine(C, x, sy, ey, w, color, layer, bbox)
    local relPoint = "BOTTOMLEFT"
    local svg = self;

    if not C.SVG_Lines then
        C.SVG_Lines={}
        C.SVG_Lines_Used={}
    end
    if not color then
        return;
    end
    --w = w * 32 * (256/254);
    local T = tremove(C.SVG_Lines) or C:CreateTexture(nil, layer or "ARTWORK")
    T:SetTexture([[Interface\BUTTONS\WHITE8X8]]);
    tinsert(C.SVG_Lines_Used,T)

    T:SetDrawLayer(layer or "ARTWORK")

    if sy>ey then
        sy, ey = ey, sy
    end

    if ( not color.def ) then
        T:SetVertexColor(color[1],color[2],color[3],color[4]);
    else
        local def = nil;
        for i = 1, #self.defs do
            if ( color.def == self.defs[i].id ) then
                def = self.defs[i];
                break;
            end
        end
        if ( def ) then
            local sY, eY = bbox[2], bbox[4];
            local sopacity, scolor = def.points[1].opacity * (color[4] or 1), def.points[1].color;
            local eopacity, ecolor = def.points[#def.points].opacity * (color[4] or 1), def.points[#def.points].color;

            --T:SetGradientAlpha("horizontal", scolor[1], scolor[2],scolor[3], sopacity, ecolor[1], ecolor[2],ecolor[3], eopacity);
        end
    end

    -- Set texture coordinates and anchors
    T:ClearAllPoints();
    T:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1);
    T:SetPoint("BOTTOMLEFT", C, relPoint, x-w/2, sy);
    T:SetPoint("TOPRIGHT",   C, relPoint, x+w/2, ey);
    T:Show()
    return T
end

function LibSVG:DrawHLine(C, y, sx, ex, w, color, layer, bbox)
    local relPoint = "BOTTOMLEFT"
    local svg = self;
    if not C.SVG_Lines then
        C.SVG_Lines={}
        C.SVG_Lines_Used={}
    end

    if not color then
        return;
    end

    local T = tremove(C.SVG_Lines) or C:CreateTexture(nil, layer or "ARTWORK")
    T:SetTexture([[Interface\BUTTONS\WHITE8X8]]);
    tinsert(C.SVG_Lines_Used,T)


    T:SetDrawLayer(layer or "ARTWORK")

    if sx>ex then
        sx, ex = ex, sx
    end

    if ( not color.def ) then
        T:SetVertexColor(color[1],color[2],color[3],color[4]);
    else
        local def = nil;
        for i = 1, #self.defs do
            if ( color.def == self.defs[i].id ) then
                def = self.defs[i];
                break;
            end
        end
        if ( def ) then
            local sY, eY = bbox[2], bbox[4];
            local sopacity, scolor = def.points[1].opacity * (color[4] or 1), def.points[1].color;
            local eopacity, ecolor = def.points[#def.points].opacity * (color[4] or 1), def.points[#def.points].color;
            T:SetGradientAlpha("horizontal", scolor[1], scolor[2],scolor[3], sopacity, ecolor[1], ecolor[2],ecolor[3], eopacity);
        end
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
        elseif ( color:match("url%(#([^%)]+)%)") ) then
            local ret = color:match("url%(#([^%)]+)%)")
            return {def = ret};
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
