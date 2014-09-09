
stop = false;
win = false

function love.load() --primera funcion
	require('entities')
	ents.Startup()
	love.graphics.setBackgroundColor(255,255,255)
end

function love.draw() --se llama con cada iteracion
	love.graphics.setColor(0,0,0,255)
	
	if stop then
		if not win then
			love.graphics.print("Game Over", 100, 100, 0, 1, 1)
		else
			love.graphics.print("You Win!!", 100, 100, 0, 1, 1)
		end
	end

	--enemies
	for i, entity in pairs(ents.objects) do
		love.graphics.setColor( entity.color[1], entity.color[2], entity.color[3] )
		love.graphics.circle( "fill", entity.x - entityRadius, entity.y - entity.radius, entity.radius, 100 )
	end

	--shots
	love.graphics.setColor( 0, 0, 0 )
	for i, shot in pairs(ents.shots) do
		love.graphics.rectangle( "fill", shot.x - shot.width/2, shot.y - shot.height/2, shot.width, shot.height )
	end

	--meteors
	love.graphics.setColor( meteorColor[1], meteorColor[2], meteorColor[3] )
	for i, meteor in pairs(ents.meteors) do
		love.graphics.circle( "fill", meteor.x - meteor.radius, meteor.y - meteor.radius, meteor.radius, 100 )
	end

	--player
	love.graphics.setColor(player.color[1], player.color[2], player.color[3])
	love.graphics.circle( "fill", player.x , player.y , player.radius, 100 )
	love.graphics.setColor( 0, 0, 0 )
	love.graphics.line(player.x, player.y, player.x + player.radius*math.cos(math.rad(player.sa)), player.y + player.radius*math.sin(math.rad(player.sa)))

end

function love.update(dt) --se llama con cada iteracion
	if not stop then 
		ents.updateShotCooldown(dt)
		ents.shot() 
		ents.updatePlayerSpeed(dt)
		ents.updatePosition(dt)
		ents.updateManeuvers(dt)
		--ents.updateMeteors(dt)
		ents.updateSpeedBoost(dt)
		ents.updateShields(dt)
		ents.collisions()
	end
end

function love.focus(bool) --true si el juego esta en foco

end

function love.keypressed(key, unicode)

end

function love.keyreleased(key, unicode)

end

function love.mousepressed( x, y, button )

end

function love.mousereleased( x, y, button )

end

function love.quit()

end