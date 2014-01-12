DELIMITER $$
DROP PROCEDURE IF EXISTS get_artwork_stats $$
DROP TABLE IF EXISTS artwork_stats $$
CREATE TABLE artwork_stats(`section` INT PRIMARY KEY,`total` INT,`complete` INT,`incomplete` INT) $$

CREATE PROCEDURE get_artwork_stats(IN _section TINYINT(1))
script:BEGIN

# SETUP #############################################################
DECLARE finished TINYINT(1) DEFAULT 0;
DECLARE type_id_f int(11);    # do not use 'type_id'
DECLARE type_name_f NVARCHAR(255);
DECLARE select_part NVARCHAR(10000);
DECLARE initial_select_part NVARCHAR(10000);
DECLARE completeness_part NVARCHAR(1000);
DECLARE complete_select NVARCHAR(12000);
DECLARE type_table NVARCHAR(255);
DECLARE cursor1 CURSOR FOR SELECT type_id,type_name FROM fanart_types WHERE type_section = _section;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
# /SETUP ############################################################


# CASING TYPE #######################################################
IF completeness_part IS NULL THEN SET completeness_part = ",("; END IF;

CASE _section
	# WHEN TV-SHOWS
	WHEN 1 THEN SET @_select_string_one := ':=IF((SELECT COUNT(image_id) FROM tblImages WHERE image_active = "y" AND image_type = "';  # why you cant use replace already here? thats annoying
				SET @_select_string_two := '" AND image_show_thetvdb_id = show_thetvdb_id) > 0, 0, 1) AS ';
				SET @type_table 		:= 'tblShows';
				SET select_part 		:= 'SELECT show_name AS item_name, show_thetvdb_id AS item_id, ';
				SET initial_select_part := select_part;

	# WHEN MUSIC
	WHEN 2 THEN SET @_select_string_one := ':=IF((SELECT COUNT(image_id) FROM music_images WHERE image_active = "y" AND image_type = "';  # why you cant use replace already here? thats annoying
				SET @_select_string_two := '" AND image_mbid = artist_mbid) > 0, 0, 1) AS ';
				SET @type_table 		:= 'music_artists';
				SET select_part 		:= 'SELECT artist_name AS item_name, artist_mbid AS item_id, ';
				SET initial_select_part := select_part;
	
	# WHEN MOVIES
	WHEN 3 THEN SET @_select_string_one := ':=IF((SELECT COUNT(image_id) FROM movie_images WHERE image_active = "y" AND image_type = "';  # why you cant use replace already here? thats annoying
				SET @_select_string_two := '" AND image_movie_tmdb_id = movie_tmdb_id) > 0, 0, 1) AS ';
				SET @type_table			:= 'movie_items';
				SET select_part 		:= 'SELECT movie_name AS item_name, movie_tmdb_id AS item_id, ';
				SET initial_select_part := select_part;

	ELSE LEAVE script;  # leave the proc when *section* is wrong - should be fine / adding a section is kinda unlikely
END CASE;

# /CASING TYPE ######################################################


# DO NOT TOUCH IT - NEVER EVER
# ################################
OPEN cursor1;
get_results: LOOP
	FETCH cursor1 INTO type_id_f, type_name_f;
	IF finished = 1 THEN LEAVE get_results; END IF;
	SET type_name_f = REPLACE(type_name_f, ' ', '_');
	IF select_part = initial_select_part	
	THEN SET select_part := CONCAT(select_part,'@',type_name_f,REPLACE(@_select_string_one,'"',"'"), type_id_f, REPLACE(@_select_string_two,'"',"'"), type_name_f);
	ELSE SET select_part := CONCAT(select_part,', @',type_name_f,REPLACE(@_select_string_one,'"',"'"), type_id_f, REPLACE(@_select_string_two,'"',"'"), type_name_f);
	END IF;

	IF completeness_part = ",("
	THEN SET completeness_part := CONCAT(completeness_part, '@',type_name_f);
	ELSE SET completeness_part := CONCAT(completeness_part,' + @', type_name_f);
	END IF;
END LOOP get_results;
CLOSE cursor1;

#SET having_part := CONCAT(having_part, '	ORDER BY completeness ASC');
SET completeness_part := CONCAT(completeness_part, ') AS completeness');
SET @total:=CONCAT('(SELECT COUNT(*) FROM ',@type_table,')');
SET @incomplete:=0;
SET @complete:=CONCAT('(SELECT COUNT(*) FROM (',select_part, completeness_part, ' FROM ', @type_table, ' ', ' ) as x WHERE completeness = ', 0, ')');
SET @exec:=CONCAT('REPLACE INTO `artwork_stats` VALUES(',_section,',',@total,',',@complete,',',@incomplete,')');
PREPARE _exec FROM @exec;
EXECUTE _exec;

SET @incomplete := (SELECT total-complete FROM artwork_stats WHERE artwork_stats.section = _section);
UPDATE artwork_stats SET incomplete = @incomplete WHERE section = _section;
SELECT section,total,complete,incomplete FROM artwork_stats WHERE section = _section;
END $$ # END OF PROCEDURE

CALL get_artwork_stats(1);
CALL get_artwork_stats(2);
CALL get_artwork_stats(3);