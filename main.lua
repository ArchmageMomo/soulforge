local Soulforge = RegisterMod("Soulforge",1);

local BumboSoul = Isaac.GetItemIdByName ("BumBo Soul")
local FlameThrower = Isaac.GetItemIdByName ("Flamethrower")
local AngelSoul = Isaac.GetItemIdByName ("Angel Soul")  --Hallo
local DemonSoul = Isaac.GetItemIdByName ("Demon Soul")
local DarkSoul = Isaac.GetItemIdByName ("Dark Soul")
local StainedSoul = Isaac.GetItemIdByName ("Stained Soul") -- Sample Image
local PureSoul = Isaac.GetItemIdByName ("Pure Soul") -- Sample Image

local repItem1 = true
local log = {}

local debugText = "";

local currCoins = 0;
local currKeys = 0;
local currBombs = 0;
local currHearts = 0;

--Function to set default values
function Soulforge:Reset()
  player = Isaac.GetPlayer(0);
  repItem1 = true
  currCoins = player:GetNumCoins();
  currKeys = player:GetNumKeys();
  currBombs = player:GetNumBombs();
  currHearts = player:GetHearts();

end

--Function to check if any consumable changed
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


-- Code for the Flamethrower
function Soulforge:FlamethrowerF()
  if Isaac.GetPlayer(0):HasCollectible(FlameThrower) and repItem1 == true then
    
    Isaac.GetPlayer(0).Damage = Isaac.GetPlayer(0).Damage*2/3
    Isaac.GetPlayer(0).FireDelay = Isaac.GetPlayer(0).FireDelay-1
    Isaac.GetPlayer(0).TearHeight = Isaac.GetPlayer(0).TearHeight-3
    Isaac.GetPlayer(0).TearFlags = Isaac.GetPlayer(0).TearFlags + TearFlags.TEAR_PIERCING + TearFlags.TEAR_BURN
    
    pos = Vector(Isaac.GetPlayer(0).Position.X, Isaac.GetPlayer(0).Position.Y);
    --Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_PYROMANIAC, pos, Vector(0,0), Isaac.GetPlayer(0))
    
    repItem1 = false
  end
end

-- deny explosion damage
function Soulforge:FlamethrowerDamage(player_x, damage, flag, source, countdown)
  local player = Isaac.GetPlayer(0);
    if player:HasCollectible(FlameThrower) and flag == DamageFlag.DAMAGE_EXPLOSION then
        return false;
    end
end

--Bumbo Soul Function
function bumboAfterPickup()
  player = Isaac.GetPlayer(0);
  if Isaac.GetPlayer(0):HasCollectible(BumboSoul) == true then
    local rand = math.random(0,5)
    if rand==0 then
      player.Damage=player.Damage+0.3;
    elseif rand==1 then
      player.MoveSpeed=player.MoveSpeed+0.2;
    elseif rand==1 then
      player.ShotSpeed=player.ShotSpeed+0.1;
    elseif rand==1 then
      player.TearHeight = player.TearHeight +0.1;
    elseif rand==1 then
      player.Luck = player.Luck+0.3;
    end
  end
end

--Dark Soul Function
function darkAfterPickup()
  if Isaac.GetPlayer(0):HasCollectible(DarkSoul) then
    pos = Vector(Isaac.GetPlayer(0).Position.X, Isaac.GetPlayer(0).Position.Y);
    if math.random(0,100) < 30 then
      Isaac.GetPlayer(0):TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 0)
    else 
      Isaac.GetPlayer(0):AddBlackHearts(2)
    end
  end
end
  
--Angel Soul Function
function Soulforge:AngelFloor()
  if Isaac.GetPlayer(0):HasCollectible(AngelSoul) == true then
    Isaac.GetPlayer(0):AddEternalHearts(1)
  end
end

--Demon Soul Function
function Soulforge:DemonFloor()
  player=Isaac.GetPlayer(0)
  if player:HasCollectible(DemonSoul) == true then 
    local rand = math.random(0,5)
    if rand==0 then
      player.Damage=player.Damage+1;
    elseif rand==1 then
      player.MoveSpeed=player.MoveSpeed+1;
    elseif rand==1 then
      player.ShotSpeed=player.ShotSpeed+0.4;
    elseif rand==1 then
      player.TearHeight = player.TearHeight +0.6;
    elseif rand==1 then
      player.Luck = player.Luck+1;
    end
    
    Isaac.GetPlayer(0):TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 0)
    
  end
end

--Function to update colors
function Soulforge:Colorupdate()
  player = Isaac.GetPlayer(0);
  if player:HasCollectible(FlameThrower) == true then
    Isaac.GetPlayer(0).TearColor = Color(255.0,93,0,1,1,0,0)
  end
  if player:HasCollectible(DarkSoul) == true then
    Isaac.GetPlayer(0).TearColor = Color(0,0,0,1,1,0,0)
  end
  if player:HasCollectible(DemonSoul) == true then
    Isaac.GetPlayer(0).TearColor = Color(159,117,117,1,1,0,0)
  end
  if player:HasCollectible(AngelSoul) == true then
    Isaac.GetPlayer(0).TearColor = Color(108,122,189,1,1,0,0)
  end
  if player:HasCollectible(BumboSoul) == true then
    Isaac.GetPlayer(0).TearColor = Color(255,215,0,1,1,0,0)
  end
  if player:HasCollectible(PureSoul) == true then
    Isaac.GetPlayer(0).TearColor = Color(255,255,255,1,1,0,0)
  end
  if player:HasCollectible(StainedSoul) == true then
    Isaac.GetPlayer(0).TearColor = Color(94,110,98,1,1,0,0)
  end
end



-- Manages the starting-stats of the player
function Soulforge:AddPlayerStats()
  player=Isaac.GetPlayer(0)
  player:GetName() == "Dead Spider" then
    
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
      player.Damage = 10
    else if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
      player.ShotSpeed = 1
    else if cacheFlag == CacheFlag.CACHE_FIREDELAY then
      player.MaxFireDelay = player.MaxFireDelay + 10
    else if cacheFlag == CacheFlag.CACHE_SPEED then
      player.MoveSpeed = 1.5
    else if cacheFlag == CacheFlag.CACHE_LUCK then
      player.Luck = 1
    end
    
    player:GetEffect():AddCollectibleEffect(CollectibleType.COLLECTIBLE_JUICY_SACK,false)
    player:GetEffect():AddCollectibleEffect(CollectibleType.COLLECTIBLE_SERPENTS_KISS ,false)
    
  end

  player:GetName() == "Neofantasia" then
   
   if cacheFlag == CacheFlag.CACHE_DAMAGE then
      player.Damage = 10
    else if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
      player.ShotSpeed = 1
    else if cacheFlag == CacheFlag.CACHE_FIREDELAY then
      player.MaxFireDelay = player.MaxFireDelay + 8
    else if cacheFlag == CacheFlag.CACHE_SPEED then
      player.MoveSpeed = 1.5
    else if cacheFlag == CacheFlag.CACHE_LUCK then
      player.Luck = 1
    end
    
    player:AddCollectible(CollectiblType.COLLECTIBLE_BLACK_HOLE, 6, false)
    player:GetEffect():AddCollectibleEffect(CollectibleType.COLLECTIBLE_GHOST_PEPPER ,false)
    
  end

  player:GetName() == "Ullisandra" then
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        player.Damage = 10
    else if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = 1
    else if cacheFlag == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = player.MaxFireDelay + 2
    else if cacheFlag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = 1.5
    else if cacheFlag == CacheFlag.CACHE_LUCK then
        player.Luck = 1
    end
    
    player:AddCollectible(CollectiblType.COLLECTIBLE_SATANIC_BIBLE, 6, false)
    player:GetEffect():AddCollectibleEffect(CollectibleType.COLLECTIBLE_MAW_OF_VOID,false)
    player:GetEffect():AddCollectibleEffect(CollectibleType.COLLECTIBLE_VARICOSE_VEINS,false)
    
  end
end


  function Soulforge:Spidermanager()
  if Isaac.GetPlayer(0):GetName=="Dead Spider" and spiderlist<8 and Game():GetFrameCount()==1 then
    Soulforge.AddSpider()
  end
end

function Soulforge:AddSpider()
  rand=math.random(0,6)
  if rand==0 then
    local spider= Isaac.spawn(EntityType.ENTITY_RAGLING,0,0,Isaac.GetPlayer(0).Position,Vector(0,0),Isaac.GetPlayer(0))
  else if rand==1 then
    local spider= Isaac.spawn(EntityType.ENTITY_SPIDER_L2,0,0,Isaac.GetPlayer(0).Position,Vector(0,0),Isaac.GetPlayer(0))
  else if rand==2 then
    local spider= Isaac.spawn(EntityType.ENTITY_BIGSPIDER,0,0,Isaac.GetPlayer(0).Position,Vector(0,0),Isaac.GetPlayer(0))
  else if rand==3
    local spider= Isaac.spawn(EntityType.ENTITY_SPIDER,0,0,Isaac.GetPlayer(0).Position,Vector(0,0),Isaac.GetPlayer(0))
  end
  spider.AddCharmed(-1)
  table.insert(spiderlist,spider)
end

function Soulforge:Fantasiamanager()
  if Isaac.GetPlayer(0):GetName=="Neofantasia" then
    rand=math.random(0,100)
    if rand*(Isaac.GetPlayer(0).Luck+0.5)<36 then
      tear=Isaac.spawn(EntityType.ENTITY_TEAR,0,0,Isaac.GetPlayer(0).Position,Vector(math.random(0,1),math.random(0,1)),0),Isaac.GetPlayer(0))
      tear.TearHeight=40
      tear.TearDamage=Isaac.GetPlayer(0).damage*1.2
    end
  end
end







--Environmental callbacks (Contain callbacks for some items)
Soulforge:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Soulforge.Reset)
--Soulforge:AddCallback( ModCallbacks.MC_POST_UPDATE, Soulforge.checkConsumables);

--Callbacks for Itemcolors (Mostly for testing purpose)
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.Colorupdate)
--Soulforge:AddCallback(ModCallbacks.MC_POST_UPDATE, Soulforge.Colorupdate)

--Callback for Items
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.FlamethrowerF)
Soulforge:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Soulforge.FlamethrowerDamage, EntityType.ENTITY_PLAYER)

--Callback for Floorupdate
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.AngelFloor)
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.DemonFloor)

--Callbacks for Characters
Soulforge:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Soulforge.AddPlayerStats)
--Soulforge:AddCallback(ModCallbacks.MC_POST_TEAR_INIT , Soulforge.Fantasiamanager)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_ROOM , Soulforge.AddSpider)
