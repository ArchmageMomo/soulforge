local Soulforge = RegisterMod("Soulforge",1);
local BumboSoul = Isaac.GetItemIdByName ("BumBo Soul");


function Soulforge:CacheUpdate(player, cacheFlag)
  local player = Isaac.GetPlayer(0);
   if (PickupVariant==PickupVariant.PICKUP_COIN) then 
  if player:HasCollectible(BumboSoul) == true then 
   
    local random = math.random(0,5);
    if (random <=1 )then
      if cacheFlag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage +0,3;
      end
    end
    if (random > 1 and random <= 2 )then
      if cacheFlag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + 0,2;
      end
    end
    if (random > 2 and random <= 3 )then
      if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed+ 0,2;
      end
    end
    if (random > 3 and random <= 4 )then
      if cacheFlag == CacheFlag.CACHE_RANGE then
        player.TearHeight = player.TearHeight +1;
      end
    end 
    if (random > 4 and random <= 5 )then
      if cacheFlag == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck +1;
      end
    end
  end
  end
end



Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.CacheUpdate);
