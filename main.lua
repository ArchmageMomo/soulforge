local Soulforge = RegisterMod("Soulforge",1);
local BumboSoul = Isaac.GetItemIdByName ("BumBo Soul");
local AngleSoul = Isaac.GetItemIdByName ("Angle Soul");




function Soulforge:SetValue ()
  local player =Isaac.GetPlayer(0)
  values = {player.Hearts, player.Damage, player.ShotSpeed, player.TearHeight, player.MoveSpeed, player.Luck} 
end

function Soulforge:PickUp ()
    if Soulforge.PICKUP_COIN == true then 
      if cacheFlag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage +1;
      end
    end
  end


function Soulforge:CacheUpdate(player, cacheFlag)
  local player = Isaac.GetPlayer(0);
  local values = {} 
  player.Hearts, player.Damage, player.ShotSpeed, player.TearHeight, player.MoveSpeed, player.Luck
  h = player.Hearts
  d = player.Damage
  s = player.ShotSpeed
  t = player.TearHeight
  m = player.MoveSpeed
  l = player.Luck
  
  values[h
  local random = math.random(0,6)
  if player:HasCollectible(BumboSoul) == true then 
    
   
    if (random <=1 )then
      if cacheFlag == CacheFlag.CACHE_DAMAGE then
        values [1] = values[1]+1
      end
    end
    if (random > 1 and random <= 2 )then
      if cacheFlag == CacheFlag.CACHE_SPEED then
        values [4] = values [4]+1
      end
    end
    if (random > 2 and random <= 3 )then
      if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
        values [2] = values [2]+1
      end 
    end
    if (random > 3 and random <= 4 )then
      if cacheFlag == CacheFlag.CACHE_RANGE then
        values [5] = values [5]+1
      end
    end 
    if (random > 4 and random <= 5 )then
      if cacheFlag == CacheFlag.CACHE_LUCK then
        values [5] = values [5]+1
      end
    end
    
  end
  player.Damage =values [1]
  player.ShotSpeed =values [2]
  player.TearHeight =values [3]
  player.MoveSpeed =values [4]
  player.Luck =values [5]
end

Soulforge:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Soulforge.CacheUpdate);
Soulforge:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Soulforge.SetValue);
Soulforge:AddCallback(ModCallbacks.MC_LEVEL_GENERATOR, Soulforge.SetValue);
