local Soulforge = RegisterMod("Soulforge",1)

local BumboSoul = Isaac.GetItemIdByName ("BumBo Soul")
local FlameThrower = Isaac.GetItemIdByName ("Flamethrower")
local AngelSoul = Isaac.GetItemIdByName ("Angel Soul")  --Hallo
local DemonSoul = Isaac.GetItemIdByName ("Demon Soul")
local DarkSoul = Isaac.GetItemIdByName ("Dark Soul")
local Stained = Isaac.GetItemIdByName ("Stained Soul") -- Sample Image
local PureSoul = Isaac.GetItemIdByName ("Pure Soul") -- Sample Image

local log = {}

local debugText = ""
local debugbool=true

local currCoins = 0
local currKeys = 0
local currBombs = 0
local currHearts = 0

local stainedState=0
local stainedMama=false
local flameFirst=true
local itemsupdated=false

local bumDmg=0
local bumRange=0
local bumSpeed=0
local bumShot=0
local bumLuck=0
local bumbcoin=0

local demonDmg=0
local demonRange=0
local demonShot=0
local demonSpeed=0
local demonLuck=0

--Function to set default values
function Soulforge:Reset()
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


function Soulforge:debug()
  Isaac.RenderText(debugText,100,100,255,0,0,255)
end

--Function to check if any consumable changed
function Soulforge:checkConsumables()
  player = Isaac.GetPlayer(0);
 
  if(currCoins < player:GetNumCoins()) then
      --debugText = "picked up a coin";
      if Isaac.GetPlayer(0):HasCollectible(BumboSoul) then
        bumbcoin=bumbcoin+player:GetNumCoins()-currCoins
        
        while bumbcoin>1 do
          bumboAfterPickup()
          bumbcoin=bumbcoin-2
          player:AddCoins(-1)
        end
      end
  end
 
  if(currKeys < player:GetNumKeys()) then
      --debugText = "picked up a key"; -- HasGoldenKey()
  end
 
  if(currBombs < player:GetNumBombs()) then
      --debugText = "picked up a bomb"; -- HasGoldenBomb()
  end
 
  if(currHearts < player:GetHearts()) then
      --debugText = "picked up a heart";
      darkAfterPickup()
  end
 
  currCoins = player:GetNumCoins();
  currKeys = player:GetNumKeys();
  currBombs = player:GetNumBombs();
  currHearts = player:GetHearts(); -- GetMaxHearts(), GetSoulHearts(), GetBlackHearts(), GetEternalHearts(), GetGoldenHearts()
end


-- Code for the Flamethrower
function Soulforge:FlamethrowerF(player,flag)
  if Isaac.GetPlayer(0):HasCollectible(FlameThrower) == true then
    
    
    if flag == CacheFlag.CACHE_DAMAGE then 
      Isaac.GetPlayer(0).Damage = Isaac.GetPlayer(0).Damage*1.5/3
    elseif flag == CacheFlag.CACHE_FIREDELAY then
      itemsupdated=true
    elseif flag == CacheFlag.CACHE_RANGE then
      Isaac.GetPlayer(0).TearFallingSpeed = Isaac.GetPlayer(0).TearFallingSpeed-3
    end
    
    
    if flameFirst==true then
      Isaac.GetPlayer(0).TearFlags = Isaac.GetPlayer(0).TearFlags + TearFlags.TEAR_PIERCING + TearFlags.TEAR_BURN
      flameFirst=false
    end
  end
end

-- deny explosion damage
function Soulforge:FlamethrowerDamage(player_x, damage, flag, source, countdown)
  local player = Isaac.GetPlayer(0);
    if player:HasCollectible(FlameThrower) and flag == DamageFlag.DAMAGE_EXPLOSION then
        return false;
    end
end

--Needed to change the Max-Firedelay
function Soulforge:FlamethrowerPost()
  if player:HasCollectible(FlameThrower) and itemsupdated==true then
    itemsupdated=false
    if Isaac.GetPlayer(0).MaxFireDelay - 8>0 then
      Isaac.GetPlayer(0).MaxFireDelay = Isaac.GetPlayer(0).MaxFireDelay - 8
    else
      Isaac.GetPlayer(0).MaxFireDelay= 1
    end
    
  end
end

--Bumbo Soul Functions
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
    --debugText="dmg:" .. bumDmg .. " spd:" .. bumSpeed .." sspd:" .. bumShot .. " rng:" .. bumRange .. " lck:" .. bumLuck
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
    --debugText="dmg:" .. demonDmg .. " spd:" .. demonSpeed .." sspd:" .. demonShot .. " rng:" .. demonRange .. " lck:" .. demonLuck
  end
end


--Stained Soul Floor function
function Soulforge:StainedFloor()
  if Isaac.GetPlayer(0):HasCollectible(Stained) == true then
    player=Isaac.GetPlayer(0)
    
    stainedStateold=stainedState
    stainedState = math.random(0,4)
    
    if stainedStateold==1 then
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
      player:EvaluateItems()
    elseif stainedStateold==3 then
      stainedMama=false
    end
  
    
    
    if stainedState==0 then
      --debugText="Add Coins"
      player:AddCoins(15)
    elseif stainedState==1 then
      --debugText="Add Damage"
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
      player:EvaluateItems()
    elseif stainedState==2 then
      --debugText="Add Hearts"
      player:AddBlackHearts(4)
    elseif stainedState==3 then
      --debugText="Add Mama"
      stainedMama=true
    end
  end
end

--Stained Soul Mama Mega effect
function Soulforge:StainedM()
  if stainedMama==true then
    rand=math.random(0,4)
    if (rand == 0) then
      Game():GetRoom():MamaMegaExplossion()
    end
  end
end

function Soulforge:StainedDmg(pla,flag)
  if Isaac.GetPlayer(0):HasCollectible(Stained) == true then
    if stainedState==1 then
      if flag == CacheFlag.CACHE_DAMAGE then 
        Isaac.GetPlayer(0).Damage=Isaac.GetPlayer(0).Damage+2
      end
    end
  end
end

function Soulforge:PureSoul () 
  if Isaac.GetPlayer(0):HasCollectible(PureSoul) == true then
    player=Isaac.GetPlayer(0)
    game = Game() 
    level = game:GetLevel()
    
    rand = math.random(0,4)
    rand= 3
    if rand==0 then
      level:ShowMap()
    elseif rand==1 then
      level:RemoveCurses()
    elseif rand==2 then
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_GOLDEN, Vector(Isaac.GetPlayer(0).Position.X, Isaac.GetPlayer(0).Position.Y), Vector(0,0), Isaac.GetPlayer(0))
    elseif rand==3 then
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GOLDEN, Vector(Isaac.GetPlayer(0).Position.X, Isaac.GetPlayer(0).Position.Y), Vector(0,0), Isaac.GetPlayer(0))
    end
    

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
  if player:HasCollectible(Stained) == true then
    Isaac.GetPlayer(0).TearColor = Color(94,110,98,1,1,0,0)
  end
end




--Environmental callbacks (Contain callbacks for some items)
Soulforge:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Soulforge.Reset)
Soulforge:AddCallback( ModCallbacks.MC_POST_UPDATE, Soulforge.checkConsumables);

--Callbacks for Itemcolors (Mostly for testing purpose)
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.Colorupdate)
Soulforge:AddCallback(ModCallbacks.MC_POST_UPDATE, Soulforge.Colorupdate)

--Callback for Items
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.FlamethrowerF)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Soulforge.StainedM)
Soulforge:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Soulforge.FlamethrowerDamage, EntityType.ENTITY_PLAYER)
Soulforge:AddCallback(ModCallbacks.MC_POST_UPDATE, Soulforge.FlamethrowerPost)
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.BumboUp)
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.DemonUp)
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.StainedDmg)


--Callback for Floorupdate
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.AngelFloor)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.DemonFloor)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.StainedFloor)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.PureSoul)

--debug
Soulforge:AddCallback(ModCallbacks.MC_POST_RENDER, Soulforge.debug)
