function ManaNuke(Monster, Enemy)
	if (Enemy:get_magic_type() == 1) then
		local rand = math.random(100);
		if (rand < 5) then
			base.common.TalkNLS(Monster, CCharacter.say, "#me murmelt eine mystische Formel.", "#me mumbles a mystical formula.");
			world:gfx(21, Monster.pos);
			world:gfx(32, Enemy.pos);
			world:makeSound(1, Enemy.pos); -- TODO: Assign Sound ID
			myEffect = CLongTimeEffect(500,10);
			Enemy.effects:addEffect(myEffect, true);
		end
	end
end
