local msg = require 'mp.msg'
require 'mp.options'
local prev_song_args = ''
local options = {username = ''}
local accepted_file_formats = {'flac', 'mp3'}
read_options(options, 'lastfm')

function has_value (tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

function mkmetatable()
	local m = {}
	for i = 0, mp.get_property("metadata/list/count") - 1 do
		local p = "metadata/list/"..i.."/"
		m[mp.get_property(p.."key")] = mp.get_property(p.."value")
	end
	return m
end

function esc(s)
	return string.gsub(s, "'", "'\\''")
end

function scrobble()
	if artist and title then
		args = string.format("scrobbler scrobble %s '%s' '%s' now -a '%s' -d %ds > /dev/null", esc(options.username), esc(artist), esc(title), esc(album), length)
		prev_song_args = args
	end
end

function enqueue()
	if artist and title then
		if options.username == '' then
			msg.info(string.format("Could not find a username! Please follow the steps in the README.md"))
			return
		end
		args = string.format("scrobbler now-playing %s '%s' '%s' -a '%s' -d %ds > /dev/null", esc(options.username), esc(artist), esc(title), esc(album), length)
		msg.verbose(args)
		os.execute(args)
		if tim then tim.kill(tim) end
		if length then
			timeout = length / 2 
		else
			timeout = 240
		end
		tim = mp.add_timeout(timeout, scrobble)
	end
end

function new_track()
	if mp.get_property("metadata/list/count") then
		local m = mkmetatable()
		local icy = m["icy-title"]
		if icy then
			-- TODO better magic
			artist, title = string.gmatch(icy, "(.+) %- (.+)")()
			album = nil
			length = nil
		else
			length = mp.get_property("duration")
			if length and tonumber(length) < 30 then return end	-- last.fm doesn't allow scrobbling short tracks
			artist = m["artist"]
			if not artist then
				artist = m["ARTIST"]
			end
			album = m["album"]
			if not album then
				album = m["ALBUM"]
			end
			title = m["title"]
			if not title then
				title = m["TITLE"]
			end
		end
		enqueue()
	end
end

function on_close()
	if not prev_song_args or prev_song_args ~= '' then
		msg.verbose(prev_song_args)
		os.execute(prev_song_args)
		prev_song_args = ''
	end
end

function on_file_loaded()
	file_format = mp.get_property("file-format")
	if not has_value(accepted_file_formats, file_format) then
		msg.info(string.format("The file format %s is not accepted. If you think this is a mistake, you can add the file format to the accepted file format list.", string.format(file_format)))
		return
	end
	new_track()
end

mp.register_event("end-file", on_close)
mp.register_event("file-loaded", on_file_loaded)
