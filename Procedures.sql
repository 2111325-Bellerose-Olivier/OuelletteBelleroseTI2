/**
* 1. Procédure intimidation
*@param _id_salle l'identifiant de la salle choisi
*@param _id_espedition l'identifiant de l'expedition
*@return intimidation BOOL qui détermine si les monstres sont intimidé ou non
*/
DELIMITER $$
CREATE PROCEDURE intimidation(IN _id_salle INT,IN _id_expedition INT,OUT intimidation BOOL)
BEGIN
	DECLARE exp_monstre INT;
    DECLARE exp_aventurier INT;
    DECLARE _intim INT;
    
    SET exp_monstre = (SELECT experience FROM Monstre INNER JOIN (Affectation_salle INNER JOIN Salle
							ON salle = id_salle) ON id_monstre = monstre
                            WHERE id_salle = _id_salle
							ORDER BY experience DESC LIMIT 1);
                            
	SET exp_aventurier = (SELECT niveau FROM Aventurier NATURAL JOIN (Expedition_aventurier NATURAL JOIN Expedition)
								WHERE id_expedition = _id_expedition
                                ORDER BY niveau DESC LIMIT 1);
                                
	SET _intim = ((exp_monstre/10)-exp_aventurier);
                                
	IF _intim > 3 THEN
		SET intimidation = 1;
	ELSE
		SET intimidation = 0;
	END IF;
                            
END $$
DELIMITER ;

/**
* 2. Malédiction D'affaiblissement
*@param _id_salle identifiant de la salle
*@param _id_exp identifiant de l'expédition
*/
DELIMITER $$
CREATE PROCEDURE malediction(IN _id_salle INT, IN _id_exp INT)
BEGIN
	DECLARE _debut_humanoid DATETIME;
    DECLARE _fin_humanoid DATETIME;
    DECLARE _debut_aventure DATETIME;
    DECLARE _fin_aventure DATETIME;
    
    SET _debut_humanoid = (SELECT debut_affectation FROM Salle INNER JOIN (Affectation_salle INNER JOIN (Monstre NATURAL JOIN Famille_monstre)
								ON monstre = id_monstre) ON id_salle = salle
                                WHERE id_salle = _id_salle AND id_famille = 1);
	SET _fin_humanoid = (SELECT fin_affectation FROM Salle INNER JOIN (Affectation_salle INNER JOIN (Monstre NATURAL JOIN Famille_monstre)
								ON monstre = id_monstre) ON id_salle = salle
                                WHERE id_salle = _id_salle AND id_famille = 1);
                                
	SET _debut_aventure = (SELECT depart FROM Expedition NATURAL JOIN (Expedition_aventure NATURAL JOIN Aventurier)
							WHERE id_expedition = _id_exp AND 
                            (nom LIKE 'Mage' OR nom LIKE 'Magicien' OR nom LIKE 'Enchenteu'
                            OR nom LIKE 'Magicienne' OR nom LIKE 'Enchenteuse'));
	SET _debut_aventure = (SELECT terminaison FROM Expedition NATURAL JOIN (Expedition_aventure NATURAL JOIN Aventurier)
							WHERE id_expedition = _id_exp AND 
                            (nom LIKE 'Mage' OR nom LIKE 'Magicien' OR nom LIKE 'Enchenteu'
                            OR nom LIKE 'Magicienne' OR nom LIKE 'Enchenteuse'));
                            
	IF (_debut_humanoid < _debut_aventure AND _fin_aventure > _debut_aventure) OR (_debut_humanoid < _debut_aventure AND _fin_aventure > _debut_aventure)
		THEN
		CALL affaiblissement_monstres(_id_salle, _debut_aventure);
	END IF;

END $$
DELIMITER ;

/**
* 5.EMBAUCHE
*@param _nom nom du monstre
*@_code code d'employe du monstre
*@_numero numéro d'assurence maladie du monstre
*@_nom_famille nom de la famille du monstre
*/
DELIMITER $$
CREATE PROCEDURE embauche(IN _nom VARCHAR(255),IN _code CHAR(4),IN _numero BLOB,IN _nom_famille VARCHAR(255))
BEGIN
	DECLARE _id_famille INT;
    SET _id_famille = (SELECT id_famille FROM Famille_monstre WHERE nom_famille LIKE _nom_famille);
    
    IF _id_famille IS NOT NULL THEN
		INSERT INTO Monstre (nom,code_employe,numero_ass_maladie,id_famille) VALUES
			(_nom,_code,_numero,_nom_famille);
	ELSE
		SIGNAL SQLSTATE '01003' SET MESSAGE_TEXT = 'la famille entré n\'exsiste pas.';
	END IF;
END $$
DELIMITER ;

/**
* 6. mort-vivant
*
*@param _nom nom de la famille
*@param _pv point de vie maximal
*@param _degat degat de base
*@param _soleil vulnérabilité au soleil
*@param _infectieux caractère infectieux du monstre
*/
DELIMITER $$
CREATE PROCEDURE mort_vivant (IN _nom VARCHAR(255),IN _pv INT,IN _degat INT,IN _soleil TINYINT,IN _infectieux TINYINT)
BEGIN
	INSERT INTO Famille_monstre (nom_famille,point_vie_maximal,degat_base) 
			VALUES (_nom,_pv,_degat);
	INSERT INTO Mort_vivant (vulnerable_soleil,infectieux)
			VALUES (_soleil,_infectieux);
END $$
DELIMITER ;

/** 3. combat
*
*@param _id_salle
*@param _id_expedition
*/
DELIMITER $$
CREATE PROCEDURE combat (IN _id_salle INT,IN _id_expedition INT) 
BEGIN
	DECLARE _moment_expedition DATETIME;
	DECLARE aventurier_degats INT;
    DECLARE monstre_degats INT;
    DECLARE aventurier_vie INT;
    DECLARE monstre_vie INT;
    
    SET _moment_expedition = (SELECT moment_visite FROM Visite_salle WHERE salle = _id_salle AND expedition = _id_expedition);
    
    WHILE aventurier_vie > 0 AND monstre_vie > 0 DO
		SET aventurier_degats = (SELECT sum(attaque) FROM Aventurier WHERE point_vie > 0);
        SET monstre_degats = (SELECT sum(attaque) FROM Monstre WHERE point_vie > 0);
        SET aventurier_vie = (SELECT sum(point_vie) FROM Aventurier);
        SET monstre_vie = (SELECT sum(point_vie) FROM Monstre);
		IF aventurier_vie > 0 THEN
			CALL infliger_dommage_monstre(_id_salle, _moment_expedition, aventurier_degats);
		END IF;
        IF monstre_vie > 0 THEN
			CALL infliger_dommage_aventurier(id_salle,_moment_expedition_monstre_degats);
		END IF;
    END WHILE;
    
    
	
END $$
DELIMITER ;

/**
*EXTRA. Pillage
*
*@param _id_salle
*@param _id_expedition
*/
DELIMITER $$
CREATE PROCEDURE pillage (IN _id_salle INT,IN _id_expedition INT)
BEGIN

END $$
DELIMITER ;

/**
*4. visite salle
*
*@param _id_salle identifiant de la salle visité
*@param _id_expe identifiant de l'expédition
*@param _moment_visite
*/
DELIMITER $$
CREATE PROCEDURE visite_salle (IN _id_salle INT, IN _id_expe INT, IN _moment_visite DATETIME)
BEGIN
	INSERT INTO Visite_salle (salle,expedition,moment_visite) 
		VALUES (_id_salle,_id_expe,_moment_visite);
	DECLARE _intimidation BOOL;
    SET _intimidation = intimidation(_id_salle, _id_expedition);
    DECLARE _vie_aventurier INT;
    SET _vie_aventurier = (SELECT sum(point_vie) FROM Aventurier);
    
    IF _intimidation = TRUE THEN
    CALL pillage(_id_salle,_id_expe);
    ELSE 
		IF _vie_aventurier > 0 THEN
		CALL pillage(_id_salle,_id_expe);
    END IF;

END $$
DELIMITER ;

