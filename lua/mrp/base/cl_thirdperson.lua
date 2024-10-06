local on = false

local function togglethirdperson()
    on = not on
end

local function calcThirdperson(ply, pos, angles, fov)
    if on then
        local view = {}
        view.origin = pos-(angles:Forward()*100)
        view.angles = angles
        view.fov = fov
     
        return view
    end
end
 
hook.Add("CalcView", "MRP_CalcThirdperson", calcThirdperson)
 
hook.Add("ShouldDrawLocalPlayer", "MyHax ShouldDrawLocalPlayer", function(ply)
    if on then
        return true
    end
end)

concommand.Add("togglethirdperson", togglethirdperson)


