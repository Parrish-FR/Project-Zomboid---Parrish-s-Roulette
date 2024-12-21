-- Coordonnées où l'option de jouer à la roulette est disponible
local validCoordinates = {
    {x = 12517, y = 4232, z = 0},
    {x = 12518, y = 4233, z = 0}
}

-- Fonction pour vérifier si le joueur est proche des coordonnées valides
local function isPlayerAtValidCoordinates(player)
    local px, py, pz = player:getX(), player:getY(), player:getZ()

    for _, coords in ipairs(validCoordinates) do
        local distance = math.sqrt((coords.x - px)^2 + (coords.y - py)^2)
        if distance <= 5 and math.floor(pz) == coords.z then
            return true
        end
    end

    return false
end

local function getRandomReward()
    local roll = ZombRand(1, 101) -- Génère un nombre aléatoire entre 1 et 100
    local total = 0

    for reward, data in pairs(Rewards.rewardChances) do
        total = total + data.chance
        if roll <= total then
            return reward, data.quantity -- Retourne l'item et la quantité
        end
    end
    return nil, nil
end

-- Fonction qui se déclenche lorsqu'on sélectionne l'option de jouer à la roulette
local function onRouletteOptionSelected(player)
    -- Obtenir l'inventaire principal
    local mainInventory = player:getInventory()
    
    -- Rechercher un jeton dans l'inventaire
    local token = mainInventory:FindAndReturn("JetonDonationLegendoid")
    
    -- Si un jeton est trouvé, le supprimer et jouer à la roulette
    if token then
        player:Say("j'utilise 1x JetonDonationLegendoid pour gagner le gros lot...")
        mainInventory:Remove(token)
        
        -- Tirer un objet de la roulette
        local reward, quantity = getRandomReward() -- Récupérer l'item et sa quantité
        if reward then
            for i = 1, quantity do
                player:getInventory():AddItem("Base." .. reward)
            end
            player:Say("Vous avez gagne : " .. quantity .. "x " .. reward .. " !")
        else
            player:Say("Rien gagne cette fois...")
        end
    else
        player:Say("je n'ai pas de JetonDonationLegendoid pour jouer...")
    end
end

-- Menu contextuel en fonction de la position du joueur
local function addRouletteContextMenu(playerIndex, context, worldObjects)
    local player = getSpecificPlayer(playerIndex)

    -- Vérifier si le joueur est aux coordonnées valides ou proche (distance <= 5)
    if isPlayerAtValidCoordinates(player) then
        -- Vérifier si l'inventaire contient un jeton
        local token = player:getInventory():FindAndReturn("JetonDonationLegendoid")
        if token then
            context:addOption("Jouer a la roulette", player, onRouletteOptionSelected)
        else
            context:addOption("Vous n'avez pas de jeton pour jouer", nil, nil):notAvailable()
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(addRouletteContextMenu)