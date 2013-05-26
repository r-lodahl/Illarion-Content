-- UPDATE common SET com_script='item.id_66_markerstone' WHERE com_itemid IN (66);


require("quest.explorersguild")
require("base.common")
require("base.ranklist")

module("item.id_66_markerstone", package.seeall)

function UseItem(User, SourceItem, ltstate)  -- DONT EDIT THIS LINE!
debug ("in use markerstone")
	local stonedata=SourceItem:getData("markerstone");
	if (tonumber(stonedata)~=0) then
		if not quest.explorersguild.CheckStone(User,tonumber(stonedata)) then
			debug(" ***************** YOU SHOULD GET THE TEXT, DUDE!")
			DisplayText = base.common.GetNLS( User, "Du hast einen Markierungsstein der Abenteurergilde entdeckt; er tr�gt die Nummer "..stonedata,"You found a marker stone of the Explorers' Guild; it has the number "..stonedata);
			quest.explorersguild.WriteStone(User,tonumber(stonedata));
			quest.explorersguild.getReward(User);
			base.ranklist.setRanklist(User, "explorerRanklist", quest.explorersguild.CountStones(User));
		else
			DisplayText = base.common.GetNLS( User, "Du hast diesen Markierungsstein der Abenteurer Gilde bereits fr�her gefunden; er tr�gt die Nummer "..stonedata..". Du hast bereits "..quest.explorersguild.CountStones(User).." dieser Steine gefunden.","You have already found that marker stone of the Explorers' Guild earlier; it has the number "..stonedata..". You have already found "..quest.explorersguild.CountStones(User).." of these stones.");
		end
		User:inform(DisplayText);
    end
debug ("after use markerstone")
end

function LookAtItem(User,Item)
debug ("in lookat markerstone")
	local stonedata=Item:getData("markerstone");
	if (tonumber(stonedata)~=0) then
		if not quest.explorersguild.CheckStone(User,tonumber(stonedata)) then
			base.lookat.SetSpecialDescription( Item, "Ein Markierungsstein der Abenteurer Gilde.","A marker stone of the Explorers' Guild.");
		else
			base.lookat.SetSpecialDescription( Item, "Du hast diesen Markierungsstein der Abenteurer Gilde bereits fr�her gefunden; er tr�gt die Nummer "..stonedata,"You have already found that marker stone of the Explorers' Guild earlier; it has the number "..stonedata);
		end
    end
	debug ("after lookat markerstone")
	world:itemInform(User,Item, base.lookat.GenerateLookAt(User, Item, base.lookat.NONE) );    
end