if ( ETaxiConfig.NPCType == "ent" ) then

	ENT.Type = "anim"
	ENT.Base = "base_gmodentity"

elseif( ETaxiConfig.NPCType == "npc" ) then
	
	ENT.Type = "ai"
	ENT.Base = "base_ai"

end