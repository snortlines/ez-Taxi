ETaxiConfig = ETaxiConfig or {}

//Are we going to use a NPC or a Entity(prop)
ETaxiConfig.NPCType = "ent" // Default = "ent"; Available choices are: ent, npc - They must be lowercased

//If the booth is an ent we're going to use this model.
ETaxiConfig.ENTModel = "models/props_equipment/phone_booth.mdl" // Default = "models/props_equipment/phone_booth.mdl"; Don't touch this if you're going to be using an NPC instead.

//If the booth is an NPC we're going to use this model.
ETaxiConfig.NPCModel = "models/Humans/Group01/Male_04.mdl" // Default = "models/Humans/Group01/Male_04.mdl"; Don't touch this if you're going to be using an ENT instead.

//If you want to change the cost then change this to a number, e.g 50. Keep it at false if you're not going to use it.
ETaxiConfig.Cost = false // Default = false; You can change this to whatever number you want.

//If you want to change the distance then change this to a number, e.g 1500. Keep it at false if you're not going to use it.
ETaxiConfig.Dist = false // Default = false; You can change this to whatever number you want.

//What should we display ontop of our booth?
ETaxiConfig.Header = "Taxi miger" // Default = "Taxi Booth"