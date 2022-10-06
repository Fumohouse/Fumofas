---
-- MusicPlayer.client.lua - Playlist initialization
--

local MusicController = require(script.Parent.MusicController)

local default = {
	{
		Codename = "sky",
		Name = "Cafe de Touhou 1 - If the Sky Clears...",
		Id = "rbxassetid://11183384399",
	},
	{
		Codename = "elevator1",
		Name = "KPM Main Series - \"CHEESE, KITCH AND RETRO\" - Life in an Elevator",
		Id = "rbxassetid://1841647093",
	},
	{
		Codename = "myon",
		Name = "ShibayanRecords - MyonMyonMyonMyonMyonMyon!",
		Id = "rbxassetid://11183399917",
	},
	{
		Codename = "adiantum",
		Name = "KPM 1000 LP Series - The Human Touch - Lazy Sunday",
		Id = "rbxassetid://1842241530",
	},
	{
		Codename = "convstore",
		Name = "Juice Music - The Sounds of Syd Dale - Convenience Store",
		Id = "rbxassetid://1839857296",
	},
	{
		Codename = "swayofnature",
		Name = "Inside Tracks - Feel Good Guitar - Sway of Nature (Electric Guitar Version)",
		Id = "rbxassetid://9038623767",
	},
	{
		Codename = "orange",
		Name = "BUTAOTOME - Orange Waltz",
		Id = "rbxassetid://11183401534",
	},
	{
		Codename = "citychill",
		Name = "JW Media Music - Urban Landscapes - City Chill",
		Id = "rbxassetid://1838138023",
	},
	{
		Codename = "honeydays",
		Name = "KPM 1000 LP Series - Chartbusters - Honey Days",
		Id = "rbxassetid://1842270639",
	},
	{
		Codename = "poscalm",
		Name = "Score Production Music - The Calm - Positive Calm",
		Id = "rbxassetid://1844272089",
	},
}

MusicController:loadPlaylist("default", default)

local cafe = {
	{
		Codename = "iris",
		Name = "Foxtail-Grass Studio - Iris",
		Id = "rbxassetid://11183418188",
	},
	{
		Codename = "relaxc",
		Name = "Juice Music - Edit Suite Companion 1 - Relax (c)",
		Id = "rbxassetid://1839841807",
	},
	{
		Codename = "nightblossom",
		Name = "Cafe de Touhou 8 - Night Time Cherry Blossom",
		Id = "rbxassetid://11183428635",
	},
	{
		Codename = "mao",
		Name = "AAAA - café de Mao",
		Id = "rbxassetid://11183438870",
	},
	{
		Codename = "chilljazz",
		Name = "Soho - Jazz Club - Chill Jazz",
		Id = "rbxassetid://1845341094",
	},
	{
		Codename = "yume",
		Name = "Yumegatari - Coffee Shop in Yume",
		Id = "rbxassetid://11183493756",
	},
	{
		Codename = "lofichilla",
		Name = "Hip Hop Shop - Chill Hop Vibes - Lo-fi Chill A",
		Id = "rbxassetid://9043887091",
	},
	{
		Codename = "shoppingave",
		Name = "AXS - Shopping Avenue - Neww Store",
		Id = "rbxassetid://1835711635",
	},
	{
		Codename = "chillhop",
		Name = "Ded Good - Chill Hop - Smooth Vibes (c)",
		Id = "rbxassetid://9044565954",
	},
	{
		Codename = "pianojazza",
		Name = "KPM Main Series - Source Music - Piano Bar Jazz (a)",
		Id = "rbxassetid://1841979451",
	},
	{
		Codename = "pianojazzb",
		Name = "KPM Main Series - Source Music - Piano Bar Jazz (b)",
		Id = "rbxassetid://1841984324",
	},
}

MusicController:loadPlaylist("cafe", cafe)

local shinmy = {
	{
		Codename = "pokemon1",
		Name = "Lake [Pokémon DPPt Remix] + Pokémon Diamond & Pearl - Eterna Forest",
		Id = "rbxassetid://11183503510",
	},
	{
		Codename = "noodlecove",
		Name = "leon chang - noodle cove",
		Id = "rbxassetid://11183526395",
	},
	{
		Codename = "moshi",
		Name = "Pegboard Nerds & Tokyo Machine - Moshi",
		Id = "rbxassetid://7024340270",
	},
	{
		Codename = "skullgirls2",
		Name = "Skullgirls - Where Money Flows Like Water",
		Id = "rbxassetid://11183529922",
	},
	{
		Codename = "cornerstorea",
		Name = "Sonoton Music - Industrial High Tech - Corner Store (A)",
		Id = "rbxassetid://1846738464",
	},
	{
		Codename = "bossanova",
		Name = "Bruton Vaults Anthologies - Kitsch Lush Strings - Prima Bossa Nova",
		Id = "rbxassetid://1837070127",
	},
}

MusicController:loadPlaylist("shinmy", shinmy)

MusicController:loadRegions()
MusicController:bindToPlayer()
