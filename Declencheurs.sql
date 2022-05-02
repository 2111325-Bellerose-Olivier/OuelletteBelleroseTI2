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


# Validation Coffre 1 : update
DROP TRIGGER IF EXISTS validation_coffre_update;
DELIMITER $$
CREATE TRIGGER validation_coffre_update BEFORE UPDATE ON Ligne_coffre FOR EACH ROW
BEGIN
	DECLARE _quantite_totale INTEGER;
	DECLARE _masse INTEGER;
    
    SET _quantite_totale = (
			SELECT
				sum(quantite)
			FROM
				Ligne_coffre
			WHERE
				coffre = NEW.coffre
	);
    
    SET _masse = (
			SELECT
				sum(quantite*masse)
			FROM
				Ligne_coffre
                INNER JOIN Objet ON objet = id_objet
			WHERE
				coffre = NEW.coffre
	);
    
    #quantite
	IF _quantite_totale > 15 THEN
		SIGNAL SQLSTATE '02005' SET MESSAGE_TEXT = 'la quantite totale d\'objets depasse 15.';
	END IF;
	#masse
	IF _masse > 300 THEN
		SIGNAL SQLSTATE '02004' SET MESSAGE_TEXT = 'la masse totale du coffre depasse 300.';
		SET @masse = _masse;
        SET @quantite = NEW.quantite;
        SET @coffre = NEW.coffre;
	END IF;
    
END; $$
DELIMITER ;

# Validation Coffre 2 : insert
DELIMITER $$
CREATE TRIGGER validation_coffre_insert BEFORE INSERT ON Ligne_coffre FOR EACH ROW
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










