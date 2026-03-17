DELIMITER $$

DROP PROCEDURE IF EXISTS available_accommodations$$

CREATE PROCEDURE available_accommodations(
    IN f_dst_id INT,
    IN f_check_in DATE,
    IN f_check_out DATE,
    IN f_rooms_needed INT,
    IN change_method BOOLEAN,
    OUT f_first_acc_id INT
)
BEGIN
    DECLARE v_dst_count INT;
    DECLARE v_max_rooms INT;

    SET f_first_acc_id = NULL;


    IF f_check_in >= f_check_out THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Σφάλμα: Η αναχώρηση πρέπει να είναι μετά την άφιξη.';
END IF;

    IF f_rooms_needed <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Σφάλμα: Απαιτείται τουλάχιστον 1 δωμάτιο.';
END IF;

SELECT COUNT(*) INTO v_dst_count FROM destination WHERE dst_id = f_dst_id;
IF v_dst_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Σφάλμα: Ο προορισμός δεν υπάρχει.';
END IF;

SELECT MAX(acc_total_rooms) INTO v_max_rooms
FROM accommodation
WHERE acc_dst_id = f_dst_id
   OR acc_dst_id IN (SELECT dst_id FROM destination WHERE dst_location = f_dst_id);


IF IFNULL(v_max_rooms, 0) < f_rooms_needed THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Σφάλμα: Ο αριθμός δωματίων υπερβαίνει τη μέγιστη χωρητικότητα των καταλυμάτων του προορισμού.';
END IF;
SELECT a.acc_id INTO f_first_acc_id
FROM accommodation a
         LEFT JOIN trip_accommodation ta
                   ON a.acc_id = ta.re_acc_id
                       AND (ta.re_check_in < f_check_out AND ta.re_check_out > f_check_in)
WHERE (a.acc_dst_id = f_dst_id OR a.acc_dst_id IN (SELECT dst_id FROM destination WHERE dst_location = f_dst_id))
  AND a.acc_status = 'AVAILABLE'
GROUP BY a.acc_id, a.acc_total_rooms, a.acc_price_per_night2, a.acc_stars, a.acc_rating
HAVING (a.acc_total_rooms - IFNULL(SUM(ta.re_rooms), 0)) >= f_rooms_needed
ORDER BY a.acc_price_per_night2 ASC, a.acc_stars DESC, a.acc_rating DESC
    LIMIT 1;


IF change_method = TRUE THEN
SELECT
    a.acc_name AS 'Επωνυμία',
    a.acc_type AS 'Τύπος',
    CONCAT(a.acc_street, ' ', a.acc_number, ', ', a.acc_city) AS 'Διεύθυνση',
    a.acc_phone AS 'Τηλέφωνο',
    a.acc_stars AS 'Αστέρια',
    a.acc_rating AS 'Βαθμολογία',
    a.acc_price_per_night2 AS 'Τιμή Δωματίου',

    CONCAT_WS(', ',
              IF(a.acc_wifi=1, 'WiFi', NULL),
              IF(a.acc_restaurant_bar=1, 'Bar/Rest', NULL),
              IF(a.acc_ac=1, 'A/C', NULL),
              IF(a.acc_accesibility=1, 'Accessibility', NULL)
    ) AS 'Παροχές',
    (a.acc_total_rooms - IFNULL(SUM(ta.re_rooms), 0)) AS 'Διαθέσιμα'
FROM accommodation a
         LEFT JOIN trip_accommodation ta
                   ON a.acc_id = ta.re_acc_id
                       AND (ta.re_check_in < f_check_out AND ta.re_check_out > f_check_in)
WHERE (a.acc_dst_id = f_dst_id OR a.acc_dst_id IN (SELECT dst_id FROM destination WHERE dst_location = f_dst_id))
  AND a.acc_status = 'AVAILABLE'

GROUP BY a.acc_id, a.acc_name, a.acc_type, a.acc_street, a.acc_number, a.acc_city,
         a.acc_phone, a.acc_stars, a.acc_rating, a.acc_price_per_night2,
         a.acc_wifi, a.acc_restaurant_bar, a.acc_ac, a.acc_accesibility, a.acc_total_rooms
HAVING (a.acc_total_rooms - IFNULL(SUM(ta.re_rooms), 0)) >= f_rooms_needed
ORDER BY a.acc_price_per_night2 ASC, a.acc_stars DESC, a.acc_rating DESC;
END IF;
END$$
DELIMITER ;

ALTER TABLE trip_accommodation
    ADD COLUMN re_nights INT(11) DEFAULT 0 AFTER re_rooms,
    ADD COLUMN re_total_cost DECIMAL(10,2) DEFAULT 0.00 AFTER re_nights;




DROP TRIGGER IF EXISTS trip_calculate;
DELIMITER $$
CREATE TRIGGER trip_calculate
    BEFORE INSERT ON trip_accommodation
    FOR EACH ROW
BEGIN
    DECLARE price_per_night DECIMAL(10,2);
    SET NEW.re_nights=DATEDIFF(NEW.re_check_out, NEW.re_check_in);
    IF NEW.re_nights<=0 THEN
        SET NEW.re_nights=1;
end if;

SELECT acc_price_per_night2 INTO price_per_night
FROM accommodation
WHERE acc_id=NEW.re_acc_id;

SET NEW.re_total_cost=NEW.re_nights*price_per_night*NEW.re_rooms;
END$$
DELIMITER ;


DELIMITER $$

DROP PROCEDURE IF EXISTS book_trip_accommodation;

CREATE PROCEDURE book_trip_accommodation(IN p_trip_id INT)
BEGIN

    DECLARE done INT DEFAULT FALSE;
    DECLARE v_dst_id INT;
    DECLARE v_arrival DATETIME;
    DECLARE v_departure DATETIME;


    DECLARE v_acc_id INT;
    DECLARE v_rooms_needed INT DEFAULT 1;


    DECLARE v_error_found BOOLEAN DEFAULT FALSE;
    DECLARE v_error_msg VARCHAR(255);
    DECLARE v_dest_count INT DEFAULT 0;

    DECLARE cur_trip_destinations CURSOR FOR
SELECT to_dst_id, to_arrival, to_departure
FROM travel_to
WHERE to_tr_id = p_trip_id
ORDER BY to_arrival ASC;


DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

START TRANSACTION;

OPEN cur_trip_destinations;

read_loop: LOOP
        FETCH cur_trip_destinations INTO v_dst_id, v_arrival, v_departure;

        IF done THEN
            LEAVE read_loop;
END IF;
        SET v_dest_count = v_dest_count + 1;

        SET v_acc_id = NULL;

CALL available_accommodations(
                v_dst_id,
                DATE(v_arrival),
                DATE(v_departure),
                v_rooms_needed,
                FALSE,
                v_acc_id
             );


IF v_acc_id IS NULL THEN

            SET v_error_found = TRUE;
            SET v_error_msg = CONCAT('Δεν βρέθηκε διαθέσιμο κατάλυμα για τον προορισμό με ID: ', v_dst_id);
            LEAVE read_loop; -- Σπάμε το loop αμέσως
ELSE

            INSERT INTO trip_accommodation (re_trip_id, re_acc_id, re_check_in, re_check_out, re_rooms)
            VALUES (p_trip_id, v_acc_id, DATE(v_arrival), DATE(v_departure), v_rooms_needed);
END IF;

END LOOP;

CLOSE cur_trip_destinations;
IF v_dest_count = 0 THEN
        SET v_error_found = TRUE;
        SET v_error_msg = CONCAT('Το ταξίδι με ID ', p_trip_id, ' δεν έχει προορισμο.');
END IF;

    IF v_error_found = TRUE THEN

        ROLLBACK;

SELECT v_error_msg AS 'Αποτέλεσμα Κράτησης';

ELSE

        COMMIT;

SELECT 'Επιτυχησ κρατηση' AS 'Αποτέλεσμα Κράτησης';

SELECT
    a.acc_name AS 'Επωνυμία',
    ta.re_check_in AS 'Άφιξη',
    ta.re_check_out AS 'Αναχώρηση',
    ta.re_nights AS 'Διανυκτερεύσεις',
    ta.re_total_cost AS 'Κόστος'
FROM trip_accommodation ta
         JOIN accommodation a ON ta.re_acc_id = a.acc_id
WHERE ta.re_trip_id = p_trip_id
ORDER BY ta.re_check_in ASC;

SELECT SUM(re_total_cost) AS 'Συνολικό Κόστος Διαμονής Ταξιδιού'
FROM trip_accommodation
WHERE re_trip_id = p_trip_id;
END IF;

END$$
DELIMITER ;

INSERT INTO destination (dst_id, dst_name, dst_rtype, dst_language_code)
VALUES (9999, 'Prague', 'ABROAD', 'EN');

INSERT INTO accommodation (acc_name, acc_type, acc_stars, acc_status, acc_inactive, acc_street, acc_number, acc_city, acc_zipcode, acc_phone, acc_email, acc_total_rooms, acc_price_per_night2, acc_dst_id)
VALUES ('Closed Hotel', 'HOTEL', 3, 'UNAVAILABLE', 'RENOVATION', 'Prague 5', 1, 'Prague', '00000', '000', 'test@mail.com', 50, 100.00, 9999);


INSERT INTO trip (tr_departure, tr_return, tr_maxseats, tr_cost_adult, tr_br_code, tr_gui_AT, tr_drv_AT)
VALUES ('2029-01-01', '2029-01-10', 50, 100, 1, 'AE59631056', 'AP10263987');

SET @rollback_trip_id = LAST_INSERT_ID();

INSERT INTO travel_to (to_tr_id, to_dst_id, to_arrival, to_departure, to_sequence)
VALUES (@rollback_trip_id, 7, '2029-01-01', '2029-01-05', 1);


INSERT INTO travel_to (to_tr_id, to_dst_id, to_arrival, to_departure, to_sequence)
VALUES (@rollback_trip_id, 9999, '2029-01-05', '2029-01-10', 2);




DELIMITER $
CREATE PROCEDURE travel_history_records( )
BEGIN

    DECLARE i INT DEFAULT 1;
    DECLARE max_records INT DEFAULT 90000;

    DECLARE random_id INT;
    DECLARE random_departure DATETIME;
    DECLARE random_return DATETIME;
    DECLARE random_total_destinations INT;
    DECLARE random_total_customers INT;
    DECLARE random_total_profit DECIMAL(10,2);
    DECLARE random_days INT;

DELETE FROM travel_history;
SET autocommit = 0;

    WHILE i <= max_records DO
            #
            SET random_id = 1000000 + i;


            SET random_departure = DATE_ADD('2018-01-01', INTERVAL FLOOR(RAND() * 2920) DAY);

            SET random_days = 3 + FLOOR(RAND() * 13);
            SET random_return = DATE_ADD(random_departure, INTERVAL random_days DAY);

            SET random_total_destinations = 1 + FLOOR(RAND() * 10);

            SET random_total_customers = 5 + FLOOR(RAND() * 36);

            SET random_total_profit = random_total_customers * (500 + RAND() * 4500);
            SET random_total_profit = ROUND(random_total_profit , 2);

INSERT INTO travel_agency_2025.travel_history VALUES (
                                                         random_id,
                                                         random_departure,
                                                         random_return,
                                                         random_total_destinations,
                                                         random_total_customers,
                                                         random_total_profit
                                                     );

IF i % 1000 = 0 THEN
                COMMIT;
END IF;

            SET i = i + 1;
END WHILE;

COMMIT;
SET autocommit = 1;

END $

DELIMITER ;


DROP PROCEDURE IF EXISTS dba_login;

DELIMITER $$

CREATE PROCEDURE dba_login(IN dba_at CHAR(10))
BEGIN
    DECLARE dba_exists INT DEFAULT 0;
    #DECLARE dba_is_active INT DEFAULT 0;
    DECLARE end_date DATE;

    #Έλεγχος 1: Υπάρχει ο AT στη βάση;
SELECT COUNT(*) INTO dba_exists
FROM database_admin
WHERE dbadmin_AT = dba_at;

#Αν δεν υπάρχει
    IF dba_exists = 0 THEN
SELECT CONCAT('ERROR: AT "', dba_at, '" DOES NOT EXIST IN THE BASE!') AS 'RESULT';

ELSE
        #Έλεγχος 2: Είναι ενεργός;
SELECT dba_end_date INTO end_date
FROM database_admin
WHERE dbadmin_AT = dba_at;

#Αν είναι ενεργός (end_date = NULL)
        IF end_date IS NULL THEN
            SET @username_dba_at = dba_at;
SELECT CONCAT('SUCCESSFUL CONNECTION WITH AT : ', dba_at) AS 'RESULT';

#Αν είναι ανενεργός
        ELSE
SELECT CONCAT('ERROR: DBA WITH AT "', dba_at, '" IS NOT ACTIVE ANYMORE (END DATE: ', end_date, ')') AS 'RESULT';
END IF;
END IF;
END$$

DELIMITER ;




DROP PROCEDURE IF EXISTS get_dates_by_destination_count;

DELIMITER $

CREATE PROCEDURE get_dates_by_destination_count(
    IN destination_count INT
)
BEGIN
    # Έλεγχος ορθότητας
    IF destination_count < 1 OR destination_count > 10 THEN
SELECT 'ERROR: NUMBER OF DESTINATIONS MUST BE BETWEEN 1 AND 10!' AS 'RESULT';
ELSE
        # Εύρεση ημερομηνιών
SELECT
    th_departure_date AS 'DEPARTURE DATE',
    th_return_date AS 'RETURN DATE',
    th_total_destinations AS 'NUMBER OF DESTINATIONS',
    th_total_customers AS 'NUMBER OF CUSTOMERS ',
    th_total_profit AS 'INCOME'
FROM travel_history
WHERE th_total_destinations = destination_count
ORDER BY th_departure_date
    LIMIT 50;

SELECT
    destination_count AS 'DESTINATIONS',
    COUNT(*) AS 'TOTAL TRIPS',
    SUM(th_total_profit) AS 'TOTAL INCOME'
FROM travel_history
WHERE th_total_destinations = destination_count;
END IF;
END$

DELIMITER ;


DROP PROCEDURE IF EXISTS get_total_profit_by_dates;

DELIMITER $

CREATE PROCEDURE get_total_profit_by_dates(IN start_date DATE, IN end_date DATE)
BEGIN
    #Έλεγχος ορθότητας ημερομηνιών
    IF start_date > end_date THEN
SELECT 'ERROR: Departure date must be before return date!' AS 'RESULT';
ELSE
        #Υπολογισμός συνολικών εσόδων
SELECT
    start_date AS 'FROM',
    end_date AS 'UNTIL',
    COUNT(*) AS 'NUMBER OF TRIPS',
    SUM(th_total_profit) AS 'TOTAL INCOME',
    ROUND(AVG(th_total_profit), 2) AS 'AVERAGE INCOME'
FROM travel_history
WHERE th_departure_date BETWEEN start_date AND end_date;
END IF;
END$

DELIMITER ;


DROP PROCEDURE IF EXISTS vehicle_assignment;
DELIMITER $
CREATE PROCEDURE vehicle_assignment(IN tr_id_par INT,IN veh_id_par INT,IN veh_kilometers_par INT )
BEGIN
    DECLARE veh_status_temp VARCHAR(20);
    DECLARE veh_capacity_temp  INT(2);
    DECLARE veh_type_temp VARCHAR(20);
    DECLARE veh_branch_temp INT;

    DECLARE driver_at_temp CHAR(10);
    DECLARE driver_license_temp ENUM('A','B','C','D');
    DECLARE trip_departure_temp DATETIME;
    DECLARE trip_return_temp DATETIME;
    DECLARE trip_branch_temp INT;

    DECLARE customers_count INT;
    DECLARE overlaping_trips INT;

    -- stoixeia oximatos
    SELECT veh_status,veh_capacity,veh_type,veh_br_code
    INTO veh_status_temp,veh_capacity_temp,veh_type_temp,veh_branch_temp
    FROM vehicle WHERE veh_id=veh_id_par;

    -- stoixeia driver kai trip
    SELECT tr_drv_AT, tr_departure, tr_return,tr_br_code
    INTO driver_at_temp,trip_departure_temp,trip_return_temp,trip_branch_temp
    FROM trip WHERE tr_id = tr_id_par;

    -- driver's license
    SELECT drv_licence INTO driver_license_temp
    FROM driver WHERE drv_AT = driver_at_temp;

    --  Kratiseis taksidiou
    SELECT COUNT(*) INTO customers_count
    FROM reservation WHERE res_tr_id=tr_id_par AND res_status != 'CANCELLED';


    -- Elegxoi
    IF veh_branch_temp != trip_branch_temp
    THEN SELECT 'Failure, this vehicle does not belong in the branch organising the trip.' AS message;
    ELSEIF veh_status_temp != 'AVAILABLE'
    THEN SELECT 'This vehicle is not available at the moment.' AS message;
    ELSEIF veh_capacity_temp < customers_count
    THEN SELECT 'Not enough capacity in the vehicle.' AS message;
    ELSEIF ((veh_type_temp = 'BUS' OR veh_type_temp = 'MINI BUS')AND (driver_license_temp != 'C' AND driver_license_temp !='D') )
    THEN SELECT 'Failure. The driver has not the required license for this type of vehicle.' AS message;
        -- Xroniki epikalipsi
    ELSE
        SELECT COUNT(*) INTO overlaping_trips
        FROM trip WHERE tr_veh_id = veh_id_par
                    AND tr_id != tr_id_par
                    AND (tr_departure< trip_return_temp AND tr_return > trip_departure_temp );

        IF overlaping_trips > 0 THEN
            SELECT 'The vehicle is assigned in another trip for this date' AS message;

        ELSE
            UPDATE vehicle
            SET veh_kilometers = veh_kilometers_par,
                veh_status = 'IN USE'
            WHERE veh_id = veh_id_par;

            UPDATE trip
            SET tr_veh_id = veh_id_par
            WHERE tr_id = tr_id_par;

            SELECT 'Vehicle assigned to this trip successfully.' AS message;
        END IF;

    END IF ;

END $
DELIMITER ;

DROP PROCEDURE IF EXISTS branchFinancialStatus;
DELIMITER $$
CREATE PROCEDURE branchFinancialStatus(IN br_code_par INT,OUT income DECIMAL(10,2), OUT expenses DECIMAL(10,2),OUT profiPercentage DECIMAL(10,2))
BEGIN

    DECLARE brcount INT;
    SELECT COUNT(*) INTO brcount FROM branch WHERE br_code =br_code_par;
    IF brcount = 0 THEN
        SET income=NULL;
        SET expenses=NULL;
        SET profiPercentage=NULL;
    END IF;


    SELECT SUM(res_total_cost) INTO income FROM reservation INNER JOIN trip ON res_tr_id=tr_id
    WHERE tr_br_code=br_code_par;

    SELECT SUM(wrk_salary) INTO expenses FROM worker INNER JOIN branch ON wrk_br_code = br_code
    WHERE br_code=br_code_par;


    SET profiPercentage = (income - expenses)/expenses;
END $$
DELIMITER ;


SELECT wrk_AT,wrk_br_code,wrk_salary FROM worker WHERE wrk_AT='XY32145698';



CALL branchFinancialStatus(5,@income4,@expenses4,@profit4);

SELECT @income4,@expenses4,@profit4;


