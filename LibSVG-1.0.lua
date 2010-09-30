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
    _G.GetBuildInfo = function() return "4.0.1", 13000, 0, 40000; end;
end


local LIBSVG = "LibSVG-1.0"
local LIBSVG_MINOR = tonumber(("$Rev: 0@project-revision@ $"):match("(%d+)")) or 10000;
if not LibStub then error(LIBSVG .. " requires LibStub.") end
local LibSVG = LibStub:NewLibrary(LIBSVG, LIBSVG_MINOR)
local LibXML = LibStub("LibXML-1.0");
if not LibXML then error(LIBSVG .. " requires LibXML-1.0.") end
LibSVG.line = "";
LibSVG.circle = "";
LibSVG.diamond = "";
LibSVG.isCata = false;
do
    local path = string.match(debugstack(1,1,0), "AddOns\\(.+)LibSVG%-1%.0%.lua");
    if path then
        LibSVG.line = [[Interface\AddOns\]] .. path .. [[line]];
        LibSVG.circle = [[Interface\AddOns\]] .. path .. [[circle]];
        LibSVG.diamond = [[Interface\AddOns\]] .. path .. [[rect]];
    else
        error(LIBSVG.." cannot determine the folder it is located in because the path is too long and got truncated in the debugstack(1,1,0) function call")
    end
    local version, build, date, tocversion = GetBuildInfo();
    if ( version:match("^4") ) then
        LibSVG.isCata = true;
    end
end

-- Upvalues, yaaaay
local
	cos,acos,sin,asin,tan,atan,floor,sqrt,abs,pow,tinsert,tremove,max,min,pi,rad,deg,fmod =
	math.cos, math.acos, math.sin, math.asin, math.tan, math.atan, math.floor, math.sqrt, math.abs, math.pow, tinsert, tremove, math.max, math.min, math.pi, math.rad, math.deg, math.fmod;

LibSVG.colors = {
	black = {0.000,0.000,0.000,1},
	navy = {0.000,0.000,0.502,1},
	darkblue = {0.000,0.000,0.545,1},
	mediumblue = {0.000,0.000,0.804,1},
	blue = {0.000,0.000,1.000,1},
	darkgreen = {0.000,0.392,0.000,1},
	green = {0.000,0.502,0.000,1},
	teal = {0.000,0.502,0.502,1},
	darkcyan = {0.000,0.545,0.545,1},
	deepskyblue = {0.000,0.749,1.000,1},
	darkturquoise = {0.000,0.808,0.820,1},
	mediumspringgreen = {0.000,0.980,0.604,1},
	lime = {0.000,1.000,0.000,1},
	springgreen = {0.000,1.000,0.498,1},
	aqua = {0.000,1.000,1.000,1},
	cyan = {0.000,1.000,1.000,1},
	midnightblue = {0.098,0.098,0.439,1},
	dodgerblue = {0.118,0.565,1.000,1},
	lightseagreen = {0.125,0.698,0.667,1},
	forestgreen = {0.133,0.545,0.133,1},
	seagreen = {0.180,0.545,0.341,1},
	darkslategray = {0.184,0.310,0.310,1},
	limegreen = {0.196,0.804,0.196,1},
	mediumseagreen = {0.235,0.702,0.443,1},
	turquoise = {0.251,0.878,0.816,1},
	royalblue = {0.255,0.412,0.882,1},
	steelblue = {0.275,0.510,0.706,1},
	darkslateblue = {0.282,0.239,0.545,1},
	mediumturquoise = {0.282,0.820,0.800,1},
	indigo = {0.294,0.000,0.510,1},
	darkolivegreen = {0.333,0.420,0.184,1},
	cadetblue = {0.373,0.620,0.627,1},
	cornflowerblue = {0.392,0.584,0.929,1},
	mediumaquamarine = {0.400,0.804,0.667,1},
	dimgray = {0.412,0.412,0.412,1},
	slateblue = {0.416,0.353,0.804,1},
	olivedrab = {0.420,0.557,0.137,1},
	slategray = {0.439,0.502,0.565,1},
	lightslategray = {0.467,0.533,0.600,1},
	mediumslateblue = {0.482,0.408,0.933,1},
	lawngreen = {0.486,0.988,0.000,1},
	chartreuse = {0.498,1.000,0.000,1},
	aquamarine = {0.498,1.000,0.831,1},
	maroon = {0.502,0.000,0.000,1},
	purple = {0.502,0.000,0.502,1},
	olive = {0.502,0.502,0.000,1},
	gray = {0.502,0.502,0.502,1},
	skyblue = {0.529,0.808,0.922,1},
	lightskyblue = {0.529,0.808,0.980,1},
	blueviolet = {0.541,0.169,0.886,1},
	darkred = {0.545,0.000,0.000,1},
	darkmagenta = {0.545,0.000,0.545,1},
	saddlebrown = {0.545,0.271,0.075,1},
	darkseagreen = {0.561,0.737,0.561,1},
	lightgreen = {0.565,0.933,0.565,1},
	mediumpurple = {0.576,0.439,0.847,1},
	darkviolet = {0.580,0.000,0.827,1},
	palegreen = {0.596,0.984,0.596,1},
	darkorchid = {0.600,0.196,0.800,1},
	yellowgreen = {0.604,0.804,0.196,1},
	sienna = {0.627,0.322,0.176,1},
	brown = {0.647,0.165,0.165,1},
	darkgray = {0.663,0.663,0.663,1},
	lightblue = {0.678,0.847,0.902,1},
	greenyellow = {0.678,1.000,0.184,1},
	paleturquoise = {0.686,0.933,0.933,1},
	lightsteelblue = {0.690,0.769,0.871,1},
	powderblue = {0.690,0.878,0.902,1},
	firebrick = {0.698,0.133,0.133,1},
	darkgoldenrod = {0.722,0.525,0.043,1},
	mediumorchid = {0.729,0.333,0.827,1},
	rosybrown = {0.737,0.561,0.561,1},
	darkkhaki = {0.741,0.718,0.420,1},
	silver = {0.753,0.753,0.753,1},
	mediumvioletred = {0.780,0.082,0.522,1},
	indianred = {0.804,0.361,0.361,1},
	peru = {0.804,0.522,0.247,1},
	chocolate = {0.824,0.412,0.118,1},
	tan = {0.824,0.706,0.549,1},
	lightgrey = {0.827,0.827,0.827,1},
	palevioletred = {0.847,0.439,0.576,1},
	thistle = {0.847,0.749,0.847,1},
	orchid = {0.855,0.439,0.839,1},
	goldenrod = {0.855,0.647,0.125,1},
	crimson = {0.863,0.078,0.235,1},
	gainsboro = {0.863,0.863,0.863,1},
	plum = {0.867,0.627,0.867,1},
	burlywood = {0.871,0.722,0.529,1},
	lightcyan = {0.878,1.000,1.000,1},
	lavender = {0.902,0.902,0.980,1},
	darksalmon = {0.914,0.588,0.478,1},
	violet = {0.933,0.510,0.933,1},
	palegoldenrod = {0.933,0.910,0.667,1},
	lightcoral = {0.941,0.502,0.502,1},
	khaki = {0.941,0.902,0.549,1},
	aliceblue = {0.941,0.973,1.000,1},
	honeydew = {0.941,1.000,0.941,1},
	azure = {0.941,1.000,1.000,1},
	sandybrown = {0.957,0.643,0.376,1},
	wheat = {0.961,0.871,0.702,1},
	beige = {0.961,0.961,0.863,1},
	whitesmoke = {0.961,0.961,0.961,1},
	mintcream = {0.961,1.000,0.980,1},
	ghostwhite = {0.973,0.973,1.000,1},
	salmon = {0.980,0.502,0.447,1},
	antiquewhite = {0.980,0.922,0.843,1},
	linen = {0.980,0.941,0.902,1},
	lightgoldenrodyellow = {0.980,0.980,0.824,1},
	oldlace = {0.992,0.961,0.902,1},
	red = {1.000,0.000,0.000,1},
	fuchsia = {1.000,0.000,1.000,1},
	magenta = {1.000,0.000,1.000,1},
	deeppink = {1.000,0.078,0.576,1},
	orangered = {1.000,0.271,0.000,1},
	tomato = {1.000,0.388,0.278,1},
	hotpink = {1.000,0.412,0.706,1},
	coral = {1.000,0.498,0.314,1},
	darkorange = {1.000,0.549,0.000,1},
	lightsalmon = {1.000,0.627,0.478,1},
	orange = {1.000,0.647,0.000,1},
	lightpink = {1.000,0.714,0.757,1},
	pink = {1.000,0.753,0.796,1},
	gold = {1.000,0.843,0.000,1},
	peachpuff = {1.000,0.855,0.725,1},
	navajowhite = {1.000,0.871,0.678,1},
	moccasin = {1.000,0.894,0.710,1},
	bisque = {1.000,0.894,0.769,1},
	mistyrose = {1.000,0.894,0.882,1},
	blanchedalmond = {1.000,0.922,0.804,1},
	papayawhip = {1.000,0.937,0.835,1},
	lavenderblush = {1.000,0.941,0.961,1},
	seashell = {1.000,0.961,0.933,1},
	cornsilk = {1.000,0.973,0.863,1},
	lemonchiffon = {1.000,0.980,0.804,1},
	floralwhite = {1.000,0.980,0.941,1},
	snow = {1.000,0.980,0.980,1},
	yellow = {1.000,1.000,0.000,1},
	lightyellow = {1.000,1.000,0.878,1},
	ivory = {1.000,1.000,0.941,1},
	white = {1.000,1.000,1.000,1},
};


function LibSVG:New()
    local svg = {};
    svg.detail = 100/70; -- default quality is 70% (which will suffice for most images)
    svg.fill = true;
	svg.defaultColor = LibSVG.colors.black;
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
	svg.Delete = LibSVG.Delete;
    return svg;
end

function LibSVG:Delete(object)
	local svg = self;
	object = object or self;
	object.canvas:SetParent(nil);
	object.canvas:Hide();
	if ( object.children ) then
		for k,child in pairs(object.children) do
			self:Delete(child);
		end
	end
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
            local def = { type = c, id = el.args.id, points = {}, transformations = {} };
            for j = 1, #el do
                local arg = el[j];
                if ( arg.class == "stop" ) then
                    local x = {};
                    x.offset = tonumber(arg.args.offset) or 0;
                    if ( arg.args.style ) then
                        x.color = LibSVG_ParseColor(arg.args.style:match("stop%-color:([^;]+)"));
                        x.opacity = tonumber(arg.args.style:match("stop%-opacity:([^;]+)")) or 1;
                    end
                    tinsert(def.points, x);
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
			if ( el.args.gradientTransform ) then
                for method, args in el.args.gradientTransform:gmatch("(%a+)%(([^%)]+)%)") do
                    local n = {};
                    for x in args:gmatch("([%d%.%-]+)") do
                        n[#n+1] = tonumber(x);
                    end
                    method = method:lower();
                    if ( method == "matrix" ) then
                        tinsert(def.transformations, { (n[1] or 0), (n[2] or 0), (n[3] or 0), (n[4] or 0), (n[5] or 0), (n[6] or 0)});
                    elseif ( method == "translate" ) then
                        tinsert(def.transformations, {1, 0, 0, 1, n[1] or 0, n[2] or 0});
                    elseif ( method == "scale" ) then
                        tinsert(def.transformations, {n[1], 0, 0, n[2], 0, 0});
                    elseif ( method == "rotate" ) then
                        local a, x, y = rad(n[1] or 0), n[2], n[3];
                        if ( not x or not y ) then
                            tinsert(def.transformations, {cos(a),sin(a),-sin(a),cos(a),0,0});
                        else
                            tinsert(def.transformations, {1, 0, 0, 1, (x or 0), (y or 0)});
                            tinsert(def.transformations, {cos(a),sin(a),-sin(a),cos(a),0,0});
                            tinsert(def.transformations, {1, 0, 0, 1, -(x or 0), -(y or 0)});
                        end
                    elseif ( method == "skewx" ) then
                        local a = rad(n[1] or 0);
                        tinsert(def.transformations, {1, 0, tan(a), 1, 0, 0});
                    elseif ( method == "skewy" ) then
                        local a = rad(n[1] or 0);
                        tinsert(def.transformations, {1, tan(a), 0, 1, 0, 0});
                    end
                end
            end
            def.x1, def.y1, def.x2, def.y2 = tonumber(el.args.x1) or 0,tonumber(el.args.y1) or 0,tonumber(el.args.x2) or 0,tonumber(el.args.y2) or 0;
            tinsert(svg.defs, def);
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
        svg.CompiledData = { canvas = svg.canvas, class = "SVG" };
        svg.canvas:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
    end
    local xml = xml or svg.xml;
    svg.CompiledArgs = svg.CompiledArgs or 0;
    local group = group or svg.CompiledData;
    group.children = {};
	local svg_CompiledArgs = 0;

    for i = 1, #xml do
        local el = xml[i];
        if ( type(el) == "table" ) then
            local object = { };
            el.args = el.args or {};
            object.tracePaths = {};
            object.lines = {};
			object.class = el.class;
			object.id = el.args.id;
			local object_lines = object.lines;
            object.strings = {};
            object.transformations = object.transformations or {};
            if ( group.transformations ) then
                for k, v in pairs(group.transformations) do
                    tinsert(object.transformations, v);
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
                        tinsert(object.transformations, { (n[1] or 0), (n[2] or 0), (n[3] or 0), (n[4] or 0), (n[5] or 0), (n[6] or 0)});
                    elseif ( method == "translate" ) then
                        tinsert(object.transformations, {1, 0, 0, 1, n[1] or 0, n[2] or 0});
                    elseif ( method == "scale" ) then
                        tinsert(object.transformations, {n[1], 0, 0, n[2], 0, 0});
                    elseif ( method == "rotate" ) then
                        local a, x, y = rad(n[1] or 0), n[2], n[3];
                        if ( not x or not y ) then
                            tinsert(object.transformations, {cos(a),sin(a),-sin(a),cos(a),0,0});
                        else
                            tinsert(object.transformations, {1, 0, 0, 1, (x or 0), (y or 0)});
                            tinsert(object.transformations, {cos(a),sin(a),-sin(a),cos(a),0,0});
                            tinsert(object.transformations, {1, 0, 0, 1, -(x or 0), -(y or 0)});
                        end
                    elseif ( method == "skewx" ) then
                        local a = rad(n[1] or 0);
                        tinsert(object.transformations, {1, 0, tan(a), 1, 0, 0});
                    elseif ( method == "skewy" ) then
                        local a = rad(n[1] or 0);
                        tinsert(object.transformations, {1, tan(a), 0, 1, 0, 0});
                    end
                end
            end

			local black = LibSVG.colors.black;
			object.stroke = group.stroke or 1.5;
			object.fill = nil;
			if ( group.fill ) then
				object.fill = object.fill or {group.fill[1],group.fill[2],group.fill[3],group.fill[4]};
			end
			object.color = group.color or {black[1],black[2],black[3],1};
			object.opacity = group.opacity or 1;
			object.sopacity = group.sopacity or 1;
			object.fopacity = group.fopacity or 1;

			for arg, val in pairs(el.args) do
				if ( arg == "stroke-width" ) then
					if ( val:lower() == "none" ) then object.stroke = nil;
					else object.stroke = tonumber(val:match("([%d%.%-]+)")) or object.stroke; -- fall back on inheritance
					end
				elseif ( arg == "stroke" ) then
					if ( val:lower() == "none" ) then object.color = nil;
					else object.color = LibSVG_ParseColor(val) or object.color; -- fall back on inheritance
					end
				elseif ( arg == "fill" ) then
					if ( val:lower() == "none" ) then object.fill = nil;
					else object.fill = LibSVG_ParseColor(val) or object.fill; -- fall back on inheritance
					end
				elseif ( arg == "opacity" ) then
					if ( val:lower() == "none" ) then object.opacity = nil;
					else object.opacity = (tonumber(val:match("([%d%.%-]+)")) or object.opacity) * object.opacity; -- fall back on inheritance
					end
				elseif ( arg == "stroke-opacity" ) then
					if ( val:lower() == "none" ) then object.opacity = nil;
					else object.sopacity = (tonumber(val:match("([%d%.%-]+)")) or object.sopacity) * object.sopacity; -- fall back on inheritance
					end
				elseif ( arg == "fill-opacity" ) then
					if ( val:lower() == "none" ) then object.opacity = nil;
					else object.fopacity = (tonumber(val:match("([%d%.%-]+)")) or object.fopacity) * object.fopacity; -- fall back on inheritance
					end
				end
			end
            if ( el.args.style ) then
                local style = el.args.style;
				for key, val in style:gmatch("([%a%-]-)%:([^;]+)") do
					key = key:lower();
					if		( key == "fill" ) then object.fill = LibSVG_ParseColor(val);
					elseif	( key == "fill-opacity" ) then object.fopacity = (tonumber(val) or 0) * object.fopacity;
					elseif ( key == "stroke-opacity" ) then object.sopacity = (tonumber(val) or 0) * object.sopacity;
                    elseif ( key == "stroke-width" ) then if ( val:lower() == "none" ) then object.stroke = false; else object.stroke = (tonumber(val) or false); end
					elseif ( key == "stroke" ) then object.color = LibSVG_ParseColor(val); if ( val:lower() == "none" ) then object.stroke = false; end
					elseif ( key == "opacity" ) then object.opacity = (tonumber(val) or 1); end
                end
            end
			object.stroke = object.stroke or 0;

			if ( object.fill ) then object.fill[4] = object.fopacity; end
			if ( object.color ) then object.color[4] = object.sopacity; end

            -- This is just debug stuff I use --
            --object.fill = nil;
            --object.color = LibSVG.colors.black;
            --object.stroke = 0;
			--object.color = nil;

            object.canvas = CreateFrame("Frame", group.canvas);
            object.canvas:SetParent(group.canvas);
            object.canvas:SetPoint("TOPLEFT");
			object.canvas:SetPoint("BOTTOMRIGHT");



            if ( el.class == "defs" ) then
				tinsert(group.children, object);
                self:CompileDefs(el);
            elseif ( el.class == "g" ) then
				tinsert(group.children, object);
                svg:Compile(el, object);
            elseif ( el.class == "circle" ) then
				tinsert(group.children, object);
                local sX, sY = nil, nil;
                local radius = tonumber(el.args.r) or 10;
                local cX = tonumber(el.args.cx) or 0;
                local cY = tonumber(el.args.cy) or 0;
                object.fillPath = {'c', cX, cY, radius};

                for x = 0, radius do
                    local y = (x/radius) * pi * 2;
                    local eX = (sin(y) * radius) + cX;
                    local eY = (cos(y) * radius) + cY;
                    if ( sX and sY ) then
                        tinsert(object_lines, {sX, sY, eX, eY});
                        svg_CompiledArgs = svg_CompiledArgs + 1;
                    end
                    sX = eX;
                    sY = eY;
                end
            elseif ( el.class == "ellipse" ) then
				tinsert(group.children, object);
                local sX, sY = nil, nil;
                local rX = tonumber(el.args.rx) or 10;
                local rY = tonumber(el.args.ry) or 10;
                local cX = tonumber(el.args.cx) or 0;
                local cY = tonumber(el.args.cy) or 0;
                local m = max(rX, rY);
                object.fillPath = {'e', cX, cY, rX, rY};
                for n = 0, m do
                    local y = (n/m) * pi * 2;
                    local x = (n/m) * pi * 2;
                    local eX = (sin(y) * rX) + cX;
                    local eY = (cos(y) * rY) + cY;
                    if ( sX and sY ) then
                        tinsert(object_lines, {sX, sY, eX, eY});
                        svg_CompiledArgs = svg_CompiledArgs + 1;
                    end
                    sX = eX;
                    sY = eY;
                end
            elseif ( el.class == "rect" ) then
				tinsert(group.children, object);
                local x = tonumber(el.args.x) or 0;
                local y = tonumber(el.args.y) or 0;
                local width = tonumber(el.args.width) or 1;
                local height = tonumber(el.args.height) or 1;
                tinsert(object_lines, {x, y, x+width, y});
                tinsert(object_lines, {x, y, x, y+height});
                tinsert(object_lines, {x+width, y, x+width, y+height});
                tinsert(object_lines, {x, y+height, x+width, y+height});
                object.fillPath = {'r', x, y, x+width, y+height};

                svg_CompiledArgs = svg_CompiledArgs + 4;
            elseif ( el.class == "polygon" ) then
				tinsert(group.children, object);
                local sX, sY = nil,nil;
                local fX, fY = nil, nil;
                local eX, eY = nil, nil;
                for x,y in (el.args.points or ""):gmatch("([%d%-%.]+),([%d%-%.]+)") do
                    eX = tonumber(x) or 0;
                    eY = tonumber(y) or 0;
                    if ( sX ~= nil ) then
                        tinsert(object_lines, {sX, sY, eX, eY});
                        svg_CompiledArgs = svg_CompiledArgs + 1;
                    end
                    sX = eX;
                    sY = eY;
                    if ( fX == nil ) then
                        fX = eX;
                        fY = eY;
                    end
                end
                if ( fX ~= nil and eX ~= nil ) then
                    tinsert(object_lines, {fX, fY, eX, eY});
                    svg_CompiledArgs = svg_CompiledArgs + 1;
                end

            elseif ( el.class == "polyline" ) then
				tinsert(group.children, object);
                local sX, sY = nil,nil;
                local eX, eY = nil, nil;
                for x,y in (el.args.points or ""):gmatch("([%d%-%.]+),([%d%-%.]+)") do
                    eX = tonumber(x) or 0;
                    eY = tonumber(y) or 0;
                    if ( sX ~= nil ) then
                        tinsert(object_lines, {sX, sY, eX, eY});
                        svg_CompiledArgs = svg_CompiledArgs + 1;
                    end
                    sX = eX;
                    sY = eY;
                end
            elseif ( el.class == "text" or el.class == "tspan" ) then
				tinsert(group.children, object);
                local ax = (tonumber(el.args.x or object.x) or 0) + (tonumber(el.args.dx) or 0);
                local ay = (tonumber(el.args.y or object.y) or 0) + (tonumber(el.args.dy) or 0);
                local size = (tonumber(el.args['font-size']) or 12);
                local text = "";
                for n = 0, #el do
                    if ( type(el[n]) == "string" ) then
                        text = text .. el[n];
                    end
                end
                object.x = ax;
                object.y = ay;
                tinsert(object.strings, {ax, ay, size, text});
                svg:Compile(el, object); -- in case we have tspans inside
          elseif ( el.class == "path" ) then
				tinsert(group.children, object);
                el.args.d = (el.args.d or "y") .. "y"; -- kludge
                local sX, sY = 0,0;
                local xX, xY = nil,nil;
                local fX, fY = nil,nil;
                for c, v in (el.args.d or ""):gmatch("(%a)([^%a]*)") do
                    local coords = {};
                    local rel = false;
                    if ( c == string.lower(c) ) then    -- If relative coords are sent, translate them
                        rel = true;
                        c = string.upper(c);
                    end
                    v:gsub("([%d%-%.]+)([^%d%-%.]+)([%d%-%.]+)", function (x, _, y)
                        tinsert(coords, {tonumber(x),tonumber(y)});
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
                            tremove(coords, 1);
                            c = "L";
                        end
                    end
                    if ( c == "L" ) then
                        for k, v in pairs(coords) do
                            eX = v[1];
                            eY = v[2];
                            if ( rel ) then eX = sX + eX; eY = sY + eY;
                            end
                            tinsert(object_lines, {sX, sY, eX, eY});
                            svg_CompiledArgs = svg_CompiledArgs + 1;
                            sX = eX;
                            sY = eY;
                        end
                    elseif ( c == "S" ) then
                        c = "C";
                        local dX, dY = 0, 0
                        if ( xX and xY ) then
                            dX, dY = sX-xX,sY-xY;
                        end
                        if ( not rel ) then
                            tinsert(coords, 1, {sX+dX, sY+dY});
                        else
                            tinsert(coords, 1, {dX, dY});
                        end
                    end
                    if ( c == "C" ) then
                        for i = 0, floor((#coords/3)-1) do
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
                            local trace = floor(2 + min(
                                abs(max(p0[1],p1[1],p2[1],p3[1]) - min(p0[1],p1[1],p2[1],p3[1])),
                                abs(max(p0[2],p1[2],p2[2],p3[2]) - min(p0[2],p1[2],p2[2],p3[2]))
                            )/svg.detail);
                            local pangle = nil;
                            for n = 1, trace do
                                local t = n / trace;
                                eX =
                                    ( pow(1-t, 3) * p0[1] ) +
                                    ( 3 * pow(1-t, 2) * t * p1[1] ) +
                                    ( 3 * (1-t) * pow(t,2) * p2[1] ) +
                                    ( pow(t, 3) * p3[1] )
                                    ;
                                eY =
                                    ( pow(1-t, 3) * p0[2] ) +
                                    ( 3 * pow(1-t, 2) * t * p1[2] ) +
                                    ( 3 * (1-t) * pow(t,2) * p2[2] ) +
                                    ( pow(t, 3) * p3[2] )
                                    ;
                                local cangle = deg(atan((eY-sY)/(eX-sX)));
                                if ( pangle == nil or abs(pangle-cangle) > svg.detail or n == trace ) then
                                    tinsert(object_lines, {sX, sY, eX, eY});
                                    svg_CompiledArgs = svg_CompiledArgs + 1;
                                    sX = eX;
                                    sY = eY;
                                    pangle = cangle;
                                end
                            end
                            xX, xY = p2[1], p2[2]; -- Set control points for shorthand bezier curves.
                            sX, sY = p3[1], p3[2]
                        end
                    elseif ( c == "Q" ) then
                        for i = 0, floor((#coords/3)-1) do
                            local p = (i*4)+1;
                            local p0 = coords[p];
                            local p1 = coords[p+1];
                            local p2 = coords[p+2];
                            local trace = 10;
                            for n = 1, trace do
                                local t = n / trace;
                                eX = ( ( sqrt(1-t) * p0[1] ) + ( 2* (1-t) * t * p1[1] ) + (pow(t, 2)*p2[1]) );
                                eY = ( ( sqrt(1-t) * p0[2] ) + ( 2* (1-t) * t * p1[2] ) + (pow(t, 2)*p2[2]) );
                                tinsert(object_lines, {sX, sY, eX, eY});
                                svg_CompiledArgs = svg_CompiledArgs + 1;
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
                            large_arc_flag = floor(tonumber(large_arc_flag));
                            sweep_flag = floor(tonumber(sweep_flag));
                            local x0,y0 = sX, sY;
                            local dx2, dy2 = (x0-x)/2, (y0-y)/2;
                            local theta = rad(tonumber(angle));

                            -- Find x1,y1
                            local x1 = (cos(theta) * dx2 + sin(theta) * dy2);
                            local y1 = (-sin(theta) * dx2 + cos(theta) * dy2);

                            -- Radii check
                            local rx = abs(rX);
                            local ry = abs(rY);
                            local Prx = rx * rx;
                            local Pry = ry * ry;
                            local Px1 = x1 * x1;
                            local Py1 = y1 * y1;
                            local d = Px1 / Prx + Py1 / Pry;
                            if (d > 1) then
                                rx = abs((sqrt(d) * rx));
                                ry = abs((sqrt(d) * ry));
                                Prx = rx * rx;
                                Pry = ry * ry;
                            end

                            -- Find cx1, cy1
                            local sign = 1;
                            if (large_arc_flag == sweep_flag) then sign = -1; end
                            local coef = (sign * sqrt(((Prx * Pry) - (Prx * Py1) - (Pry * Px1)) / ((Prx * Py1) + (Pry * Px1))));
                            local cx1 = coef * ((rx * y1) / ry);
                            local cy1 = coef * -((ry * x1) / rx);

                            -- Find (cx, cy) from (cx1, cy1)
                            local sx2 = (x0 + x) / 2;
                            local sy2 = (y0 + y) / 2;
                            local cx = sx2 + (cos(theta) * cx1 - sin(theta) * cy1);
                            local cy = sy2 + (sin(theta) * cx1 + cos(theta) * cy1);

                            -- Compute the angleStart (theta1) and the angleExtent (dtheta)
                            local ux = (x1 - cx1) / rx;
                            local uy = (y1 - cy1) / ry;
                            local vx = (-x1 - cx1) / rx;
                            local vy = (-y1 - cy1) / ry;
                            local p, n;

                            n =  sqrt((ux * ux) + (uy * uy));
                            p = ux; -- (1 * ux) + (0 * uy)
                            sign = 1;
                            if (uy < 0) then sign = -1; end

                            local angleStart = (sign * acos(p / n));

                            n = sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy));
                            p = ux * vx + uy * vy;
                            sign = 1;
                            if (ux * vy - uy * vx < 0) then sign = -1; end

                            local angleExtent = (sign * acos(p / n));
                            if (sweep_flag == 0 and angleExtent > 0) then
                                angleExtent = angleExtent - (pi*2);
                            elseif (sweep_flag == 1 and angleExtent < 0) then
                                    angleExtent = angleExtent + (pi*2);
                            end
                            angleExtent = fmod(angleExtent, pi*2);
                            angleStart = fmod(angleStart, pi*2);
                            local m = floor(max(rX, rY)/svg.detail)+1;
                            local pangle = nil;
                            for n = 1, m do
                                local a = (-angleStart - (angleExtent * n / m));
                                local eX = (cos(a) * rX) + cx;
                                local eY = -(sin(a) * rY) + cy;
                                local cangle = deg(atan((eY-sY)/(eX-sX)));
                                if ( pangle == nil or abs(pangle-cangle) > svg.detail or n == m ) then
                                        tinsert(object_lines, {sX, sY, eX, eY});
                                        svg_CompiledArgs = svg_CompiledArgs + 1;
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
                            tinsert(object_lines, {eX,eY,fX,fY});
                            svg_CompiledArgs = svg_CompiledArgs + 1;
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
	svg.CompiledArgs = svg.CompiledArgs + svg_CompiledArgs;
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
            if ( err and err ~= "cannot resume dead coroutine" ) then print(ret, err); end
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
            local sx,sy,ex,ey = tonumber(line[1]), tonumber(line[2]), tonumber(line[3]), tonumber(line[4]);
            local ax,ay = LibSVG_transform(object.transformations, sx, sy);
            local bx,by = LibSVG_transform(object.transformations, ex, ey);
            if ( ax < bbox[1] ) then bbox[1] = ax; end if ( ax > bbox[3] ) then bbox[3] = ax; end
            if ( bx < bbox[1] ) then bbox[1] = bx; end if ( bx > bbox[3] ) then bbox[3] = bx; end
            if ( ay < bbox[2] ) then bbox[2] = ay; end if ( ay > bbox[4] ) then bbox[4] = ay; end
            if ( by < bbox[2] ) then bbox[2] = by; end if ( by > bbox[4] ) then bbox[4] = by; end
            self:DrawLine(object.canvas, sx,sy,ex,ey, object.stroke, object.color, object.transformations, object.tracePaths);
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
                local ax,ay = LibSVG_transform(object.transformations, f[2], f[3]);
                local bx,by = LibSVG_transform(object.transformations, f[4], f[5]);
                local rotation = tan( ( bx-ax) / (by-ay) );
                if not C.SVG_Lines then C.SVG_Lines={} C.SVG_Lines_Used={} end
                local T = tremove(C.SVG_Lines) or C:CreateTexture(nil, "BACKGROUND");
                if ( abs(rotation) == 0 or abs(rotation) == ( pi/2) ) then
                    T:SetTexture(1,1,1,1);
                    tinsert(C.SVG_Lines_Used,T)
                    --T:SetDrawLayer("BACKGROUND", -1);
                    if ( not color.def ) then
                        T:SetVertexColor(color[1],color[2],color[3],pow(color[4],2));
                    else
                    end
                    T:ClearAllPoints();
                    T:SetTexCoord(0,1,0,1);
                    s = true;
                end
                T:SetPoint("TOPLEFT", C, "TOPLEFT", min(ax,bx), max(-ay,-by));
                T:SetPoint("BOTTOMRIGHT",   C, "TOPLEFT", max(ax,bx), min(-ay,-by));

                T:Show();
            elseif ( f[1] == 'c' ) then
                local cx, cy = f[2], f[3];
                local r = f[4];
                local ax,ay = LibSVG_transform(object.transformations, cx-r, cy-r);
                local bx,by = LibSVG_transform(object.transformations, cx+r, cy+r);
                if not C.SVG_Lines then C.SVG_Lines={} C.SVG_Lines_Used={} end
                local T = tremove(C.SVG_Lines) or C:CreateTexture();
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
                            n = n + 1;
                            if ( fmod(n,2) == 0 ) then
                               if ( abs(prev-Y) >= 1 ) then
                                    if ( LibSVG.isCata ) then
                                        self:DrawVLine(object.canvas,k,prev,Y,2, object.fill, -1, object.bbox, object.transformations);
                                    else
                                        self:DrawVLine(object.canvas,k,prev,Y,2, object.fill, "BACKGROUND", object.bbox, object.transformations);
                                    end
                                end
                            end
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
            local ax,ay = LibSVG_transform(object.transformations, str[1], str[2]);
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

function LibSVG_transform(t, x, y)
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
    sx,sy = LibSVG_transform(transforms, sx, sy);
    ex,ey = LibSVG_transform(transforms, ex, ey);

    sy = -sy;
    ey = -ey;

    if ( sx < 0 ) then sx = floor(sx - 0.5); else sx = floor(sx + 0.5); end
    if ( ex < 0 ) then ex = floor(ex - 0.5); else ex = floor(ex + 0.5); end

    local relPoint = "TOPLEFT"
    local steps = abs(sx-ex);

    if ( tracePaths) then
        local py,px = nil, nil;
        for i = 1, steps do
            local x = sx + ((ex-sx) * (i / steps));
            local y = sy + ((ey-sy) * ( i / steps));
            if ( not tracePaths[x] ) then tracePaths[x] = {}; end
            tinsert(tracePaths[x], y);
        end
    end
--[[
    if ( sy < 0 ) then sy = floor(sy - 0.5); else sy = floor(sy + 0.5); end
    if ( ey < 0 ) then ey = floor(ey - 0.5); else ey = floor(ey + 0.5); end

    local relPoint = "BOTTOMLEFT"
    local steps = abs(sy-ey);

    if ( tracePaths) then
        for i = 1, steps do
            local x = sx + ((ex-sx) * (i / steps));
            local y = sy + ((ey-sy) * ( i / steps));
            --if ( y < 0 ) then y = floor(y + 0.5); else y = floor(y - 0.5); end
            if ( not tracePaths[y] ) then tracePaths[y] = {}; end
            tinsert(tracePaths[y], x);
        end
    end
]]
    if sx==ex then
        return self:DrawVLine(C,sx,sy,ey,w, color)
    end
    if sy==ey then
        if ( LibSVG.isCata ) then
            return self:DrawHLine(C,sy,sx,ex,w, color, 0, tracePaths)
        else
            return self:DrawHLine(C,sy,sx,ex,w, color, "ARTWORK", tracePaths)
        end
    end
    w = w * 32 * (256/254);

    if ( abs( sx - ex) < 1 and abs(sy - ey) < 1 ) then -- lines that don't go anywhere makes me a sad panda.
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


    local T = tremove(C.SVG) or C:CreateTexture()
    T:SetTexture(LibSVG.line);
	T:SetNonBlocking(true);
    tinsert(C.SVG_Used,T)

    if ( LibSVG.isCata ) then
        T:SetDrawLayer("ARTWORK", layer or 0)
    else
        T:SetDrawLayer(layer or "ARTWORK")
    end
    T:SetVertexColor(color[1],color[2],color[3],color[4]);

    -- Set texture coordinates and anchors
    T:SetTexCoord(TLx, TLy, BLx, BLy, TRx, TRy, BRx, BRy);
    T:SetPoint("TOPLEFT",   C, relPoint, cx - Bwid, cy + Bhgt);
    T:SetWidth(Bwid*2);
    T:SetHeight(Bhgt*2);
    T:Show()
    return T
end



function LibSVG:DrawVLine(C, x, sy, ey, w, color, layer, bbox, transforms)
    local relPoint = "TOPLEFT"
    local svg = self;

    if not C.SVG_Lines then
        C.SVG_Lines={}
        C.SVG_Lines_Used={}
    end
    if not color or w == 0 then
        return;
    end
    --w = w * 32 * (256/254);
    local T = tremove(C.SVG_Lines) or C:CreateTexture()
	T:SetNonBlocking(true);
    tinsert(C.SVG_Lines_Used,T)

    if ( LibSVG.isCata ) then
        T:SetDrawLayer("ARTWORK", layer or 0)
    else
        T:SetDrawLayer(layer or "ARTWORK")
    end

    if sy>ey then
        sy, ey = ey, sy
    end

    if ( not color.def ) then
        T:SetTexture(color[1],color[2],color[3],pow(color[4],2));
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
            local sX, eX = bbox[1], bbox[3];
            if ( def.x1 and def.x2 and transforms and def.type == "lineargradient" ) then
                sX, sY = LibSVG_transform(transforms, def.x1, def.y1);
                eX, eY = LibSVG_transform(transforms, def.x2, def.y2);
                if ( eX < sX ) then
                    sX, eX = eX, sX;
                end
            end
			if ( def.transformations ) then
				sX, sY = LibSVG_transform(def.transformations, sX, sY);
				eX, eY = LibSVG_transform(def.transformations, eX, eY);
			end
            local l = (eX - sX); if ( l == 0 ) then l = 0.01; end
            local a = ( x - sX ) / l;
            local fo, fc, fp = def.points[1].opacity * (color[4] or 1), def.points[1].color, 0;
            local eo, ec, ep = def.points[#def.points].opacity * (color[4] or 1), def.points[#def.points].color, 0;
            for n = 1, #def.points do
                local d = def.points[n];
                if ( d.offset >= a ) then
                    eo, ec, ep = def.points[n].opacity * (color[4] or 1), def.points[n].color, def.points[n].offset;
                    break;
                end
                fo, fc, fp = def.points[n].opacity * (color[4] or 1), def.points[n].color, def.points[n].offset;
            end
            local z = (ep - fp);
            if ( z == 0 ) then z = 0.5; end
            local c = ( ep - a ) / z;
            local d = 1 - c;
            if ( c + d > 1 ) then c, d = (c/(c+d)), (d/(c+d)); end
            T:SetTexture( (fc[1]*c)+(ec[1]*d), (fc[2]*c)+(ec[2]*d), (fc[3]*c)+(ec[3]*d), pow((fo*c)+(eo*d),2) );
        end
    end

    -- Set texture coordinates and anchors
    T:ClearAllPoints();
    T:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1);
    T:SetPoint("TOPLEFT", C, "TOPLEFT", x-(w/2), ey);
    T:SetWidth(w);
    T:SetHeight(abs(sy-ey));
    T:Show()
    return T
end

function LibSVG:DrawHLine(C, y, sx, ex, w, color, layer, bbox)
    local relPoint = "TOPLEFT"
    local svg = self;
    if not C.SVG_Lines then
        C.SVG_Lines={}
        C.SVG_Lines_Used={}
    end

    if not color or w == 0 then
        return;
    end

    local T = tremove(C.SVG_Lines) or C:CreateTexture()
    T:SetTexture(1,1,1,1);
    tinsert(C.SVG_Lines_Used,T)


    if ( LibSVG.isCata ) then
        T:SetDrawLayer("ARTWORK", layer or 0)
    else
        T:SetDrawLayer(layer or "ARTWORK")
    end

    if sx>ex then
        sx, ex = ex, sx
    end

    if ( not color.def ) then
        T:SetVertexColor(color[1],color[2],color[3],color[4]);
    end

    -- Set texture coordinates and anchors
    T:ClearAllPoints();
    T:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1);
    T:SetPoint("BOTTOMLEFT", C, relPoint, sx, y-w/2);
    T:SetPoint("TOPRIGHT",   C, relPoint, ex, y+w/2);
    T:Show()
    return T
end

function LibSVG_ParseColor(color)
    if ( type(color) == "string" ) then
        color = color:gsub("%s", "");
        if ( color:sub(1,1) == "#" ) then
            local ret = {};
            if ( color:len() == 4 ) then
                string.gsub(color, "([0-9a-fA-F])", function (x) tinsert(ret, tonumber(x, 16) / 15); end);
            else
                string.gsub(color, "([0-9a-fA-F][0-9a-fA-F])", function (x) tinsert(ret, tonumber(x, 16) / 255); end);
            end
            tinsert(ret, 1);
            return ret;
        elseif ( color:match("url%(#([^%)]+)%)") ) then
            local ret = color:match("url%(#([^%)]+)%)")
            return {def = ret};
        elseif ( color:match("%((%d+),(%d+),(%d+)%)") ) then
            local ret = {color:match("%((%d+),(%d+),(%d+)%)")};
            tinsert(ret,1);
            return ret;
        elseif ( LibSVG.colors[color:lower()] ) then
			local color = LibSVG.colors[color:lower()];
            return {color[1], color[2], color[3], 1};
        end
    end
    return nil;
end
