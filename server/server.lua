local VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
    print = VORPutils.Print:initialize(print) --Initial setup 
end)
local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)


RegisterNetEvent("rainbow_telegram_directory:SearchDirectory")
AddEventHandler("rainbow_telegram_directory:SearchDirectory", function(searchText, requestedPage)
    local _source = source

    if Config.Debug then print("rainbow_telegram_directory:SearchDirectory", searchText) end


    local offset = (requestedPage - 1) * Config.ResultsPerPage


    -- Build the main query
    local querySelect = "SELECT ut.telegram, CONCAT(c1.firstname, ' ', c1.lastname) AS `full_char_name` FROM user_telegram AS ut JOIN `characters` c1 ON ut.charid=c1.charidentifier "
    local queryOrderBy = " ORDER BY `full_char_name` LIMIT " .. Config.ResultsPerPage .. " OFFSET " .. offset .. ";"
    

    local queryWhere

    if searchText == "*" then
        queryWhere = "WHERE ut.opted_in=1"
    else
        queryWhere = "WHERE ut.opted_in=1 AND ( LOWER(c1.firstname) LIKE LOWER(CONCAT ('%', @searchText, '%')) OR LOWER(c1.lastname) LIKE LOWER(CONCAT ('%', @searchText, '%')))"
    end


    -- Get the count
    local countQueryFull = "SELECT COUNT(id) FROM user_telegram AS ut JOIN `characters` c1 ON ut.charid=c1.charidentifier " .. queryWhere .. ";"
    local rowCount = MySQL.scalar.await(countQueryFull, {})

    if Config.Debug then print("rainbow_telegram_directory:SearchDirectory - rowCount", rowCount) end


    local queryFull = querySelect .. queryWhere .. queryOrderBy

    -- Calculate the number of pages
    local pagesTotal = 1
    if rowCount > Config.ResultsPerPage then
        pagesTotal = math.ceil(rowCount / Config.ResultsPerPage)
    end

    -- Execute the query
    exports.oxmysql:execute(queryFull, {["@searchText"] = searchText}, function(dirResults)
        if Config.Debug then print('dirResults: ', dirResults) end
        if #dirResults == 0 then
            dirResults = nil
        end
        TriggerClientEvent("rainbow_telegram_directory:ReturnSearchResults", _source, dirResults, requestedPage, pagesTotal)
    end)




end)

RegisterNetEvent("rainbow_telegram_directory:CheckOpted")
AddEventHandler("rainbow_telegram_directory:CheckOpted", function()
    local _source = source

    if Config.Debug then print("rainbow_telegram_directory:CheckOpted") end

    local Character = VORPcore.getUser(_source).getUsedCharacter
    local charIdentifier = Character.charIdentifier

    local hasARecord = true
    exports.oxmysql:execute("SELECT ut.opted_in FROM user_telegram AS ut WHERE ut.charid=@charid; ", {["@charid"] = charIdentifier}, function(isOptedIn)
        if Config.Debug then print('isOptedIn: ', isOptedIn) end
        
        if #isOptedIn == 0 then
            hasARecord = false
            isOptedIn = nil
        else
            isOptedIn = isOptedIn[1].opted_in
        end
        TriggerClientEvent("rainbow_telegram_directory:ReturnOptedResults", _source, hasARecord, isOptedIn)
    end)

end)

RegisterNetEvent("rainbow_telegram_directory:SetOpted")
AddEventHandler("rainbow_telegram_directory:SetOpted", function(opted)
    local _source = source

    if Config.Debug then print("rainbow_telegram_directory:SetOpted", opted) end

    local Character = VORPcore.getUser(_source).getUsedCharacter
    local charIdentifier = Character.charIdentifier

    exports.oxmysql:execute("UPDATE user_telegram AS ut SET ut.opted_in=@opted WHERE ut.charid=@charid", 
		{ ["@opted"] = opted, ["@charid"] = charIdentifier }, function(result) end)

end)


--------

function setJailTime(jailTimeInSeconds)
    jailTime = jailTimeInSeconds
end
