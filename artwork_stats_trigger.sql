# MOVIES
DELIMITER $$
CREATE TRIGGER ai_movie_images AFTER INSERT ON movie_images
	FOR EACH ROW BEGIN
		CALL get_artwork_stats(3);
	END;
$$

CREATE TRIGGER au_movie_images AFTER UPDATE ON movie_images
	FOR EACH ROW BEGIN
		CALL get_artwork_stats(3);
	END;
$$

# MUSIC
DELIMITER $$
CREATE TRIGGER ai_music_images AFTER INSERT ON music_images
	FOR EACH ROW BEGIN
		CALL get_artwork_stats(2);
	END;
$$

CREATE TRIGGER au_music_images AFTER UPDATE ON music_images
	FOR EACH ROW BEGIN
		CALL get_artwork_stats(2);
	END;
$$

#SHOWS
DELIMITER $$
CREATE TRIGGER ai_tblImages AFTER INSERT ON tblImages
	FOR EACH ROW BEGIN
		CALL get_artwork_stats(1);
	END;
$$

CREATE TRIGGER au_tblImages AFTER UPDATE ON tblImages
	FOR EACH ROW BEGIN
		CALL get_artwork_stats(1);
	END;
$$