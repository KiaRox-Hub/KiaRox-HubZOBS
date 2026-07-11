local library = loadstring(game:HttpGet('https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/library', true))()
local tab = library:CreateWindow('Reign Fall Script')
local main = tab:AddFolder('Main')

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
        print(v)
    end
})

main:AddToggle({
    text = 'Toggle',
    flag = 'toggle',
    callback = function(v)
        print(v)
    end
})

main:AddToggle({
    text = 'Toggle',
    flag = 'toggle',
    callback = function(v)
        print(v)
    end
})

main:AddButton({
    text = 'Click me',
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