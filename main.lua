local Soulforge = RegisterMod("Soulforge",1)

local BumboSoul = Isaac.GetItemIdByName ("BumBo Soul")
local FlameThrower = Isaac.GetItemIdByName ("Flamethrower")
local AngelSoul = Isaac.GetItemIdByName ("Angel Soul")  --Hallo
local DemonSoul = Isaac.GetItemIdByName ("Demon Soul")
local DarkSoul = Isaac.GetItemIdByName ("Dark Soul")
local Stained = Isaac.GetItemIdByName ("Stained Soul") -- Sample Image
local PureSoul = Isaac.GetItemIdByName ("Pure Soul") -- Sample Image

local repItem1 = true
local log = {}

local debugText = ""

local currCoins = 0
local currKeys = 0
local currBombs = 0
local currHearts = 0

local stainedState=0
local stainedMama=false

--Function to set default values
function Soulforge:Reset()
  player = Isaac.GetPlayer(0);
  repItem1 = true
  currCoins = player:GetNumCoins();
  currKeys = player:GetNumKeys();
  currBombs = player:GetNumBombs();
  currHearts = player:GetHearts();
  stainedState=0;
end

function Soulforge:debug()
  Isaac.RenderText(debugText,100,100,255,0,0,255)
end

--Function to check if any consumable changed
function Soulforge:checkConsumables()
  player = Isaac.GetPlayer(0);
 
  if(currCoins < player:GetNumCoins()) then
      --debugText = "picked up a coin";
      bumboAfterPickup()
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
function Soulforge:FlamethrowerF()
  if Isaac.GetPlayer(0):HasCollectible(FlameThrower) and repItem1 == true then
    
    Isaac.GetPlayer(0).Damage = Isaac.GetPlayer(0).Damage*2/3
    Isaac.GetPlayer(0).FireDelay = Isaac.GetPlayer(0).FireDelay-1
    Isaac.GetPlayer(0).TearHeight = Isaac.GetPlayer(0).TearHeight-3
    Isaac.GetPlayer(0).TearFlags = Isaac.GetPlayer(0).TearFlags + TearFlags.TEAR_PIERCING + TearFlags.TEAR_BURN
    
    pos = Vector(Isaac.GetPlayer(0).Position.X, Isaac.GetPlayer(0).Position.Y);
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_PYROMANIAC, pos, Vector(0,0), Isaac.GetPlayer(0))
    
    repItem1 = false
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
    rand = math.random(0,5)
    if rand==0 then
      player.Damage=player.Damage+1;
    elseif rand==1 then
      player.MoveSpeed=player.MoveSpeed+1;
    elseif rand==2 then
      player.ShotSpeed=player.ShotSpeed+0.4;
    elseif rand==3 then
      player.TearHeight = player.TearHeight +0.6;
    elseif rand==4 then
      player.Luck = player.Luck+1;
    end
    
    Isaac.GetPlayer(0):TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 0)
    
  end
end

--Stained Soul Floor function
function Soulforge:StainedFloor()
  if Isaac.GetPlayer(0):HasCollectible(Stained) == true then
    player=Isaac.GetPlayer(0)
    if stainedState==1 then
      player.Damage=player.Damage-2
    elseif stainedState==4 then
      stainedMama=false
    end
    
    stainedState = math.random(0,5)
    if stainedState==0 then
      --debugText="Add Coins"
      player:AddCoins(15)
    elseif stainedState==1 then
      --debugText="Add Damage"
      player.Damage=player.Damage+2
    elseif stainedState==2 then
      --debugText="Add Devilroom"
      Game():GetRoom():TrySpawnDevilRoomDoor()
    elseif stainedState==3 then
      --debugText="Add Hearts"
      player:AddBlackHearts(4)
    elseif stainedState==4 then
      --debugText="Add Mama"
      stainedMama=true
    end
  end
end

--Pure Soul Function
function Soulforge:PureFloor () 
  if Isaac.GetPlayer(0):HasCollectible(PureSoul) == true then
    player=Isaac.GetPlayer(0)
    game = Game() 
    level = game:GetLevel()
    
    rand = math.random(0,5)
    if rand==0 then
      level:ShowMap()
    elseif rand==1 then
      level:RemoveCurses()
    elseif rand==2 then
      level:InitializeDevilAngelRoom(true,false)
      Game():GetRoom():TrySpawnDevilRoomDoor()
    elseif rand==3 then
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_GOLDEN, Vector(Isaac.GetPlayer(0).Position.X, Isaac.GetPlayer(0).Position.Y), Vector(0,0), Isaac.GetPlayer(0))
    elseif rand==4 then
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

--Callback for Floorupdate
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.AngelFloor)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.DemonFloor)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.StainedFloor)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.PureFloor)

--debug
Soulforge:AddCallback(ModCallbacks.MC_POST_RENDER, Soulforge.debug)
