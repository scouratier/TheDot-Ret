arms = LibStub("AceAddon-3.0"):NewAddon("arms", "AceConsole-3.0", "AceEvent-3.0")

function MakeCode( r , g , b)
    return r/255 , g/255 , b/255
end

function arms:OnInitialize()
    -- Called when the addon is loaded
    self:Print("DOT LOADED: Ret-1.0")

    spells = {  }
    spells["Inquisition"] =                 {r = 1  , g = 0  , b = 0  }  
    spells["Templar's Verdict"] =           {r = 2  , g = 0  , b = 0  }
    spells["Execution Sentence"] =          {r = 4  , g = 0  , b = 0  }
    spells["Hammer of Wrath"] =             {r = 8  , g = 0  , b = 0  }
    spells["Crusader Strike"] =             {r = 16 , g = 0  , b = 0  }
    spells["Judgment"] =                    {r = 32 , g = 0  , b = 0  }
    spells["Exorcism"] =                    {r = 64 , g = 0  , b = 0  }
    spells["Avenging Wrath"] =              {r = 128, g = 0  , b = 0  }
    spells["Guardian of Ancient Kings"] =   {r = 0  , g = 1  , b = 0  }
    spells["Flash of Light"] =              {r = 0  , g = 2  , b = 0  }    
    spells["Fist of Justice"] =             {r = 0  , g = 4  , b = 0  }
    spells["Eternal Flame"] =               {r = 0  , g = 8  , b = 0  }
    spells["Blessing of Kings"] =           {r = 0  , g = 16 , b = 0  }
    spells["Cleanse"] =                     {r = 0  , g = 32 , b = 0  }
    spells["Hand of Freedom"] =             {r = 0  , g = 64 , b = 0  }
    spells["Rebuke"] =                      {r = 0  , g = 128, b = 0  }
    spells["Lay on Hands"] =                {r = 0  , g = 0  , b = 1  }
end

function arms:OnEnable()
    square_size = 15
    local f = CreateFrame( "Frame" , "one" , UIParent )
    f:SetFrameStrata( "HIGH" )
    f:SetWidth( square_size * 2 )
    f:SetHeight( square_size )
    f:SetPoint( "TOPLEFT" , square_size * 2 , 0 )
    
    self.two = CreateFrame( "StatusBar" , nil , f )
    self.two:SetPoint( "TOPLEFT" )
    self.two:SetWidth( square_size )
    self.two:SetHeight( square_size )
    self.two:SetStatusBarTexture("Interface\\AddOns\\thedot\\Images\\Gloss")
    self.two:SetStatusBarColor( 0 , 0 , 0 )
    
    self.three = CreateFrame( "StatusBar" , nil , f )
    self.three:SetPoint( "TOPLEFT" , square_size , 0)
    self.three:SetWidth( square_size )
    self.three:SetHeight( square_size )
    self.three:SetStatusBarTexture("Interface\\AddOns\\thedot\\Images\\Gloss")
    self.three:SetStatusBarColor( 0 , 0 , 0 )
    
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    --self:RegisterEvent("CHAT_MSG_WHISPER")
end

function arms:OnDisable()
    -- Called when the addon is disabled
end

function canCastNow(inSpell)
    local start, duration, enable
    local usable, noRage = IsUsableSpell( inSpell )
        if usable == true then
            start, duration, enable = GetSpellCooldown( inSpell )
            if start == 0 then
                return true , 0
            end
        else
            return false , 0
        end
    return false , (start+duration - GetTime())
end

function arms:ACTIONBAR_UPDATE_COOLDOWN()
end

function arms:COMBAT_LOG_EVENT_UNFILTERED()
    -- Start by reseting the dot state:
    self.two:SetStatusBarColor(0, 0, 0);
    self.three:SetStatusBarColor(0, 0, 0);      

    local mana = 0
    local holyPower = 0
    local BlessingofKings = 0
    local ArtofWar = 0
    local DivinePurpose = 0
    local Inquisition = 1
    local spellName
    local red = 0
    local green = 0
    local blue = 0
    local shade = 0
    local nextCast = {}
    local noSpell =  { r = 0 , g = 0 , b = 0 } 
    nextCast = noSpell
    	
    -- are we in combat
    if InCombatLockdown() == true or UnitAffectingCombat("focus") == true then
        local mana = UnitPower("player",0)
        local holyPower = UnitPower("player",9)
        local holyPowerMax = UnitPowerMax("player",9)


        
        aowbuff, aowrank, aowicon, aowcount = UnitBuff( "player" , "Art of War")
        if aowbuff ~= nil then
            nextCast = spells["Exorcism"]
        end

        tv, tvcoodown = canCastNow( "Templar's Verdict" )
        if tv == true then
            nextCast = spells["Templar's Verdict"]
        end
          
        cs, cscoodown = canCastNow( "Crusader Strike" )
        if cs == true then
            nextCast = spells["Crusader Strike"]
        end

        jud, judcoodown = canCastNow( "Judgment" )
        if jud == true then
            nextCast = spells["Judgment"]
        end

        ex, excoodown = canCastNow( "Exorcism" )
        if ex == true then
            nextCast = spells["Exorcism"]
        end

        aw, awcooldown = canCastNow("Avenging Wrath")
        if aw == true then
            nextCast = spells["Avenging Wrath"]
        end

        how, howcooldown = canCastNow( "Hammer of Wrath")
        if how == true then
            nextCast = spells["Hammer of Wrath"]
        end

        es, escooldown = canCastNow( "Execution Sentence")
        if es == true then
            nextCast = spells["Execution Sentence"]
        end

        tv, tvcooldown = canCastNow("Templar's Verdict")
        if tv == true and holyPower == holyPowerMax then
            nextCast = spells["Templar's Verdict"]
        end
        
    else
        -- not in combat
        local bless, blessrank, blessicon, blesscount, blessdebuffType, blessduration, blessexpirationTime, blessisMine, blessisStealable  = UnitBuff("player","Blessing of Kings");
        bk, bkcooldown = canCastNow( "Blessing of Kings" )
        if bk == true and bless == nil then
            nextCast = spells["Blessing of Kings"]
        end
        
    end
    

    red = red + nextCast["r"]
    green = green + nextCast["g"]
    blue = blue + nextCast["b"]
    --self:Print( red , green , blue )
    self.two:SetStatusBarColor(red/255, green/255, blue/255)
    red = 0
    green = 0
    blue = 0
    self.three:SetStatusBarColor( red/255, green/255, blue/255 );
end