# Validation Coffre 2 : insert
DROP TRIGGER IF EXISTS validation_coffre_insert;
DELIMITER $$
CREATE TRIGGER validation_coffre_insert BEFORE INSERT ON Ligne_coffre FOR EACH ROW
BEGIN
	DECLARE _quantite_totale INTEGER;
    DECLARE _masse_coffre INTEGER;
    DECLARE _masse_objet INTEGER;
	# Trouver quelle est la masse de l'objet ajouté
    SET _masse_objet = (
			SELECT
				masse
			FROM
				Ligne_coffre
                INNER JOIN Objet ON objet = id_objet
			WHERE
				coffre = NEW.coffre AND objet = NEW.objet
    );
    
    # Ajouter la quantite a la somme des quantite de la old.Table
    SET _quantite_totale = (
			SELECT
				sum(quantite)
			FROM
				Ligne_coffre
			WHERE
				coffre = NEW.coffre
	) + NEW.quantite;
    
    # Ajouter la masse a la somme des masses de la old.Table
    SET _masse_coffre = (
			SELECT
				sum(quantite*masse)
			FROM
				Ligne_coffre
                INNER JOIN Objet ON objet = id_objet
			WHERE
				coffre = NEW.coffre
	) + (NEW.quantite*_masse_objet);
    
    SET @quantite_totale = _quantite_totale;
    SET @masse_coffre = _masse_coffre;
    IF _quantite_totale>15 THEN
		SIGNAL SQLSTATE '02012' SET MESSAGE_TEXT = 'La somme des quantites des objets du coffre depasse 15.';
    END IF;
    IF _masse_coffre>300 THEN
		SIGNAL SQLSTATE '02013' SET MESSAGE_TEXT = 'La somme des masses dans le coffre depasse 300.';
    END IF;
END; $$
DELIMITER ;