SELECT (SELECT COUNT(DISTINCT image_movie_tmdb_id) FROM movie_images) as movies_with_images, (SELECT COUNT(*) FROM movie_items) as count_movies;
SELECT (SELECT COUNT(DISTINCT image_show_thetvdb_id) FROM tblImages) as shows_with_images, (SELECT COUNT(*) FROM tblShows) as count_shows;
SELECT (SELECT COUNT(DISTINCT image_mbid) FROM music_images) as music_with_images, (SELECT COUNT(*) FROM music_artists) as count_artists;