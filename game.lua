

local composer = require( "composer" )
local scene = composer.newScene()

local physics = require "physics"
physics.start()
physics.setGravity( 0, 100 )

local mydata = require( "mydata" )


local gameStarted = false

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here

---------------------------------------------------------------------------------


function onCollision( event )
	if ( event.phase == "began" ) then
		composer.gotoScene( "restart" )
		
	end
end

function platformScroller(self,event)
	
	if self.x < (-900 + (self.speed*2)) then
		self.x = 900
	else 
		self.x = self.x - self.speed
	end
	
end



function flyUp(event)
	
   if event.phase == "began" then
       
		if gameStarted == false then
			 player.bodyType = "dynamic"
			 instructions.alpha = 0
			 tb.alpha = 1
			 addColumnTimer = timer.performWithDelay(1000, addColumns, -1)
			 moveColumnTimer = timer.performWithDelay(2, moveColumns, -1)
			 gameStarted = true
			 player:applyForce(0, -300, player.x, player.y)
		else 
       
	    player:applyForce(0, -600, player.x, player.y)
		
      end
	end
end



function moveColumns()
		for a = elements.numChildren,1,-1  do
			if(elements[a].x < display.contentCenterX - 170) then
				if elements[a].scoreAdded == false then
					mydata.score = mydata.score + 1
					tb.text = mydata.score
					elements[a].scoreAdded = true
				end
			end
			if(elements[a].x > -100) then
				elements[a].x = elements[a].x - 12
			else 
				elements:remove(elements[a])
			end	
		end
end

function addColumns()
	
	height = math.random(display.contentCenterY - 200, display.contentCenterY + 200)

	topColumn = display.newImageRect('topColumn.png',100,714)
	topColumn.anchorX = 0.5
	topColumn.anchorY = 1
	topColumn.x = display.contentWidth + 100
	topColumn.y = height - 160
	topColumn.scoreAdded = false
	physics.addBody(topColumn, "static", {density=1, bounce=0.1, friction=.2})
	elements:insert(topColumn)
	
	bottomColumn = display.newImageRect('bottomColumn.png',100,714)
	bottomColumn.anchorX = 0.5
	bottomColumn.anchorY = 0
	bottomColumn.x = display.contentWidth + 100
	bottomColumn.y = height + 160
	physics.addBody(bottomColumn, "static", {density=1, bounce=0.1, friction=.2})
	elements:insert(bottomColumn)

end	

local function checkMemory()
   collectgarbage( "collect" )
   local memUsage_str = string.format( "MEMORY = %.3f KB", collectgarbage( "count" ) )
   --print( memUsage_str, "TEXTURE = "..(system.getInfo("textureMemoryUsed") / (1024 * 1024) ) )
end


-- "scene:create()"
function scene:create( event )

   local sceneGroup = self.view
   
   gameStarted = false
   mydata.score = 0

   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.
   
   local background = display.newImage("bg.png")
	sceneGroup:insert(background)

    bg = display.newImageRect('bg.png',900,1425)
	bg.anchorX = 0
	bg.anchorY = 1
	bg.x = 0
	bg.y = display.contentHeight
	bg.speed = 4
	sceneGroup:insert(bg)
    
    elements = display.newGroup()
	elements.anchorChildren = true
	elements.anchorX = 0
	elements.anchorY = 1
	elements.x = 0
	elements.y = 0
	sceneGroup:insert(elements)

	ground = display.newImageRect('ground.png',900,162)
	ground.anchorX = 0
	ground.anchorY = 1
	ground.x = 0
	ground.y = display.contentHeight
	sceneGroup:insert(ground)

	platform = display.newImageRect('platform.png',900,53)
	platform.anchorX = 0
	platform.anchorY = 1
	platform.x = 0
	platform.y = display.viewableContentHeight - 110
	physics.addBody(platform, "static", {density=.1, bounce=0.1, friction=.2})
	platform.speed = 4
	sceneGroup:insert(platform)

	platform2 = display.newImageRect('platform.png',900,53)
	platform2.anchorX = 0
	platform2.anchorY = 1
	platform2.x = platform2.width
	platform2.y = display.viewableContentHeight - 110
	physics.addBody(platform2, "static", {density=.1, bounce=0.1, friction=.2})
	platform2.speed = 4
	sceneGroup:insert(platform2)
	
	p_options = 
	{
		-- Required params
		width = 80,
		height = 42,
		numFrames = 2,
		-- content scaling
		sheetContentWidth = 160,
		sheetContentHeight = 42,
	}

	playerSheet = graphics.newImageSheet( "bat.png", p_options )
	player = display.newSprite( playerSheet, { name="player", start=1, count=2, time=500 } )
	player.anchorX = 0.5
	player.anchorY = 0.5
	player.x = display.contentCenterX - 150
	player.y = display.contentCenterY
	physics.addBody(player, "static", {density=.1, bounce=0.1, friction=1})
	player:applyForce(0, -300, player.x, player.y)
	player:play()
	sceneGroup:insert(player)
	
	tb = display.newText(mydata.score,display.contentCenterX,
	150, "pixelmix", 58)
	tb:setFillColor(0,0,0)
	tb.alpha = 0
	sceneGroup:insert(tb)
	
	instructions = display.newImageRect("instructions.png",400,328)
	instructions.anchorX = 0.5
	instructions.anchorY = 0.5
	instructions.x = display.contentCenterX
	instructions.y = display.contentCenterY
	sceneGroup:insert(instructions)
	
   
end

-- "scene:show()"


function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
	  
	composer.removeScene("start")
	Runtime:addEventListener("touch", flyUp)

	platform.enterFrame = platformScroller
	Runtime:addEventListener("enterFrame", platform)

	platform2.enterFrame = platformScroller
	Runtime:addEventListener("enterFrame", platform2)
    
    Runtime:addEventListener("collision", onCollision)
   
    memTimer = timer.performWithDelay( 1000, checkMemory, 0 )
	  
   end
end

-- "scene:hide()"
function scene:hide( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
	  Runtime:removeEventListener("touch", flyUp)
	Runtime:removeEventListener("enterFrame", platform)
	Runtime:removeEventListener("enterFrame", platform2)
	Runtime:removeEventListener("collision", onCollision)
	timer.cancel(addColumnTimer)
	timer.cancel(moveColumnTimer)
	timer.cancel(memTimer)
	  
	  
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end

-- "scene:destroy()"
function scene:destroy( event )

   local sceneGroup = self.view

   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene













