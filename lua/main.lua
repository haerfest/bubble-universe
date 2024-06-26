-- Bubble Universe
-- https://www.stardot.org.uk/forums/viewtopic.php?t=25833
--
-- To run (macOS):
--   $ open /Applications/love.app --args $PWD

function love.load()
	love.window.setTitle("Bubble Universe")
	love.window.setMode(1920, 1080, { fullscreen = true, vsync = -1 })
	love.keyboard.setKeyRepeat(true)
	love.graphics.setPointSize(2)

	w, h = love.graphics.getDimensions()
	tx, ty = w / 2, h / 2
	sc = math.min(w - 50, h - 50) / 4

	keys = {
		["escape"] = love.event.quit,
		["space"] = reset,
		["1"] = function(delta)
			n = math.max(n - delta, 1)
		end,
		["2"] = function(delta)
			n = n + delta
		end,
		["3"] = function(delta)
			m = math.max(m - delta, 1)
		end,
		["4"] = function(delta)
			m = m + delta
		end,
		["a"] = function()
			n, m, rx, ry = 1500, 10, 0.005, -0.004
		end,
	}

	t = 0
	points = {}

	reset()
end

function reset()
	-- #objects and #particles per object
	n, m = 200, 200
	-- starting angles
	rx, ry = math.pi * 2 / 235, 1
end

function love.update(dt)
	local a, b, x, y, k

	points = {}

	k = 0
	for i = 0, n - 1 do
		x, y = 0, 0
		for j = 0, m - 1 do
			a = x + i * rx + t
			b = y + i * ry + t
			x = math.sin(a) + math.sin(b)
			y = math.cos(a) + math.cos(b)
			points[k] = { x, y, i / n, j / m, (n - i + m - j) / (n + m) }
			k = k + 1
		end
	end

	t = t + dt / 22 -- at 60 fps ~ π / 4096
end

function love.draw()
	love.graphics.print(string.format("fps %d n %d m %d rx %.3f ry %.3f", love.timer.getFPS(), n, m, rx, ry), 0, 0)
	love.graphics.translate(tx, ty)
	love.graphics.scale(sc, sc)
	love.graphics.points(points)
end

function sign(x)
	return x < 0 and -1 or 1
end

function love.mousepressed(x, y, button, istouch, presses)
	local mx, my
	if button == 1 then
		-- scale and limit to [-2, +2]
		mx, my = (x - tx) / sc, (y - ty) / sc
		mx, my = math.max(-2, math.min(mx, 2)), math.max(-2, math.min(my, 2))
		-- more resolution closer to 0, less so closer to ±2
		mx, my = sign(mx) * mx ^ 2 / 2, sign(my) * my ^ 2 / 2
		-- scale to [-2π, +2π]
		rx, ry = mx * math.pi, -my * math.pi
	end
end

function love.keypressed(key, scancode, isrepeat)
	handler = keys[key]
	if handler then
		lshift = love.keyboard.isDown("lshift")
		rshift = love.keyboard.isDown("rshift")
		delta = (lshift or rshift) and 50 or 1
		handler(delta)
	end
end
