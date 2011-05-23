require("monster.base.drop")
require("monster.base.lookat")
require("monster.base.quests")
require("base.messages");
module("monster.mon_29_animals", package.seeall)


function ini(Monster)

init=true;
monster.base.quests.iniQuests();
killer={}; --A list that keeps track of who attacked the monster last

end


function enemyNear(Monster,Enemy)

    if init==nil then
        ini(Monster);
    end

    return false
end

function enemyOnSight(Monster,Enemy)

    if init==nil then
        ini(Monster);
    end

    if monster.base.drop.DefaultSlowdown( Monster ) then
        return true
    else
        return false
    end
end

function onAttacked(Monster,Enemy)

    if init==nil then
        ini(Monster);
    end

    killer[Monster.id]=Enemy.id; --Keeps track who attacked the monster last
end

function onCasted(Monster,Enemy)

    if init==nil then
        ini(Monster);
    end

    killer[Monster.id]=Enemy.id; --Keeps track who attacked the monster last
end

function onDeath(Monster)

    if killer[Monster.id] ~= nil then

        murderer=getCharForId(killer[Monster.id]);
    
        if murderer then --Checking for quests

            monster.base.quests.checkQuest(murderer,Monster);
            killer[Monster.id]=nil;
            murderer=nil;

        end
    end

    monster.base.drop.ClearDropping();
    local MonID=Monster:get_mon_type();

    if (MonID==291) then --sheep

        monster.base.drop.AddDropItem(63,1,50,333,0,1); --inners
        monster.base.drop.AddDropItem(170,10,50,333,0,2); --wool
        monster.base.drop.AddDropItem(2934,1,100,333,0,3); --lamb meat

    elseif (MonID==292) then --pig

        monster.base.drop.AddDropItem(63,1,50,333,0,1); --inners
        monster.base.drop.AddDropItem(69,1,50,333,0,2); --leather
        monster.base.drop.AddDropItem(307,1,100,333,0,3); --pork

    elseif (MonID==293) then --cow

        monster.base.drop.AddDropItem(69,1,50,333,0,1); --leather
        monster.base.drop.AddDropItem(333,1,50,333,0,2); --horn
        monster.base.drop.AddDropItem(2940,1,100,333,0,3); --steak

    elseif (MonID==294) then --deer

        monster.base.drop.AddDropItem(63,1,50,333,0,1); --inners
        monster.base.drop.AddDropItem(552,1,100,333,0,2); --deer meat

    elseif (MonID==295) then --bunny

        monster.base.drop.AddDropItem(63,1,50,333,0,1); --inners
        monster.base.drop.AddDropItem(553,1,100,333,0,2); --rabbit meat

    end
    monster.base.drop.Dropping(Monster);
end
