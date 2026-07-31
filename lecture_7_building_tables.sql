DROP TABLE IF EXISTS artist;

CREATE TABLE artist(
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY ,
    name VARCHAR(30) UNIQUE
);

DROP TABLE IF EXISTS album;

CREATE TABLE album(
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY ,
    title varchar(128) UNIQUE ,
    artist_id INTEGER REFERENCES artist(id) ON DELETE CASCADE

);




CREATE TABLE genre (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY ,
    name VARCHAR(30) UNIQUE

);


CREATE TABLE track (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY ,
    title VARCHAR(128) ,
    len INTEGER ,
    rating INTEGER ,
    count INTEGER ,
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE ,
    genre_id INTEGER REFERENCES genre(id) ON DELETE CASCADE ,
    UNIQUE (title , album_id)

);

SELECT * FROM genre;
select * from track;
SELECT * FROM artist;
SELECT * FROM album;



INSERT INTO artist (name)
VALUES
    ('Linkin Park'),
    ('Coldplay'),
    ('Adele');

INSERT INTO album (title, artist_id)
VALUES
    ('Meteora', 1),
    ('Hybrid Theory', 1),
    ('Parachutes', 2),
    ('25', 3);

INSERT INTO genre (name)
VALUES
    ('Rock'),
    ('Alternative Rock'),
    ('Pop');

INSERT INTO track (
    title,
    len,
    rating,
    count,
    album_id,
    genre_id
)
VALUES
    ('Numb', 185, 5, 1500, 1, 1),
    ('Faint', 162, 5, 1200, 1, 2),
    ('In the End', 216, 5, 2000, 2, 2),
    ('Yellow', 269, 5, 1800, 3, 2),
    ('Hello', 295, 5, 2500, 4, 3),
    ('Send My Love', 223, 4, 1300, 4, 3);


SELECT
    album.title,
    artist.name
FROM album
JOIN artist ON album.artist_id = artist.id;


SELECT
    track.title as track ,
    album.title as album ,
    artist.name as artist ,
    genre.name as genre
FROM track
JOIN album
    ON track.album_id = album.id
JOIN genre
    ON track.genre_id = genre.id
JOIN artist
    ON album.artist_id = artist.id;