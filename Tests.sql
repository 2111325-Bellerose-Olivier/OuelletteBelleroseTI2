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

