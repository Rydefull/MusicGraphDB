USE master;
GO
DROP DATABASE IF EXISTS MusicGraph;
GO
CREATE DATABASE MusicGraph;
GO

USE MusicGraph;
GO

-- Создание таблиц узлов
DROP TABLE IF EXISTS Bands;
CREATE TABLE Bands (
    ID INT PRIMARY KEY NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Genre VARCHAR(100) NOT NULL
) AS NODE;

DROP TABLE IF EXISTS Albums;
CREATE TABLE Albums (
    ID INT PRIMARY KEY NOT NULL,
    Title VARCHAR(100) NOT NULL,
    ReleaseYear INT NOT NULL
) AS NODE;

DROP TABLE IF EXISTS Members;
CREATE TABLE Members (
    ID INT PRIMARY KEY NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Instrument VARCHAR(100) NOT NULL
) AS NODE;

-- Вставка данных в таблицы узлов
INSERT INTO Bands (ID, Name, Genre)
VALUES 
(1, 'The Beatles', 'Rock'),
(2, 'Led Zeppelin', 'Rock'),
(3, 'Pink Floyd', 'Progressive Rock'),
(4, 'Metallica', 'Metal'),
(5, 'Nirvana', 'Grunge'),
(6, 'Radiohead', 'Alternative Rock'),
(7, 'The Rolling Stones', 'Rock'),
(8, 'Queen', 'Rock'),
(9, 'AC/DC', 'Hard Rock'),
(10, 'The Doors', 'Psychedelic Rock');

INSERT INTO Albums (ID, Title, ReleaseYear)
VALUES 
(1, 'Abbey Road', 1969),
(2, 'Led Zeppelin IV', 1971),
(3, 'The Dark Side of the Moon', 1973),
(4, 'Master of Puppets', 1986),
(5, 'Nevermind', 1991),
(6, 'OK Computer', 1997),
(7, 'Sticky Fingers', 1971),
(8, 'A Night at the Opera', 1975),
(9, 'Back in Black', 1980),
(10, 'The Doors', 1967);

INSERT INTO Members (ID, Name, Instrument)
VALUES 
(1, 'John Lennon', 'Vocals/Guitar'),
(2, 'Paul McCartney', 'Vocals/Bass'),
(3, 'George Harrison', 'Guitar'),
(4, 'Ringo Starr', 'Drums'),
(5, 'Robert Plant', 'Vocals'),
(6, 'Jimmy Page', 'Guitar'),
(7, 'John Paul Jones', 'Bass'),
(8, 'John Bonham', 'Drums'),
(9, 'David Gilmour', 'Guitar/Vocals'),
(10, 'Roger Waters', 'Bass/Vocals');

-- Создание таблиц рёбер
CREATE TABLE MemberOfBand AS EDGE;
CREATE TABLE ReleasedAlbum AS EDGE;
CREATE TABLE Influenced AS EDGE;

-- Ввод данных в таблицы рёбер
INSERT INTO MemberOfBand ($from_id, $to_id)
VALUES 
((SELECT $node_id FROM Members WHERE ID = 1), (SELECT $node_id FROM Bands WHERE ID = 1)),
((SELECT $node_id FROM Members WHERE ID = 2), (SELECT $node_id FROM Bands WHERE ID = 1)),
((SELECT $node_id FROM Members WHERE ID = 3), (SELECT $node_id FROM Bands WHERE ID = 1)),
((SELECT $node_id FROM Members WHERE ID = 4), (SELECT $node_id FROM Bands WHERE ID = 1)),
((SELECT $node_id FROM Members WHERE ID = 5), (SELECT $node_id FROM Bands WHERE ID = 2)),
((SELECT $node_id FROM Members WHERE ID = 6), (SELECT $node_id FROM Bands WHERE ID = 2)),
((SELECT $node_id FROM Members WHERE ID = 7), (SELECT $node_id FROM Bands WHERE ID = 2)),
((SELECT $node_id FROM Members WHERE ID = 8), (SELECT $node_id FROM Bands WHERE ID = 2)),
((SELECT $node_id FROM Members WHERE ID = 9), (SELECT $node_id FROM Bands WHERE ID = 3)),
((SELECT $node_id FROM Members WHERE ID = 10), (SELECT $node_id FROM Bands WHERE ID = 3));

INSERT INTO ReleasedAlbum ($from_id, $to_id)
VALUES 
((SELECT $node_id FROM Bands WHERE ID = 1), (SELECT $node_id FROM Albums WHERE ID = 1)),
((SELECT $node_id FROM Bands WHERE ID = 2), (SELECT $node_id FROM Albums WHERE ID = 2)),
((SELECT $node_id FROM Bands WHERE ID = 3), (SELECT $node_id FROM Albums WHERE ID = 3)),
((SELECT $node_id FROM Bands WHERE ID = 4), (SELECT $node_id FROM Albums WHERE ID = 4)),
((SELECT $node_id FROM Bands WHERE ID = 5), (SELECT $node_id FROM Albums WHERE ID = 5)),
((SELECT $node_id FROM Bands WHERE ID = 6), (SELECT $node_id FROM Albums WHERE ID = 6)),
((SELECT $node_id FROM Bands WHERE ID = 7), (SELECT $node_id FROM Albums WHERE ID = 7)),
((SELECT $node_id FROM Bands WHERE ID = 8), (SELECT $node_id FROM Albums WHERE ID = 8)),
((SELECT $node_id FROM Bands WHERE ID = 9), (SELECT $node_id FROM Albums WHERE ID = 9)),
((SELECT $node_id FROM Bands WHERE ID = 10), (SELECT $node_id FROM Albums WHERE ID = 10));

INSERT INTO Influenced ($from_id, $to_id)
VALUES 
((SELECT $node_id FROM Bands WHERE ID = 1), (SELECT $node_id FROM Bands WHERE ID = 4)),
((SELECT $node_id FROM Bands WHERE ID = 2), (SELECT $node_id FROM Bands WHERE ID = 4)),
((SELECT $node_id FROM Bands WHERE ID = 3), (SELECT $node_id FROM Bands WHERE ID = 5)),
((SELECT $node_id FROM Bands WHERE ID = 4), (SELECT $node_id FROM Bands WHERE ID = 6)),
((SELECT $node_id FROM Bands WHERE ID = 5), (SELECT $node_id FROM Bands WHERE ID = 6));


--------------------------------Match---------------------

-- 1. Найти всех участников группы 'The Beatles'
SELECT m.Name, m.Instrument
FROM Members AS m, MemberOfBand AS mb, Bands AS b
WHERE MATCH(m-(mb)->b) AND b.Name = 'The Beatles';

-- 2. Найти все альбомы, выпущенные группой 'Pink Floyd'
SELECT a.Title, a.ReleaseYear
FROM Albums AS a, ReleasedAlbum AS ra, Bands AS b
WHERE MATCH(b-(ra)->a) AND b.Name = 'Pink Floyd';

-- 3. Найти все группы, на которые оказала влияние группа 'The Beatles'
SELECT b2.Name
FROM Bands AS b1, Influenced AS inf, Bands AS b2
WHERE MATCH(b1-(inf)->b2) AND b1.Name = 'The Beatles';

-- 4. Найти все группы и их альбомы, выпущенные в 1971 году
SELECT b.Name, a.Title
FROM Bands AS b, ReleasedAlbum AS ra, Albums AS a
WHERE MATCH(b-(ra)->a) AND a.ReleaseYear = 1971;

-- 5. Найти всех участников групп, играющих в жанре 'Rock'
SELECT m.Name, m.Instrument, b.Name AS Band
FROM Members AS m, MemberOfBand AS mb, Bands AS b
WHERE MATCH(m-(mb)->b) AND b.Genre = 'Rock';


------------------Shortest_path------------------

SELECT a1.Title AS Album1, a2.Title AS Album2
FROM Albums AS a1
	, ReleasedAlbum AS r1
	, Bands AS b1
	, ReleasedAlbum AS r2
	, Bands AS b2
	, Albums AS a2
WHERE MATCH(SHORTEST_PATH((a1)-(r1)->(b1)<-(r2)-(a2)))
	AND a1.Title = 'Abbey Road'
	AND a2.Title = 'OK Computer';


--------------Настройки для power bi------------

SELECT @@servername --Rydefull\SQLEXPRESS

---Название базы данных: MusicGraph

---Скрипт для графа---

USE MusicGraph;
GO

SELECT B1.ID AS IdFirst
    , B1.Name AS First
    , CONCAT(N'band', B1.ID) AS [First image name]
    , B2.ID AS IdSecond
    , B2.Name AS Second
    , CONCAT(N'band', B2.ID) AS [Second image name]
FROM dbo.Bands AS B1
    , dbo.Influenced AS I
    , dbo.Bands AS B2
WHERE MATCH (B1-(I)->B2);

USE MusicGraph;
GO

SELECT B.ID AS IdFirst
    , B.Name AS First
    , CONCAT(N'band', B.ID) AS [First image name]
    , A.ID AS IdSecond
    , A.Title AS Second
    , CONCAT(N'album', A.ID) AS [Second image name]
    , A.ReleaseYear AS ReleaseYear
FROM dbo.Bands AS B
    , dbo.ReleasedAlbum AS R
    , dbo.Albums AS A
WHERE MATCH (B-(R)->A);

USE MusicGraph;
GO

SELECT M.ID AS IdFirst,
       M.Name AS First,
       CONCAT(N'member', M.ID) AS [First image name],
       B.ID AS IdSecond,
       B.Name AS Second,
       CONCAT(N'band', B.ID) AS [Second image name]
FROM dbo.Members AS M,
     dbo.MemberOfBand AS MOB,
     dbo.Bands AS B
WHERE MATCH (M-(MOB)->B);

