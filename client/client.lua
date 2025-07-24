VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
    print = VORPutils.Print:initialize(print) --Initial setup 
end)
VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)


local isOpen = false
local playerCoords


-------- THREADS

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1 * 1000)
        playerCoords = GetEntityCoords(PlayerPedId())
    end
end)

Citizen.CreateThread(function()
    -- Citizen.Wait(3 * 1000)

    local promptGroup = VORPutils.Prompts:SetupPromptGroup()
    local prompt = promptGroup:RegisterPrompt("Peruse Directory", Config.PromptButton, 1, 1, true, 'click', {})

    while true do
        local sleep = 1000
        if playerCoords and not isOpen then
            for k,v in pairs(Config.Coords) do
                if #(playerCoords - v.position) < Config.PromptDistance then
                    sleep = 1
                    promptGroup:ShowGroup("Telegram Directory")

                    if prompt:HasCompleted() then
                        openDirectory()
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)



RegisterNetEvent("rainbow_telegram_directory:ReturnSearchResults")
AddEventHandler("rainbow_telegram_directory:ReturnSearchResults", function(dirResults, currentPage, pagesTotal)
	if Config.Debug then print("ReturnSearchResults", dirResults) end
    if Config.Debug then print("ReturnSearchResults - currentPage, pagesTotal", currentPage, pagesTotal) end

    SendNUIMessage({
        type = "updateList",
        directoryList = dirResults,
        currentPage = currentPage,
        pagesTotal = pagesTotal,
    })
end)

RegisterNetEvent("rainbow_telegram_directory:ReturnOptedResults")
AddEventHandler("rainbow_telegram_directory:ReturnOptedResults", function(hasARecord, isOptedIn)
	if Config.Debug then print("ReturnOptedResults", hasARecord, isOptedIn) end

    if hasARecord == false or isOptedIn == nil then
        VORPcore.NotifyRightTip("Please check the post office to receive a telegram number first.", 6000)
        return
    end

    SendNUIMessage({
        type = "view",
        directoryList = {},
        isOptedIn = isOptedIn,
    })
	SetNuiFocus(true, true)
	-- SetNuiFocusKeepInput(true)
	isOpen = true

    TriggerServerEvent("rainbow_telegram_directory:SearchDirectory", "*", 1)
end)



-------- FUNCTIONS

function openDirectory()

    TriggerServerEvent("rainbow_telegram_directory:CheckOpted")
    
end

function closeDirectory()
    SendNUIMessage({
        type = "close",
    })
    SetNuiFocus(false, false)
    isOpen = false
end

RegisterNUICallback("searchDir", function(args, cb)
	if Config.Debug then print("args", args) end

    local requestedPage = 1
    if args.requestedPage and args.requestedPage ~= "" and args.requestedPage > 0 then
        requestedPage = args.requestedPage
    end

    if not args or not args.input or string.len(args.input) < 2 then
        TriggerServerEvent("rainbow_telegram_directory:SearchDirectory", "*", requestedPage)
    else
        local searchString = args.input:gsub('%A','')
        TriggerServerEvent("rainbow_telegram_directory:SearchDirectory", searchString, requestedPage)
    end

	cb("ok")
end)

RegisterNUICallback("copied", function(args, cb)
    VORPcore.NotifyRightTip("Number copied.", 6000)
    PlayFrontendSound("HUD_SHOP_SOUNDSET", "READ")
	cb("ok")
end)

RegisterNUICallback("clear", function(args, cb)
    TriggerServerEvent("rainbow_telegram_directory:SearchDirectory", "*", 1)
	cb("ok")
end)

RegisterNUICallback("setOpted", function(args, cb)
    if Config.Debug then print("args", args) end
    TriggerServerEvent("rainbow_telegram_directory:SetOpted", args.opted)
	cb("ok")
end)

RegisterNUICallback('closeView', function(args, cb)
	if Config.Debug then print("closeView") end
	closeDirectory()
	cb('ok')
end)


function PlayFrontendSound(newSoundSetRef, newSoundSetName)
    frontend_soundset_ref = newSoundSetRef
    frontend_soundset_name = newSoundSetName

    if frontend_soundset_ref ~= 0 then
    Citizen.InvokeNative(0x0F2A2175734926D8, frontend_soundset_name, frontend_soundset_ref) -- load sound frontend
    end
    Citizen.InvokeNative(0x67C540AA08E4A6F5, frontend_soundset_name, frontend_soundset_ref, true, 0) -- play sound frontend
end