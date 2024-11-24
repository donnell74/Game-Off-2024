extends Control

@export var soundtrack : Array[Song] = []
@export var currently_playing_index = 0

func _ready() -> void:
	soundtrack.shuffle()
	_switch_track(currently_playing_index)
	%BgMusicPlayer.finished.connect(_on_bg_music_player_finished)

func _switch_track(index: int) -> void:
	currently_playing_index = index
	if currently_playing_index == soundtrack.size():
		currently_playing_index = 0
	
	%BgMusicPlayer.stream = soundtrack[currently_playing_index].stream
	%BgMusicPlayer.play()
	_update_music_info()
	%SongCanvasLayer.visible = true
	%SongVisibleTimer.start()

func _update_music_info() -> void:
	var song = soundtrack[currently_playing_index]
	%AlbumTexture.texture = song.album.art
	%AlbumTexture.texture
	%SongTitleLabel.text = song.title
	%AlbumTitleLabel.text = song.album.title
	%ArtistLabel.text = song.album.artist

func _on_bg_music_player_finished() -> void:
	_switch_track(currently_playing_index + 1)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Play Last Song"):
		_switch_track(currently_playing_index - 1)

	if event.is_action_pressed("Play Next Song"):
		_switch_track(currently_playing_index + 1)

func _on_song_visible_timer_timeout() -> void:
	%SongCanvasLayer.visible = false
