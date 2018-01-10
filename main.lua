local Soulforge = RegisterMod("Soulforge",1);
local BumboSoul = Isaac.GetItemIdByName ("BumBo Soul")
local FlameThrower = Isaac.GetItemIdByName ("Item1")
--ArcaneLockdown: Nachtrefferfolge auf selben gegner explodieren aus ihm (zerstört die gegner nicht) Tears(Player)
--Flamethrower: Flammenwerfer
--Angle Soul:HP(ethernal Harts) pro flooor Angle Deal 


function Soulforge:CacheUpdate(player, CacheFlag)
  
  local player = Isaac.GetPlayer(0);
  local random = math.random(0,6)
  local fd = Isaac.GetPlayer(0).MaxFireDelay / 2;
  
  if player:HasCollectible(FlameThrower) == true then 
    Isaac.GetPlayer(0).TearColor = Color(255.0,93,0,1,1,0,0)
    Isaac.GetPlayer(0).Damage = 3
    Isaac.GetPlayer(0).FireDelay = fd-1
    Isaac.GetPlayer(0).TearHeight = 2
    Isaac.GetPlayer(0).TearFlags = Isaac.GetPlayer(0).TearFlags +             TearFlags.TEAR_PIERCING + TearFlags.TEAR_BURN
    
  end

  if player:HasCollectible(BumboSoul) == true then 

    player.Damage=player.Damage+math.random(0,1)*0.5;
    player.MoveSpeed=player.MoveSpeed+math.random(0,1)*0.5;
    player.ShotSpeed=player.ShotSpeed+math.random(0,1)*0.2;
    player.TearHeight = player.TearHeight +math.random(0,1)*0.3;
    player.Luck = player.Luck+math.random(0,1)*0.5;
  
end
end

function Soulforge:Color()
    local player= Isaac.GetPlayer(0)
    if Isaac.GetPlayer(0):HasCollectible(FlameThrower) then
    Isaac.GetPlayer(0).TearColor = Color(255.0,93,0,1,1,0,0)
    end
  end

  Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.CacheUpdate)
  Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.Color)
  Soulforge:AddCallback(ModCallbacks.MC_POST_UPDATE, Soulforge.Color)