SLASH_CLASSFIXER1 = "/classfixer"

SlashCmdList["CLASSFIXER"] = function(msg)
    msg = msg:lower()
    if msg == "toggle class" then
        CF.db.enableClassPatch = not CF.db.enableClassPatch
        print("Class patching is now", CF.db.enableClassPatch and "enabled" or "disabled")
    elseif msg == "toggle color" then
        CF.db.enableColorPatch = not CF.db.enableColorPatch
        print("Color patching is now", CF.db.enableColorPatch and "enabled" or "disabled")
    else
        print("Usage: /classfixer toggle class | toggle color")
    end
end