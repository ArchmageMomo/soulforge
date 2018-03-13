local Soulforge = RegisterMod("Soulforge",1);

local BumboSoul = Isaac.GetItemIdByName ("BumBo Soul")
local FlameThrower = Isaac.GetItemIdByName ("Flamespitter")
local AngleSoul = Isaac.GetItemIdByName ("Angel Soul")
local DemonSoul = Isaac.GetItemIdByName ("Demon Soul")
local DarkSoul= Isaac.GetItemIdByName ("Dark Soul")
local StainedSoul = Isaac.GetItemIdByName ("Stained Soul") -- Sample Image
local PureSoul = Isaac.GetItemIdByName ("Pure Soul") -- Sample Image

local repItem1 = true
local repItem2 = true
local log = {}


--BumboSoul: Gives a random Stat up
--Flamethrower: A fucking Flamethrower what would you expect
--Angle Soul:Grants Isaac an Ethernal Heart per flooor 

--this funktions sets the boolean false if the player has the Item
function Soulforge:Reset()
    repItem1 = true
    repItem2 = true

end


function Soulforge:CacheUpdate(player, cacheFlag)
  
  local player = Isaac.GetPlayer(0);
  local fd = Isaac.GetPlayer(0).MaxFireDelay * 4; 
  local isStatChanged = 0
  local heart = true
  
      
  
  if (cacheFlag == CacheFlag.CACHE_FIREDELAY) then 
    isStatChanged = 1 
  end
  
  -- This Code let's me change the Tear-rate 
  if player:HasCollectible(FlameThrower) == true and isStatChanged == 1  then
    player.MaxFireDelay = player.MaxFireDelay - (fd/4)
    isStatChanged = 0
  end
  
  -- Code for the Flamethrower
  if player:HasCollectible(FlameThrower) and repItem1 == true then 
    Isaac.GetPlayer(0).TearColor = Color(255.0,93,0,1,1,0,0)
    Isaac.GetPlayer(0).Damage = 3
    Isaac.GetPlayer(0).FireDelay = fd-1
    Isaac.GetPlayer(0).TearHeight = 2
    Isaac.GetPlayer(0).TearFlags = Isaac.GetPlayer(0).TearFlags +             TearFlags.TEAR_PIERCING + TearFlags.TEAR_BURN
    pos = Vector(Isaac.GetPlayer(0).Position.X, Isaac.GetPlayer(0).Position.Y);
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_PYROMANIAC, pos, Vector(0,0), Isaac.GetPlayer(0))
    repItem1 = false
  end
  
  -- This code is for Bumbo Soul
  if player:HasCollectible(BumboSoul) == true then 
    
    player.Damage=player.Damage+math.random(0,1)*0.5;
    player.MoveSpeed=player.MoveSpeed+math.random(0,1)*0.5;
    player.ShotSpeed=player.ShotSpeed+math.random(0,1)*0.2;
    player.TearHeight = player.TearHeight +math.random(0,1)*0.3;
    player.Luck = player.Luck+math.random(0,1)*0.5;
  end
end

--DarkSoul Function
function Soulforge:darksoulF()
  Isaac.GetPlayer(0):AddHealth(-1)
  -- This code is for DarkSoul
  if Isaac.GetPlayer(0):HasCollectible(DarkSoul) then
    pos = Vector(Isaac.GetPlayer(0).Position.X, Isaac.GetPlayer(0).Position.Y);
    if math.random(0,100) < 30 then
      Isaac.GetPlayer(0):AddHealth(-1)
    else 
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART,  HeartSubType.HEART_BLACK, pos, Vector(0, 0), Isaac.GetPlayer(0))
    end
  end
end





--This function is just additionally if the tearcolor changes 
function Soulforge:FlamethrowerC()
    local player= Isaac.GetPlayer(0)
    if Isaac.GetPlayer(0):HasCollectible(FlameThrower) then
      Isaac.GetPlayer(0).TearColor = Color(255.0,93,0,1,1,0,0)
    end
  end
  
-- This function gives Isaac one Ethernal heart each floor
function Soulforge:AngleFloor()
  local player=Isaac.GetPlayer(0)
  if Isaac.GetPlayer(0):HasCollectible(AngleSoul) == true then 
    pos = Vector(Isaac.GetPlayer(0).Position.X, Isaac.GetPlayer(0).Position.Y);
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART,  HeartSubType.HEART_ETERNAL, pos, Vector(0, 0), Isaac.GetPlayer(0))
    
  end
end

function Soulforge:DemonFloor()
  local player=Isaac.GetPlayer(0)
  
  
  
  if player:HasCollectible(DemonSoul) == true then 
    local rand = math.random(0,5)
    if rand==0 then
      player.Damage=player.Damage+0.5;
    elseif rand==1 then
      player.MoveSpeed=player.MoveSpeed+0.5;
    elseif rand==1 then
      player.ShotSpeed=player.ShotSpeed+0.2;
    elseif rand==1 then
      player.TearHeight = player.TearHeight +0.3;
    elseif rand==1 then
      player.Luck = player.Luck+0.5;
    end
    
    pos1 = Vector(player.Position.X, player.Position.Y);
    Isaac.Spawn(EntityType.ENTITY_BOMBDROP, BombVariant.BOMB_SUPERTROLL,  0, pos1, Vector(0, 0), player)
    pos1 = Vector(player.Position.X, player.Position.Y-1);
    Isaac.Spawn(EntityType.ENTITY_BOMBDROP, BombVariant.BOMB_SUPERTROLL,  0, pos1, Vector(0, 0), player)
    pos1 = Vector(player.Position.X-1, player.Position.Y-1);
    Isaac.Spawn(EntityType.ENTITY_BOMBDROP, BombVariant.BOMB_SUPERTROLL,  0, pos1, Vector(0, 0), player)
    pos1 = Vector(player.Position.X+1, player.Position.Y-1);
    Isaac.Spawn(EntityType.ENTITY_BOMBDROP, BombVariant.BOMB_SUPERTROLL,  0, pos1, Vector(0, 0), player)
    pos1 = Vector(player.Position.X+1, player.Position.Y);
    Isaac.Spawn(EntityType.ENTITY_BOMBDROP, BombVariant.BOMB_TROLL,  0, pos1, Vector(0, 0), player)
    pos1 = Vector(player.Position.X+1, player.Position.Y+1);
    Isaac.Spawn(EntityType.ENTITY_BOMBDROP, BombVariant.BOMB_TROLL,  0, pos1, Vector(0, 0), player)
    pos1 = Vector(player.Position.X, player.Position.Y-1);
    Isaac.Spawn(EntityType.ENTITY_BOMBDROP, BombVariant.BOMB_TROLL,  0, pos1, Vector(0, 0), player)
    
    Isaac.GetPlayer(0).TearColor = Color(180.0,180,0,1,1,0,0) 
    
  end
end
  
  Soulforge:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Soulforge.Reset)
  
  Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.CacheUpdate)
  
  Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.FlamethrowerC)
  Soulforge:AddCallback(ModCallbacks.MC_POST_UPDATE, Soulforge.FlamethrowerC)
  
  Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.AngleFloor)

  Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.darksoulF)

  Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.DemonFloor)
  
