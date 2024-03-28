-- DDDDDDDDDDDDD            OOOOOOOOO    TTTTTTTTTTTTTTTTTTTTTTT     MMMMMMMM               MMMMMMMM
-- D::::::::::::DDD       OO:::::::::OO  T:::::::::::::::::::::T     M:::::::M             M:::::::M
-- D:::::::::::::::DD   OO:::::::::::::OOT:::::::::::::::::::::T     M::::::::M           M::::::::M
-- DDD:::::DDDDD:::::D O:::::::OOO:::::::T:::::TT:::::::TT:::::T     M:::::::::M         M:::::::::M
--   D:::::D    D:::::DO::::::O   O::::::TTTTTT  T:::::T  TTTTTT     M::::::::::M       M::::::::::M   eeeeeeeeeeee   nnnn  nnnnnnnn   uuuuuu    uuuuuu
--   D:::::D     D:::::O:::::O     O:::::O       T:::::T             M:::::::::::M     M:::::::::::M ee::::::::::::ee n:::nn::::::::nn u::::u    u::::u
--   D:::::D     D:::::O:::::O     O:::::O       T:::::T             M:::::::M::::M   M::::M:::::::Me::::::eeeee:::::en::::::::::::::nnu::::u    u::::u
--   D:::::D     D:::::O:::::O     O:::::O       T:::::T             M::::::M M::::M M::::M M::::::e::::::e     e:::::nn:::::::::::::::u::::u    u::::u
--   D:::::D     D:::::O:::::O     O:::::O       T:::::T             M::::::M  M::::M::::M  M::::::e:::::::eeeee::::::e n:::::nnnn:::::u::::u    u::::u
--   D:::::D     D:::::O:::::O     O:::::O       T:::::T             M::::::M   M:::::::M   M::::::e:::::::::::::::::e  n::::n    n::::u::::u    u::::u
--   D:::::D     D:::::O:::::O     O:::::O       T:::::T             M::::::M    M:::::M    M::::::e::::::eeeeeeeeeee   n::::n    n::::u::::u    u::::u
--   D:::::D    D:::::DO::::::O   O::::::O       T:::::T             M::::::M     MMMMM     M::::::e:::::::e            n::::n    n::::u:::::uuuu:::::u
-- DDD:::::DDDDD:::::D O:::::::OOO:::::::O     TT:::::::TT           M::::::M               M::::::e::::::::e           n::::n    n::::u:::::::::::::::uu
-- D:::::::::::::::DD   OO:::::::::::::OO      T:::::::::T           M::::::M               M::::::Me::::::::eeeeeeee   n::::n    n::::nu:::::::::::::::u
-- D::::::::::::DDD       OO:::::::::OO        T:::::::::T           M::::::M               M::::::M ee:::::::::::::e   n::::n    n::::n uu::::::::uu:::u
-- DDDDDDDDDDDDD            OOOOOOOOO          TTTTTTTTTTT           MMMMMMMM               MMMMMMMM   eeeeeeeeeeeeee   nnnnnn    nnnnnn   uuuuuuuu  uuuu

-- _____                _           _   _            ___  ___     _____
-- /  __ \              | |         | | | |           |  \/  |    |  __ \
-- | /  \/_ __ ___  __ _| |_ ___  __| | | |__  _   _  | .  . |_ __| |  \/ __ _ _ __ ___   ___ _ __
-- | |   | '__/ _ \/ _` | __/ _ \/ _` | | '_ \| | | | | |\/| | '__| | __ / _` | '_ ` _ \ / _ | '__|
-- | \__/| | |  __| (_| | ||  __| (_| | | |_) | |_| | | |  | | |_ | |_\ | (_| | | | | | |  __| |
--  \____|_|  \___|\__,_|\__\___|\__,_| |_.__/ \__, | \_|  |_|_(_) \____/\__,_|_| |_| |_|\___|_|
--                                              __/ |
--                                             |___/

local wasInitialized = false
local sharedState = {} -- Shared state including vehicle

local state = {}

local function updateVehicleExtrasState(vehicle)
    sharedState.vehicleExtras = {}
    for extraID = 0, 20 do
        if DoesExtraExist(vehicle, extraID) then
            sharedState.vehicleExtras[extraID] = IsVehicleExtraTurnedOn(vehicle, extraID) == 1
        end
    end
end

function GetModsFromVehicle(entity, index)
    local tempMods = {}
    local name = GetModSlotName(entity, index)
    for m = 0, GetNumVehicleMods(entity, index) do
        if m == 0 then
            table.insert(tempMods, "Stock "..name)
        else
            table.insert(tempMods, name.." "..m)
        end
    end
    return tempMods
end

function IsModIgnored(modName)
    local ignoredMods = {"", "Spoiler", "Front Bumper", "Rear Bumper", "Skirt", "Exhaust", "Chassis", "Grill", "Bonnet", "Left Wing", "Right Wing", "Roof"}
    for _,v in pairs(ignoredMods) do
        if v == modName then
            return true
        end
    end
end

function DoesBoneExist(vehicle, bone)
    return GetEntityBoneIndexByName(vehicle, bone) ~= -1
end


local function uiThread()
    while true do
        local vehicle = sharedState.vehicle

        if WarMenu.Begin("dotMenu") then
            WarMenu.MenuButton("Extras", "dotMenuExtras")
            WarMenu.MenuButton("Signs (Mod Kits)", "dotMenuModKits")
            WarMenu.MenuButton("Doors", "dotMenuDoors")

            openBombBay = WarMenu.Button("~y~Raise/Lower Sign")
            if openBombBay then

                    if not AreBombBayDoorsOpen(vehicle) then
                        OpenBombBayDoors(vehicle)
                    else
                        CloseBombBayDoors(vehicle)
                    end
            end

            -- WarMenu.Button('Button', 'Subtext')
			-- if WarMenu.IsItemHovered() then
			-- 	WarMenu.ToolTip('Tooltip example.')
			-- end

			-- local isPressed, inputText = WarMenu.InputButton('InputButton', nil, state.inputText)
			-- if isPressed and inputText then
			-- 	state.inputText = inputText
			-- end

			-- if WarMenu.SpriteButton('SpriteButton', 'commonmenu', state.useAltSprite and 'shop_gunclub_icon_b' or 'shop_garage_icon_b') then
			-- 	state.useAltSprite = not state.useAltSprite
			-- end

			-- if WarMenu.CheckBox('CheckBox', state.isChecked) then
			-- 	state.isChecked = not state.isChecked
			-- end

			-- local _, currentIndex = WarMenu.ComboBox('ComboBox', items, state.currentIndex)
			-- state.currentIndex = currentIndex

            WarMenu.End()
        elseif WarMenu.Begin("dotMenuDoors") then
            -- Populate valid doors for the current vehicle
            validDoors = {}  -- Reset at each menu opening to refresh the state
            for index, door in ipairs(doors) do
                local valid = GetIsDoorValid(vehicle, index - 1)
                if index == 7 then
                    valid = DoesBoneExist(vehicle, "door_hatch_l")
                end
                if valid then
                    table.insert(validDoors, door)
                end
            end
        
            -- Handling no valid doors found
            if #validDoors == 0 then
                WarMenu.Button("NO DOORS FOUND")
            else
                for index, door in ipairs(validDoors) do
                    if WarMenu.Button("Toggle "..door) then
                        local isDoorOpen = GetVehicleDoorAngleRatio(vehicle, index - 1) > 0.1
                        if isDoorOpen then
                            SetVehicleDoorShut(vehicle, index - 1, false)
                        else
                            SetVehicleDoorOpen(vehicle, index - 1, false, false)
                        end
        
                        -- Special handling for Bomb Bay Doors
                        if index == 7 then
                            if not AreBombBayDoorsOpen(vehicle) then
                                OpenBombBayDoors(vehicle)
                            else
                                CloseBombBayDoors(vehicle)
                            end
                        end
                    end
                end
            end
        
            -- Additional options for opening/closing all doors and removing a door
            if WarMenu.Button("Open all doors") then
                for i = 0, #doors - 1 do  -- Assuming #doors includes all possible indices
                    SetVehicleDoorOpen(vehicle, i, false, false)
                end
            end
        
            if WarMenu.Button("Close all doors") then
                for i = 0, #doors - 1 do
                    SetVehicleDoorShut(vehicle, i, false)
                end
            end
        
        
            WarMenu.End()
        
        elseif WarMenu.Begin("dotMenuExtras") then
            for extraID = 0, 20 do
                if sharedState.vehicleExtras[extraID] ~= nil then
                    local extraName = 'Extra ' .. extraID
                    local isExtraOn = sharedState.vehicleExtras[extraID]

                    local isPressed = WarMenu.CheckBox(extraName, isExtraOn)
                    if isPressed then
                        -- Toggle the state of this extra
                        isExtraOn = not isExtraOn
                        sharedState.vehicleExtras[extraID] = isExtraOn

                        -- Apply the new state to the vehicle
                        SetVehicleExtra(vehicle, extraID, isExtraOn and 0 or 1)
                    end
                end
            end


            WarMenu.End()
        elseif WarMenu.Begin("dotMenuModKits") then
            SetVehicleModKit(vehicle, 0)  -- Initialize mod kit to ensure mods are applicable
            local validModsFound = false
        
            for i = 0, 10 do  -- Assuming you want to iterate through the first 11 mod types
                local slotName = GetModSlotName(vehicle, i)
                -- Check if the slotName is valid and not ignored by your custom logic
                if slotName ~= nil then
                    local modsFromVehicle = GetModsFromVehicle(vehicle, i)
                    local currentModIndex = GetVehicleMod(vehicle, i) + 2  -- Adjusting for WarMenu's 1-indexed ComboBox
        
                    -- WarMenu ComboBox to select a mod for the current slot
                    if #modsFromVehicle > 0 then
                        local isPressed, selectedIndex = WarMenu.ComboBox(slotName, modsFromVehicle, currentModIndex)
                        if isPressed then
                            -- Apply the selected mod, adjusting index back for GTA's 0-indexed mods
                            SetVehicleMod(vehicle, i, selectedIndex - 1, false)
                            validModsFound = true
                        end
                    end
                end
            end
        
            if not validModsFound then
                -- Display a button/message indicating no mods were found
                WarMenu.Button("No vehicle mods located")
            end
            
            WarMenu.End()
        end
        
        
        -- elseif WarMenu.Begin("dotMenuModKits") then
        --     SetVehicleModKit(vehicle, 0)
        --     local valid = false
        --     for i = 0, 10 do
        --         local slotName = GetModSlotName(vehicle, i)
        --         if slotName ~= nil then
        --             local _, currentIndex = WarMenu.ComboBox(slotName, GetModsFromVehicle(vehicle, i), state.currentIndex)
        --             state.currentIndex = currentIndex

        --             -- Items:AddList(slotName, GetModsFromVehicle(vehicle, i), GetVehicleMod(vehicle, i) + 2, "Modify "..slotName, nil, false, function(index, _, onListChange)
        --             --     if onListChange then
        --             --         SetVehicleMod(vehicle, i, index - 2, false)
        --             --     end
        --             -- end)
        --             valid = true
        --         end
        --     end

        --     if not valid then
        --         WarMenu.Button("No vehicle mods located", "Unable to locate vehicle modifications")
        --     end
		-- 	-- local numModKits = GetNumVehicleMods(vehicle)


		-- 	-- for modKitIndex = 0, numModKits - 1 do
		-- 	-- 	if WarMenu.MenuButton('Mod Kit ' .. modKitIndex, 'applyModKitMenu') then
		-- 	-- 		-- Store the selected modKitIndex for later use
		-- 	-- 		sharedState.selectedModKit = modKitIndex
		-- 	-- 	end
		-- 	-- end

		-- 	-- if sharedState.selectedModKit then
		-- 	-- 	local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		-- 	-- 	SetVehicleModKit(vehicle, sharedState.selectedModKit)
		-- 	-- 	sharedState.selectedModKit = nil -- Clear the selection
		-- 	-- end

        --     WarMenu.End()
        -- end

        Wait(0)
    end
end

RegisterCommand('dotMenu', function()
    local ped = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsIn(ped, false)
    local numModKits = GetNumVehicleMods(vehicle)
    for i = 0, 10 do
        local slotName = GetModSlotName(vehicle, i)
        if slotName ~= nil then
            print(slotName)
            print(GetModsFromVehicle(vehicle, i))
        end
    end



    if not wasInitialized then
        WarMenu.CreateMenu('dotMenu', 'DOT Menu')
        WarMenu.SetMenuSubTitle('dotMenu', 'Created by Mr.Gamer')
        WarMenu.CreateSubMenu('dotMenuExtras', 'dotMenu', 'Extras')
		WarMenu.CreateSubMenu('dotMenuModKits', 'dotMenu', 'Signs')
        WarMenu.CreateSubMenu('dotMenuDoors', 'dotMenu', 'Doors')
        Citizen.CreateThread(uiThread)
        wasInitialized = true
    end

    if IsPedInAnyVehicle(ped, false) and GetPedInVehicleSeat(vehicle, -1) == ped then
        sharedState.vehicle = vehicle
        updateVehicleExtrasState(vehicle)  -- Initialize or update the extras' states
        WarMenu.OpenMenu('dotMenu')
    end
end)