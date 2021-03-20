OptWriter_ModuleFiles = {
    "Swift_0_Core/swift.lua",
    "Swift_0_Core/api.lua",
    "Swift_0_Core/debug.lua",
    "Swift_0_Core/behavior.lua",

    "Swift_1_DialogCore/source.lua",
    "Swift_1_DialogCore/api.lua",
    "Swift_1_DisplayCore/source.lua",
    "Swift_1_DisplayCore/api.lua",
    "Swift_1_JobsCore/source.lua",
    "Swift_1_JobsCore/api.lua",
    "Swift_1_ScriptingValueCore/source.lua",
    "Swift_1_ScriptingValueCore/api.lua",
    "Swift_1_SoundCore/source.lua",
    "Swift_1_SoundCore/api.lua",
    "Swift_1_TextCore/source.lua",
    "Swift_1_TextCore/api.lua",
    "Swift_1_TradingCore/source.lua",
    "Swift_1_TradingCore/api.lua",
    "Swift_2_JobsRealtime/source.lua",
    "Swift_2_JobsRealtime/api.lua",
    "Swift_2_WeatherCore/source.lua",
    "Swift_2_WeatherCore/api.lua",
    "Swift_3_QuestCore/source.lua",
    "Swift_3_QuestCore/api.lua",

    "Swift_0_Core/selfload.lua",
};

function OptWriter_LoadSource(_File)
    local fh = io.open("../modules/" .._File, "rt");
    if not fh then
        print("file not found: ../modules/" .._File);
        return "";
    end
    print("loading: ../modules/" .._File);
    fh:seek("set", 0);
    local Contents = fh:read("*all");
    fh:close();
    return Contents;
end

function OptWriter_ConcatSources()
    local Content = "";
    for i= 1, #OptWriter_ModuleFiles, 1 do
        Content = Content .. OptWriter_LoadSource(OptWriter_ModuleFiles[i]);
    end
    return Content;
end

function OptWriter_Write()
    local QsbContent = OptWriter_ConcatSources();
    local fh = io.open("../var/qsb.lua", "rt");
    if fh ~= nil then
        os.remove("../var/qsb.lua");
        fh:close();
    end
    local fh = io.open("../var/qsb.lua", "wt");
    assert(fh, "Output file can not be created!");
    print("write qsb to var");
    fh:write(QsbContent);
    fh:close();
end

OptWriter_Write();

