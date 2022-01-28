---
-- MusicPlayer.client.lua - Playlist initialization
--

local MusicController = require(script.Parent.MusicController)

local default = {
	{
		Codename = "sky",
		Name = "Cafe de Touhou 1 - If the Sky Clears...",
		Id = "rbxassetid://7369629922",
	},
	{
		Codename = "dream",
		Name = "Cafe de Touhou 1 - Perfect Day Dream",
		Id = "rbxassetid://5778724726",
	},
	{
		Codename = "myon",
		Name = "ShibayanRecords - MyonMyonMyonMyonMyonMyon!",
		Id = "rbxassetid://5090678105",
	},
	{
		Codename = "adiantum",
		Name = "ShibayanRecords - Tiny Little Adiantum",
		Id = "rbxassetid://1277436406",
	},
	{
		Codename = "blue",
		Name = "Cafe de Touhou 3 - Blue Magic Preset",
		Id = "rbxassetid://7369315696",
	},
	{
		Codename = "velvet",
		Name = "Shoji Meguro - Blues in Velvet Room",
		Id = "rbxassetid://4684737593",
		Volume = 0.2,
	},
	{
		Codename = "orange",
		Name = "BUTAOTOME - Orange Waltz",
		Id = "rbxassetid://2847252562",
	},
	{
		Codename = "jazz1",
		Name = "Touhou Jazz - The Alstromeria the Gods Loved",
		Id = "rbxassetid://151875398",
	},
	{
		Codename = "jazz2",
		Name = "Touhou Jazz - Shanghai Teahouse ~ Chinese Tea",
		Id = "rbxassetid://152672123",
		Volume = 0.2,
	},
	{
		Codename = "lorim",
		Name = "Night in the Woods - Lori M.",
		Id = "rbxassetid://883339167",
	},
}

MusicController:loadPlaylist("default", default)

local cafe = {
	{
		Codename = "iris",
		Name = "Foxtail-Grass Studio - Iris",
		Id = "rbxassetid://7542397338",
	},
	{
		Codename = "yakuza1",
		Name = "Yakuza 0 - Money Makes Money",
		Id = "rbxassetid://5655154612",
	},
	{
		Codename = "nightblossom",
		Name = "Cafe de Touhou 8 - Night Time Cherry Blossom",
		Id = "rbxassetid://4528247551",
	},
	{
		Codename = "mao",
		Name = "AAAA - café de Mao",
		Id = "rbxassetid://6026165348",
	},
	{
		Codename = "shesharestory",
		Name = "Yui Yamaguchi - She Share Story",
		Id = "rbxassetid://5047056155",
	},
	{
		Codename = "yume",
		Name = "Mitsukiyo - Coffee Shop in Yume",
		Id = "rbxassetid://6898635990",
	},
	{
		Codename = "acnl5",
		Name = "Animal Crossing New Leaf - 5PM",
		Id = "rbxassetid://959072219",
	},
	{
		Codename = "rest",
		Name = "Persona 5 - Have a Short Rest",
		Id = "rbxassetid://6027974752",
	},
	{
		Codename = "skullgirls1",
		Name = "Skullgirls - Event ~ Calm",
		Id = "rbxassetid://160432963",
	},
	{
		Codename = "pickaxe",
		Name = "Night in the Woods - Ol' Pickaxe",
		Id = "rbxassetid://2188386678",
	},
	{
		Codename = "acnl8",
		Name = "Animal Crossing New Leaf - 8AM",
		Id = "rbxassetid://277476192",
	},
}

MusicController:loadPlaylist("cafe", cafe)

local shinmy = {
	{
		Codename = "pokemon1",
		Name = "Lake [Pokémon DPPt Remix] + Pokémon Diamond & Pearl - Eterna Forest",
		Id = "rbxassetid://2062660461",
	},
	{
		Codename = "noodlecove",
		Name = "leon chang - noodle cove",
		Id = "rbxassetid://3758561517",
	},
	{
		Codename = "popcorncastle",
		Name = "leon chang - Popcorn Castle",
		Id = "rbxassetid://911417358",
	},
	{
		Codename = "skullgirls2",
		Name = "Skullgirls - Where Money Flows Like Water",
		Id = "rbxassetid://7024270921",
	},
	{
		Codename = "hourglass",
		Name = "Oliver Buckland - Hourglass Meadow",
		Id = "rbxassetid://7256470158",
	},
	{
		Codename = "pokemon2",
		Name = "Pokémon Brilliant Diamond & Shining Pearl - Galactic Eterna Building",
		Id = "rbxassetid://8107315480",
	},
}

MusicController:loadPlaylist("shinmy", shinmy)

MusicController:loadRegions()
MusicController:bindToPlayer()
