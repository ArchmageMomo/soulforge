local Soulforge = RegisterMod("Soulforge",1);

local BumboSoul = Isaac.GetItemIdByName ("BumBo Soul")
local FlameThrower = Isaac.GetItemIdByName ("Flamespitter")
local AngleSoul = Isaac.GetItemIdByName ("Angel Soul")  --Hallo
local DemonSoul = Isaac.GetItemIdByName ("Demon Soul")
<<<<<<< HEAD
local DarkSoul = Isaac.GetItemIdByName ("Dark Soul")
=======
local DarkSoul= Isaac.GetItemIdByName ("Dark Soul")
>>>>>>> Fruestueck
local StainedSoul = Isaac.GetItemIdByName ("Stained Soul") -- Sample Image
local PureSoul = Isaac.GetItemIdByName ("Pure Soul") -- Sample Image

local repItem1 = true
local log = {}

local debugText = "hello";

local currCoins = 0;
local currKeys = 0;
local currBombs = 0;
local currHearts = 0;

--BumboSoul: Gives a random Stat up
--Flamethrower: A fucking Flamethrower what would you expect
--Angle Soul:Grants Isaac an Ethernal Heart per flooor 

--this funktions sets the boolean false if the player has the Item
function Soulforge:Reset()
    player=Isaac.GetPlayer(0)
  
    repItem1 = true
<<<<<<< HEAD
=======
    repItem2 = true
    
    currCoins = player:GetNumCoins();
    currKeys = player:GetNumKeys();
    currBombs = player:GetNumBombs();
    currHearts = player:GetHearts();

>>>>>>> Fruestueck
end

function Soulforge:checkConsumables()
  player = Isaac.GetPlayer(0);
 
  if(currCoins < player:GetNumCoins()) then
      debugText = "picked up a coin";
      bumboAfterPickup()
  end
 
  if(currKeys < player:GetNumKeys()) then
      debugText = "picked up a key"; -- HasGoldenKey()
  end
 
  if(currBombs < player:GetNumBombs()) then
      debugText = "picked up a bomb"; -- HasGoldenBomb()
  end
 
  if(currHearts < player:GetHearts()) then
      debugText = "picked up a heart";
      darkAfterPickup()
  end
 
  currCoins = player:GetNumCoins();
  currKeys = player:GetNumKeys();
  currBombs = player:GetNumBombs();
  currHearts = player:GetHearts(); -- GetMaxHearts(), GetSoulHearts(), GetBlackHearts(), GetEternalHearts(), GetGoldenHearts()
end

function Soulforge:CacheUpdate(player, cacheFlag)
  
  local player = Isaac.GetPlayer(0);
  local fd = Isaac.GetPlayer(0).MaxFireDelay * 4; 
  local isStatChanged = 0
  local heart = true
  
      
  
  if (cacheFlag == CacheFlag.CACHE_FIREDELAY) then 
    isStatChanged = 1 
  end
  
  -- This Code let's me change the Tearrate 
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
<<<<<<< HEAD
  if player:HasCollectible(BumboSoul) == true then 
    Soulforge.BumboSoulColor
    player.Damage=player.Damage+math.random(0,1)*0.5;
    player.MoveSpeed=player.MoveSpeed+math.random(0,1)*0.5;
    player.ShotSpeed=player.ShotSpeed+math.random(0,1)*0.2;
    player.TearHeight = player.TearHeight +math.random(0,1)*0.3;
    player.Luck = player.Luck+math.random(0,1)*0.5
end
  
  -- This code is for DarkSoul
  if player:HasCollectible(DarkSoul) == true then
<<<<<<< HEAD
     Soulforge.DarkSoulColor
     random = math.random(0,100)
      Isaac.GetPlayer(0).Damage=player.Damage+random
=======
     Isaac.GetPlayer(0).Damage=Isaac.GetPlayer(0).Damage+math.random(0,100)
      
    
    --[[if  --Isaac collects red heart
      if math.random(0,100) >= 50 then --for 50% chance
         Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART,  HeartSubType.HEART_BLACK, pos, Vector(0, 0), Isaac.GetPlayer(0))--]]
>>>>>>> 6eecd06293a7f6a352e41639ba3e23e40528b31e
      
    if math.random(0,100) < 30 then --for 30% chance
      Isaac.GetPlayer(0):AddHealth(-0.5) --Isaac takes damage
    else --else (for 70%)
      --Isaac is healed (picks up black heart)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART,  HeartSubType.HEART_BLACK, pos, Vector(0, 0), Isaac.GetPlayer(0)) 
    end
    end
end 
=======
  --if player:HasCollectible(BumboSoul) == true then 
    
    --player.Damage=player.Damage+math.random(0,1)*0.5;
    --player.MoveSpeed=player.MoveSpeed+math.random(0,1)*0.5;
    --player.ShotSpeed=player.ShotSpeed+math.random(0,1)*0.2;
    --player.TearHeight = player.TearHeight +math.random(0,1)*0.3;
    --player.Luck = player.Luck+math.random(0,1)*0.5;
  --end
end


function bumboAfterPickup()
  if Isaac.GetPlayer(0):HasCollectible(BumboSoul) == true then
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
  end
end
--DarkSoul Function
function darkAfterPickup()
  if Isaac.GetPlayer(0):HasCollectible(DarkSoul) then
    pos = Vector(Isaac.GetPlayer(0).Position.X, Isaac.GetPlayer(0).Position.Y);
    if math.random(0,100) < 30 then
      Isaac.GetPlayer(0):TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 0)
    else 
      Isaac.GetPlayer(0):AddBlackHearts(1)
    end
  end
end


>>>>>>> Fruestueck



--This function is just additionally if the tearcolor changes 
function Soulforge:Color()
    local player= Isaac.GetPlayer(0)
    if Isaac.GetPlayer(0):HasCollectible(FlameThrower) then
    Isaac.GetPlayer(0).TearColor = Color(255.0,93,0,1,1,0,0)
    end
  end
  
  
-- This function gives Isaac one Ethernal heart each floor
function Soulforge:GiveHeart()
  if Isaac.GetPlayer(0):HasCollectible(AngleSoul) == true then 
    pos = Vector(Isaac.GetPlayer(0).Position.X, Isaac.GetPlayer(0).Position.Y);
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART,  HeartSubType.HEART_ETERNAL, pos, Vector(0, 0), Isaac.GetPlayer(0))
    
  end
end


function Soulforge:DarkSoulColor()
  Isaac.GetPlayer(0).TearColor = Color(0,0,0,1,1,0,0)
end

function Soulforge:BumboSoulColor():
  Isaac.GetPlayer(0).TearColor = Color(227,198,197,1,1,0,0)
end
<<<<<<< HEAD

function Soulforge:AngelSoulColor():
  Isaac.GetPlayer(0).TearColor = Color(108,122,189,1,1,0,0)
end

function Soulforge:DemonSoulColor():
  Isaac.GetPlayer(0).TearColor = Color(159,117,117,1,1,0,0)
end

function Soulforge:StainedSoulColor():
  Isaac.GetPlayer(0).TearColor = Color(94,110,98,1,1,0,0)
end

function Soulforge:PureSoulColor():
  Isaac.GetPlayer(0).TearColor = Color(255,255,255,1,1,0,0)
end


=======
  
  Soulforge:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Soulforge.Reset)
  Soulforge:AddCallback( ModCallbacks.MC_POST_UPDATE, Soulforge.checkConsumables);
  
  Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.CacheUpdate)
  
  Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.FlamethrowerC)
  Soulforge:AddCallback(ModCallbacks.MC_POST_UPDATE, Soulforge.FlamethrowerC)
  
  Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.AngleFloor)

  --Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.darksoulF)

  Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.DemonFloor)
>>>>>>> Fruestueck
  
  Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.CacheUpdate)
  Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.Color)
  Soulforge:AddCallback(ModCallbacks.MC_POST_UPDATE, Soulforge.Color)
  Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.GiveHeart)
  Soulforge:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Soulforge.Reset)
