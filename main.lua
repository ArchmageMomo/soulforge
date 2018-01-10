local Soulforge = RegisterMod("Soulforge",1);
local BumboSoul = Isaac.GetItemIdByName ("BumBo Soul")
local FlameThrower = Isaac.GetItemIdByName ("Item1")
--ArcaneLockdown: Nachtrefferfolge auf selben gegner explodieren aus ihm (zerstört die gegner nicht) Tears(Player)
--Flamethrower: Flammenwerfer
--Angle Soul:HP(ethernal Harts) pro flooor Angle Deal 

function bit(p)
     return 1 << p
end

function hasbit(x, p)
    return (x & p)
end

function setbit(x, p)
    return x | p
end

function Soulforge:CacheUpdate(player, CacheFlag)
  
  local player = Isaac.GetPlayer(0);
  local random = math.random(0,6)
  
  if player:HasCollectible(FlameThrower) == true then 
    Isaac.GetPlayer(0).TearColor = Color(255.0,93,0,1,1,0,0)
    Isaac.GetPlayer(0).Damage = 3
    Isaac.GetPlayer(0).FireDelay = Isaac.GetPlayer(0).FireDelay -2
    Isaac.GetPlayer(0).TearHeight = 2
    Isaac.GetPlayer(0).TearFlags = Isaac.GetPlayer(0).TearFlags + TearFlags.TEAR_PIERCING + TearFlags.TEAR_BURN
    
 
  end

  if player:HasCollectible(BumboSoul) == true then 

    local random = math.random(0,6);
    if (random >= 0 and random < 6) then
      if (random <=1 )then
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
          player.Damage=player.Damage+1.0
        end
      end
      if (random > 1 and random <= 2 )then
        if cacheFlag == CacheFlag.CACHE_SPEED then
          player.MoveSpeed=player.MoveSpeed+1.0
        end
      end
      if (random > 2 and random <= 3 )then
        if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
          player.ShotSpeed=player.ShotSpeed+1.0
        end 
      end
      if (random > 3 and random <= 4 )then
        if cacheFlag == CacheFlag.CACHE_RANGE then
          player.TearHeight = player.TearHeight +1.0 
        end
      end 
      if (random > 4 and random <= 5 )then
        if cacheFlag == CacheFlag.CACHE_LUCK then
          player.Luck = player.Luck+1.0
        end
      end

    end

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