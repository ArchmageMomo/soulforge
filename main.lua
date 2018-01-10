local Soulforge = RegisterMod("Soulforge",1);
local BumboSoul = Isaac.GetItemIdByName ("BumBo Soul");
local FlameThrower = Isaac.GetItemByName ("Flamethrower");
--ArcaneLockdown: Nachtrefferfolge auf selben gegner explodieren aus ihm (zerstört die gegner nicht) Tears(Player)
--Flamethrower: Flammenwerfer
--Angle Soul:HP(ethernal Harts) pro flooor Angle Deal 

function Soulforge:CacheUpdate(player, CacheFlag)
  
  local player = Isaac.GetPlayer(0);
  local random = math.random(0,6)
  
  if player:HasCollectible(FlameThrower) == true then 
    Isaac.GetPlayer(0).TearColor = Color(0.003921568627451,0.010752688172043,0,0,0,0,0)
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
      Isaac.GetPlayer(0).TearColor = Color(0.003921568627451,0.010752688172043,0.0,0,0,0,0)
    end
  end

  Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.CacheUpdate)
  Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.Color)
  Soulforge:AddCallback(ModCallbacks.MC_POST_UPDATE, Soulforge.Color)