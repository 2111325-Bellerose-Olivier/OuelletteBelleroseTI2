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


/**
# Validation Coffre 1 : update
*
*@Dependencies Ligne_coffre
*/
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

/**
# Declencheur mortalite : update
*
*@Dependencies Affectation_salle
*/
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

/**
# Declencher éléments opposé:  insert
*
*@Dependencies Affectation_salle, Elementaire
*/
DROP TRIGGER IF EXISTS elements_oppose;
DELIMITER $$
CREATE TRIGGER elements_oppose AFTER INSERT ON Affectation_salle FOR EACH ROW
BEGIN
	DECLARE _salle INT;
    DECLARE _temps_debut DATETIME;
    DECLARE _temps_fin DATETIME;
    DECLARE _verification INT;
    
    SET _salle = (SELECT salle FROM Affectation_salle);
    SET _temps_debut = (SELECT debut_affectation FROM Affectation_salle);
    SET _temps_fin = (SELECT fin_affectation FROM Affectation_salle);
    
    SET _verification = (SELECT elements_opposes_piece(_salle,_temps_debut,_temps_fin));
    
    IF _verification = 1 THEN
		SIGNAL SQLSTATE '01002' SET MESSAGE_TEXT = 'Il y a un élémentaire d\'eau et de feu d\'assigné à la même salle.';
	END IF;
    
END $$
DELIMITER ;

/**
* déclencheur hashage
* 
*@Dependencies Coffre_tresor
*/
DROP TRIGGER IF EXISTS hashage;
DELIMITER $$
CREATE TRIGGER hashage BEFORE INSERT ON Coffre_tresor FOR EACH ROW
BEGIN
	DECLARE _code CHAR(64);
    
    SET _code = (SELECT code_secret FROM Coffre_tresor);

     SET NEW.code_secret = SHA2(_code,256);
    
END $$
DELIMITER ;

         








