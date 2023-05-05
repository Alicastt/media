
EventsModSprites = {}

EventsModSprites.getSprites = function()	
	getTexture("Item_ExperimentalSyringe.png");
	print("EventsMod : Textures and Sprites Loaded.");
end


Events.OnPreMapLoad.Add(EventsModSprites.getSprites);
