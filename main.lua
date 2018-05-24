-- loading the mod
local Soulforge = RegisterMod("Soulforge",1)

-- initializing the items
local BumboSoul = Isaac.GetItemIdByName ("Bumbo Soul")
local FlameThrower = Isaac.GetItemIdByName ("Flamethrower")
TearVariant.FLAMETHROWER = Isaac.GetEntityVariantByName("FlameTear") --Loads the animation for the Flamethrower
local AngelSoul = Isaac.GetItemIdByName ("Angel Soul")
local DemonSoul = Isaac.GetItemIdByName ("Demon Soul")
local DarkSoul = Isaac.GetItemIdByName ("Dark Soul")
local Stained = Isaac.GetItemIdByName ("Stained Soul")
local PureSoul = Isaac.GetItemIdByName ("Pure Soul")
PickupVariant.WeakSoul=Isaac.GetEntityVariantByName("Weak Soul")

local SoulforgeVariant=Isaac.GetEntityVariantByName("Soulforge")

local HudPickup=Sprite()
HudPickup:Load("gfx/ui/NumUI.anm2",true)
local HudSouls=Sprite()
HudSouls:Load("gfx/ui/SoulsUI.anm2",true)

-- variables for debuging
local debugText = ""
local debugbool=true

-- variables to keep track of the current pickups and red health
local currCoins = 0
local currKeys = 0
local currBombs = 0
local currHearts = 0


local defaultrundata={
  weakcounter=0,
  soulforgecost=10,
  
  bumDmg=0,
  bumRange=0,
  bumSpeed=0,
  bumShot=0,
  bumLuck=0,
  bumcoin=0,

  demonDmg=0,
  demonRange=0,
  demonShot=0,
  demonSpeed=0,
  demonLuck=0,

  stagecount=0,
  costcount=0,
  stainedState=0,

  stainedMama=false,
  flameFirst=true,

  runseed=Game():GetSeeds():GetStartSeedString()
}
dupestate=defaultrundata

-- keeps track of which side of isaac and in which direction neofantasias tear got fired
local firedtear=1

--keeps track of the offset values for neofantasia
local offsetval1=2
local offsetval2=32
local offsetmod=0

--for save management
local loaded=false

local showSouls=0
local checker=true

-- function to set default values for the mod
function Soulforge:Reset()
  debugText=""
  debugbool=true
  
  player = Isaac.GetPlayer(0);
  currCoins = player:GetNumCoins();
  currKeys = player:GetNumKeys();
  currBombs = player:GetNumBombs();
  currHearts = player:GetHearts();
  
  firedtear=0
  
  offsetval1=2
  offsetval2=32
  offsetmod=0
  
  --making sure dupestate has the right values
  dupestate.runseed=Game():GetSeeds():GetStartSeedString()
  dupestate.weakcounter=0
  dupestate.bumDmg=0
  dupestate.bumRange=0
  dupestate.bumSpeed=0
  dupestate.bumShot=0
  dupestate.bumLuck=0
  dupestate.bumcoin=0
  dupestate.demonDmg=0
  dupestate.demonRange=0
  dupestate.demonShot=0
  dupestate.demonSpeed=0
  dupestate.demonLuck=0
  dupestate.stagecount=0
  dupestate.costcount=0
  dupestate.stainedState=0
  dupestate.stainedMama=false
  dupestate.flameFirst=true
  
  loaded=false
  
  showSouls=player.FrameCount+90
  checker=true
end

-- function to display debug text in game if needed. not in use until debugbool gets set true
function Soulforge:debug()
  if debugbool then
    -- to display a debug message comment all other messages and set debugbool to true in the reset function.
    Isaac.RenderText(debugText,100,100,255,0,0,255)
  end
end

-- function to check if any consumable or red hearts changed
function Soulforge:checkConsumables()
  player = Isaac.GetPlayer(0);
  
  -- generaly it compares the old coin value with the new one if the game got updated
  
  if(currCoins < player:GetNumCoins()) then
      --debugText = "picked up a coin"
      
      -- checks if the player has the bumbo soul and updates the bumbo coin value.
      if Isaac.GetPlayer(0):HasCollectible(BumboSoul) then
        defaultrundata.bumcoin=defaultrundata.bumcoin+player:GetNumCoins()-currCoins
        -- if the player has 2 or more coins, the bumboAfterPickup function gets called and coin and bumbo coin values get updated acordingly
        while defaultrundata.bumcoin>1 do
          bumboAfterPickup()
          defaultrundata.bumcoin=defaultrundata.bumcoin-2
          player:AddCoins(-1)
        end
      end
      if player:GetNumCoins()==99 then
        EvaluateNeofantasiaStage()
      end
  end
  
  -- calls darkAfterPickup if a red heart gets picked up
  if(currHearts < player:GetHearts()) then
      --debugText = "picked up a heart";
      darkAfterPickup()
  end
 
  -- unused pickup checks
  if(currKeys < player:GetNumKeys()) then
      --debugText = "picked up a key"
      if player:GetNumKeys()==42 then
        EvaluateNeofantasiaStage()
      end
  end
  
  if player:HasGoldenKey() then
    --debugText=  "picked up a golden key"
  end
 
  if(currBombs < player:GetNumBombs()) then
      --debugText = "picked up a bomb"
  end
 
  if player:HasGoldenBomb() then
    --debugText=  "picked up a golden bomb"
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
      if Isaac.GetPlayer(0).MaxFireDelay - 8>0 then
        Isaac.GetPlayer(0).MaxFireDelay = Isaac.GetPlayer(0).MaxFireDelay - 8
      else
        Isaac.GetPlayer(0).MaxFireDelay= 1
      end
    elseif flag == CacheFlag.CACHE_RANGE then
      Isaac.GetPlayer(0).TearFallingSpeed = Isaac.GetPlayer(0).TearFallingSpeed+10
      Isaac.GetPlayer(0).TearFallingAcceleration = Isaac.GetPlayer(0).TearFallingAcceleration+1
      Isaac.GetPlayer(0).TearHeight=Isaac.GetPlayer(0).TearHeight/2
    end
    
    if defaultrundata.flameFirst==true then
      Isaac.GetPlayer(0).TearFlags = Isaac.GetPlayer(0).TearFlags + TearFlags.TEAR_PIERCING + TearFlags.TEAR_BURN
      defaultrundata.flameFirst=false
    end
  end
end

--function that adds the flame graphics to flamethrower
function Soulforge:FlamethrowerV()
  if Isaac.GetPlayer(0):HasCollectible(FlameThrower) then
    for _,entity in pairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_TEAR then
            local tearData = entity:GetData()
            local tear = entity:ToTear()
            if tearData.FlameTear == nil then
                tearData.FlameTear = 1
                tear:ChangeVariant(TearVariant.FLAMETHROWER)
            end
        end
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



-- function to randomly add stacks on stats and force a reevaluation 
function bumboAfterPickup()
  player = Isaac.GetPlayer(0);
  rand = math.random(0,4)
  
  if rand==0 then
    defaultrundata.bumDmg=defaultrundata.bumDmg+1
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
  elseif rand==1 then
    defaultrundata.bumSpeed=defaultrundata.bumSpeed+1
    player:AddCacheFlags(CacheFlag.CACHE_SPEED)
  elseif rand==2 then
    defaultrundata.bumShot=defaultrundata.bumShot+1
    player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
  elseif rand==3 then
    defaultrundata.bumRange=defaultrundata.bumRange+1
    player:AddCacheFlags(CacheFlag.CACHE_RANGE)
  elseif rand==4 then
    defaultrundata.bumLuck=defaultrundata.bumLuck+1
    player:AddCacheFlags(CacheFlag.CACHE_LUCK)
  end
  
  player:EvaluateItems()
end

-- function to set stats acordingly to bumbo-stat-stacks
function Soulforge:BumboUp(pla,flag)
  
  if player:HasCollectible(BumboSoul) then
    player = Isaac.GetPlayer(0);
    
    if flag == CacheFlag.CACHE_DAMAGE then 
      player.Damage=player.Damage+0.1*defaultrundata.bumDmg
    elseif flag == CacheFlag.CACHE_RANGE then
      player.TearFallingSpeed = player.TearFallingSpeed+0.04*defaultrundata.bumRange
    elseif flag == CacheFlag.CACHE_LUCK then
      player.Luck = player.Luck+0.4*defaultrundata.bumLuck
    elseif flag == CacheFlag.CACHE_SHOTSPEED then
      player.ShotSpeed=player.ShotSpeed+0.004*defaultrundata.bumShot
    elseif flag == CacheFlag.CACHE_SPEED then
      player.MoveSpeed=player.MoveSpeed+0.06*defaultrundata.bumSpeed
    end
    --debugText="dmg:" .. defaultrundata.bumDmg .. " spd:" .. defaultrundata.bumSpeed .." sspd:" .. defaultrundata.bumShot .. " rng:" .. defaultrundata.bumRange .. " lck:" .. defaultrundata.bumLuck
  end
end

-- function for either damaging the players red hearts or adding a black heart
function darkAfterPickup()
  if Isaac.GetPlayer(0):HasCollectible(DarkSoul) then
    pos = Vector(Isaac.GetPlayer(0).Position.X, Isaac.GetPlayer(0).Position.Y);
    if RNG():RandomInt(100) < 30 then
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
    rand = math.random(0,4)
    if rand==0 then
      defaultrundata.demonDmg=defaultrundata.demonDmg+1
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    elseif rand==1 then
      defaultrundata.demonSpeed=defaultrundata.demonSpeed+1
      player:AddCacheFlags(CacheFlag.CACHE_SPEED)
    elseif rand==2 then
      defaultrundata.demonShot=defaultrundata.demonShot+1
      player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
    elseif rand==3 then
      defaultrundata.demonRange=defaultrundata.demonRange+1
      player:AddCacheFlags(CacheFlag.CACHE_RANGE)
    elseif rand==4 then
      defaultrundata.demonLuck=defaultrundata.demonLuck+1
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
      player.Damage=player.Damage+2*defaultrundata.demonDmg
    elseif flag == CacheFlag.CACHE_RANGE then
      player.TearFallingSpeed = player.TearFallingSpeed+0.1*defaultrundata.demonRange
    elseif flag == CacheFlag.CACHE_LUCK then
      player.Luck = player.Luck+1*defaultrundata.demonLuck
    elseif flag == CacheFlag.CACHE_SHOTSPEED then
      player.ShotSpeed=player.ShotSpeed+0.4*defaultrundata.demonShot
    elseif flag == CacheFlag.CACHE_SPEED then
      player.MoveSpeed=player.MoveSpeed+0.1*defaultrundata.demonSpeed
    end
    --debugText="dmg:" .. defaultrundata.demonDmg .. " spd:" .. defaultrundata.demonSpeed .." sspd:" .. defaultrundata.demonShot .. " rng:" .. defaultrundata.demonRange .. " lck:" .. defaultrundata.demonLuck
  end
end


-- function for giving diverse effects at the begining of each floor if player obsesses the stained soul
function Soulforge:StainedFloor()
  if Isaac.GetPlayer(0):HasCollectible(Stained) == true then
    player=Isaac.GetPlayer(0)
    
    -- neccessary to remove some effects: Mama Mega explosion chance and damage up
    -- stainedState decides which effect will be called later in this function
    stainedStateold=stainedState
    defaultrundata.stainedState = math.random(0,4)
    
    if stainedStateold==1 then
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
      player:EvaluateItems()
    elseif stainedStateold==3 then
      defaultrundata.stainedMama=false
    end
  
    
    -- read the debugText strings for information on what each of the effects does
    if defaultrundata.stainedState==0 then
      --debugText="Add Coins"
      player:AddCoins(15)
    elseif defaultrundata.stainedState==1 then
      --debugText="Add Damage"
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
      player:EvaluateItems()
    elseif defaultrundata.stainedState==2 then
      --debugText="Add Black Heart"
      player:AddBlackHearts(4)
    elseif defaultrundata.stainedState==3 then
      --debugText="Add Mama Mega "
      defaultrundata.stainedMama=true
    end
  end
end

-- function to manage the stained soul Mama Mega effect
function Soulforge:StainedM()
  if defaultrundata.stainedMama==true then
    rand=math.random(0,100)
    if rand+(Isaac.GetPlayer(0).Luck*2)>80 then
      Game():GetRoom():MamaMegaExplossion()
    end
  end
end

-- function to update the damage if the stained soul requires it.
function Soulforge:StainedDmg(pla,flag)
  if Isaac.GetPlayer(0):HasCollectible(Stained) == true then
    if defaultrundata.stainedState==1 then
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
      --debugText="Show Map"
    elseif rand==1 then
      level:RemoveCurses()
      --debugText="Remove curses"
    elseif rand==2 then
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_GOLDEN, Vector(Isaac.GetPlayer(0).Position.X, Isaac.GetPlayer(0).Position.Y), Vector(0,0), Isaac.GetPlayer(0))
      --debugText="Spawn Golden Key"
    elseif rand==3 then
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GOLDEN, Vector(Isaac.GetPlayer(0).Position.X, Isaac.GetPlayer(0).Position.Y), Vector(0,0), Isaac.GetPlayer(0))
      --debugText="Spawn Golden Bomb"
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
  elseif player:GetName() == "Dead Spider" then
    
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
  elseif player:GetName() == "Neofantasia" then
   
   if cacheFlag == CacheFlag.CACHE_DAMAGE then
      player.Damage = player.Damage -2.5
    end
    if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
      player.ShotSpeed = player.ShotSpeed - 10
    end
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
      player.MaxFireDelay = player.MaxFireDelay-6
    end
    if cacheFlag == CacheFlag.CACHE_SPEED then
      player.MoveSpeed = player.MoveSpeed + 3
    end
    if cacheFlag == CacheFlag.CACHE_LUCK then
      player.Luck = player.Luck + 1
    end
    
  end
end

-- function that manages the spacebar-items of the custom player characters. also clears their costumes on initialization and sets the weak souls for ALL characters in the game.
function  Soulforge:Playermanager()
  player=Isaac.GetPlayer(0)
  player:ClearCostumes()
  

  if player:GetName() == "Isaac" then
    defaultrundata.weakcounter=0
  elseif player:GetName() == "Magdalene" then
    defaultrundata.weakcounter=5
  elseif player:GetName() == "Cain" then
    defaultrundata.weakcounter=2
  elseif player:GetName() == "Judas" then
    defaultrundata.weakcounter=1
  elseif player:GetName() == "???" then
    defaultrundata.weakcounter=0
  elseif player:GetName() == "Eve" then
    defaultrundata.weakcounter=6
  elseif player:GetName() == "Samson" then
    defaultrundata.weakcounter=0
  elseif player:GetName() == "Azazel" then
    defaultrundata.weakcounter=0
  elseif player:GetName() == "Lazarus" then
    defaultrundata.weakcounter=1
  elseif player:GetName() == "Eden" then
    defaultrundata.weakcounter=RNG():RandomInt(8)
  elseif player:GetName() == "The Lost" then
    defaultrundata.weakcounter=10
  elseif player:GetName() == "Lilith" then
    defaultrundata.weakcounter=8
  elseif player:GetName() == "Keeper" then
    defaultrundata.weakcounter=4
  elseif player:GetName() == "Apollyon" then
    defaultrundata.weakcounter=0
  elseif player:GetName() == "The Forgotten" then
    defaultrundata.weakcounter=1
  elseif player:GetName() == "Ulisandra" then
    player:AddBoneHearts(4)
    player:AddHearts(8) --Those lines set the hearts of the character to 4 fully filled bone hearts. Pre Booster 5 Ulisandra had 4 Hearts and "VARICOSE VEINS". Rebalanced some power into starting stats
    player:AddCollectible(CollectibleType.COLLECTIBLE_SATANIC_BIBLE, 6, false)
    -- sets the hair as costume with high priority
    Costume = Isaac.GetCostumeIdByPath("gfx/characters/costume_ulisandrahair.anm2")
    player:AddNullCostume(Costume)
    
    defaultrundata.weakcounter=4
    
  elseif player:GetName() == "Dead Spider" then
    player:AddCollectible(DarkSoul,0 , true)
    player:ClearCostumes()
    
    defaultrundata.weakcounter=0
    
  elseif player:GetName() == "Neofantasia" then
    player:AddCollectible(Stained,0 , true)
    player:ClearCostumes()
    player:AddCollectible(CollectibleType.COLLECTIBLE_BLACK_HOLE, 6, false)
    EvaluateNeofantasiaStage()
    
    Costume = Isaac.GetCostumeIdByPath("gfx/characters/costume_neohair0.anm2")
    player:AddNullCostume(Costume)
    
    defaultrundata.weakcounter=10
    
    
  -- sets souls for seemingly popular modded characters
  elseif player:GetName() == "Mei" then
    defaultrundata.weakcounter=7
  elseif player:GetName() == "Nemesis" then
      defaultrundata.weakcounter=0
  elseif player:GetName() == "Samael" then
    defaultrundata.weakcounter=4
  else
    -- Sets souls for any character not in this function. IS CONSISTENT FOR EACH CHARACTER
    defaultrundata.weakcounter=RNG():RandomInt(8)
  end
  
  
end

-- function for managing the passive effect of "Dead Spider" (spawning spiders on visiting new rooms)
function Soulforge:Spidermanager()
  if Isaac.GetPlayer(0):GetName()=="Dead Spider" and Game():GetRoom():IsFirstVisit()then
    AddSpider()
    --debugText="Spider spawned"
  end
end

-- function that spawns spiders depending on the players luck.
function AddSpider()
  luck=Isaac.GetPlayer(0).Luck
  -- spawn-chance and randomizer
  if 16-luck>3 then
    rand=RNG():RandomInt(16-luck)
  else
    rand=RNG():RandomInt(4)
  end
  
  if rand==0 then
    spider= Isaac.Spawn(EntityType.ENTITY_RAGLING,0,0,Isaac.GetPlayer(0).Position,Vector(0,0),Isaac.GetPlayer(0))
    --debugText="Spider type 0"
    addspidertolist(spiderlist,spider)
  elseif rand==1 then
    spider= Isaac.Spawn(EntityType.ENTITY_SPIDER_L2,0,0,Isaac.GetPlayer(0).Position,Vector(0,0),Isaac.GetPlayer(0))
    --debugText="Spider type 1"
    addspidertolist(spiderlist,spider)
  elseif rand==2 then
    spider= Isaac.Spawn(EntityType.ENTITY_BIGSPIDER,0,0,Isaac.GetPlayer(0).Position,Vector(0,0),Isaac.GetPlayer(0))
    --debugText="Spider type 2"
    addspidertolist(spiderlist,spider)
  elseif rand==3 then
    spider= Isaac.Spawn(EntityType.ENTITY_SPIDER,0,0,Isaac.GetPlayer(0).Position,Vector(0,0),Isaac.GetPlayer(0))
    --debugText="Spider type 3"
    addspidertolist(spiderlist,spider)
  end
end

-- functions that adds spiders to the list (duh :P) and charms them.
function addspidertolist(list,entity)
  entity:AddCharmed(-1)
  table.insert(list,entity)
end

-- function for managing the offset of the tears 
function Soulforge:NeoTearsOff(entity)
  if Isaac.GetPlayer(0):GetName()=="Neofantasia" then
    player=Isaac.GetPlayer(0)
    --debugText=player:GetFireDirection() --returns 0 to 3 for l,u,r,d
    
    offsetx=0
    offsety=0
    if player:GetFireDirection()==0 then
      offsetx=offsetval1
      offsety=firedtear*offsetval2/1.2+offsetmod
    elseif player:GetFireDirection()==2 then
      offsetx=offsetval1
      offsety=-firedtear*offsetval2/1.2-offsetmod
    elseif player:GetFireDirection()== 1 then
      offsety=-offsetval1
      offsetx=-firedtear*offsetval2+offsetmod
    elseif player:GetFireDirection()==3 then
      offsety=-offsetval1
      offsetx=firedtear*offsetval2-offsetmod
    end
    player.TearsOffset=Vector(offsetx, offsety)
    
    if firedtear==1 then
      firedtear=-1
      offsetmod=offsetmod*-1
    else
      firedtear=1
    end
  end
  
end

-- function for managing the passive effect of "Neofantasia" (Spawning floating tears depending on luck)
function Soulforge:Fantasiamanager()
  if Isaac.GetPlayer(0):GetName()=="Neofantasia" then
    rand=RNG():RandomInt(100)
    -- just an overly complicated way for determining the chance of spawning an floating tear
    if 1+rand+(Isaac.GetPlayer(0).Luck*3)>74 or defaultrundata.costcount>4 then
      --determins how many tears to spawn depending on costume-stage
      if defaultrundata.costcount>6 then
        n=2
      elseif defaultrundata.costcount>1 then
        n=0
      else
        n=-1
      end
      for i=0,n do
        tear=Isaac.GetPlayer(0):FireTear(Isaac.GetPlayer(0).Position,Vector(math.random(-1,1)*Isaac.GetPlayer(0).MoveSpeed,math.random(-1,1)*Isaac.GetPlayer(0).MoveSpeed,0),false,true,false)
        tear.CollisionDamage=Isaac.GetPlayer(0).Damage*1.3
        --debugText=i
        
          
        if defaultrundata.costcount>2 then
          tear.TearFlags = tear.TearFlags + TearFlags.TEAR_HOMING
          tear.HomingFriction=1.3
        end
        
        if defaultrundata.costcount>3 then
          tear.CollisionDamage=Isaac.GetPlayer(0).Damage*1.5
        end
      end
    end
  end
end

-- to evaluate if the player meets the requirement for the next costume and setting the costume
function EvaluateNeofantasiaStage()
	player=Isaac.GetPlayer(0)
	if player:GetName()=="Neofantasia" then
		stage=0
		soul=0
		
    -- Has the player cleared 2,4,6,8 floors?
		if defaultrundata.stagecount > 1 then
			stage=stage+1
		end
		if defaultrundata.stagecount > 3 then
			stage=stage+1
		end
		if defaultrundata.stagecount > 5 then
			stage=stage+1
		end
		if defaultrundata.stagecount > 7 then
			stage=stage+1
		end
    
		-- How many of the soul item does the player have? (>=2 -> proc)
		if player:HasCollectible(DemonSoul) then
			soul=soul+1
		end
		if player:HasCollectible(DarkSoul) then
			soul=soul+1
		end
		if player:HasCollectible(AngelSoul) then
			soul=soul+1
		end
		if player:HasCollectible(BumboSoul) then
			soul=soul+1
		end
		if player:HasCollectible(PureSoul) then
			soul=soul+1
		end
		if player:HasCollectible(Stained) then
			soul=soul+1
		end
		if soul > 2 then
			stage=stage+1
		end
		
    -- does the player have "The Soul"?
		if player:HasCollectible(CollectibleType.COLLECTIBLE_SOUL) then
			stage=stage+1
		end
    -- does the Player have more than 10 collectibles?
		if player:GetCollectibleCount() > 10 then
			stage=stage+1
		end
    -- does the player reach the coin limit?
		if player:GetNumCoins() == 99 then
			stage=stage+1
		end
    -- does the player hold 42 keys or more?
		if player:GetNumKeys() > 41 then
			stage=stage+1
		end
    -- has the player overcome his abysmally low damage?
		if player.Damage > 14 then
			stage=stage+1
		end
		
    --debugText="stages: " .. defaultrundata.stagecount .. " souls:" .. soul .. " collectibles: " .. player:GetCollectibleCount() .. " coins: " .. player:GetNumCoins() .. " keys: " .. player:GetNumKeys() .. " damage: " .. player.Damage
    
		-- loads a costume for every costume stage (starts with 0, caped at 7)
		if stage >= 0 and stage <= 6 then
			if checkcostume(stage) then
        --debugText="gfx/characters/costume_neohair" .. stage .. ".anm2"
				Costume = Isaac.GetCostumeIdByPath("gfx/characters/costume_neohair" .. stage .. ".anm2")
				player:AddNullCostume(Costume)
			end
		elseif stage > 6 then
			if checkcostume(stage) then
				Costume = Isaac.GetCostumeIdByPath("gfx/characters/costume_neohair7.anm2")
				player:AddNullCostume(Costume)
			end
		end
		defaultrundata.costcount=stage
		
	end
end

-- function to remove costumes if neccessary
function checkcostume(stage)
	if stage ~= defaultrundata.costcount and defaultrundata.costcount ~= -1 then
		Costume = Isaac.GetCostumeIdByPath("gfx/characters/costume_neohair" .. defaultrundata.costcount .. ".anm2")
		Isaac.GetPlayer(0):TryRemoveNullCostume(Costume)
		return true
	elseif defaultrundata.costcount==-1 then
    return true
  else
		return false
	end
end

-- function needed for keeping track of the number of floors the player cleared
function Soulforge:FantasiaNewFloor()
	if Isaac.GetPlayer(0):GetName()=="Neofantasia" then
    defaultrundata.stagecount=defaultrundata.stagecount+1
    EvaluateNeofantasiaStage()
  end
end

-- function activates two of the passive abilities that come with higher skin stages: holy mantle; more tear coverage
function Soulforge:FantasiaNewRoom()
	if Isaac.GetPlayer(0):GetName()=="Neofantasia" then
    EvaluateNeofantasiaStage()
    
    if defaultrundata.costcount>0 then
      offsetmod=13
    else
      offsetmod=0
    end
    if defaultrundata.costcount>4 then
      Isaac.GetPlayer(0):GetEffects():AddCollectibleEffect(313, true);
    end
  end
end

--function displays how many weak souls the player has picked up after he actually picked one up (also when a Soulforge is in the same room.) Also displays which souls you actualy have.
function Soulforge:UIRender()
  player=Isaac.GetPlayer(0)
  if player.FrameCount<showSouls then
    HudPickup:SetFrame("Idle",0)
    HudPickup:RenderLayer(0,Vector(55,69))
    HudPickup:SetFrame("Idle",math.floor(defaultrundata.weakcounter/10)+1)
    HudPickup:RenderLayer(0,Vector(60,69))
    HudPickup:SetFrame("Idle",defaultrundata.weakcounter%10 +1)
    HudPickup:RenderLayer(0,Vector(66,69))
  end
  
  if player:HasCollectible(BumboSoul) then
    HudSouls:SetFrame("Idle",0)
  else
    HudSouls:SetFrame("Transparent",0)
  end
  HudSouls:RenderLayer(0,Vector(10,210))
  if player:HasCollectible(DarkSoul) then
    HudSouls:SetFrame("Idle",1)
  else
    HudSouls:SetFrame("Transparent",1)
  end
  HudSouls:RenderLayer(0,Vector(25,210))
  if player:HasCollectible(AngelSoul) then
    HudSouls:SetFrame("Idle",2)
  else
    HudSouls:SetFrame("Transparent",2)
  end
  HudSouls:RenderLayer(0,Vector(10,225))
  if player:HasCollectible(DemonSoul) then
    HudSouls:SetFrame("Idle",3)
  else
    HudSouls:SetFrame("Transparent",3)
  end
  HudSouls:RenderLayer(0,Vector(25,225))
  if player:HasCollectible(PureSoul) then
    HudSouls:SetFrame("Idle",4)
  else
    HudSouls:SetFrame("Transparent",4)
  end
  HudSouls:RenderLayer(0,Vector(10,240))
  if player:HasCollectible(Stained) then
    HudSouls:SetFrame("Idle",5)
  else
    HudSouls:SetFrame("Transparent",5)
  end
  HudSouls:RenderLayer(0,Vector(25,240))
end

-- function handles the spawn of weak souls after enemies died.
function Soulforge:WeakSpawn(entity)
  spawn=false
  --checks if the entity is dead (duh?)
  if entity:IsDead() then
    --checks if the entity is an actual enemy (duh?)
    if entity:IsEnemy() then
      --checks if the enemy is an boss and NO multi-entity boss (duh?)
      if entity:IsBoss() and entity.Type~=EntityType.ENTITY_LARRYJR and entity.Type~=EntityType.ENTITY_PIN and entity.Type~=EntityType.ENTITY_ENVY and entity.Type~=EntityType.ENTITY_FISTULA_BIG  and entity.Type~=EntityType.ENTITY_FISTULA_SMALL and entity.Type~=EntityType.ENTITY_BLASTOCYST_BIG   and entity.Type~=EntityType.ENTITY_BLASTOCYST_SMALL  then
        --guaranteed spawn
        spawn = true
        Position = entity.Position
      else
        --you have to be lucky.
        rand=math.random(0,100)
        if rand+player.Luck>95 then
          spawn = true
          Position = entity.Position
        end
      end
    end
    --Spawns a soul if the boolean got switched to true
    if spawn == true then
      soul= Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.WeakSoul, math.random(0,2), Position, Vector(0,0), Isaac.GetPlayer(0))
      soul.Position = Game():GetRoom():FindFreePickupSpawnPosition(Position, 0, true)
      soul.Visible = true
      soul:GetSprite():Play("Appear",true)
    end
  end
end

-- function handles the pickup of the weak souls
function Soulforge:WeakColl(ent,coll)
  if coll.Type==Isaac.GetPlayer(0).Type and ent.Variant==PickupVariant.WeakSoul then
    player=Isaac.GetPlayer(0)
    s=ent:GetSprite()
    if s:IsPlaying("Idle") then
			s:Play("Collect",true)
			defaultrundata.weakcounter = math.min(99,defaultrundata.weakcounter + 1)
			Soulforge:SaveState(player)
			showSouls = player.FrameCount + 90
      ent.EntityCollisionClass=EntityCollisionClass.ENTCOLL_NONE
    end
  end
end

-- function handles the transition between the different states of the weak souls and removes them after being picked up.
function Soulforge:WeakUpdate(ent)
  if ent.Type==5 and ent.Variant==PickupVariant.WeakSoul then
    local	s = ent:GetSprite()
    if s:IsFinished("Appear") then
      s:Play("Idle",true)
    elseif s:IsFinished("Collect") then
      ent:Remove()
    end
  end
end

--manages if a soulforge gets spawned on a new floor and which amount of souls it takes
function Soulforge:SoulforgeSpawn()
  if math.random(4) < 2 then
    rand=(math.random(0,2)+2)*5
    defaultrundata.soulforgecost=rand
    if Game():GetRoom():GetGridCollision(32) == 0 then
      Isaac.Spawn(6,6002,0,Game():GetRoom():GetGridPosition(32), Vector(0,0), nil)
    else
      Isaac.Spawn(6,6002,0,Isaac.GetPlayer().Position+3, Vector(0,0), nil)
    end
  end
end

-- manages the transactions on soulforges and triggers the fitting load animations
function Soulforge:SoulforgeCollision(player,entity)
  if entity.Type==6 and entity.Variant==SoulforgeVariant and entity:GetSprite():IsPlaying("Idle"..defaultrundata.soulforgecost) then
    
    if defaultrundata.soulforgecost<=defaultrundata.weakcounter then
      entity:GetSprite():Play("Load"..defaultrundata.soulforgecost,true)
      defaultrundata.weakcounter=defaultrundata.weakcounter-defaultrundata.soulforgecost
    end
  --debugText="Soulforge Collider works "..entity.Variant.." "..entity.Type
  end
end

-- manages the animations of the Soulforges and spawns a Soul when all animations are finished
function Soulforge:SoulforgeUpdate()
  entities=Isaac:GetRoomEntities()
  for i = 1, #entities do
    entity=entities[i]
    if entity.Type==6 and entity.Variant==SoulforgeVariant then
      
      local	s = entity:GetSprite()
      
      
      if s:IsPlaying("Idle10") and defaultrundata.soulforgecost~=10 then 
        --debugText="different animation"
        s:Play("Idle"..defaultrundata.soulforgecost,true)
      end
      
      if s:IsPlaying("Load"..defaultrundata.soulforgecost) then
        showSouls=player.FrameCount+15
      elseif s:IsPlaying("Idle"..defaultrundata.soulforgecost) then
        showSouls=player.FrameCount+2
      end
      
      if s:IsFinished("Load"..defaultrundata.soulforgecost) then
        checker=true
        s:Play("Active",true)
        --debugText="Soulforge Idle finished"
      elseif s:IsFinished("Active") then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, entity.Position, Vector(0,0), entity)
        
        random = math.random(5)
        mod=0
        while checker==true do
          if random == 0 and Isaac.GetPlayer(0):HasCollectible(DarkSoul)==false and Isaac.GetPlayer(0):HasCollectible(BumboSoul)==false then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE,BumboSoul,entity.Position,Vector(0,0),nil)
            checker=false
          elseif random == 1 and Isaac.GetPlayer(0):HasCollectible(BumboSoul)==false and Isaac.GetPlayer(0):HasCollectible(DarkSoul)==false then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE,DarkSoul,entity.Position,Vector(0,0),nil)
            checker=false
          elseif random == 2 and Isaac.GetPlayer(0):HasCollectible(DemonSoul)==false and Isaac.GetPlayer(0):HasCollectible(AngelSoul)==false then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE,AngelSoul,entity.Position,Vector(0,0),nil)
            checker=false
          elseif random == 3 and Isaac.GetPlayer(0):HasCollectible(AngelSoul)==false and Isaac.GetPlayer(0):HasCollectible(DemonSoul)==false then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE,DemonSoul,entity.Position,Vector(0,0),nil)
            checker=false
          elseif random == 4 and Isaac.GetPlayer(0):HasCollectible(Stained)==false and Isaac.GetPlayer(0):HasCollectible(PureSoul)==false then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE,PureSoul,entity.Position,Vector(0,0),nil)
            checker=false
          elseif random == 5 and Isaac.GetPlayer(0):HasCollectible(PureSoul)==false and Isaac.GetPlayer(0):HasCollectible(Stained)==false then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE,Stained,entity.Position,Vector(0,0),nil)
            checker=false
          else
            if mod==5 then checker=false else
              mod=mod+1
              random=math.fmod(random+mod,6)
            end
          end
        end   
        entity:Remove()
        --debugText="Soulforge Despawned"
      end
    end
  end
end

-- Environmental callbacks
Soulforge:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Soulforge.Reset)
Soulforge:AddCallback( ModCallbacks.MC_POST_UPDATE, Soulforge.checkConsumables)

-- Callbacks for the flamethrower
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.FlamethrowerF)
Soulforge:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Soulforge.FlamethrowerDamage, EntityType.ENTITY_PLAYER)
Soulforge:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE,Soulforge.FlamethrowerV)

-- Callbacks for functions that need to be called at the begining of each floor
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.AngelFloor)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.DemonFloor)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.StainedFloor)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.PureSoul)

-- Callbacks for the Character specific functions
Soulforge:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Soulforge.Playermanager)
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.SetPlayerStats)
Soulforge:AddCallback(ModCallbacks.MC_POST_TEAR_INIT , Soulforge.NeoTearsOff)
Soulforge:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION  , Soulforge.Fantasiamanager)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_ROOM , Soulforge.Spidermanager)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL , Soulforge.FantasiaNewFloor)
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_ROOM , Soulforge.FantasiaNewRoom)

-- Callbacks for the dynamic reevaluation of some items and Mama Mega 
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Soulforge.StainedM)
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.BumboUp)
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.DemonUp)
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.StainedDmg)
Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.DemonUp)

--callback for dynamicaly displaying your collected weak souls
Soulforge:AddCallback(ModCallbacks.MC_POST_RENDER, Soulforge.UIRender)
-- callback for spawning and picking up weak souls
Soulforge:AddCallback(ModCallbacks.MC_NPC_UPDATE, Soulforge.WeakSpawn)
Soulforge:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION  , Soulforge.WeakColl)
Soulforge:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE , Soulforge.WeakUpdate)


--callbacks for the soulforge
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL , Soulforge.SoulforgeSpawn)
Soulforge:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION , Soulforge.SoulforgeCollision)
Soulforge:AddCallback(ModCallbacks.MC_POST_RENDER , Soulforge.SoulforgeUpdate)

-- debug callback (not in environmental because it doesn't have any effects on the mod in casual use). also callbacks for debug colors
Soulforge:AddCallback(ModCallbacks.MC_POST_RENDER, Soulforge.debug)
--Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.Colorupdate)
--Soulforge:AddCallback(ModCallbacks.MC_POST_UPDATE, Soulforge.Colorupdate)



-- code for saving run-states between multiple starts of the game. code inspired by `the ritual_910051385` mod
function Soulforge:SaveState()
  
  if not loaded then
    LoadState()
    loaded=true
  end
  
	local savedata = ""

  if defaultrundata.flameFirst then
    flame=1
  else
    flame=0
  end
  if defaultrundata.stainedMama then
    mama=1
  else
    mama=0
  end
  
  --Saves the seed followed by every relevant value of the mod as one string. Values get converted to a number with 4 digits before getting appended to the string.
	savedata=savedata..dupestate.runseed
  savedata=savedata..(1000+flame)
  savedata=savedata..(1005+mama)
  savedata=savedata..(1010+defaultrundata.stainedState)
  savedata=savedata..(1020+defaultrundata.costcount)
  savedata=savedata..(1040+defaultrundata.stagecount)
  savedata=savedata..(1100+defaultrundata.demonLuck)
  savedata=savedata..(1120+defaultrundata.demonSpeed)
  savedata=savedata..(1140+defaultrundata.demonShot)
  savedata=savedata..(1160+defaultrundata.demonRange)
  savedata=savedata..(1180+defaultrundata.demonDmg)
  savedata=savedata..(1200+defaultrundata.bumcoin)
  savedata=savedata..(2000+defaultrundata.bumLuck)
  savedata=savedata..(3000+defaultrundata.bumShot)
  savedata=savedata..(4000+defaultrundata.bumSpeed)
  savedata=savedata..(5000+defaultrundata.bumRange)
  savedata=savedata..(6000+defaultrundata.bumDmg)
  savedata=savedata..(7777+defaultrundata.weakcounter)
  savedata=savedata..(8000+defaultrundata.soulforgecost)

	Isaac.SaveModData(Soulforge,savedata)
  
  --debugText=savedata
  
end


function LoadState()
  local save = Isaac.LoadModData(Soulforge)
  
  -- runs as long as there are values left to load
  while string.len(save) > 3 do
    -- special part of the loop for loading the seed and checking if there is a new one 
    if string.len(save)>=4*19 then
      seed=string.sub(save, 1, 9)
      
      if seed==Game():GetSeeds():GetStartSeedString() then
        save = string.sub(save, 10)
        defaultrundata.runseed=Game():GetSeeds():GetStartSeedString()
        --debugText="Same Seed"
      else
        --loads the default state instead and exits the loop
        save=""
        defaultrundata=dupestate
        --debugText="Other Seed"
      end
    else
      -- one by one loads the values
      num = tonumber(string.sub(save, 1, 4))
      save = string.sub(save, 5)
      
      
      if num>=8000 then
        defaultrundata.soulforgecost=num-8000
      elseif num >= 7777 then
        defaultrundata.weakcounter=num-7777
      elseif num>=6000 then
        defaultrundata.bumDmg=num-6000
      elseif num>=5000 then
        defaultrundata.bumRange=num-5000
      elseif num>=4000 then
        defaultrundata.bumSpeed=num-4000
      elseif num>=3000 then
        defaultrundata.bumShot=num-3000
      elseif num>=2000 then
        defaultrundata.bumLuck=num-2000
      elseif num>=1200 then
        defaultrundata.bumcoin=num-1200
      elseif num>=1180 then
        defaultrundata.demonDmg=num-1180
      elseif num>=1160 then
        defaultrundata.demonRange=num-1160
      elseif num>=1140 then
        defaultrundata.demonShot=num-1140
      elseif num>=1120 then
        defaultrundata.demonSpeed=num-1120
      elseif num>=1100 then
        defaultrundata.demonLuck=num-1100
      elseif num>=1040 then
        defaultrundata.stagecount=num-1040
      elseif num>=1020 then
        defaultrundata.costcount=num-1020
      elseif num>=1010 then
        defaultrundata.stainedState=num-1010
      elseif num>=1005 then
        if num-1005==1 then
          num=true
        else
          num=false
        end
        defaultrundata.stainedMama=num
      elseif num>=1000 then
        if num-1000==1 then
          num=true
        else
          num=false
        end
        defaultrundata.flameFirst=num
      end
    end
  end
end

Soulforge:AddCallback( ModCallbacks.MC_POST_PLAYER_UPDATE , Soulforge.SaveState)
Soulforge:AddCallback( ModCallbacks.MC_POST_GAME_STARTED , Soulforge.SaveState)