-- Scuba Trash

debug = true

-- Player data
player = { x = 200, y = 710, speed = 150, img = nil}
isAlive = true
score = 0

-- Timers
-- Los declaramos aqui para no tener que editarlos en multiples sitios

createFishTimerMax = 0.4
createFishTimer = createEnemyFishMax

createTrashTimerMax = 0.4
createTrashTimer = createTrashTimerMax

-- Image storage
trashImg = nil
fishImg = nil

-- Sound
gunSound = nil

-- Entity Storage
trashes = {} -- array con la basura que esta flotando
fishes = {} -- array con los peces que van apareciendo

function love.load(arg)
	player.img = love.graphics.newImage('assets/Aircraft_03.png')
	trashImg = love.graphics.newImage('assets/bullet_2_orange.png')
	fishImg = love.graphics.newImage('assets/enemy.png')
	gunSound = love.audio.newSource('assets/gun-sound.wav', static)
end

function love.update(dt)
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	-- Player Horizontal Movement

	if love.keyboard.isDown('left', 'a') then
		if player.x > 0 then
			player.x = player.x - (player.speed * dt)
		end
	elseif love.keyboard.isDown('right', 'd') then
		if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
			player.x = player.x + (player.speed * dt)
		end
	end

	-- Player Vertical Movement

	if love.keyboard.isDown('up', 'w') then
		if player.y > 0 then
			player.y = player.y - (player.speed * dt)
		end
	elseif love.keyboard.isDown('down', 's') then
		if player.y < (love.graphics.getHeight() - player.img:getHeight()) then
			player.y = player.y + (player.speed * dt)
		end
	end	

	-- time out fish creation
	createTrashTimer = createTrashTimer - (1 * dt)
	if createTrashTimer < 0 then
		createTrashTimer = createTrashTimerMax

		-- create a fish
		randomNumber = math.random(10, love.graphics.getWidth() - 10)
		newTrash = { x = randomNumber , y = -10, img = trashImg}
		table.insert(trashes, newTrash)
	end	

	-- actualizamos las posiciones de las basuras
	for i, trash in ipairs(trashes) do
		trash.y = trash.y + (250 * dt)

		if trash.y > love.graphics.getHeight() then -- eliminamos las basuras cuando salen de la pantalla
			table.remove(trashes, i)
		end
	end

	-- time out fish creation
	createFishTimer = createFishTimer - (1 * dt)
	if createFishTimer < 0 then
		createFishTimer = createFishTimerMax

		-- create a fish
		randomNumber = math.random(10, love.graphics.getHeight() - 10)
		newFish = { x = -10 , y = randomNumber, img = fishImg}
		table.insert(fishes, newFish)
	end

	-- actualizamos la posicion de los fishes
	for i, fish in ipairs(fishes) do
		fish.x = fishe.x + (250 * dt)

		if fish.x > love.graphics.getWidth() then -- eliminamos los fishes cuando salen de la pantalla
			table.remove(fishes, i)
		end
	end

	-- run our collision detection
	-- Since there will be fewer enemies on screen than trashes we'll loop them first
	-- Also, we need to see if the enemies hit our player
	for i, fish in ipairs(fishes) do
		for j, trash in ipairs(trashes) do
			if CheckCollision(fish.x, fish.y, fish.img:getWidth(), fish.img:getHeight(), trash.x, trash.y, trash.img:getWidth(), trash.img:getHeight()) then
				table.remove(trashes, j)
				table.remove(fishes, i)
				score = score + 1
			end
		end

		if CheckCollision(fish.x, fish.y, fish.img:getWidth(), fish.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) 
		and isAlive then
			table.remove(enemies, i)
			isAlive = false
		end
	end

	if not isAlive and love.keyboard.isDown('r') then
		-- remove all our trashes and enemies from screen
		fishes = {}
		trashes = {}

		-- reset timers
		createTrashTimer = createTrashTimerMax
		createFishTimer = createFishTimerMax

		-- move player back to default position
		player.x = 50
		player.y = 710

		-- reset our game state
		score = 0
		isAlive = true
	end
	
end

function love.draw(dt)
	if isAlive then
		love.graphics.draw(player.img, player.x, player.y)
		-- Ejercicio: Display the Score
		love.graphics.print("Score: "..score, love.graphics:getWidth()-100, 100)
	else
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end

	for i, trash in ipairs(trashes) do
		love.graphics.draw(trash.img, trash.x, trash.y)
	end

	for i, fish in ipairs(fishes) do
		love.graphics.draw(fish.img, fish.x, fish.y)
	end
end

-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
		 x2 < x1+w1 and
		 y1 < y2+h2 and
		 y2 < y1+h1
end