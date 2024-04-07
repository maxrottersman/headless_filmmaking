local mp = require 'mp'
local utils = require 'mp.utils'

local function log(level, message)
    mp.msg[level](message)
end

local function read_timecode(file_path)
    local file = io.open(file_path, "r")
    if not file then
        log("error", "Failed to open timecode file: " .. file_path)
        return nil
    end
    local timecode = file:read("*line")
    file:close()
    return timecode
end

local function strip_leading_zeros(timecode)
    return string.gsub(timecode, "0*(%d+:%d+:%d+%.%d+)", "%1")
end

local function create_batch_file()
    -- Get the video file path
    local video_path = mp.get_property("path")
    if not video_path then
        log("error", "Failed to get video file path")
        mp.osd_message("Failed to get video file path")
        return
    end

    -- Extract the directory path and file name from the video file path
    local video_dir, video_name = utils.split_path(video_path)
    if not video_dir or not video_name then
        log("error", "Failed to extract directory path and file name from video file path")
        mp.osd_message("Failed to extract directory path and file name")
        return
    end

    -- Construct the file paths for mark_in.txt and mark_out.txt
    local mark_in_path = utils.join_path(video_dir, "mark_in.txt")
    local mark_out_path = utils.join_path(video_dir, "mark_out.txt")

    -- Read the timecodes from mark_in.txt and mark_out.txt
    local mark_in = read_timecode(mark_in_path)
    local mark_out = read_timecode(mark_out_path)

    if not mark_in or not mark_out then
        log("error", "Failed to read timecodes from mark_in.txt or mark_out.txt")
        mp.osd_message("Failed to read timecodes")
        return
    end

    -- Strip leading zeros from the timecodes
    mark_in = strip_leading_zeros(mark_in)
    mark_out = strip_leading_zeros(mark_out)

    -- Construct the FFmpeg command with placeholders for input and output paths
    local ffmpeg_cmd = string.format('ffmpeg -ss %s -to %s -i "%s" -c:v libx264 -c:a aac -b:a 128k -y "%s.mp4"',
                                     mark_in, mark_out, video_path, "%output_name%")

    -- Construct the batch file path
    local batch_file_path = utils.join_path(video_dir, "run_ffmpeg.bat")

    -- Open the batch file for writing
    local batch_file = io.open(batch_file_path, "w")
    if not batch_file then
        log("error", "Failed to create batch file: " .. batch_file_path)
        mp.osd_message("Failed to create batch file")
        return
    end

    -- Write the batch file contents
    batch_file:write("@echo off\n")
    batch_file:write(string.format('echo Creating clip from %s to %s\n', mark_in, mark_out))
    batch_file:write('set /p "output_name=Enter the output filename (without .mp4): "\n')
    batch_file:write(string.format('set "ffmpeg_cmd=%s"\n', ffmpeg_cmd))
    batch_file:write('echo Running FFmpeg command:\n')
    batch_file:write('echo %ffmpeg_cmd%\n')
    batch_file:write('%ffmpeg_cmd%\n')
    --batch_file:write("pause\n")
    batch_file:close()

    log("info", "Batch file created: " .. batch_file_path)
    mp.osd_message("Batch file created: " .. batch_file_path)
end

mp.add_key_binding("alt+m", "create_batch_file", create_batch_file)