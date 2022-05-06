/**
* Test fonction 1 : monstres_en_vie()
*/
START TRANSACTION;

#Les monstres Molustus et Nefustus sont vaincus.
UPDATE Monstre SET point_vie = 0 WHERE id_monstre = 11;
UPDATE Monstre SET point_vie = 0 WHERE id_monstre = 15;

SELECT id_monstre, point_vie, id_salle FROM Monstre
INNER JOIN Affectation_salle ON id_monstre = monstre
INNER JOIN Salle ON salle = id_salle
	WHERE (id_salle = 1) AND
		('1082-06-26 04:00:00' BETWEEN debut_affectation AND fin_affectation);

#Assert
SELECT monstres_en_vie(1, '1082-06-26 04:00:00') AS resultat;

ROLLBACK;

/**
* Test fonction 2 : aventuriers_en_vie()
*/
START TRANSACTION;

#Arrange
UPDATE Aventurier SET point_vie = 0 WHERE id_aventurier = 5;#8
UPDATE Aventurier SET point_vie = 0 WHERE id_aventurier = 9;#12
UPDATE Aventurier SET point_vie = 0 WHERE id_aventurier = 15;#7
-- SELECT id_aventurier, point_vie FROM Aventurier
-- NATURAL JOIN Expedition_aventurier
-- NATURAL JOIN Expedition
-- 	WHERE id_expedition = 1;

SELECT aventuriers_en_vie(1) AS 'aventuriers_en_vie() : 0';#Expected 0

UPDATE Aventurier SET point_vie = 1 WHERE id_aventurier = 5;

SELECT aventuriers_en_vie(1) AS 'aventuriers_en_vie() : 1';#Expected 1

ROLLBACK;

/**
* Test Trigger 1 : validation_coffre_update (quantite)
*/
START TRANSACTION;

#etape 1: un personnage regarde ce qu'il y a dans le coffre 1
SELECT coffre, objet, quantite, masse FROM Ligne_coffre
INNER JOIN Objet ON id_objet = objet
	WHERE coffre = 1;

#etape 2: un personnage essaie de rajouter 3 armures de nain de plus dans le coffre 1.
UPDATE Ligne_coffre SET quantite = 11
	WHERE coffre = 1 AND objet = 2;
#ca n'a pas fonctionne, ca ne rentre pas. Donc, il a mis 2 de plus a la place.
UPDATE Ligne_coffre SET quantite = 10
	WHERE coffre = 1 AND objet = 2;
    
#etape 3: le personnage vérifie le résultat.
SELECT coffre, objet, quantite, masse FROM Ligne_coffre
INNER JOIN Objet ON id_objet = objet
	WHERE coffre = 1;

ROLLBACK;

/**
* Test Trigger 2 : validation_coffre_update (masse)
*/
START TRANSACTION;

#etape 1: un personnage regarde ce qu'il y a dans le coffre 2
SELECT coffre, objet, quantite, masse FROM Ligne_coffre
INNER JOIN Objet ON id_objet = objet
	WHERE coffre = 2;

#etape 2: un personnage essaie de rajouter 5 forces de l'elephant de plus dans le coffre 2.
UPDATE Ligne_coffre SET quantite = 10#5 (+5)
	WHERE coffre = 2 AND objet = 13;
#ca ne marche pas. Donc, il a mis 2 de plus a la place.
UPDATE Ligne_coffre SET quantite = 7#5 (+2)
	WHERE coffre = 2 AND objet = 13;

#etape 3
SELECT coffre, group_concat(objet), group_concat(quantite), group_concat(masse), sum(quantite*masse) FROM Objet
INNER JOIN Ligne_coffre ON id_objet = objet
	WHERE coffre = 1
GROUP BY coffre;

SELECT
	sum(quantite*masse)
FROM
	Ligne_coffre
	INNER JOIN Objet ON objet = id_objet
WHERE
	coffre = 1;

ROLLBACK;

/**
* Test Trigger 3 : validation_coffre_insert (quantite)
*/       
START TRANSACTION;













ROLLBACK;