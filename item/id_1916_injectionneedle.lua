--[[
    SQL-Commands:
    INSERT INTO items VALUES (1916, 1, 25, 254, 1916, item.id_1916_injectionneedle, false, 0, 0, 1, 1, 'Injektionsnadel', 'injection needle', 'Eine fein gearbeitet, hohle Nadel.', 'A small, hollow needle.', 1, injectionNeedle, 0);
    INSERT INTO items VALUES (1917, 1, 25, 254, 1917, NULL, false, 0, 0, 1, 1, 'Flasche mit Blut', 'bottle with blood', '', '', 1, bottleBlood, 0);
    UPDATE items SET itm_name_german = 'Leere Kleine Flasche', itm_name_english = 'empty small bottle', itm_name = 'emptySmallBottle' WHERE itm_id == 790;
]]

local common = require("base.common")
local fighting = require("base.fightingutil")

local SELECTION_SELF_INDEX = 0
local SELECTION_FRONT_INDEX = 1
local SELECTION_ALLOW_INDEX = 0

local M = {}

function M.UseItem(user, sourceItem, ltstate)
    if not common.hasItemIdInHand(Item.emptySmallBottle) then
        user:inform(getText("Du benötigst kleine Flaschen zum Blutabnehmen.","You need small bottles for sampling blood."))
        return
    end

    local injectionTargetDialogCallback = function(dialog)
       injectionTargetDialog(dialog, user, frontUser) 
    end

    local dialog = SelectionDialog(getText("Injektionsnadel", "Injection Needle"), getText("Wähle die Person aus, der du Blut abnehmen möchtest.", "Choose the person from who you want to take a blood sample."), injectionTargetDialogCallback)
    dialog:addOption(0, getText("Mir selbst", "Myself"))

    local frontUser = common.GetFrontCharacter(User)
    if frontUser ~= nil then
        dialog:addOption(0, User.name)
    end

    User:requestSelectionDialog(dialog)
end

function injectionTargetDialog(dialog, user, frontUser)
    if not dialog:getSuccess() then
        return
    end

    local selectionIndex = dialog:getSelectedIndex()

    if selectionIndex == SELECTION_SELF_INDEX then
        getBloodSample(user, user)
    else if selectionIndex == SELECTION_FRONT_INDEX then
        local frontTargetConsentDialogCallback = function(dialog)
            if not dialog:getSuccess() or dialog:getSelectedIndex() ~= SELECTION_ALLOW_INDEX then
                user:inform(getText("Dein Ziel hat der Blutentnahme nicht zugestimmt", "Your target declined the blood sampling."))
                return
            end

            getBloodSample(user, frontUser)
        end

        local dialog = SelectionDialog(getText("Blutabnahme", "Blood Sampling", user.name..getText(" möchte dir Blut abnehmen", " wants to take a blood sample", frontTargetConsentDialogCallback)))
        dialog:addOption(0, getText("Erlauben", "Allow"))
        dialog:addOption(0, getText("Ablehnen", "Decline"))
        frontUser:requestSelectionDialog(dialog)
    end
end

function getBloodSample(user, target)
    local emptyBottles = common.getItemInHand(Item.emptySmallBottle)

    if emptyBottles == nil then
        user:inform(getText("Irgendetwas ging schief.", "Something did not work."))
        return
    end

    emptyBottles.number = emptyBottles.number - 1

    local itemData = {
        descriptionDe = "Eine Blutprobe von "..target.name,
        descriptionEn = "A blood sample of "..target.name,
        id = user.id,
        strength = user:getBaseAttribute("strength"),
        dexterity = user:getBaseAttribute("dexterity"),
        constitution = user:getBaseAttribute("constitution"),
        agility = user:getBaseAttribute("agility"),
        intelligence = user:getBaseAttribute("intelligence"),
        perception = user:getBaseAttribute("perception"),
        willpower = user:getBaseAttribute("willpower"),
        essence = user:getBaseAttribute("essence"),
        sex = user:getBaseAttribute("sex"),
        age = user:getBaseAttribute("age"),
        bodyHeight = user:getBaseAttribute("body_height"),
        skinColor = user:getSkinColour(),
        hairColor = user:getHairColour(),
        race = user:getRace(),
        magicType = user:getMagicType(),
        isMage = fighting.isMagicUser(user)
    }

    common.CreateItem(user, 1917, 1, 0, itemData)
end

return M
