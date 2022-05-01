--FLAPPY BIRD GAME WITH A TWIST
--Made within 2 hours before new year of 2022
--
--Further additions such as:
--  * title/menu screen
--  * game juice
--  * sound effects
--were made post new year
--
--
--CODE BY @flamendless Brandon Blanker Lim-it
--ARTS BY @wits Conrad Reyes

love.graphics.setDefaultFilter("nearest", "nearest")

local QUARTER_PI = math.pi / 4
local JUMP_STRENGTH = 480
local HSPEED = 128
local GRAVITY = 720
local CHANCE = 0.25
local WW, WH = love.graphics.getDimensions()
local TIMER, ANIM_TIMER = 0, 0
local DURATION = 0.5
local FRAME_SPEED = 0.25
local SCORE = 0
local STR_GAME_OVER = "GAME OVER!"
local STR_RESTART = "Press R to Restart"

local font_score = love.graphics.newFont("assets/minecraft.ttf", 32)
local font_title = love.graphics.newFont("assets/minecraft.ttf", 64)
local font_btns = love.graphics.newFont("assets/minecraft.ttf", 48)

local assets = {
	images = {
		bg = "assets/bg.png",
		clouds = "assets/clouds.png",
		waves = "assets/waves.png",
		bird = "assets/bird.png",
		fish = "assets/fish.png",
		sun = "assets/sun.png",
	},
	bgm = {
		title = "assets/title_bgm.ogg",
		main = "assets/main_bgm.ogg",
		dead = "assets/dead_bgm.ogg",
	}
}

local images = {}
local bgm = {}
local states = {title = 1, game = 2, game_over = 3}
local current_state = states.title

local bg, clouds, waves
local rect1 = {x = 0, y = 0, w = WW, h = WH * 0.5}
local rect2 = {x = 0, y = WH * 0.5, w = WW, h = WH * 0.5}
local overlay = true
local title_texts_intro = false
local bird_appear = false
local title = {str = "FLAPPY IBON", x = 0, y = -WH * 0.25}
local btns = {
	{str = "PLAY", x = 0, y = WH * 1.25, ty = WH * 0.6},
	{str = "QUIT", x = 0, y = WH * 1.5, ty = WH * 0.75}
}
local btn_i = 1

local player = {
	ix = -64,
	iy = WH * 0.5 - 32,
	x = WW * 0.5,
	y = WH * 0.5,
	jump_strength = 0,
	is_alive = true,
	frame = 0,
	rotation = 0,
	sx = 1, sy = 1,
	ox = 0, oy = 0,
}

local fishes = {}
local function create_fish()
	local fw, fh = images.fish:getDimensions()
	local fish = {
		x = love.math.random(0, WW),
		y = WH,
		rotation = 0,
		sx = love.math.random() < 0.5 and -1 or 1,
		sy = 1,
		ox = fh * 0.5,
		oy = fh * 0.5,
		jump_strength = love.math.random(JUMP_STRENGTH * 1.5, JUMP_STRENGTH * 3),
		gravity = love.math.random(GRAVITY, GRAVITY * 3),
		is_alive = true,
		is_gold = love.math.random() < 0.25,
	}
	table.insert(fishes, fish)
end

local function is_colliding(x1, y1, w1, h1, x2, y2, w2, h2)
	local hor = (x1 + w1 >= x2) and (x1 <= x2 + w2)
	local ver = (y1 + h1 >= y2) and (y1 <= y2 + h2)
	return hor and ver
end

function love.load()
	for k, v in pairs(assets.images) do
		images[k] = love.graphics.newImage(v)
	end

	for k, v in pairs(assets.bgm) do
		local source = love.audio.newSource(v, "stream")
		source:setLooping(false)
		bgm[k] = source
	end

	local bw, bh = images.bird:getDimensions()
	player.quad = love.graphics.newQuad(0, 0, 64, 64, bw, bh)
	player.ox = bw * 0.5
	player.oy = bh * 0.5

	local bgw, bgh = images.bg:getDimensions()
	bg = love.graphics.newQuad(0, 0, bgw * 2, bgh * 2, bgw, bgh)
	images.bg:setWrap("repeat", "repeat")

	local cw, ch = images.clouds:getDimensions()
	clouds = love.graphics.newQuad(0, 0, cw * 2, ch * 2, cw, ch)
	images.clouds:setWrap("repeat", "repeat")

	local ww, wh = images.waves:getDimensions()
	waves = love.graphics.newQuad(0, 0, ww * 2, wh * 2, ww, wh)
	images.waves:setWrap("repeat", "repeat")

	bgm.title:play()
end

function love.update(dt)
	TIMER = TIMER + dt
	ANIM_TIMER = ANIM_TIMER + dt

	local bgx, bgy, bgw, bgh = bg:getViewport()
	bg:setViewport(bgx + 128 * dt, bgy, bgw, bgh)

	local cx, cy, cw, ch = bg:getViewport()
	clouds:setViewport(cx + 164 * dt, cy, cw, ch)

	local wx, wy, ww, wh = waves:getViewport()
	waves:setViewport(wx + 164 * dt, wy, ww, wh)

	if ANIM_TIMER >= FRAME_SPEED then
		player.frame = player.frame + 1
		if player.frame >= 2 then
			player.frame = 0
		end
		player.quad:setViewport(player.frame * 64, 0, 64, 64)
		ANIM_TIMER = 0
	end

	if current_state == states.title then
		local ms = 256
		if overlay then
			rect1.y = rect1.y - ms * dt
			rect2.y = rect2.y + ms * dt
			overlay = not (rect1.y + rect1.h < 0 and rect2.y > WH)
			title_texts_intro = not overlay
		elseif title_texts_intro then
			local is_all_finished = false

			if title.y < WH * 0.25 then
				title.y = title.y + ms * dt
			else
				is_all_finished = true
			end

			for _, btn in ipairs(btns) do
				if btn.y > btn.ty then
					btn.y = btn.y - ms * dt
					is_all_finished = false
				else
					is_all_finished = true
				end
			end

			if is_all_finished then
				title_texts_intro = false
				bird_appear = true
			end
		elseif bird_appear then
			local speed = 8
			local dy = math.sin(TIMER * speed)
			if player.ix < WW * 0.5 then
				player.ix = player.ix + 128 * dt
			end

			player.rotation = player.rotation + math.sin(TIMER) * dt
			player.iy = player.iy + 256 * dy * dt
		end

	elseif current_state == states.game then
		if not player.is_alive then return end

		local left = love.keyboard.isDown("left") or love.keyboard.isDown("a")
		local right = love.keyboard.isDown("right") or love.keyboard.isDown("d")
		local dir = 0
		if left then
			dir = -1
		elseif right then
			dir = 1
		end

		player.x = player.x + HSPEED * dt * dir
		player.y = player.y - player.jump_strength * dt
		player.jump_strength = player.jump_strength - GRAVITY * dt
		player.rotation = player.rotation + dt * dir

		if player.y > WH then
			player.is_alive = false
			current_state = states.game_over
			bgm.main:stop()
			bgm.dead:play()
			return
		end

		local fw, fh = images.fish:getDimensions()
		for _, fish in ipairs(fishes) do
			fish.y = fish.y - fish.jump_strength * dt
			fish.jump_strength = fish.jump_strength - fish.gravity * dt
			fish.sy = fish.jump_strength > 0 and 1 or -1

			local coll = is_colliding(
				player.x - player.ox, player.y - player.oy, 64, 64,
				fish.x - fish.ox, fish.y - fish.oy, fw, fh)

			if coll then
				if fish.is_gold then
					fish.is_alive = false
					SCORE = SCORE + 25
				else
					player.is_alive = false
					current_state = states.game_over
					bgm.main:stop()
					bgm.dead:play()
					return
				end
			end

			if fish.y > WH + 64 then
				fish.is_alive = false
				SCORE = SCORE + 1
			end
		end

		for i = #fishes, 1, -1 do
			local fish = fishes[i]
			if not fish.is_alive then
				table.remove(fishes, i)
			end
		end

		if TIMER >= DURATION then
			local r = love.math.random()
			if r <= CHANCE then
				create_fish()
				TIMER = 0
			end
		end
	end
end

function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(images.bg, bg)
	love.graphics.draw(images.clouds, clouds)
	love.graphics.draw(images.sun, 32, -64, 0, 0.75, 0.75)

	if current_state == states.title then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(images.waves, waves)
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.draw(images.bird, player.quad, player.ix, player.iy,
				player.rotation, player.sx, player.sy, player.ox, player.oy)

			love.graphics.setColor(1, 1, 0, 1)
			love.graphics.setFont(font_title)
			love.graphics.printf(title.str, title.x, title.y, WW, "center")

			love.graphics.setFont(font_btns)
			for i, btn in ipairs(btns) do
				if btn_i == i then
					love.graphics.setColor(1, 0, 0, 1)
				else
					love.graphics.setColor(1, 1, 0, 1)
				end
				love.graphics.printf(btn.str, btn.x, btn.y, WW, "center")
			end

			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.rectangle("fill", rect1.x, rect1.y, rect1.w, rect1.h)
			love.graphics.rectangle("fill", rect2.x, rect2.y, rect2.w, rect2.h)
	elseif current_state == states.game then
		love.graphics.draw(images.bird, player.quad, player.x, player.y,
			player.rotation, player.sx, player.sy, player.ox, player.oy)
		love.graphics.setColor(1, 0, 0, 1)

		for _, fish in ipairs(fishes) do
			if fish.is_alive then
				if fish.is_gold then
					love.graphics.setColor(1, 1, 0, 1)
				else
					love.graphics.setColor(1, 1, 1, 1)
				end

				love.graphics.draw(images.fish,
					fish.x, fish.y,
					fish.rotation, fish.sx, fish.sy, fish.ox, fish.oy)
			end
		end

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(images.waves, waves)

		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.setFont(font_score)
		love.graphics.print(tostring(SCORE), WW - font_score:getWidth(SCORE) - 16, 16)
	elseif current_state == states.game_over then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.setFont(font_score)
		love.graphics.print(STR_GAME_OVER,
			WW * 0.5 - font_score:getWidth(STR_GAME_OVER) * 0.5,
			WH * 0.25 - font_score:getHeight(STR_GAME_OVER) * 0.5)

		local score = "SCORE: " .. SCORE
		love.graphics.print(score,
			WW * 0.5 - font_score:getWidth(score) * 0.5,
			WH * 0.5 - font_score:getHeight(score) * 0.5)

		love.graphics.print(STR_RESTART,
			WW * 0.5 - font_score:getWidth(STR_RESTART) * 0.5,
			WH * 0.75 - font_score:getHeight(STR_RESTART) * 0.5)
	end
end

function love.keypressed(key)
	if current_state == states.title then
		if key == "up" or key == "w" then
			btn_i = btn_i - 1
		elseif key == "down" or key == "s" then
			btn_i = btn_i + 1
		elseif (key == "return" or key == "space") and bird_appear then
			if btn_i == 1 then
				current_state = states.game
				bgm.title:stop()
				bgm.main:play()
			elseif btn_i == 2 then
				love.event.quit()
			end
		end

		if btn_i < 1 then
			btn_i = #btns
		elseif btn_i > #btns then
			btn_i = 1
		end
	elseif current_state == states.game then
		local can_jump = player.y >= 0
		if can_jump and key == "space" then
			player.jump_strength = JUMP_STRENGTH
		end
	elseif current_state == states.game_over then
		if not player.is_alive and key == "r" then
			current_state = states.game
			fishes = {}
			TIMER = 0
			SCORE = 0
			player = {
				ix = -64,
				iy = WH * 0.5 - 32,
				x = WW * 0.5,
				y = WH * 0.5,
				jump_strength = 0,
				is_alive = true,
				frame = 0,
				rotation = 0,
				sx = 1, sy = 1,
				ox = 0, oy = 0,
				quad = player.quad,
			}
			bgm.dead:stop()
			bgm.main:play()
		end
	end
end
