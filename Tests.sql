# Test fonction monstres_en_vie()
#Arrange
UPDATE Monstre SET point_vie = 0 WHERE id_monstre = 11;
UPDATE Monstre SET point_vie = 0 WHERE id_monstre = 15;

SELECT id_monstre, point_vie, id_salle FROM Monstre
INNER JOIN Affectation_salle ON id_monstre = monstre
INNER JOIN Salle ON salle = id_salle
	WHERE (id_salle = 1) AND
		('1082-06-26 04:00:00' BETWEEN debut_affectation AND fin_affectation);

#Assert
SELECT monstres_en_vie(1, '1082-06-26 04:00:00') AS resultat;

# Test fonction aventuriers_en_vie()
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

# Test Trigger validation_coffre_update(masse)
#etape 1
SELECT coffre, objet, quantite, masse FROM Ligne_coffre
INNER JOIN Objet ON id_objet = objet
	WHERE coffre = 1 OR coffre = 2;

#etape 2
#Try{
-- TRANSACTION;
UPDATE Ligne_coffre SET quantite = 400
	WHERE coffre = 1 AND objet = 2;
#Catch{
-- ROLLBACK;
    
UPDATE Ligne_coffre SET quantite = 3
	WHERE coffre = 1 AND objet = 2;

#etape 3
SELECT coffre, group_concat(objet), group_concat(quantite), group_concat(masse), sum(quantite*masse) FROM Objet
INNER JOIN Ligne_coffre ON id_objet = objet
	WHERE coffre = 1 OR coffre = 2
GROUP BY coffre;

SELECT @masse, @quantite, @coffre, @retour;

SELECT
	sum(quantite*masse)
FROM
	Ligne_coffre
	INNER JOIN Objet ON objet = id_objet
WHERE
	coffre = 1;
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        