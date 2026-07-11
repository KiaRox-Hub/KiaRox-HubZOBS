local library = loadstring(game:HttpGet('https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/library', true))()
local tab = library:CreateWindow('Reign Fall Script')
local main = tab:AddFolder('Main')

main:AddToggle({
    text = 'ESP',
    flag = 'toggle',
    callback = function(v)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local function highlightCharacters()
    for _, object in pairs(workspace:GetChildren()) do
        if object:IsA("Model") and (object.Name == "Male" or object.Name == "Model") then
            local humanoid = object:FindFirstChildOfClass("Humanoid") or object:FindFirstChildWhichIsA("Humanoid", true)
            if humanoid then                
			if not object:FindFirstChildOfClass("Highlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = object
                    highlight.Parent = object
                    highlight.FillColor = Color3.fromRGB(255, 0, 0) 
                    highlight.FillTransparency = 0.99
                    highlight.OutlineColor = Color3.fromRGB(0, 0, 255) 
                    highlight.OutlineTransparency = 0.2 
                end
            end
        end
    end
end

while true do
    highlightCharacters()
    task.wait(1) 
            end
    end
})


main:AddToggle({
    text = 'Aimbot',
    flag = 'toggle',
    callback = function(v)
        print(v)
    end
})

main:AddToggle({
    text = 'Headshot',
    flag = 'toggle',
    callback = function(v)
            
            Oldnamecall = hookmetamethod (game, "...namecall", function(self, ...)
   local args {...}

        if getnamecallmethod() == "FireServer" and self.Name == "ClientBulletHit" then
            args[1] = args[1].Parent.Head
            args[3] =1
        end
    return Oldnamecall (self, unpack(args))
    end)
            
    end
})

main:AddToggle({
    text = 'Auto Reload',
    flag = 'toggle',
    callback = function(v)
        autoReloadThread = task.spawn(function()
			while autoReloadEnabled do
				task.wait(reloadInterval)
				local char = LocalPlayer.Character
				if char then
					for _, child in ipairs(char:GetChildren()) do
						local serverEvents = child:FindFirstChild("ServerEvents")
						if serverEvents then
							local reloadAmmo = serverEvents:FindFirstChild("ReloadAmmo")
							if reloadAmmo then
								pcall(function()
									reloadAmmo:FireServer(false)
    end
})

main:AddToggle({
    text = 'No Recoil',
    flag = 'toggle',
    callback = function(v)
    local CameraRecoil = nil
for _, v in pairs(getgc(true)) do
    if type(v) == "table" and rawget(v, "Apply") and rawget(v, "_Init") then
        CameraRecoil = v
        break
    end
end
if not CameraRecoil then
    local success, module = pcall(function() 
        return require(game:GetService("ReplicatedFirst").Scripts.Camera.CameraRecoil) 
    end)
    if success then CameraRecoil = module end
end
if CameraRecoil then
    CameraRecoil.Apply = function()
        return nil
    end
    local setupConstants = function()
        local debug = debug or {getupvalues = getupvalues, setupvalue = setupvalue}
        for i = 1, 30 do
            local val = debug.getupvalue(CameraRecoil.Apply, i)
            if type(val) == "vector3" then
                debug.setupvalue(CameraRecoil.Apply, i, Vector3.new(0,0,0))
            elseif type(val) == "number" then
                debug.setupvalue(CameraRecoil.Apply, i, 0)
            end
        end
    end
    pcall(setupConstants)
                                                end
    end
})

main:AddButton({
    text = 'Button',
    flag = 'button',
    callback = function()
        print('hello world')
    end
})

main:AddSlider({
    text = 'Fov',
    min = 70,
    max = 170,
    dual = true,
    type = 'slider',
    callback = function(v)
        print(v)
    end
})

main:AddList({
    text = 'Color',
    values = {'Red', 'Green', 'Blue'},
    callback = function(value)
        print('Selected color:', value)
    end,
    open = false,
    flag = 'color_option'
})


main:AddLabel({
    text = 'Dev By KaiRox',
    type = 'label'
})

library:Close()
library:Init()