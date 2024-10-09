surface.CreateFont( "ScoreboardDefault", {
    font    = "Helvetica",
    size    = 22,
    weight    = 800
} )

surface.CreateFont( "ScoreboardDefaultTitle", {
    font    = "Helvetica",
    size    = 32,
    weight    = 800
} )

local scoreboard
local Menu
--
-- This defines a new panel type for the player row. The player row is given a player
-- and then from that point on it pretty much looks after itself. It updates player info
-- in the think function, and removes itself when the player leaves the server.
--
local actions =
    {
        {"ulx ban", " $", "fadmin/icons/ban"},
        {"ulx kick", " $", "fadmin/icons/kick"},
        {"ulx bring", " $", "fadmin/icons/teleport"},
        {"ulx goto", " $", "fadmin/icons/teleport"},
        {"ulx cloak" ," $", "fadmin/icons/cloak"},
        {"ulx uncloak", " $", "fadmin/icons/disable"},
        {"FSpectate", " ", "fadmin/icons/spectate"},
    }
local PLAYER_LINE = {
    Init = function( self )
        self.AvatarButton = self:Add("DButton")
        self.AvatarButton:Dock(LEFT)
        self.AvatarButton:SetSize(40, 40)
        self.AvatarButton.DoClick = function()
            self.Player:ShowProfile()
        end

        self.Avatar = vgui.Create( "AvatarImage", self.AvatarButton )
        self.Avatar:SetSize(40, 40)
        self.Avatar:SetMouseInputEnabled(false)

        self.Name = self:Add("DLabel")
        self.Name:Dock(FILL)
        self.Name:SetFont("ScoreboardDefault")
        self.Name:SetTextColor(Color( 255, 255, 255))
        self.Name:DockMargin(8, 0, 0, 0)
        self.Name:SetMouseInputEnabled(true)
        self.Name.DoRightClick = function()
            local target = self.Player
            Menu = DermaMenu()

            for _, action in ipairs(actions) do
                CAMI.PlayerHasAccess(
                    LocalPlayer(),
                    action[1],
                    function(b, _)
                        if not b then return end
                        local btn = Menu:AddOption(action[1])
                        btn:SetIcon(action[3])
                        btn.DoClick = function()
                            if not IsValid(target) then return end
                            LocalPlayer():ConCommand(
                                action[1]..action[2]..target:UserID()
                            )
                        end
                    end
                )
            end
            Menu:Open()
        end


        self.Mute = self:Add("DImageButton")
        self.Mute:SetSize(40, 40)
        self.Mute:Dock(RIGHT)

        self.Ping = self:Add("DLabel")
        self.Ping:Dock(RIGHT)
        self.Ping:SetWidth(50)
        self.Ping:SetFont("ScoreboardDefault")
        self.Ping:SetTextColor(Color( 255, 255, 255))
        self.Ping:SetContentAlignment(5)

        self.Deaths = self:Add("DLabel")
        self.Deaths:Dock(RIGHT)
        self.Deaths:SetWidth(50)
        self.Deaths:SetFont("ScoreboardDefault")
        self.Deaths:SetTextColor(Color( 255, 255, 255))
        self.Deaths:SetContentAlignment(5)

        self.Kills = self:Add("DLabel")
        self.Kills:Dock(RIGHT)
        self.Kills:SetWidth(50)
        self.Kills:SetFont("ScoreboardDefault")
        self.Kills:SetTextColor(Color( 255, 255, 255))
        self.Kills:SetContentAlignment(5)

        self.Regiment = self:Add("DImage")
        self.Regiment:Dock(RIGHT)
        self.Regiment:SetContentAlignment(5)

        self.Rank = self:Add("DImage")
        self.Rank:Dock(RIGHT)
        self.Rank:DockMargin(0, 0, 12, 0)
        self.Rank:SetSize(30, 40)
        self.Rank:SetContentAlignment(5)

        self:Dock(TOP)
        self:DockPadding(3, 3, 3, 3)
        self:SetHeight(40 + 3 * 2)
        self:DockMargin(2, 0, 2, 2)

    end,

    Setup = function(self, pl)
        self.Player = pl

        self.Avatar:SetPlayer(pl)

        self:Think(self)

        self.faction = 0
        self.regiment = 0

        --local friend = self.Player:GetFriendStatus()
        --MsgN( pl, " Friend: ", friend )
    end,

    Think = function(self)

        if not IsValid(self.Player) or not self.Player.MRPRank then
            self:SetZPos(9999) -- Causes a rebuild
            self:Remove()
            return
        end

        
        self.faction = self.Player:MRPFaction()
        self.regiment = self.Player:MRPRegiment()
        if self.faction ~= 0 and self.regiment ~=0 then
            self.Name:SetText(self.Player:RPName())
            local width = MRP.Factions[self.faction][self.regiment]["whratio"] * 40
            self.Regiment:SetSize(width, 40)
            self.Regiment:SetImage(MRP.Factions[self.faction][self.regiment]["insignia"])
            local rankId = self.Player:MRPRank()
            self.Rank:SetImage(
                MRP.Factions[self.faction][self.regiment][rankId]["shoulderrank"]
            )
        else
            self.Name:SetText(self.Player:Nick())
        end

        if self.NumKills == nil or self.NumKills ~= self.Player:Frags() then
            self.NumKills = self.Player:Frags()
            self.Kills:SetText(self.NumKills)
        end

        if self.NumDeaths == nil or self.NumDeaths ~= self.Player:Deaths() then
            self.NumDeaths = self.Player:Deaths()
            self.Deaths:SetText(self.NumDeaths)
        end

        if self.NumPing == nil or self.NumPing ~= self.Player:Ping() then
            self.NumPing = self.Player:Ping()
            self.Ping:SetText( self.NumPing )
        end

        --
        -- Change the icon of the mute button based on state
        --
        if self.Muted == nil or self.Muted ~= self.Player:IsMuted() then
            self.Muted = self.Player:IsMuted()
            if self.Muted then
                self.Mute:SetImage("icon32/muted.png")
            else
                self.Mute:SetImage("icon32/unmuted.png")
            end

            self.Mute.DoClick = function()
                self.Player:SetMuted( not self.Muted)
            end
            self.Mute.OnMouseWheeled = function(s, delta)
                local vol = self.Player:GetVoiceVolumeScale() + ( delta / 100 * 5 )
                self.Player:SetVoiceVolumeScale(vol)
                s.LastTick = CurTime()
            end

            self.Mute.PaintOver = function(s, w, h)
                if not IsValid(self.Player) then return end

                local a = 255 - math.Clamp( CurTime() - ( s.LastTick or 0 ), 0, 3 ) * 255
                if a <= 0 then return end

                draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, a * 0.75 ) )
                draw.SimpleText(
                    math.ceil( self.Player:GetVoiceVolumeScale() * 100 ) .. "%",
                    "DermaDefaultBold", w / 2, h / 2, Color( 255, 255, 255, a ),
                    TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
                )
            end

        end

        --
        -- Connecting players go at the very bottom
        --
        if self.Player:Team() == TEAM_CONNECTING then
            self:SetZPos( 2000 + self.Player:EntIndex() )
            return
        end

        --
        -- This is what sorts the list. The panels are docked in the z order,
        -- so if we set the z order according to kills they'll be ordered that way!
        -- Careful though, it's a signed short internally, so needs to range between 
        -- -32,768k and +32,767
        --
        self:SetZPos( ( self.NumKills * -50 ) + self.NumDeaths + self.Player:EntIndex() )

    end,

    Paint = function( self, w, h )

        if ( not IsValid( self.Player ) ) then
            return
        end

        --
        -- We draw our background a different colour based on the status of the player
        --

        if self.Player:Team() == TEAM_CONNECTING and not game.SinglePlayer() then
            draw.RoundedBox( 4, 0, 0, w, h, Color( 80, 203, 207, 160) )
            return
        end

        if not self.Player:Alive() then
            draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 160 ) )
            return
        end

        if self.Player:IsAdmin() then
            draw.RoundedBox( 4, 0, 0, w, h, Color( 230, 0, 0, 160 ) )
            return
        end

        draw.RoundedBox( 4, 0, 0, w, h, Color( 230, 230, 230, 160 ) )

    end
}

--
-- Convert it from a normal table into a Panel Table based on DPanel
--
PLAYER_LINE = vgui.RegisterTable( PLAYER_LINE, "DPanel" )

--
-- Here we define a new panel table for the scoreboard. It basically consists
-- of a header and a scrollpanel - into which the player lines are placed.
--
local SCORE_BOARD = {
    Init = function( self )

        self.Header = self:Add( "Panel" )
        self.Header:Dock( TOP )
        self.Header:SetHeight( 100 )
        self.Header:SetText( "100" )

        self.Name = self.Header:Add( "DLabel" )
        self.Name:SetFont( "ScoreboardDefaultTitle" )
        self.Name:SetTextColor( color_white )
        self.Name:Dock( TOP )
        self.Name:SetHeight( 40 )
        self.Name:SetContentAlignment( 5 )
        self.Name:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )
        self.Name:SetText( "100" )

        --self.NumPlayers = self.Header:Add( "DLabel" )
        --self.NumPlayers:SetFont( "ScoreboardDefault" )
        --self.NumPlayers:SetTextColor( color_white )
        --self.NumPlayers:SetPos( 0, 100 - 30 )
        --self.NumPlayers:SetSize( 300, 30 )
        --self.NumPlayers:SetContentAlignment( 4 )

        self.Scores = self:Add( "DScrollPanel" )
        self.Scores:Dock( FILL )

    end,

    PerformLayout = function( self )

        self:SetSize( 700, ScrH() - 200 )
        self:SetPos( ScrW() / 2 - 350, 100 )

    end,

    -- self, w, h
    --Paint = function( self, w, h )

        --draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 200 ) )

    --end,

    -- self, w, h
    Think = function( self, _, _ )

        self.Name:SetText( "BraverySoldiers" )

        --
        -- Loop through each player, and if one doesn't have a score entry - create it.
        --
        local plyrs = player.GetAll()
        for _, pl in pairs( plyrs ) do

            if not IsValid( pl.ScoreEntry ) then
                pl.ScoreEntry = vgui.CreateFromTable( PLAYER_LINE, pl.ScoreEntry )
                pl.ScoreEntry:Setup( pl )

                self.Scores:AddItem( pl.ScoreEntry )
            end
        end

    end
}

SCORE_BOARD = vgui.RegisterTable( SCORE_BOARD, "EditablePanel" )

--[[---------------------------------------------------------
    Name: gamemode:ScoreboardShow( )
    Desc: Sets the scoreboard to visible
-----------------------------------------------------------]]
hook.Add("ScoreboardShow", "MRP_Scoreboard", function()

    if not IsValid(scoreboard) then
        scoreboard = vgui.CreateFromTable( SCORE_BOARD )
    end

    if IsValid(scoreboard) then
        scoreboard:Show()
        scoreboard:MakePopup()
        scoreboard:SetKeyboardInputEnabled( false )
    end
    return true

end)

--[[---------------------------------------------------------
    Name: gamemode:ScoreboardHide( )
    Desc: Hides the scoreboard
-----------------------------------------------------------]]
hook.Add("ScoreboardHide", "MRP_Scoreboard", function()
    if IsValid( scoreboard ) then
        scoreboard:Hide()
        if IsValid(Menu) then Menu:Remove() end
    end
    return true

end)
