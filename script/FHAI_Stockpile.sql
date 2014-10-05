CREATE OR REPLACE FUNCTION makestockpile(avgDistance integer)
  RETURNS integer AS
$BODY$
DECLARE
	qty int;
	oldpossibleStockLocs int := 0;
	newpossibleStockLocs int := 0;
	currentSPavg real := 0;
	currentArrlen int := 0;
	currentSPlocs integer[] := '{}';
	currentSPwh int := 0;
	tempSPavg real := 0;
	tempArrlen int := 0;
	tempSPlocs integer[] := '{}';
	flocs RECORD;
	tlocs RECORD;
BEGIN	
	ALTER TABLE roadnw DROP COLUMN serviced RESTRICT;
	ALTER TABLE roadnw ADD COLUMN serviced varchar(5);

	UPDATE roadnw SET serviced = NULL, traverse = NULL;

	LOOP
		oldpossibleStockLocs := oldpossibleStockLocs + 1;
		
		FOR flocs IN SELECT DISTINCT fromloc FROM roadnw WHERE serviced IS NULL LOOP
			FOR tlocs IN SELECT toloc, kms FROM roadnw WHERE fromloc = flocs.fromloc AND serviced IS NULL ORDER BY kms LOOP
				IF (((tempSPavg * tempArrlen) + tlocs.kms) / (tempArrlen + 1) <= avgDistance) THEN
					tempSPavg := ((tempSPavg * tempArrlen) + tlocs.kms) / (tempArrlen + 1);
					tempArrlen := tempArrlen + 1;
					tempSPlocs := array_append(tempSPlocs, tlocs.toloc);
				ELSE
					EXIT;
				END IF;
			END LOOP;			
			IF ((tempArrlen > currentArrlen) OR (tempArrlen = currentArrlen AND tempSPavg > currentSPavg)) THEN
				currentSPavg := tempSPavg;
				currentSPlocs := tempSPlocs;
				currentSPwh := flocs.fromloc;
				currentArrlen := tempArrlen;           
			END IF;
			tempSPavg := 0;
			tempArrlen := 0;
			tempSPlocs := '{}';  
			
		END LOOP;

		EXIT WHEN currentSPlocs = '{}';
		
		FOR thistoloc in 1 .. array_upper(currentSPlocs, 1) LOOP
		    UPDATE roadnw SET serviced = 'YES', traverse = oldpossibleStockLocs WHERE serviced IS NULL AND fromloc = currentSPwh AND toloc = currentSPlocs[thistoloc];
		    UPDATE roadnw SET serviced = 'NO' WHERE serviced IS NULL AND (fromloc = currentSPlocs[thistoloc] OR toloc = currentSPlocs[thistoloc]);
		END LOOP;   
		
		UPDATE roadnw SET serviced = 'NO' WHERE serviced IS NULL AND toloc = currentSPwh;

		currentSPavg := 0;
		currentSPlocs := '{}';
		currentSPwh := 0;
		currentArrlen := 0;
	END LOOP;

	RETURN newpossibleStockLocs;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

SELECT makestockpile(100)

SELECT fromloc, toloc, kms, traverse, serviced FROM roadnw WHERE serviced = 'YES'
UNION ALL
SELECT DISTINCT fromloc, fromloc, 0, (SELECT MAX(traverse) FROM roadnw)+1, 'SELF' 
FROM roadnw
WHERE fromloc NOT IN (	SELECT DISTINCT fromloc FROM roadnw WHERE serviced = 'YES'
			UNION
			SELECT DISTINCT toloc FROM roadnw WHERE serviced = 'YES')
ORDER BY traverse, fromloc, kms

