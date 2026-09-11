extends Node

const MIX_RATE_05404 := 22050
const POOL_SIZE_05404 := 4

var cue_streams_05404: Dictionary = {}
var players_05404: Array[AudioStreamPlayer] = []
var cue_count_05404 := 0
var last_cue_05404 := ""

func _ready() -> void:
	add_to_group("audio_feedback_05404")
	_build_streams_05404()
	for i in range(POOL_SIZE_05404):
		var player := AudioStreamPlayer.new()
		player.name = "FeedbackVoice05404_%d" % i
		player.bus = "Master"
		add_child(player)
		players_05404.append(player)

func _build_streams_05404() -> void:
	cue_streams_05404 = {
		"attack": _make_tone_05404(132.0, 0.095, 0.62, 54.0),
		"action": _make_tone_05404(330.0, 0.070, 0.44, 40.0),
		"pickup": _make_tone_05404(520.0, 0.095, 0.42, 180.0),
		"alert": _make_tone_05404(205.0, 0.150, 0.56, -70.0),
		"weapon": _make_tone_05404(410.0, 0.060, 0.38, 95.0),
		"sprint": _make_tone_05404(260.0, 0.055, 0.28, 25.0),
		"denied": _make_tone_05404(145.0, 0.105, 0.35, -35.0)
	}

func _make_tone_05404(freq: float, duration: float, amplitude: float, sweep: float) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE_05404
	wav.stereo = false
	var frames := maxi(1, int(duration * float(MIX_RATE_05404)))
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	for i in range(frames):
		var t := float(i) / float(MIX_RATE_05404)
		var p := float(i) / float(frames)
		var env := pow(1.0 - p, 2.1)
		var local_freq := maxf(30.0, freq + sweep * p)
		var sample := sin(TAU * local_freq * t) * amplitude * env
		# Um segundo harmônico curto evita o som de beep puro sem exigir assets externos.
		sample += sin(TAU * local_freq * 1.92 * t) * amplitude * 0.20 * env
		var pcm := clampi(int(sample * 32767.0), -32768, 32767)
		var unsigned_pcm := pcm & 0xffff
		bytes[i * 2] = unsigned_pcm & 0xff
		bytes[i * 2 + 1] = (unsigned_pcm >> 8) & 0xff
	wav.data = bytes
	return wav

func play_cue_05404(kind: String, strength: float = 1.0) -> bool:
	var key := kind if cue_streams_05404.has(kind) else "action"
	if players_05404.is_empty() or not cue_streams_05404.has(key):
		return false
	var selected := players_05404[0]
	for candidate in players_05404:
		if not candidate.playing:
			selected = candidate
			break
	selected.stream = cue_streams_05404[key] as AudioStream
	selected.volume_db = clampf(-8.0 + (clampf(strength, 0.25, 1.5) - 1.0) * 4.0, -14.0, -2.0)
	selected.pitch_scale = 1.0
	selected.play()
	cue_count_05404 += 1
	last_cue_05404 = key
	return true

func get_audio_feedback_debug_05404() -> Dictionary:
	return {
		"version": "0.5.40.4",
		"registered_cues": cue_streams_05404.size(),
		"pool_size": players_05404.size(),
		"mix_rate": MIX_RATE_05404,
		"emitted": cue_count_05404,
		"last_cue": last_cue_05404,
		"procedural": true
	}
