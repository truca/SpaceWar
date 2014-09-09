ents = {}
ents.objects = {}
ents.shots = {}
ents.meteors = {}
classes = {}
id = 1
shotID = 1

shotHeight = 5
shotWidth = 5

playerMaxSpeed = 200
playerMinSpeed = -200

playerAngleDelta = 400
playerSpeedDelta = 50

player = {}

shotCooldown = 0
maxShotCooldown = 0.25

shotSpeed = 200
entityRadius = 10

screenWidth = 800
meteorRadius = 15
meteorColor = {200, 50, 50}

meteorCooldown = 5
meteorTimer = 0
meteorQuantity = 5
meteorAngle = 45
meteorSpeed = 400

speedboostSpeed = 600
speedboostCooldown = 10
speedboostTimer = 10
speedboostDuration = 2
speedboostTime = 0
speedboostActivated = false

proshots = 10
proshotAngle = 20

ents.maneuvers = {}

shieldblock = false
shieldblockCooldown = 2
shieldblockTimer = 0
shieldblockDuration = 2
shieldblockTime = 0


--timer, index, {time, angle, speed}
ents.maneuvers.minion = {0, 1, {{8, 180, 80}, {8, 0, 80}}}
ents.maneuvers.hunter = {0, 1, {{0, 45, 80}, {2, 135, 80}, {2,-135, 80}, {2, -45, 80}}}


function ents.Startup()
	ents.initClasses()

	--name, x, y, speedA, speedR, radius
	ents.Create( classes.minion, 20, 20, 0 )
	ents.Create( classes.minion, 50, 20, 0 )
	ents.Create( classes.minion, 35, 50, 0 )
	ents.Create( classes.minion, 65, 50, 0 )

	ents.Create( classes.hunter, 400, 100, 0 )

	ents.Create( classes.shield, 100, 100, 0 )
	ents.Create( classes.shield, 100, 150, 0 )

	ents.createPlayer(50, 200, 60, 0, 20, 20)
end

function ents.initClasses()
	--radius, color, speed, class
	classes.minion = {}
	classes.minion.radius = 10
	classes.minion.color = {0,0,150}
	classes.minion.speed = 80
	classes.minion.health = 10
	classes.minion.className = "minion"

	classes.hunter = {}
	classes.hunter.radius = 10
	classes.hunter.color = {150,0,0}
	classes.hunter.speed = 100
	classes.hunter.health = 20
	classes.hunter.className = "hunter"

	classes.shield = {}
	classes.shield.radius = 20
	classes.shield.color = {0,0,0}
	classes.shield.speed = 0
	classes.shield.health = 10
	classes.shield.className = "shield"
end

function ents.Create( class, x, y, speedA )
	local entity = {}
	entity.id = id
	entity.class = class.className
	entity.x = x
	entity.y = y
	entity.sa = speedA --speed Angular

	entity.sr = class.speed --speed Radial
	entity.radius = class.radius
	entity.color = class.color
	entity.health = class.health

	ents.objects[id] = entity
	id = id + 1
end

function ents.updatePosition( dt )
	--update enemies position
	for i, entity in pairs(ents.objects) do 
    	entity.x = entity.x + (entity.sr*math.cos( math.rad(entity.sa) ))*dt
    	entity.y = entity.y + (entity.sr*math.sin( math.rad(entity.sa) ))*dt
	end
	--update shots position
	for i, shot in pairs(ents.shots) do 
    	shot.x = shot.x + (shot.sr*math.cos( math.rad(shot.sa) ))*dt
    	shot.y = shot.y + (shot.sr*math.sin( math.rad(shot.sa) ))*dt
	end
	--update meteor position
	for i, meteor in pairs(ents.meteors) do 
    	meteor.x = meteor.x + (meteor.speed*math.cos( math.rad(meteor.angle) ))*dt
    	meteor.y = meteor.y + (meteor.speed*math.sin( math.rad(meteor.angle) ))*dt
	end

	player.x = player.x + (player.sr*math.cos( math.rad(player.sa) ))*dt
    player.y = player.y + (player.sr*math.sin( math.rad(player.sa) ))*dt

    if player.x - player.radius < 0 then player.x = player.radius end
    if player.x + player.radius > 800 then player.x = 800 - player.radius end

    if player.y - player.radius < 0 then player.y = player.radius end
    if player.y + player.radius > 600 then player.y = 600 - player.radius end
end

function ents.createPlayer( x, y, sa, sr, health, radius )
	player.x = x
	player.y = y
	player.sa = sa --speed angular
	player.sr = sr --speed radial
	player.health = health
	player.radius = radius
	player.color = {255,0,0}
	player.shotDamage = 10
end

function ents.createShot( x, y, sa, sr, damage )
	local shot = {}
	shot.x = x
	shot.y = y
	shot.sr = sr
	shot.sa = sa
	shot.height = shotHeight
	shot.width = shotWidth
	shot.damage = damage

	ents.shots[shotID] = shot
	shotID = shotID + 1
end

function ents.updatePlayerSpeed(dt)
	if love.keyboard.isDown("left") then player.sa = player.sa - playerAngleDelta*dt	end
	if love.keyboard.isDown("right") then player.sa = player.sa + playerAngleDelta*dt	end

	if love.keyboard.isDown("d") then
		ents.activateSpeedBoost()
	end

	if not speedboostActivated then
		if love.keyboard.isDown("up") then
			player.sr = playerMaxSpeed
		elseif love.keyboard.isDown("down") then 
			player.sr = playerMinSpeed
		else 
			player.sr = 0;
		end
	else
		if love.keyboard.isDown("up") then
			player.sr = speedboostSpeed
		elseif love.keyboard.isDown("down") then 
			player.sr = -1*speedboostSpeed
		else 
			player.sr = 0;
		end
	end 
end

function ents.shot()
	--normal shot
	if love.keyboard.isDown("a") and shotCooldown == 0 then 
		ents.createShot(player.x, player.y, player.sa, shotSpeed, player.shotDamage) 
		shotCooldown = maxShotCooldown
	end
	--pro shot
	if love.keyboard.isDown("s") and shotCooldown == 0  and proshots > 0 then 
		ents.createShot(player.x, player.y, player.sa - proshotAngle, shotSpeed, player.shotDamage)
		ents.createShot(player.x, player.y, player.sa, shotSpeed, player.shotDamage)
		ents.createShot(player.x, player.y, player.sa + proshotAngle, shotSpeed, player.shotDamage) 
		proshots = proshots - 1
		shotCooldown = maxShotCooldown
	end
end

function ents.updateShotCooldown(dt)
	shotCooldown = shotCooldown - dt
	if shotCooldown < 0 then shotCooldown = 0 end
end

function ents.updateManeuvers(dt)
	for class, maneuver in pairs(ents.maneuvers) do
		maneuver[1] = maneuver[1] + dt
		if maneuver[1] >= maneuver[3][maneuver[2]][1] then 
			for i, enemy in pairs(ents.objects) do
				if enemy.class == class then 
					enemy.sa = maneuver[3][maneuver[2]][2]
					enemy.sr = maneuver[3][maneuver[2]][3]
				end
			end
			maneuver[2] = maneuver[2] + 1
			if maneuver[2] > table.getn(maneuver[3]) then 
				maneuver[2] = 1 
			end
			--print("class: "..class.." maneuver: "..maneuver[2])
			maneuver[1] = 0
		end
	end
end

function ents.collisions()
	--shots collision with player or enemies
	for i, shot in pairs(ents.shots) do
		for j, enemy in pairs(ents.objects) do
			if ents.collision(enemy, shot, enemy.radius) then
				if (shieldblock) and (enemy.class == "shield") then 
					print("blocked")
					table.remove(ents.shots, i)
				else 
					print(enemy.class .. " got a shot!!")
					enemy.health = enemy.health - shot.damage
					table.remove(ents.shots, i)
					if enemy.health <= 0 then table.remove(ents.objects, j) end
					--print("enemy shot:" .. enemy.id .. " health: " .. enemy.health .. "enemies remaining: " .. table.getn(ents.objects))
					if table.getn(ents.objects) == 0 then 
						win = true 
						stop = true
					end
				end
			end
		end


	end

	--collision between player and enemies
	for i, enemy in pairs(ents.objects) do
		if ents.collision(enemy, player, enemy.radius + player.radius) then
			stop = true
		end
	end

	--collision between player and meteors
	for i, meteor in pairs(ents.meteors) do
		if ents.collision(meteor, player, meteor.radius + player.radius) then
			stop = true
		end
	end
end

function ents.collision(ent1, ent2, dist)
	return math.pow(ent1.x-ent2.x, 2)+math.pow(ent1.y-ent2.y, 2) <= math.pow(dist, 2)
end

function ents.meteorRain( quantity, angle, speed )
	ents.meteors = {}
	separation = screenWidth/(quantity+1)
	for i=1, quantity, 1 do
		meteor = {}
		meteor.x = separation*i
		meteor.y = 0
		meteor.speed = speed
		meteor.angle = angle
		meteor.color = meteorColor
		meteor.radius = meteorRadius
		ents.meteors[i] = meteor
	end
end

function ents.updateMeteors(dt)
	meteorTimer = meteorTimer + dt
	if meteorTimer >= meteorCooldown then
		ents.meteorRain(meteorQuantity, meteorAngle, meteorSpeed)
		meteorTimer = 0
		if meteorAngle == 45 then 
			meteorAngle = 135 
		else 
			meteorAngle = 45 
		end 
	end
end

function ents.activateSpeedBoost()
	if (not speedboostActivated) and speedboostTimer >= speedboostCooldown then
		speedboostActivated = true
	end
end

function ents.updateSpeedBoost(dt)
	if speedboostActivated then
		speedboostTime = speedboostTime + dt
		if speedboostTime >= speedboostDuration then 
			speedboostActivated = false
			speedboostTime = 0
			speedboostTimer = 0
		end
	else
		if speedboostTimer < speedboostCooldown then
			speedboostTimer = speedboostTimer + dt
		end
	end
end

function ents.updateShields(dt)
	if shieldblock then
		shieldblockTime = shieldblockTime + dt
		if shieldblockTime >= shieldblockDuration then 
			shieldblock = false
			shieldblockTime = 0
			shieldblockTimer = 0
			swapShields()
		end
	else
		shieldblockTimer = shieldblockTimer + dt
		if shieldblockTimer >= shieldblockCooldown then
			shieldblock = true
			shieldblockTime = 0
			shieldblockTimer = 0
			swapShields()
		end
	end
end

function swapShields()
	if shieldblock then
		for i, enemy in pairs(ents.objects) do
			if enemy.class == "shield" then enemy.color = {150,150,150} end
		end
	else 
		for i, enemy in pairs(ents.objects) do
			if enemy.class == "shield" then enemy.color = {0,0,0} end
		end
	end
end