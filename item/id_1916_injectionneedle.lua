--[[
    SQL-Commands:
    INSERT INTO items VALUES (1916, 1, 25, 254, 1916, item.id_1916_injectionneedle, false, 0, 0, 1, 1, 'Injektionsnadel', 'injection needle', 'Eine fein gearbeitet, hohle Nadel.', 'A small, hollow needle.', 1, injectionNeedle, 0);
    INSERT INTO items VALUES (1917, 1, 25, 254, 1917, NULL, false, 0, 0, 1, 1, 'Flasche mit Blut', 'bottle with blood', '', '', 1, bottleBlood, 0);
    UPDATE items SET itm_name_german = 'Leere Kleine Flasche', itm_name_english = 'empty small bottle', itm_name = 'emptySmallBottle' WHERE itm_id = 790;
]]

local common = require("base.common")
local fighting = require("base.fightingutil")
local religion = require("content.gods")

local SELECTION_SELF_INDEX = 0
local SELECTION_FRONT_INDEX = 1
local SELECTION_ALLOW_INDEX = 0

local M = {}

local function getBloodSample(user, target)
    local emptyBottles = common.getItemInHand(user, Item.emptySmallBottle)

    if emptyBottles == nil then
        user:inform(common.GetNLS(user, "Irgendetwas ging schief.", "Something did not work."))
        return
    end

    local emptyBottleDescriptionDe = emptyBottles:getData("descriptionDe")
    local emptyBottleDescriptionEn = emptyBottles:getData("descriptionEn")

    world:erase(emptyBottles, 1)

    local itemData = {
        descriptionDe = emptyBottleDescriptionDe,
        descriptionEn = emptyBottleDescriptionEn,
        id = target.id,
        strength = target:getBaseAttribute("strength"),
        dexterity = target:getBaseAttribute("dexterity"),
        constitution = target:getBaseAttribute("constitution"),
        agility = target:getBaseAttribute("agility"),
        intelligence = target:getBaseAttribute("intelligence"),
        perception = target:getBaseAttribute("perception"),
        willpower = target:getBaseAttribute("willpower"),
        essence = target:getBaseAttribute("essence"),
        sex = target:getBaseAttribute("sex"),
        age = target:getBaseAttribute("age"),
        bodyHeight = target:getBaseAttribute("body_height"),
        skinColorRed = target:getSkinColour().red,
        skinColorGreen = target:getSkinColour().green,
        skinColorBlue = target:getSkinColour().blue,
        hairColorRed = target:getHairColour().red,
        hairColorGreen = target:getHairColour().green,
        hairColorBlue = target:getHairColour().blue,
        race = target:getRace(),
        magicType = target:getMagicType(),
        isMage = fighting.isMagicUser(target) and 1 or 0,
        godDevoted = target:getQuestProgress(religion._QUEST_DEVOTION),
        godPriesthood = target:getQuestProgress(religion._QUEST_PRIESTHOOD)
    }

    common.CreateItem(user, 1917, 1, 333, itemData)
end

local function injectionTargetDialog(dialog, user, frontUser)
    if not dialog:getSuccess() then
        return
    end

    local selectionIndex = dialog:getSelectedIndex()

    if selectionIndex == SELECTION_SELF_INDEX then
        getBloodSample(user, user)
    elseif selectionIndex == SELECTION_FRONT_INDEX then
        local frontTargetConsentDialogCallback = function(consentResult)
            if not consentResult:getSuccess() or consentResult:getSelectedIndex() ~= SELECTION_ALLOW_INDEX then
                user:inform(common.GetNLS(
                    user, "Dein Ziel hat der Blutentnahme nicht zugestimmt", "Your target declined the blood sampling."
                ))
                return
            end

            getBloodSample(user, frontUser)
        end

        local consentDialog = SelectionDialog(
            common.GetNLS(frontUser, "Blutabnahme", "Blood Sampling"),
            user.name..common.GetNLS(frontUser, " möchte dir Blut abnehmen", " wants to take a blood sample"),
            frontTargetConsentDialogCallback
        )
        consentDialog:addOption(0, common.GetNLS(frontUser, "Erlauben", "Allow"))
        consentDialog:addOption(0, common.GetNLS(frontUser, "Ablehnen", "Decline"))
        frontUser:requestSelectionDialog(consentDialog)
    end
end

function M.UseItem(user, sourceItem, _)
    if not common.IsItemInHands(sourceItem) then
        user:inform(common.GetNLS(
            user, "Du musst die Nadel in den Händen halten", "You have to use the needle with your hands."
        ))
        return
    end

    if not common.hasItemIdInHand(user, Item.emptySmallBottle) then
        user:inform(common.GetNLS(
            user, "Du benötigst kleine Flaschen zum Blutabnehmen.","You need small bottles for sampling blood."
        ))
        return
    end

    local frontUser = common.GetFrontCharacter(user)

    local injectionTargetDialogCallback = function(dialog)
       injectionTargetDialog(dialog, user, frontUser)
    end

    local dialog = SelectionDialog(
        common.GetNLS(user, "Injektionsnadel", "Injection Needle"),
        common.GetNLS(
            user,
            "Wähle die Person aus, der du Blut abnehmen möchtest.",
            "Choose the person from who you want to take a blood sample."
        ),
        injectionTargetDialogCallback
    )
    dialog:addOption(0, common.GetNLS(user, "Mir selbst", "Myself"))

    if frontUser ~= nil then
        dialog:addOption(0, user.name)
    end

    user:requestSelectionDialog(dialog)
end

return M
