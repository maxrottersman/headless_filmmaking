local mp = require 'mp'
local utils = require 'mp.utils'

local function log(level, message)
    mp.msg[level](message)
end

local function format_timecode(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    local milliseconds = math.floor((seconds % 1) * 1000)
    return string.format("%02d:%02d:%02d.%03d", hours, minutes, secs, milliseconds)
end

local function save_timecode(file_name)
    -- Get the current time position
    local time_pos = mp.get_property_number("time-pos")
    if not time_pos then
        log("error", "Failed to get current time position")
        mp.osd_message("Failed to get current time position")
        return
    end

    -- Get the video file path
    local video_path = mp.get_property("path")
    if not video_path then
        log("error", "Failed to get video file path")
        mp.osd_message("Failed to get video file path")
        return
    end

    -- Extract the directory path from the video file path
    local video_dir = utils.split_path(video_path)
    if not video_dir then
        log("error", "Failed to extract directory path from video file path")
        mp.osd_message("Failed to extract directory path")
        return
    end

    -- Construct the file path for the timecode file
    local file_path = utils.join_path(video_dir, file_name)
    if not file_path then
        log("error", "Failed to construct file path for " .. file_name)
        mp.osd_message("Failed to construct file path")
        return
    end

    -- Format the timecode in FFmpeg compatible format
    local timecode = format_timecode(time_pos)

    -- Open the file for writing
    local file, err = io.open(file_path, "w")
    if not file then
        log("error", "Failed to open file for writing: " .. err)
        mp.osd_message("Failed to open file for writing")
        return
    end

    -- Write the timecode to the file
    local success, err = file:write(timecode)
    if not success then
        log("error", "Failed to write timecode to file: " .. err)
        mp.osd_message("Failed to write timecode to file")
        file:close()
        return
    end

    -- Close the file
    file:close()

    log("info", "Timecode saved to: " .. file_path)
    mp.osd_message("Timecode saved to: " .. file_path)
end

local function save_mark_in()
    save_timecode("mark_in.txt")
end

local function save_mark_out()
    save_timecode("mark_out.txt")
end

mp.add_key_binding("alt+b", "save_mark_in", save_mark_in)
mp.add_key_binding("alt+n", "save_mark_out", save_mark_out)