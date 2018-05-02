-- loading the mod
local Soulforge = RegisterMod("Soulforge",1)

-- initializing the items
local BumboSoul = Isaac.GetItemIdByName ("BumBo Soul")
local FlameThrower = Isaac.GetItemIdByName ("Flamethrower")
local AngelSoul = Isaac.GetItemIdByName ("Angel Soul")  --Hallo
local DemonSoul = Isaac.GetItemIdByName ("Demon Soul")
local DarkSoul = Isaac.GetItemIdByName ("Dark Soul")
local Stained = Isaac.GetItemIdByName ("Stained Soul") -- Sample Image
local PureSoul = Isaac.GetItemIdByName ("Pure Soul") -- Sample Image

-- variables for debuging
local debugText = ""
local debugbool=true

-- variables to keep track of the current pickups and red health
local currCoins = 0
local currKeys = 0
local currBombs = 0
local currHearts = 0

-- variables to manage the stained soul
local stainedState=0
local stainedMama=false

-- variables to manage the "flamethrower"
local flameFirst=true
local itemsupdated=false -- workaround for firerate update

-- variables to manage bumbo soul
local bumDmg=0
local bumRange=0
local bumSpeed=0
local bumShot=0
local bumLuck=0
local bumbcoin=0

-- variables to manage demon soul
local demonDmg=0
local demonRange=0
local demonShot=0
local demonSpeed=0
local demonLuck=0

-- function to set default values for the mod
function Soulforge:Reset()
  debugText=""
  debugbool=false
  
  player = Isaac.GetPlayer(0);
  currCoins = player:GetNumCoins();
  currKeys = player:GetNumKeys();
  currBombs = player:GetNumBombs();
  currHearts = player:GetHearts();
  
  stainedState=0;
  
  bumDmg=0
  bumRange=0
  bumSpeed=0
  bumShot=0
  bumLuck=0
  bumbcoin=0
  
  demonDmg=0
  demonRange=0
  demonShot=0
  demonSpeed=0
  demonLuck=0
  
  
end

-- function to display debug text in game if needed. not in use until debugbool gets set true
function Soulforge:debug()
  if debugbool==true then
    -- to display a debug message comment all other messages and set debugbool to true in the reset function.
    Isaac.RenderText(debugText,100,100,255,0,0,255)
  end
end

-- function to check if any consumable or red hearts changed
function Soulforge:checkConsumables()
  player = Isaac.GetPlayer(0);
  
  -- generaly it compares the old coin value with the new one if the game got updated
  
  if(currCoins < player:GetNumCoins()) then
      debugText = "picked up a coin"
      
      -- checks if the player has the bumbo soul and updates the bumbo coin value.
      if Isaac.GetPlayer(0):HasCollectible(BumboSoul) then
        bumbcoin=bumbcoin+player:GetNumCoins()-currCoins
        -- if the player has 2 or more coins, the bumboAfterPickup function gets called and coin and bumbo coin values get updated acordingly
        while bumbcoin>1 do
          bumboAfterPickup()
          bumbcoin=bumbcoin-2
          player:AddCoins(-1)
        end
      end
  end
  
  -- calls darkAfterPickup if a red heart gets picked up
  if(currHearts < player:GetHearts()) then
      debugText = "picked up a heart";
      darkAfterPickup()
  end
 
  -- unused pickup checks
  if(currKeys < player:GetNumKeys()) then
      debugText = "picked up a key"
  end
  
  if player:HasGoldenKey() then
    debugText=  "picked up a golden key"
  end
 
  if(currBombs < player:GetNumBombs()) then
      debugText = "picked up a bomb"
  end
 
  if player:HasGoldenBomb() then
    debugText=  "picked up a golden bomb"
  end
 
  -- updates the current values of their respective type
  currCoins = player:GetNumCoins();
  currKeys = player:GetNumKeys();
  currBombs = player:GetNumBombs();
  currHearts = player:GetHearts(); -- GetMaxHearts(), GetSoulHearts(), GetBlackHearts(), GetEternalHearts(), GetGoldenHearts()
end


-- function to set the stats and TearFlags for flamethrower.
function Soulforge:FlamethrowerF(player,flag)
  if Isaac.GetPlayer(0):HasCollectible(FlameThrower) == true then

    pos = Vector(Isaac.GetPlayer(0).Position.X, Isaac.GetPlayer(0).Position.Y)
    if flag == CacheFlag.CACHE_DAMAGE then 
      Isaac.GetPlayer(0).Damage = Isaac.GetPlayer(0).Damage*1.5/3
    elseif flag == CacheFlag.CACHE_FIREDELAY then
      itemsupdated=true
    elseif flag == CacheFlag.CACHE_RANGE then
      -- I don't know the reason why this appearently doesn't get called .-.
      -- Moved it to the flame First block below as it seems to work there
    end
    
    if flameFirst==true then
      Isaac.GetPlayer(0).TearFlags = Isaac.GetPlayer(0).TearFlags + TearFlags.TEAR_PIERCING + TearFlags.TEAR_BURN
      flameFirst=false
      Isaac.GetPlayer(0).TearFallingSpeed = Isaac.GetPlayer(0).TearFallingSpeed-1.7
    end
  end
end

-- function to prevent explosion damage on player
function Soulforge:FlamethrowerDamage(player_x, damage, flag, source, countdown)
  local player = Isaac.GetPlayer(0)
    if player:HasCollectible(FlameThrower) and flag == DamageFlag.DAMAGE_EXPLOSION then
        return false;
    end
end

-- Workaround function seemingly needed to change the Max-Firedelay.
function Soulforge:FlamethrowerPost()
  if player:HasCollectible(FlameThrower) and itemsupdated==true then
    itemsupdated=false
    -- increases tearrate drasticaly without making it negative. 
    if Isaac.GetPlayer(0).MaxFireDelay - 8>0 then
      Isaac.GetPlayer(0).MaxFireDelay = Isaac.GetPlayer(0).MaxFireDelay - 8
    else
      Isaac.GetPlayer(0).MaxFireDelay= 1
    end
  end
end

-- function to randomly add stacks on stats and force a reevaluation 
function bumboAfterPickup()
  player = Isaac.GetPlayer(0);
  local rand = math.random(0,5)
  
  if rand==0 then
    bumDmg=bumDmg+1
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
  elseif rand==1 then
    bumSpeed=bumSpeed+1
    player:AddCacheFlags(CacheFlag.CACHE_SPEED)
  elseif rand==2 then
    bumShot=bumShot+1
    player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
  elseif rand==3 then
    bumRange=bumRange+1
    player:AddCacheFlags(CacheFlag.CACHE_RANGE)
  elseif rand==4 then
    bumLuck=bumLuck+1
    player:AddCacheFlags(CacheFlag.CACHE_LUCK)
  end
  
  player:EvaluateItems()
end

-- function to set stats acordingly to bumbo-stat-stacks
function Soulforge:BumboUp(pla,flag)
  
  if player:HasCollectible(BumboSoul) then
    player = Isaac.GetPlayer(0);
    
    if flag == CacheFlag.CACHE_DAMAGE then 
      player.Damage=player.Damage+0.1*bumDmg
    elseif flag == CacheFlag.CACHE_RANGE then
      player.TearFallingSpeed = player.TearFallingSpeed+0.04*bumRange
    elseif flag == CacheFlag.CACHE_LUCK then
      player.Luck = player.Luck+0.4*bumLuck
    elseif flag == CacheFlag.CACHE_SHOTSPEED then
      player.ShotSpeed=player.ShotSpeed+0.004*bumShot
    elseif flag == CacheFlag.CACHE_SPEED then
      player.MoveSpeed=player.MoveSpeed+0.06*bumSpeed
    end
    debugText="dmg:" .. bumDmg .. " spd:" .. bumSpeed .." sspd:" .. bumShot .. " rng:" .. bumRange .. " lck:" .. bumLuck
  end
end

-- function for either damaging the players red hearts or adding a black heart
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
  
-- function for adding an eternal heart at the begining of each floor
function Soulforge:AngelFloor()
  if Isaac.GetPlayer(0):HasCollectible(AngelSoul) == true then
    Isaac.GetPlayer(0):AddEternalHearts(1)
  end
end

-- function for adding stacks on demon-soul-stats, damaging the player and reevaluating the stats at the begining of each floor
function Soulforge:DemonFloor()
  player=Isaac.GetPlayer(0)
  if player:HasCollectible(DemonSoul) == true then 
    rand = math.random(0,5)
    if rand==0 then
      demonDmg=demonDmg+1
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    elseif rand==1 then
      demonSpeed=demonSpeed+1
      player:AddCacheFlags(CacheFlag.CACHE_SPEED)
    elseif rand==2 then
      demonShot=demonShot+1
      player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
    elseif rand==3 then
      demonRange=demonRange+1
      player:AddCacheFlags(CacheFlag.CACHE_RANGE)
    elseif rand==4 then
      demonLuck=demonLuck+1
      player:AddCacheFlags(CacheFlag.CACHE_LUCK)
    end
    
    Isaac.GetPlayer(0):TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 0)
    player:EvaluateItems()
    
  end
end

-- function to set stats acordingly to demon-soul-stat-stacks
function Soulforge:DemonUp(pla,flag)
  
  if player:HasCollectible(DemonSoul) then
    player = Isaac.GetPlayer(0);
    
    if flag == CacheFlag.CACHE_DAMAGE then 
      player.Damage=player.Damage+2*demonDmg
    elseif flag == CacheFlag.CACHE_RANGE then
      player.TearFallingSpeed = player.TearFallingSpeed+0.1*demonRange
    elseif flag == CacheFlag.CACHE_LUCK then
      player.Luck = player.Luck+1*demonLuck
    elseif flag == CacheFlag.CACHE_SHOTSPEED then
      player.ShotSpeed=player.ShotSpeed+0.4*demonShot
    elseif flag == CacheFlag.CACHE_SPEED then
      player.MoveSpeed=player.MoveSpeed+0.1*demonSpeed
    end
    debugText="dmg:" .. demonDmg .. " spd:" .. demonSpeed .." sspd:" .. demonShot .. " rng:" .. demonRange .. " lck:" .. demonLuck
  end
end


-- function for giving diverse effects at the begining of each floor if player obsesses the stained soul
function Soulforge:StainedFloor()
  if Isaac.GetPlayer(0):HasCollectible(Stained) == true then
    player=Isaac.GetPlayer(0)
    
    -- neccessary to remove some effects: Mama Mega explosion chance and damage up
    -- stainedState decides which effect will be called later in this function
    stainedStateold=stainedState
    stainedState = math.random(0,4)
    
    if stainedStateold==1 then
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
      player:EvaluateItems()
    elseif stainedStateold==3 then
      stainedMama=false
    end
  
    
    -- read the debugText strings for information on what each of the effects does
    if stainedState==0 then
      debugText="Add Coins"
      player:AddCoins(15)
    elseif stainedState==1 then
      debugText="Add Damage"
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
      player:EvaluateItems()
    elseif stainedState==2 then
      debugText="Add Black Heart"
      player:AddBlackHearts(4)
    elseif stainedState==3 then
      debugText="Add Mama Mega "
      stainedMama=true
    end
  end
end

-- function to manage the stained soul Mama Mega effect
function Soulforge:StainedM()
  if stainedMama==true then
    rand=math.random(0,100)
    if rand*(Isaac.GetPlayer(0).Luck+1)>80 then
      Game():GetRoom():MamaMegaExplossion()
    end
  end
end

-- function to update the damage if the stained soul requires it.
function Soulforge:StainedDmg(pla,flag)
  if Isaac.GetPlayer(0):HasCollectible(Stained) == true then
    if stainedState==1 then
      if flag == CacheFlag.CACHE_DAMAGE then 
        Isaac.GetPlayer(0).Damage=Isaac.GetPlayer(0).Damage+2
      end
    end
  end
end

-- function for giving diverse effects at the begining of each floor if player obsesses the pure soul
function Soulforge:PureSoul () 
  if Isaac.GetPlayer(0):HasCollectible(PureSoul) == true then
    player=Isaac.GetPlayer(0)
    game = Game() 
    level = game:GetLevel()
    
    rand = math.random(0,4)
    
    -- read the debugText strings for information on what each of the effects does
    if rand==0 then
      level:ShowMap()
      debugText="Show Map"
    elseif rand==1 then
      level:RemoveCurses()
      debugText="Remove curses"
    elseif rand==2 then
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_GOLDEN, Vector(Isaac.GetPlayer(0).Position.X, Isaac.GetPlayer(0).Position.Y), Vector(0,0), Isaac.GetPlayer(0))
      debugText="Spawn Golden Key"
    elseif rand==3 then
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GOLDEN, Vector(Isaac.GetPlayer(0).Position.X, Isaac.GetPlayer(0).Position.Y), Vector(0,0), Isaac.GetPlayer(0))
      debugText="Spawn Golden Bomb"
    end
    

  end
end

--Function to update colors
function Soulforge:Colorupdate()
  player = Isaac.GetPlayer(0);
  if player:HasCollectible(FlameThrower) == true then
    Isaac.GetPlayer(0).TearColor = Color(255.0,93,0,1,1,0,0)
  elseif player:HasCollectible(DarkSoul) == true then
    Isaac.GetPlayer(0).TearColor = Color(0,0,0,1,1,0,0)
  elseif player:HasCollectible(DemonSoul) == true then
    Isaac.GetPlayer(0).TearColor = Color(159,117,117,1,1,0,0)
  elseif player:HasCollectible(AngelSoul) == true then
    Isaac.GetPlayer(0).TearColor = Color(108,122,189,1,1,0,0)
  elseif player:HasCollectible(BumboSoul) == true then
    Isaac.GetPlayer(0).TearColor = Color(255,215,0,1,1,0,0)
  elseif player:HasCollectible(PureSoul) == true then
    Isaac.GetPlayer(0).TearColor = Color(255,255,255,1,1,0,0)
  elseif player:HasCollectible(Stained) == true then
    Isaac.GetPlayer(0).TearColor = Color(94,110,98,1,1,0,0)
  end
end


-- function that manages starting stats of custom player characters
function Soulforge:SetPlayerStats(p,cacheFlag)
  player=Isaac.GetPlayer(0)
  
  if player:GetName() == "Ulisandra" then
    
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
      player.Damage = player.Damage + 2
    end
    if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
      player.ShotSpeed =player.ShotSpeed + 0.3
    end
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
      player.MaxFireDelay = player.MaxFireDelay + 20
    end
    if cacheFlag == CacheFlag.CACHE_SPEED then
      player.MoveSpeed = player.MoveSpeed - 0.7
    end
    if cacheFlag == CacheFlag.CACHE_LUCK then
      player.Luck = player.Luck -- Redundant but kept for possible rebalancing purpose
    end
  end
  
  if player:GetName() == "Dead Spider" then
    
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
      player.Damage = player.Damage + 2
    end
    if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
      player.ShotSpeed = player.ShotSpeed - 1
    end
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
      player.MaxFireDelay = player.MaxFireDelay + 2
    end
    if cacheFlag == CacheFlag.CACHE_SPEED then
      player.MoveSpeed = player.MoveSpeed + 0.5
    end
    if cacheFlag == CacheFlag.CACHE_LUCK then
      player.Luck = player.Luck - 1
    end
  end
  
  if player:GetName() == "Neofantasia" then
   
   if cacheFlag == CacheFlag.CACHE_DAMAGE then
      player.Damage = player.Damage -2
    end
    if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
      player.ShotSpeed = player.ShotSpeed - 2
    end
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
      player.MaxFireDelay = player.MaxFireDelay - 4
    end
    if cacheFlag == CacheFlag.CACHE_SPEED then
      player.MoveSpeed = player.MoveSpeed + 3
    end
    if cacheFlag == CacheFlag.CACHE_LUCK then
      player.Luck = player.Luck + 1
    end
    
  end
end

-- function that manages the spacebar-items of the custom player characters. also clears costumes on initialization
function  Soulforge:Playermanager()
  player=Isaac.GetPlayer(0)
  player:ClearCostumes()
  

  if player:GetName() == "Ulisandra" then
    player:AddBoneHearts(4)
    player:AddHearts(8) --Those lines set the hearts of the character to 4 fully filled bone hearts. Pre Booster 5 Ulisandra had 4 Hearts and "VARICOSE VEINS". Rebalanced some power into starting stats
    player:AddCollectible(CollectibleType.COLLECTIBLE_SATANIC_BIBLE, 6, false)
    -- sets the hair as costume with high priority
    Costume = Isaac.GetCostumeIdByPath("gfx/characters/costume_ulisandrahair.anm2")
    player:AddNullCostume(Costume)
    
  end
  
  if player:GetName() == "Dead Spider" then
    player:AddCollectible(DarkSoul,0 , true)
    player:ClearCostumes()
    
  end
  
  if player:GetName() == "Neofantasia" then
    player:AddCollectible(Stained,0 , true)
    player:ClearCostumes()
    player:AddCollectible(CollectibleType.COLLECTIBLE_BLACK_HOLE, 6, false)
    
  end
  
  
end

-- list for spawned spiders
local spiderlist={}

-- function for managing the passive effect of "Dead Spider" (spawning spiders on visiting new rooms)
function Soulforge:Spidermanager()
  if Isaac.GetPlayer(0):GetName()=="Dead Spider" and Game():GetRoom():IsFirstVisit()then
    AddSpider()
    debugText="Spider spawned"
  end
end

-- function that spawns spiders depending on the players luck.
function AddSpider()
  luck=Isaac.GetPlayer(0).Luck
  -- spawn-chance and randomizer
  if 16-luck>3 then
    rand=math.random(0,16-luck)
  else
    rand=math.random(0,4)
  end
  
  if rand==0 then
    spider= Isaac.Spawn(EntityType.ENTITY_RAGLING,0,0,Isaac.GetPlayer(0).Position,Vector(0,0),Isaac.GetPlayer(0))
    debugText="Spider type 0"
    addspidertolist(spiderlist,spider)
  elseif rand==1 then
    spider= Isaac.Spawn(EntityType.ENTITY_SPIDER_L2,0,0,Isaac.GetPlayer(0).Position,Vector(0,0),Isaac.GetPlayer(0))
    debugText="Spider type 1"
    addspidertolist(spiderlist,spider)
  elseif rand==2 then
    spider= Isaac.Spawn(EntityType.ENTITY_BIGSPIDER,0,0,Isaac.GetPlayer(0).Position,Vector(0,0),Isaac.GetPlayer(0))
    debugText="Spider type 2"
    addspidertolist(spiderlist,spider)
  elseif rand==3 then
    spider= Isaac.Spawn(EntityType.ENTITY_SPIDER,0,0,Isaac.GetPlayer(0).Position,Vector(0,0),Isaac.GetPlayer(0))
    debugText="Spider type 3"
    addspidertolist(spiderlist,spider)
  end
end

-- functions that adds spiders to the list (duh :P) and charms them.
function addspidertolist(list,entity)
  entity:AddCharmed(-1)
  table.insert(list,entity)
end

-- function for managing the passive effect of "Neofantasia" (Spawning floating tears depending on luck)
function Soulforge:Fantasiamanager()
  if Isaac.GetPlayer(0):GetName()=="Neofantasia" then
    rand=math.random(0,100)
    -- just an overly complicated way for determining the chance of spawning an floating tear
    if 1+rand*(Isaac.GetPlayer(0).Luck+0.5)>74 then
      tear=Isaac.Spawn(EntityType.ENTITY_TEAR,0,0,Isaac.GetPlayer(0).Position,Vector(math.random(-1,1)*Isaac.GetPlayer(0).MoveSpeed,math.random(-1,1)*Isaac.GetPlayer(0).MoveSpeed,0),Isaac.GetPlayer(0))
      tear.CollisionDamage=Isaac.GetPlayer(0).Damage*1.2
    end
  end
end






-- Environmental callbacks
Soulforge:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Soulforge.Reset)
Soulforge:AddCallback( ModCallbacks.MC_POST_UPDATE, Soulforge.checkConsumables);

-- Callbacks for the flamethrower
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.FlamethrowerF)
Soulforge:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Soulforge.FlamethrowerDamage, EntityType.ENTITY_PLAYER)
Soulforge:AddCallback(ModCallbacks.MC_POST_UPDATE, Soulforge.FlamethrowerPost)

-- Callbacks for functions that need to be called at the begining of each floor
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.AngelFloor)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.DemonFloor)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.StainedFloor)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.PureSoul)

-- Callbacks for the Character specific functions
Soulforge:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Soulforge.Playermanager)
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.SetPlayerStats)
Soulforge:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR , Soulforge.Fantasiamanager)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_ROOM , Soulforge.Spidermanager)

-- Callbacks for the dynamic reevaluation of some items and Mama Mega 
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Soulforge.StainedM)
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.BumboUp)
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.DemonUp)
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.StainedDmg)
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.DemonUp)

-- debug callback (not in environmental because it doesn't have any effects on the mod in casual use). also callbacks for debug colors
Soulforge:AddCallback(ModCallbacks.MC_POST_RENDER, Soulforge.debug)
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.Colorupdate)
Soulforge:AddCallback(ModCallbacks.MC_POST_UPDATE, Soulforge.Colorupdate)
