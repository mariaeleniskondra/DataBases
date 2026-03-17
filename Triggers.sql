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



DROP TRIGGER IF EXISTS trigger_trip_insert;
DELIMITER $
CREATE TRIGGER trigger_trip_insert
    AFTER INSERT ON trip
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'INSERT', 'trip');
END$
DELIMITER ;


#UPDATE

DROP TRIGGER IF EXISTS trigger_trip_update;
DELIMITER $
CREATE TRIGGER trigger_trip_update
    AFTER UPDATE ON trip
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'UPDATE', 'trip');
END$
DELIMITER ;


#DELETE

DROP TRIGGER IF EXISTS trigger_trip_delete;
DELIMITER $
CREATE TRIGGER trigger_trip_delete
    AFTER DELETE ON trip
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'DELETE', 'trip');
END$
DELIMITER ;



#TRIGGERS GIA PINAKA : RESERVATION

#INSERT

DROP TRIGGER IF EXISTS trigger_reservation_insert;
DELIMITER $
CREATE TRIGGER trigger_reservation_insert
    AFTER INSERT ON reservation
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'INSERT', 'reservation');
END$
DELIMITER ;


#UPDATE

DROP TRIGGER IF EXISTS trigger_reservation_update;
DELIMITER $
CREATE TRIGGER trigger_reservation_update
    AFTER UPDATE ON reservation
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'UPDATE', 'reservation');
END$
DELIMITER ;


#DELETE

DROP TRIGGER IF EXISTS trigger_reservation_delete;
DELIMITER $
CREATE TRIGGER trigger_reservation_delete
    AFTER DELETE ON reservation
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'DELETE', 'reservation');
END$
DELIMITER ;



#TRIGGES GIA PINAKA: CUSTOMER

#INSERT

DROP TRIGGER IF EXISTS trigger_customer_insert;
DELIMITER $
CREATE TRIGGER trigger_customer_insert
    AFTER INSERT ON customer
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'INSERT', 'customer');
END$
DELIMITER ;


#UPDATE

DROP TRIGGER IF EXISTS trigger_customer_update;
DELIMITER $
CREATE TRIGGER trigger_customer_update
    AFTER UPDATE ON customer
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'UPDATE', 'customer');
END$
DELIMITER ;


#DELETE

DROP TRIGGER IF EXISTS trigger_customer_delete;
DELIMITER $
CREATE TRIGGER trigger_customer_delete
    AFTER DELETE ON customer
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'DELETE', 'customer');
END$
DELIMITER ;



#TRIGGERS GIA PINAKA: DESTINATION

#INSERT

DROP TRIGGER IF EXISTS trigger_destination_insert;
DELIMITER $
CREATE TRIGGER trigger_destination_insert
    AFTER INSERT ON destination
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'INSERT', 'destination');
END$
DELIMITER ;


#UPDATE

DROP TRIGGER IF EXISTS trigger_destination_update;
DELIMITER $
CREATE TRIGGER trigger_destination_update
    AFTER UPDATE ON destination
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'UPDATE', 'destination');
END$
DELIMITER ;


#DELETE

DROP TRIGGER IF EXISTS trigger_destination_delete;
DELIMITER $
CREATE TRIGGER trigger_destination_delete
    AFTER DELETE ON destination
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'DELETE', 'destination');
END$
DELIMITER ;



#TRIGGERS GIA PINAKA: ACCOMMODATION

#INSERT

DROP TRIGGER IF EXISTS trigger_accommodation_insert;
DELIMITER $
CREATE TRIGGER trigger_accommodation_insert
    AFTER INSERT ON accommodation
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'INSERT', 'accommodation');
END$
DELIMITER ;


#UPDATE

DROP TRIGGER IF EXISTS trigger_accommodation_update;
DELIMITER $
CREATE TRIGGER trigger_accommodation_update
    AFTER UPDATE ON accommodation
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'UPDATE', 'accommodation');
END$
DELIMITER ;


#DELETE

DROP TRIGGER IF EXISTS trigger_accommodation_delete;
DELIMITER $
CREATE TRIGGER trigger_accommodation_delete
    AFTER DELETE ON accommodation
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'DELETE', 'accommodation');
END$
DELIMITER ;



#TRIGGERS GIA PINAKA: TRIP ACCOMMODATION

#INSERT

DROP TRIGGER IF EXISTS trigger_trip_accommodation_insert;
DELIMITER $
CREATE TRIGGER trigger_trip_accommodation_insert
    AFTER INSERT ON trip_accommodation
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'INSERT', 'trip_accommodation');
END$
DELIMITER ;


#UPDATE

DROP TRIGGER IF EXISTS trigger_trip_accommodation_update;
DELIMITER $
CREATE TRIGGER trigger_trip_accommodation_update
    AFTER UPDATE ON trip_accommodation
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'UPDATE', 'trip_accommodation');
END$
DELIMITER ;


#DELETE

DROP TRIGGER IF EXISTS trigger_trip_accommodation_delete;
DELIMITER $
CREATE TRIGGER trigger_trip_accommodation_delete
    AFTER DELETE ON trip_accommodation
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'DELETE', 'trip_accommodation');
END$
DELIMITER ;



#TRIGGERS GIA PINAKA : VEHICLE

#INSERT

DROP TRIGGER IF EXISTS trigger_vehicle_insert;
DELIMITER $
CREATE TRIGGER trigger_vehicle_insert
    AFTER INSERT ON vehicle
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'INSERT', 'vehicle');
END$
DELIMITER ;


#UPDATE

DROP TRIGGER IF EXISTS trigger_vehicle_update;
DELIMITER $
CREATE TRIGGER trigger_vehicle_update
    AFTER UPDATE ON vehicle
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'UPDATE', 'vehicle');
END$
DELIMITER ;


#DELETE

DROP TRIGGER IF EXISTS trigger_vehicle_delete;
DELIMITER $
CREATE TRIGGER trigger_vehicle_delete
    AFTER DELETE ON vehicle
    FOR EACH ROW
BEGIN
    INSERT INTO log (log_date, log_time, log_dba_username, log_change_type, log_table)
    VALUES (CURDATE(), CURTIME(),IFNULL(@username_dba_at, 'UNKNOWN'), 'DELETE', 'vehicle');
END$
DELIMITER ;


DROP TRIGGER IF EXISTS salaryIncreaseCheck;
DELIMITER $$
CREATE TRIGGER salaryIncreaseCheck
    BEFORE UPDATE ON worker
    FOR EACH ROW
BEGIN
    DECLARE br_income DECIMAL(10,2);
    DECLARE br_expenses DECIMAL(10,2);
    DECLARE br_profit DECIMAL(10,2);
    DECLARE increasePercentagecheck DECIMAL(10,2);

    IF NEW.wrk_salary > OLD.wrk_salary THEN
        CALL branchFinancialStatus(NEW.wrk_br_code,br_income,br_expenses,br_profit);

        IF br_profit <0
        THEN SIGNAL SQLSTATE VALUE '45000'
            SET MESSAGE_TEXT ='Invalid salary increase, because the branch is not profitable at the moment.';
        END IF;

        IF br_profit>=0 THEN
            SET increasePercentagecheck = (NEW.wrk_salary-OLD.wrk_salary)/OLD.wrk_salary;
            IF increasePercentagecheck >0.02 THEN
                SIGNAL SQLSTATE VALUE '45000'
                    SET MESSAGE_TEXT ='Invalid salary increase.The increase exceeds the 2% limit.';
            END IF;
        END IF;


    END IF ;

END $$
