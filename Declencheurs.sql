/**
* 
* 
* 
*/
DROP FUNCTION IF EXISTS les_validations_coffre;
DELIMITER $$
CREATE FUNCTION les_validations_coffre() RETURNS INT CONTAINS SQL DETERMINISTIC
BEGIN
	
END $$
DELIMITER ;

# Validation Coffre 1 : insert
DELIMITER $$
CREATE TRIGGER validation_coffre_insert BEFORE INSERT ON Ligne_coffre FOR EACH ROW
BEGIN
	DECLARE _masse INTEGER;
    
    SET _masse = (
			SELECT
				sum(masse)
			FROM
				Objet
                INNER JOIN Coffre ON id_objet = objet
			WHERE
				coffre = NEW.coffre
	);
    
	#masse
    IF _masse > 350 THEN
		SIGNAL SQLSTATE '00000' SET MESSAGE_TEXT = 'la masse excede 350kg.';
	END IF;
	#quantite
	IF NEW.quantite > 15 THEN
		SIGNAL SQLSTATE '00000' SET MESSAGE_TEXT = 'la quantite totale d\'objets depasse 15.';
	END IF;
    
END; $$
DELIMITER ;

# Validation Coffre 2 : update
DELIMITER $$
CREATE TRIGGER validation_coffre_update BEFORE UPDATE ON Ligne_coffre FOR EACH ROW
BEGIN
	SELECT les_validations_coffre();
END; $$
DELIMITER ;


# Declencheur mortalite : update
DROP TRIGGER IF EXISTS declencheur_mortalite;
DELIMITER $$
CREATE TRIGGER declencheur_mortalite AFTER UPDATE ON Monstre FOR EACH ROW
BEGIN
	IF NEW.point_vie <= 0 THEN
		UPDATE Affectation_salle INNER JOIN Monstre ON monstre = id_monstre
		SET Affectation_salle.fin_affectation = now()
		WHERE
            point_vie = NEW.point_vie;
	END IF;

END; $$
DELIMITER ;





#etape 1
START TRANSACTION;

#etape 2
SELECT point_vie, id_monstre, fin_affectation
FROM Affectation_salle
INNER JOIN Monstre ON monstre = id_monstre;

#etape 3
UPDATE Monstre SET point_vie = 0
	WHERE id_monstre = 1;

#etape 4
SELECT point_vie, id_monstre, fin_affectation
FROM Affectation_salle
INNER JOIN Monstre ON monstre = id_monstre;

#etape 5
ROLLBACK;

















