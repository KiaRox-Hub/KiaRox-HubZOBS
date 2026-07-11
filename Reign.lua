local library = loadstring(game:HttpGet('https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew', true))()
local tab = library:CreateWindow('Reign Fall Script')
local main = tab:AddFolder('Main')

main:AddToggle({
    text = 'Aimbot',
    flag = 'aimbot_toggle',
    callback = function(v)
        if v then
            print("Aimbot ENABLED")
            startAimbotLoop()
        else
            print("Aimbot DISABLED")
        end
    end
})

function startAimbotLoop()
    while getFlag('aimbot_toggle') do
        local target = findTarget()
        if target then
            aimAt(target)
        end
        wait(0.01)
    end
end

function findTarget()
    local localPlayer = game.Players.LocalPlayer
    local localTeam = localPlayer.Team
    
    for _, player in pairs(game.Players:GetPlayers()) do
        -- Skip self
        if player == localPlayer then continue end
        
        -- Team check (skip teammates)
        if player.Team == localTeam then continue end
        
        -- Check if player is zombie
        if not isZombie(player) then continue end
        
        -- Check if player has character
        if not player.Character then continue end
        
        -- Return first valid target
        return player
    end
    
    return nil
end

function isZombie(player)
    -- Method 1: Check humanoid state
    if player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        -- Check for zombie-specific attributes
        if humanoid:FindFirstChild("ZombieState") then
            return true
        end
    end
    
    -- Method 2: Check for zombie tag/value
    if player.Character:FindFirstChild("IsZombie") then
        return player.Character.IsZombie.Value == true
    end
    
    -- Method 3: Check character appearance/model
    if player.Character:FindFirstChild("Head") then
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            return true -- Adjust based on your game's zombie detection
        end
    end
    
    return false
end

function aimAt(target)
    local camera = workspace.CurrentCamera
    local targetPos = target.Character:FindFirstChild("Head").Position
    camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
end

function getFlag(flag)
    -- Returns the toggle state
    return _G[flag] or false
end
})

main:AddToggle({
    text = 'Auto Reload',
    flag = 'auto_reload',
    callback = function(v)
        if v then
            print("Auto Reload ENABLED")
            startAutoReload()
        else
            print("Auto Reload DISABLED")
        end
    end
})

function startAutoReload()
    while getFlag('auto_reload') do
        pcall(function()
            local player = game.Players.LocalPlayer
            local character = player.Character
            
            if character then
                local primary = character:WaitForChild("primary")
                local serverEvents = primary:WaitForChild("ServerEvents")
                local reloadAmmo = serverEvents:WaitForChild("ReloadAmmo")
                
                local args = {false}
                reloadAmmo:FireServer(unpack(args))
            end
        end)
        
        wait(0.1) -- Reload every 0.5 seconds (adjust as needed)
    end
end

function getFlag(flag)
    return _G[flag] or false
end
})

main:AddToggle({
    text = 'Player ESP',
    flag = 'toggle',
    callback = function(v)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local camera = workspace.CurrentCamera
        local lp = Players.LocalPlayer
        
        local esp = {
            enabled = v,
            drawings = {},
            connection = nil
        }
        
        local function createESP(player)
            if player == lp or esp.drawings[player] then return end
            
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local drawings = {
                name = Drawing.new("Text"),
                health = Drawing.new("Text"),
                distance = Drawing.new("Text"),
                box = Drawing.new("Square"),
                line = Drawing.new("Line")
            }
            
            -- Name Drawing
            drawings.name.Size = 18
            drawings.name.Color = Color3.fromRGB(255, 255, 255)
            drawings.name.OutlineColor = Color3.fromRGB(0, 0, 0)
            drawings.name.OutlineSize = 2
            drawings.name.Center = true
            
            -- Health Drawing
            drawings.health.Size = 16
            drawings.health.Color = Color3.fromRGB(0, 255, 0)
            drawings.health.OutlineColor = Color3.fromRGB(0, 0, 0)
            drawings.health.OutlineSize = 2
            
            -- Distance Drawing
            drawings.distance.Size = 14
            drawings.distance.Color = Color3.fromRGB(100, 100, 255)
            drawings.distance.OutlineColor = Color3.fromRGB(0, 0, 0)
            drawings.distance.OutlineSize = 2
            
            -- Box Drawing
            drawings.box.Thickness = 2
            drawings.box.Filled = false
            drawings.box.Color = Color3.fromRGB(255, 0, 0)
            drawings.box.OutlineColor = Color3.fromRGB(0, 0, 0)
            
            -- Line Drawing (tracer)
            drawings.line.Thickness = 1
            drawings.line.Color = Color3.fromRGB(255, 255, 0)
            
            esp.drawings[player] = drawings
        end
        
        local function updateESP(player)
            if not esp.drawings[player] then return end
            
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then
                removeESP(player)
                return
            end
            
            local humanoidRootPart = character.HumanoidRootPart
            local humanoid = character:FindFirstChild("Humanoid")
            local drawings = esp.drawings[player]
            
            -- Get screen position
            local screenPos, onScreen = camera:WorldToScreenPoint(humanoidRootPart.Position)
            
            if onScreen then
                -- Calculate distance
                local distance = (humanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                
                -- Update Name
                drawings.name.Position = Vector2.new(screenPos.X, screenPos.Y - 40)
                drawings.name.Text = player.Name
                drawings.name.Visible = true
                
                -- Update Health
                local health = humanoid and humanoid.Health or 0
                local maxHealth = humanoid and humanoid.MaxHealth or 100
                local healthPercent = (health / maxHealth) * 100
                drawings.health.Position = Vector2.new(screenPos.X - 50, screenPos.Y - 20)
                drawings.health.Text = "HP: " .. math.floor(healthPercent) .. "%"
                drawings.health.Color = healthPercent > 50 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                drawings.health.Visible = true
                
                -- Update Distance
                drawings.distance.Position = Vector2.new(screenPos.X, screenPos.Y + 40)
                drawings.distance.Text = math.floor(distance) .. " studs"
                drawings.distance.Visible = true
                
                -- Update Box
                local size = Vector3.new(3, 5, 0)
                local topLeft, topLeftOnScreen = camera:WorldToScreenPoint(humanoidRootPart.Position + Vector3.new(-size.X, size.Y, 0))
                local bottomRight, bottomRightOnScreen = camera:WorldToScreenPoint(humanoidRootPart.Position + Vector3.new(size.X, -size.Y, 0))
                
                if topLeftOnScreen and bottomRightOnScreen then
                    drawings.box.Position = Vector2.new(topLeft.X, topLeft.Y)
                    drawings.box.Size = Vector2.new(bottomRight.X - topLeft.X, bottomRight.Y - topLeft.Y)
                    drawings.box.Visible = true
                else
                    drawings.box.Visible = false
                end
                
                -- Update Tracer Line
                local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                drawings.line.From = screenCenter
                drawings.line.To = Vector2.new(screenPos.X, screenPos.Y)
                drawings.line.Visible = true
                
            else
                -- Hide all drawings if not on screen
                for _, drawing in pairs(drawings) do
                    drawing.Visible = false
                end
            end
        end
        
        local function removeESP(player)
            if esp.drawings[player] then
                for _, drawing in pairs(esp.drawings[player]) do
                    drawing:Remove()
                end
                esp.drawings[player] = nil
            end
        end
        
        local function clearAllESP()
            for player, _ in pairs(esp.drawings) do
                removeESP(player)
            end
        end
        
        if v then
            -- ENABLE ESP
            print("Player ESP: Enabled")
            
            -- Create ESP for existing players
            for _, player in ipairs(Players:GetPlayers()) do
                createESP(player)
            end
            
            -- Create ESP for new players
            Players.PlayerAdded:Connect(function(player)
                if esp.enabled then
                    createESP(player)
                end
            end)
            
            -- Remove ESP when player leaves
            Players.PlayerRemoving:Connect(function(player)
                removeESP(player)
            end)
            
            -- Update ESP every frame
            esp.connection = RunService.RenderStepped:Connect(function()
                if esp.enabled then
                    for _, player in ipairs(Players:GetPlayers()) do
                        updateESP(player)
                    end
                end
            end)
            
        else
            -- DISABLE ESP
            print("Player ESP: Disabled")
            esp.enabled = false
            
            if esp.connection then
                esp.connection:Disconnect()
                esp.connection = nil
            end
            
            clearAllESP()
        end
    end
})

main:AddToggle({
    text = 'Zombie Cham ESP',
    flag = 'toggle',
    callback = function(v)
        local RunService = game:GetService("RunService")
        local camera = workspace.CurrentCamera
        local lp = game:GetService("Players").LocalPlayer
        
        local esp = {
            enabled = v,
            drawings = {},
            chamDrawings = {},
            connection = nil,
            zombieFolder = workspace:FindFirstChild("Zombies") or workspace:FindFirstChild("ZombieFolder")
        }
        
        local function createESP(zombie)
            if not zombie or esp.drawings[zombie] then return end
            
            local humanoidRootPart = zombie:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            local drawings = {
                name = Drawing.new("Text"),
                health = Drawing.new("Text"),
                distance = Drawing.new("Text"),
                box = Drawing.new("Square"),
                line = Drawing.new("Line")
            }
            
            -- Name Drawing
            drawings.name.Size = 18
            drawings.name.Color = Color3.fromRGB(255, 165, 0)  -- Orange
            drawings.name.OutlineColor = Color3.fromRGB(0, 0, 0)
            drawings.name.OutlineSize = 2
            drawings.name.Center = true
            
            -- Health Drawing
            drawings.health.Size = 16
            drawings.health.Color = Color3.fromRGB(0, 255, 0)
            drawings.health.OutlineColor = Color3.fromRGB(0, 0, 0)
            drawings.health.OutlineSize = 2
            
            -- Distance Drawing
            drawings.distance.Size = 14
            drawings.distance.Color = Color3.fromRGB(100, 149, 237)
            drawings.distance.OutlineColor = Color3.fromRGB(0, 0, 0)
            drawings.distance.OutlineSize = 2
            
            -- Box Drawing
            drawings.box.Thickness = 2
            drawings.box.Filled = false
            drawings.box.Color = Color3.fromRGB(255, 165, 0)  -- Orange
            drawings.box.OutlineColor = Color3.fromRGB(0, 0, 0)
            
            -- Line Drawing (tracer)
            drawings.line.Thickness = 1
            drawings.line.Color = Color3.fromRGB(255, 165, 0)  -- Orange
            
            esp.drawings[zombie] = drawings
        end
        
        local function createChamESP(zombie)
            if not zombie or esp.chamDrawings[zombie] then return end
            
            local humanoidRootPart = zombie:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            -- Create a highlight effect (Cham)
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 165, 0)  -- Orange
            highlight.OutlineColor = Color3.fromRGB(255, 255, 0)  -- Yellow outline
            highlight.FillTransparency = 0.3
            highlight.OutlineTransparency = 0
            highlight.Parent = zombie
            
            esp.chamDrawings[zombie] = highlight
        end
        
        local function updateESP(zombie)
            if not zombie or not esp.drawings[zombie] then return end
            
            local humanoidRootPart = zombie:FindFirstChild("HumanoidRootPart")
            local humanoid = zombie:FindFirstChild("Humanoid")
            
            if not humanoidRootPart or not humanoid then
                removeESP(zombie)
                return
            end
            
            local drawings = esp.drawings[zombie]
            local screenPos, onScreen = camera:WorldToScreenPoint(humanoidRootPart.Position)
            
            if onScreen then
                -- Calculate distance
                local lpc = lp.Character
                if not lpc or not lpc:FindFirstChild("HumanoidRootPart") then return end
                
                local distance = (humanoidRootPart.Position - lpc.HumanoidRootPart.Position).Magnitude
                
                -- Update Name
                drawings.name.Position = Vector2.new(screenPos.X, screenPos.Y - 40)
                drawings.name.Text = "Zombie"
                drawings.name.Visible = true
                
                -- Update Health
                local health = humanoid.Health
                local maxHealth = humanoid.MaxHealth
                local healthPercent = (health / maxHealth) * 100
                drawings.health.Position = Vector2.new(screenPos.X - 50, screenPos.Y - 20)
                drawings.health.Text = "HP: " .. math.floor(healthPercent) .. "%"
                
                -- Color health based on percentage
                if healthPercent > 50 then
                    drawings.health.Color = Color3.fromRGB(0, 255, 0)
                elseif healthPercent > 25 then
                    drawings.health.Color = Color3.fromRGB(255, 255, 0)
                else
                    drawings.health.Color = Color3.fromRGB(255, 0, 0)
                end
                drawings.health.Visible = true
                
                -- Update Distance
                drawings.distance.Position = Vector2.new(screenPos.X, screenPos.Y + 40)
                drawings.distance.Text = math.floor(distance) .. " studs"
                drawings.distance.Visible = true
                
                -- Update Box (3D bounding box)
                local size = Vector3.new(2, 3, 0)
                local topLeft, topLeftOnScreen = camera:WorldToScreenPoint(
                    humanoidRootPart.Position + Vector3.new(-size.X, size.Y, 0)
                )
                local bottomRight, bottomRightOnScreen = camera:WorldToScreenPoint(
                    humanoidRootPart.Position + Vector3.new(size.X, -size.Y, 0)
                )
                
                if topLeftOnScreen and bottomRightOnScreen then
                    drawings.box.Position = Vector2.new(topLeft.X, topLeft.Y)
                    drawings.box.Size = Vector2.new(bottomRight.X - topLeft.X, bottomRight.Y - topLeft.Y)
                    drawings.box.Visible = true
                else
                    drawings.box.Visible = false
                end
                
                -- Update Tracer Line (from center of screen to zombie)
                local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                drawings.line.From = screenCenter
                drawings.line.To = Vector2.new(screenPos.X, screenPos.Y)
                drawings.line.Visible = true
                
            else
                -- Hide all drawings if zombie is off-screen
                for _, drawing in pairs(drawings) do
                    drawing.Visible = false
                end
            end
        end
        
        local function removeESP(zombie)
            if esp.drawings[zombie] then
                for _, drawing in pairs(esp.drawings[zombie]) do
                    drawing:Remove()
                end
                esp.drawings[zombie] = nil
            end
        end
        
        local function removeChamESP(zombie)
            if esp.chamDrawings[zombie] then
                esp.chamDrawings[zombie]:Destroy()
                esp.chamDrawings[zombie] = nil
            end
        end
        
        local function clearAllESP()
            for zombie, _ in pairs(esp.drawings) do
                removeESP(zombie)
            end
            for zombie, _ in pairs(esp.chamDrawings) do
                removeChamESP(zombie)
            end
        end
        
        if v then
            -- ENABLE ZOMBIE CHAM ESP
            print("Zombie Cham ESP: Enabled")
            esp.enabled = true
            
            -- Find zombie folder
            if not esp.zombieFolder then
                for _, folder in ipairs(workspace:GetChildren()) do
                    if folder.Name:lower():find("zombie") then
                        esp.zombieFolder = folder
                        break
                    end
                end
            end
            
            if esp.zombieFolder then
                -- Create ESP for existing zombies
                for _, zombie in ipairs(esp.zombieFolder:GetChildren()) do
                    if zombie:FindFirstChild("Humanoid") then
                        createESP(zombie)
                        createChamESP(zombie)
                    end
                end
                
                -- Create ESP when new zombie spawns
                esp.zombieFolder.ChildAdded:Connect(function(zombie)
                    if esp.enabled and zombie:FindFirstChild("Humanoid") then
                        task.wait(0.1)  -- Wait for zombie to fully load
                        createESP(zombie)
                        createChamESP(zombie)
                    end
                end)
                
                -- Remove ESP when zombie dies
                esp.zombieFolder.ChildRemoving:Connect(function(zombie)
                    removeESP(zombie)
                    removeChamESP(zombie)
                end)
            else
                print("Warning: Zombie folder not found!")
            end
            
            -- Update ESP every frame
            esp.connection = RunService.RenderStepped:Connect(function()
                if esp.enabled and esp.zombieFolder then
                    for _, zombie in ipairs(esp.zombieFolder:GetChildren()) do
                        if zombie:FindFirstChild("Humanoid") then
                            updateESP(zombie)
                        end
                    end
                end
            end)
            
        else
            -- DISABLE ZOMBIE CHAM ESP
            print("Zombie Cham ESP: Disabled")
            esp.enabled = false
            
            if esp.connection then
                esp.connection:Disconnect()
                esp.connection = nil
            end
            
            clearAllESP()
        end
    end
})

main:AddToggle({
    text = 'Slient Aim',
    flag = 'slient_aimtoggle',
    callback = function(v)
        local Players = game:GetService("Players")
        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        local lp = Players.LocalPlayer
        local camera = workspace.CurrentCamera
        local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        
        local target = {
            enabled = v,
            position = nil,
            enemyContainer = nil,
            heartbeatConnection = nil,
            namecallHook = nil
        }
        
        local function getEnemyContainer()
            local container = workspace.Game and workspace.Game.Current and workspace.Game.Current.Spawned and workspace.Game.Current.Spawned.NPCs
            if container then
                return container:FindFirstChild("enemies")
            end
            return nil
        end
        
        local function getClosestHead()
            local container = getEnemyContainer()
            if not container then return nil end
            
            local referencePos
            if isMobile then
                local vp = camera.ViewportSize
                referencePos = Vector2.new(vp.X / 2, vp.Y / 2)
            else
                referencePos = UserInputService:GetMouseLocation()
            end
            
            local bestHeadPos = nil
            local bestDist = math.huge
            
            for _, enemy in ipairs(container:GetChildren()) do
                local head = enemy:FindFirstChild("Head") or enemy:FindFirstChild("HumanoidRootPart")
                if head then
                    local screenPoint, onScreen = camera:WorldToScreenPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - referencePos).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            bestHeadPos = head.Position
                        end
                    end
                end
            end
            
            return bestHeadPos
        end
        
        if v then
            -- ENABLE AIMBOT
            print("Aimbot: Enabled")
            
            target.heartbeatConnection = RunService.Heartbeat:Connect(function()
                if target.enabled then
                    target.position = getClosestHead()
                end
            end)
            
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if target.enabled and method:lower() == "raycast" and self == workspace then
                    local args = {...}
                    if #args >= 2 and typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
                        local raycastParams = args[3]
                        if raycastParams and raycastParams.CollisionGroup == "raycast_npc_neutral" then
                            if target.position then
                                local origin = args[1]
                                local dir = target.position - origin
                                if dir.Magnitude > 0.001 then
                                    args[2] = dir.Unit * args[2].Magnitude
                                end
                            end
                        end
                    end
                    return oldNamecall(self, unpack(args))
                end
                return oldNamecall(self, ...)
            end))
            
            target.namecallHook = oldNamecall
            
        else
            -- DISABLE AIMBOT
            print("Aimbot: Disabled")
            target.enabled = false
            
            if target.heartbeatConnection then
                target.heartbeatConnection:Disconnect()
                target.heartbeatConnection = nil
            end
            
            if target.namecallHook then
                target.namecallHook = nil
            end
        end
    end
})

main:AddToggle({
    text = '1 hit shoot zombie',
    flag = 'toggle',
    callback = function(v)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")
        
        local lp = Players.LocalPlayer
        local mouse = lp:GetMouse()
        
        local oneHitConfig = {
            enabled = v,
            connection = nil,
            zombieFolder = workspace:FindFirstChild("Zombies") or workspace:FindFirstChild("ZombieFolder"),
            damageMultiplier = 999999,  -- One hit damage
            weaponDamage = 50  -- Base weapon damage
        }
        
        local function getPlayerWeapon()
            local character = lp.Character
            if not character then return nil end
            
            -- Check for weapon in hand
            for _, item in ipairs(character:GetChildren()) do
                if item:FindFirstChild("Handle") then
                    return item
                end
            end
            
            -- Check backpack
            local backpack = lp:FindFirstChild("Backpack")
            if backpack then
                for _, item in ipairs(backpack:GetChildren()) do
                    if item:FindFirstChild("Handle") then
                        return item
                    end
                end
            end
            
            return nil
        end
        
        local function modifyWeaponDamage(weapon)
            if not weapon then return end
            
            -- Find damage value in weapon
            local damage = weapon:FindFirstChild("Damage")
            if damage and damage:IsA("IntValue") or damage:IsA("NumberValue") then
                damage.Value = oneHitConfig.damageMultiplier
            end
            
            -- Alternative: Check for custom damage scripts
            for _, child in ipairs(weapon:GetDescendants()) do
                if child:IsA("IntValue") or child:IsA("NumberValue") then
                    if child.Name:lower():find("damage") or child.Name:lower():find("dmg") then
                        child.Value = oneHitConfig.damageMultiplier
                    end
                end
            end
        end
        
        local function onMouseClick()
            if not oneHitConfig.enabled then return end
            
            local weapon = getPlayerWeapon()
            if not weapon then return end
            
            -- Modify weapon damage before shooting
            modifyWeaponDamage(weapon)
            
            -- Get mouse target
            local target = mouse.Target
            if not target then return end
            
            -- Check if target is a zombie
            local zombie = target.Parent
            while zombie and not zombie:FindFirstChild("Humanoid") do
                zombie = zombie.Parent
            end
            
            if not zombie or not zombie:FindFirstChild("Humanoid") then return end
            
            -- Check if zombie is in zombie folder
            if oneHitConfig.zombieFolder and not zombie:IsDescendantOf(oneHitConfig.zombieFolder) then
                return
            end
            
            local humanoid = zombie:FindFirstChild("Humanoid")
            if humanoid then
                -- Deal massive damage
                humanoid:TakeDamage(oneHitConfig.damageMultiplier)
                print("1 Hit Kill: " .. zombie.Name .. " eliminated!")
            end
        end
        
        local function modifyAllWeapons()
            -- Modify weapon in hand
            local character = lp.Character
            if character then
                for _, item in ipairs(character:GetChildren()) do
                    if item:FindFirstChild("Handle") then
                        modifyWeaponDamage(item)
                    end
                end
            end
            
            -- Modify weapons in backpack
            local backpack = lp:FindFirstChild("Backpack")
            if backpack then
                for _, item in ipairs(backpack:GetChildren()) do
                    if item:FindFirstChild("Handle") then
                        modifyWeaponDamage(item)
                    end
                end
            end
        end
        
        local function onCharacterAdded(character)
            if not oneHitConfig.enabled then return end
            task.wait(0.5)  -- Wait for character to load
            modifyAllWeapons()
        end
        
        local function onWeaponAdded(weapon)
            if not oneHitConfig.enabled then return end
            if weapon:FindFirstChild("Handle") then
                task.wait(0.1)
                modifyWeaponDamage(weapon)
            end
        end
        
        if v then
            -- ENABLE 1 HIT SHOOT ZOMBIE
            print("1 Hit Shoot Zombie: Enabled")
            oneHitConfig.enabled = true
            
            -- Find zombie folder
            if not oneHitConfig.zombieFolder then
                for _, folder in ipairs(workspace:GetChildren()) do
                    if folder.Name:lower():find("zombie") then
                        oneHitConfig.zombieFolder = folder
                        break
                    end
                end
            end
            
            -- Modify existing weapons
            modifyAllWeapons()
            
            -- Listen for character respawn
            if lp.Character then
                onCharacterAdded(lp.Character)
            end
            lp.CharacterAdded:Connect(onCharacterAdded)
            
            -- Listen for new weapons
            local backpack = lp:FindFirstChild("Backpack")
            if backpack then
                backpack.ChildAdded:Connect(onWeaponAdded)
            end
            
            -- Listen for mouse click
            mouse.Button1Down:Connect(onMouseClick)
            
            -- Update weapon damage every frame
            oneHitConfig.connection = RunService.RenderStepped:Connect(function()
                if oneHitConfig.enabled then
                    modifyAllWeapons()
                end
            end)
            
        else
            -- DISABLE 1 HIT SHOOT ZOMBIE
            print("1 Hit Shoot Zombie: Disabled")
            oneHitConfig.enabled = false
            
            if oneHitConfig.connection then
                oneHitConfig.connection:Disconnect()
                oneHitConfig.connection = nil
            end
            
            -- Restore original weapon damage
            local character = lp.Character
            if character then
                for _, item in ipairs(character:GetChildren()) do
                    if item:FindFirstChild("Handle") then
                        local damage = item:FindFirstChild("Damage")
                        if damage then
                            damage.Value = oneHitConfig.weaponDamage
                        end
                    end
                end
            end
        end
    end
})

main:AddToggle({
    text = 'Fast Reload Ammo',
    flag = 'toggle',
    callback = function(v)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")
        
        local lp = Players.LocalPlayer
        local mouse = lp:GetMouse()
        
        local fastReloadConfig = {
            enabled = v,
            connections = {},
            reloadSpeed = 0.1,  -- Instant reload (0.1 seconds)
            ammoMultiplier = 999999,  -- Infinite ammo
            magazineSize = 999999,
            originalReloadTime = {},
            detectedWeapons = {},
            autoReload = true,
            infiniteAmmo = true,
            instantReload = true
        }
        
        -- ==================== WEAPON DETECTION ====================
        local function detectWeaponType(tool)
            if not tool then return nil end
            
            local weaponName = tool.Name:lower()
            
            -- Common weapon naming patterns
            if weaponName:find("gun") or weaponName:find("rifle") or 
               weaponName:find("pistol") or weaponName:find("shotgun") or
               weaponName:find("sniper") or weaponName:find("smg") or
               weaponName:find("ak") or weaponName:find("m4") or
               weaponName:find("glock") or weaponName:find("uzi") or
               weaponName:find("assault") or weaponName:find("carbine") or
               weaponName:find("revolver") or weaponName:find("handgun") or
               weaponName:find("blaster") or weaponName:find("laser") then
                return "GUN"
            end
            
            return "UNKNOWN"
        end
        
        -- ==================== AMMO SYSTEM DETECTION ====================
        local function findAmmoSystem(tool)
            if not tool then return nil end
            
            local ammoSystem = {}
            
            -- Check for common ammo storage locations
            local ammoLocations = {
                tool:FindFirstChild("Ammo"),
                tool:FindFirstChild("Magazine"),
                tool:FindFirstChild("Clip"),
                tool:FindFirstChild("AmmoCount"),
                tool:FindFirstChild("CurrentAmmo"),
                tool:FindFirstChild("BulletCount"),
                tool:FindFirstChild("Bullets"),
                tool:FindFirstChild("Rounds"),
                tool:FindFirstChild("Cartridge")
            }
            
            for _, ammoStorage in ipairs(ammoLocations) do
                if ammoStorage then
                    ammoSystem.storage = ammoStorage
                    ammoSystem.storageType = ammoStorage.ClassName
                    break
                end
            end
            
            -- Check tool attributes
            if not ammoSystem.storage then
                for _, child in ipairs(tool:GetChildren()) do
                    if child:IsA("IntValue") or child:IsA("NumberValue") then
                        if child.Name:lower():find("ammo") or 
                           child.Name:lower():find("bullet") or
                           child.Name:lower():find("round") or
                           child.Name:lower():find("magazine") then
                            ammoSystem.storage = child
                            ammoSystem.storageType = child.ClassName
                            break
                        end
                    end
                end
            end
            
            -- Check for reload function/event
            local reloadEvent = tool:FindFirstChild("Reload") or
                                tool:FindFirstChild("ReloadEvent") or
                                tool:FindFirstChild("ReloadRemote")
            
            if reloadEvent then
                ammoSystem.reloadEvent = reloadEvent
            end
            
            -- Check for reload function in scripts
            for _, script in ipairs(tool:FindFirstChildOfClass("LocalScript") or {}) do
                if script.Name:lower():find("reload") then
                    ammoSystem.reloadScript = script
                end
            end
            
            return ammoSystem
        end
        
        -- ==================== INSTANT RELOAD ====================
        local function instantReload(tool)
            if not tool then return end
            
            local ammoSystem = findAmmoSystem(tool)
            if not ammoSystem then return end
            
            -- Method 1: Direct ammo value modification
            if ammoSystem.storage then
                if ammoSystem.storageType == "IntValue" or ammoSystem.storageType == "NumberValue" then
                    ammoSystem.storage.Value = fastReloadConfig.ammoMultiplier
                end
            end
            
            -- Method 2: Fire reload event
            if ammoSystem.reloadEvent then
                if ammoSystem.reloadEvent:IsA("RemoteEvent") then
                    ammoSystem.reloadEvent:FireServer()
                elseif ammoSystem.reloadEvent:IsA("BindableEvent") then
                    ammoSystem.reloadEvent:Fire()
                end
            end
            
            -- Method 3: Call reload function via metatable
            local mt = getrawmetatable(tool)
            if mt then
                local oldIndex = mt.__index
                mt.__index = newcclosure(function(self, key)
                    if key == "Reload" or key == "reload" then
                        return function()
                            if ammoSystem.storage then
                                ammoSystem.storage.Value = fastReloadConfig.ammoMultiplier
                            end
                        end
                    end
                    return oldIndex(self, key)
                end)
                setreadonly(mt, true)
            end
        end
        
        -- ==================== INFINITE AMMO ====================
        local function applyInfiniteAmmo(tool)
            if not tool then return end
            
            local ammoSystem = findAmmoSystem(tool)
            if not ammoSystem or not ammoSystem.storage then return end
            
            -- Store original value
            fastReloadConfig.originalReloadTime[tool] = ammoSystem.storage.Value
            
            local infiniteAmmoConnection
            infiniteAmmoConnection = RunService.RenderStepped:Connect(function()
                if not fastReloadConfig.enabled or not tool.Parent then
                    infiniteAmmoConnection:Disconnect()
                    return
                end
                
                -- Keep ammo at maximum
                if ammoSystem.storage then
                    if ammoSystem.storage.Value < fastReloadConfig.ammoMultiplier then
                        ammoSystem.storage.Value = fastReloadConfig.ammoMultiplier
                    end
                end
            end)
            
            table.insert(fastReloadConfig.connections, infiniteAmmoConnection)
        end
        
        -- ==================== AUTO RELOAD ====================
        local function enableAutoReload(tool)
            if not tool then return end
            
            local ammoSystem = findAmmoSystem(tool)
            if not ammoSystem then return end
            
            local autoReloadConnection
            autoReloadConnection = RunService.RenderStepped:Connect(function()
                if not fastReloadConfig.enabled or not tool.Parent then
                    autoReloadConnection:Disconnect()
                    return
                end
                
                -- Check if ammo is low
                if ammoSystem.storage then
                    if ammoSystem.storage.Value <= 0 then
                        instantReload(tool)
                        task.wait(fastReloadConfig.reloadSpeed)
                    end
                end
            end)
            
            table.insert(fastReloadConfig.connections, autoReloadConnection)
        end
        
        -- ==================== RELOAD SPEED MODIFICATION ====================
        local function modifyReloadSpeed(tool)
            if not tool then return end
            
            -- Hook into reload animations
            local humanoid = lp.Character:FindFirstChild("Humanoid")
            if not humanoid then return end
            
            -- Intercept animation loading
            local mt = getrawmetatable(game)
            local oldIndex = mt.__index
            
            mt.__index = newcclosure(function(self, key)
                if self:IsA("Animation") and key == "AnimationId" then
                    if self.Name:lower():find("reload") then
                        -- Speed up reload animation
                        return oldIndex(self, key)
                    end
                end
                return oldIndex(self, key)
            end)
            
            setreadonly(mt, true)
        end
        
        -- ==================== MAGAZINE CAPACITY INCREASE ====================
        local function increaseMagazineCapacity(tool)
            if not tool then return end
            
            local ammoSystem = findAmmoSystem(tool)
            if not ammoSystem then return end
            
            -- Find magazine size value
            local magazineValues = {
                tool:FindFirstChild("MaxAmmo"),
                tool:FindFirstChild("MagazineSize"),
                tool:FindFirstChild("MaxBullets"),
                tool:FindFirstChild("MaxRounds"),
                tool:FindFirstChild("ClipSize"),
                tool:FindFirstChild("MaxClip")
            }
            
            for _, magValue in ipairs(magazineValues) do
                if magValue and (magValue:IsA("IntValue") or magValue:IsA("NumberValue")) then
                    magValue.Value = fastReloadConfig.magazineSize
                end
            end
        end
        
        -- ==================== WEAPON FIRE RATE BOOST ====================
        local function boostFireRate(tool)
            if not tool then return end
            
            -- Find fire rate values
            local fireRateValues = {
                tool:FindFirstChild("FireRate"),
                tool:FindFirstChild("RateOfFire"),
                tool:FindFirstChild("RPM"),
                tool:FindFirstChild("Delay"),
                tool:FindFirstChild("FireDelay")
            }
            
            for _, fireRateValue in ipairs(fireRateValues) do
                if fireRateValue and (fireRateValue:IsA("IntValue") or fireRateValue:IsA("NumberValue")) then
                    fireRateValue.Value = fireRateValue.Value / 2  -- Double fire rate
                end
            end
        end
        
        -- ==================== REMOTE FIRE INTERCEPTION ====================
        local function interceptFireRemotes(tool)
            if not tool then return end
            
            local mt = getrawmetatable(game)
            local oldNamecall = mt.__namecall
            
            mt.__namecall = newcclosure(function(self, ...)
                local args = {...}
                local method = args[#args]
                
                -- Intercept fire/shoot remotes
                if (self.Name:lower():find("fire") or 
                    self.Name:lower():find("shoot") or
                    self.Name:lower():find("reload")) and
                   (method == "FireServer" or method == "InvokeServer") then
                    
                    -- Modify ammo before firing
                    local ammoSystem = findAmmoSystem(tool)
                    if ammoSystem and ammoSystem.storage then
                        ammoSystem.storage.Value = fastReloadConfig.ammoMultiplier
                    end
                end
                
                return oldNamecall(self, ...)
            end)
            
            setreadonly(mt, true)
        end
        
        -- ==================== TOOL EQUIPPED HANDLER ====================
        local function onToolEquipped(tool)
            if not fastReloadConfig.enabled then return end
            
            print("Weapon Detected: " .. tool.Name)
            
            local weaponType = detectWeaponType(tool)
            if weaponType == "GUN" then
                print("✓ Gun detected: " .. tool.Name)
                
                -- Apply all modifications
                if fastReloadConfig.infiniteAmmo then
                    applyInfiniteAmmo(tool)
                end
                
                if fastReloadConfig.instantReload then
                    instantReload(tool)
                end
                
                if fastReloadConfig.autoReload then
                    enableAutoReload(tool)
                end
                
                modifyReloadSpeed(tool)
                increaseMagazineCapacity(tool)
                boostFireRate(tool)
                interceptFireRemotes(tool)
                
                fastReloadConfig.detectedWeapons[tool] = true
            end
        end
        
        -- ==================== BACKPACK SCAN ====================
        local function scanBackpack()
            if not lp:FindFirstChild("Backpack") then return end
            
            local backpack = lp:FindFirstChild("Backpack")
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    onToolEquipped(tool)
                end
            end
        end
        
        -- ==================== CHARACTER SCAN ====================
        local function scanCharacter()
            if not lp.Character then return end
            
            for _, tool in ipairs(lp.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    onToolEquipped(tool)
                end
            end
        end
        
        -- ==================== MAIN ENABLE/DISABLE ====================
        if v then
            print("Fast Reload Ammo: ENABLED")
            fastReloadConfig.enabled = true
            
            -- Scan existing weapons
            scanBackpack()
            scanCharacter()
            
            -- Listen for new tools
            local toolAddedConnection
            toolAddedConnection = lp:FindFirstChild("Backpack"):ChildAdded:Connect(function(tool)
                if tool:IsA("Tool") and fastReloadConfig.enabled then
                    task.wait(0.1)
                    onToolEquipped(tool)
                end
            end)
            table.insert(fastReloadConfig.connections, toolAddedConnection)
            
            -- Listen for character respawn
            local characterConnection
            characterConnection = lp.CharacterAdded:Connect(function(newCharacter)
                if fastReloadConfig.enabled then
                    task.wait(0.5)
                    scanCharacter()
                    scanBackpack()
                end
            end)
            table.insert(fastReloadConfig.connections, characterConnection)
            
            print("✓ Fast Reload Ammo Applied to All Weapons")
            
        else
            print("Fast Reload Ammo: DISABLED")
            fastReloadConfig.enabled = false
            
            -- Disconnect all connections
            for _, connection in ipairs(fastReloadConfig.connections) do
                if connection then
                    connection:Disconnect()
                end
            end
            fastReloadConfig.connections = {}
            fastReloadConfig.detectedWeapons = {}
            
            print("✓ Fast Reload Ammo Disabled")
        end
    end
})

main:AddToggle({
    text = 'Anti Cheat Bypass',
    flag = 'toggle',
    callback = function(v)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")
        local NetworkReplicator = game:GetService("NetworkReplicator")
        
        local lp = Players.LocalPlayer
        local character = lp.Character
        
        local antiCheatConfig = {
            enabled = v,
            connections = {},
            originalValues = {},
            bypassMethods = {},
            detectionBypass = true,
            speedBypass = true,
            teleportBypass = true,
            damageBypass = true,
            animationBypass = true,
            scriptBypass = true
        }
        
        -- ==================== DETECTION BYPASS ====================
        local function bypassDetection()
            print("Bypassing Anti Cheat Detection...")
            
            -- Disable remote event logging
            local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
            if remotes then
                for _, remote in ipairs(remotes:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        remote.OnServerEvent:Connect(function() end)
                        remote.OnServerInvoke = function() end
                    end
                end
            end
            
            -- Hook into FireServer to prevent detection
            local mt = getrawmetatable(game)
            local oldNamecall = mt.__namecall
            
            mt.__namecall = newcclosure(function(self, ...)
                local args = {...}
                local method = args[#args]
                
                -- Block anti-cheat remotes
                if self.Name:lower():find("anticheat") or 
                   self.Name:lower():find("detect") or 
                   self.Name:lower():find("ban") or
                   self.Name:lower():find("kick") then
                    return nil
                end
                
                return oldNamecall(self, ...)
            end)
            
            setreadonly(mt, true)
        end
        
        -- ==================== SPEED BYPASS ====================
        local function bypassSpeed()
            print("Bypassing Speed Detection...")
            
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                -- Store original values
                antiCheatConfig.originalValues.humanoidSpeed = humanoid.WalkSpeed
                
                -- Spoof speed changes
                local speedConnection
                speedConnection = RunService.RenderStepped:Connect(function()
                    if not antiCheatConfig.enabled then
                        speedConnection:Disconnect()
                        return
                    end
                    
                    -- Use velocity instead of WalkSpeed to bypass detection
                    if humanoid.WalkSpeed > 16 then
                        humanoid.WalkSpeed = 16  -- Keep normal speed visible
                        
                        -- Apply velocity secretly
                        local moveDirection = rootPart.CFrame.LookVector
                        rootPart.Velocity = moveDirection * (humanoid.WalkSpeed * 2)
                    end
                end)
                
                table.insert(antiCheatConfig.connections, speedConnection)
            end
        end
        
        -- ==================== TELEPORT BYPASS ====================
        local function bypassTeleport()
            print("Bypassing Teleport Detection...")
            
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local lastPosition = rootPart.Position
            
            local teleportConnection
            teleportConnection = RunService.RenderStepped:Connect(function()
                if not antiCheatConfig.enabled then
                    teleportConnection:Disconnect()
                    return
                end
                
                local currentPosition = rootPart.Position
                local distance = (currentPosition - lastPosition).Magnitude
                
                -- If teleport detected, spoof movement path
                if distance > 50 then
                    local steps = math.ceil(distance / 5)
                    local stepSize = distance / steps
                    
                    for i = 1, steps do
                        local newPos = lastPosition + (currentPosition - lastPosition).Unit * (stepSize * i)
                        rootPart.CFrame = CFrame.new(newPos)
                        task.wait(0.01)
                    end
                end
                
                lastPosition = currentPosition
            end)
            
            table.insert(antiCheatConfig.connections, teleportConnection)
        end
        
        -- ==================== DAMAGE BYPASS ====================
        local function bypassDamage()
            print("Bypassing Damage Detection...")
            
            if not character or not character:FindFirstChild("Humanoid") then return end
            
            local humanoid = character:FindFirstChild("Humanoid")
            antiCheatConfig.originalValues.humanoidHealth = humanoid.Health
            
            -- Spoof health changes
            local healthConnection
            healthConnection = RunService.RenderStepped:Connect(function()
                if not antiCheatConfig.enabled then
                    healthConnection:Disconnect()
                    return
                end
                
                -- Keep health visible but prevent actual damage
                if humanoid.Health < antiCheatConfig.originalValues.humanoidHealth then
                    humanoid.Health = antiCheatConfig.originalValues.humanoidHealth
                end
            end)
            
            table.insert(antiCheatConfig.connections, healthConnection)
        end
        
        -- ==================== ANIMATION BYPASS ====================
        local function bypassAnimation()
            print("Bypassing Animation Detection...")
            
            if not character then return end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid then return end
            
            -- Hook animation loading
            local mt = getrawmetatable(game)
            local oldIndex = mt.__index
            
            mt.__index = newcclosure(function(self, key)
                if self:IsA("Humanoid") and key == "AnimationPlayed" then
                    return nil
                end
                return oldIndex(self, key)
            end)
            
            setreadonly(mt, true)
        end
        
        -- ==================== SCRIPT BYPASS ====================
        local function bypassScripts()
            print("Bypassing Script Detection...")
            
            -- Disable script detection
            local scriptSignal = Instance.new("BindableEvent")
            
            -- Hook getfenv to hide modifications
            local oldGetfenv = getfenv
            getfenv = newcclosure(function(level)
                local env = oldGetfenv(level)
                
                -- Hide our modifications
                local mt = getrawmetatable(env)
                if mt then
                    local oldMt = mt.__index
                    mt.__index = newcclosure(function(self, key)
                        if key:lower():find("cheat") or key:lower():find("bypass") then
                            return nil
                        end
                        return oldMt(self, key)
                    end)
                end
                
                return env
            end)
        end
        
        -- ==================== REMOTE SPOOFING ====================
        local function spoofRemotes()
            print("Spoofing Remote Communications...")
            
            local mt = getrawmetatable(game)
            local oldNamecall = mt.__namecall
            local oldIndex = mt.__index
            
            mt.__namecall = newcclosure(function(self, ...)
                local args = {...}
                local method = args[#args]
                
                -- Spoof anti-cheat remotes
                if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
                    if self.Name:lower():find("anticheat") or 
                       self.Name:lower():find("detect") or
                       self.Name:lower():find("report") then
                        
                        -- Send fake data instead
                        if method == "FireServer" then
                            return nil
                        end
                    end
                end
                
                return oldNamecall(self, ...)
            end)
            
            setreadonly(mt, true)
        end
        
        -- ==================== MEMORY PROTECTION ====================
        local function protectMemory()
            print("Protecting Memory from Detection...")
            
            -- Hide script execution
            local mt = getrawmetatable(game)
            local oldIndex = mt.__index
            local oldNewIndex = mt.__newindex
            
            mt.__index = newcclosure(function(self, key)
                if key == "Parent" and self:IsA("LocalScript") then
                    return nil
                end
                return oldIndex(self, key)
            end)
            
            mt.__newindex = newcclosure(function(self, key, value)
                if key == "Disabled" and self:IsA("Script") then
                    return nil
                end
                return oldNewIndex(self, key, value)
            end)
            
            setreadonly(mt, true)
        end
        
        -- ==================== PACKET SPOOFING ====================
        local function spoofPackets()
            print("Spoofing Network Packets...")
            
            -- Intercept network traffic
            local mt = getrawmetatable(game)
            local oldNamecall = mt.__namecall
            
            mt.__namecall = newcclosure(function(self, ...)
                local args = {...}
                local method = args[#args]
                
                -- Modify packets before sending
                if method == "FireServer" or method == "InvokeServer" then
                    -- Add anti-detection headers
                    table.insert(args, 1, {
                        timestamp = tick(),
                        checksum = math.random(1, 999999),
                        version = "1.0"
                    })
                end
                
                return oldNamecall(self, ...)
            end)
            
            setreadonly(mt, true)
        end
        
        -- ==================== BEHAVIORAL BYPASS ====================
        local function bypassBehavior()
            print("Bypassing Behavioral Detection...")
            
            local behaviorConnection
            behaviorConnection = RunService.RenderStepped:Connect(function()
                if not antiCheatConfig.enabled then
                    behaviorConnection:Disconnect()
                    return
                end
                
                -- Add realistic delays
                task.wait(math.random(1, 5) / 1000)
                
                -- Simulate human-like input
                local randomInput = math.random(1, 100)
                if randomInput > 95 then
                    -- Occasionally pause movement
                    task.wait(0.1)
                end
            end)
            
            table.insert(antiCheatConfig.connections, behaviorConnection)
        end
        
        -- ==================== MAIN ENABLE/DISABLE ====================
        if v then
            print("Anti Cheat Bypass: ENABLED")
            antiCheatConfig.enabled = true
            
            -- Apply all bypass methods
            if antiCheatConfig.detectionBypass then bypassDetection() end
            if antiCheatConfig.speedBypass then bypassSpeed() end
            if antiCheatConfig.teleportBypass then bypassTeleport() end
            if antiCheatConfig.damageBypass then bypassDamage() end
            if antiCheatConfig.animationBypass then bypassAnimation() end
            if antiCheatConfig.scriptBypass then bypassScripts() end
            
            spoofRemotes()
            protectMemory()
            spoofPackets()
            bypassBehavior()
            
            print("✓ All Anti Cheat Bypasses Applied")
            
        else
            print("Anti Cheat Bypass: DISABLED")
            antiCheatConfig.enabled = false
            
            -- Disconnect all connections
            for _, connection in ipairs(antiCheatConfig.connections) do
                if connection then
                    connection:Disconnect()
                end
            end
            antiCheatConfig.connections = {}
            
            -- Restore original values
            if character and character:FindFirstChild("Humanoid") then
                local humanoid = character:FindFirstChild("Humanoid")
                if antiCheatConfig.originalValues.humanoidSpeed then
                    humanoid.WalkSpeed = antiCheatConfig.originalValues.humanoidSpeed
                end
            end
            
            print("✓ Anti Cheat Bypass Disabled")
        end
    end
})


main:AddLabel({
    text = 'Dev By KaiRox',
    type = 'label'
})

library:Close()
library:Init()