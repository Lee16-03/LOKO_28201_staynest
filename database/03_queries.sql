-- ============================================================
-- StayNest - CRUD queries for the business process
-- Run each statement with Ctrl+Enter, or the whole file with F5.
-- ============================================================
SET DEFINE OFF

-- ------------------------------------------------------------
-- 0. CHECK THAT THE DATA IS LOADED
-- ------------------------------------------------------------
SELECT 'ADMINISTRATORS' AS table_name, COUNT(*) AS total_rows FROM administrators
UNION ALL SELECT 'HOSTS',         COUNT(*) FROM hosts
UNION ALL SELECT 'GUESTS',        COUNT(*) FROM guests
UNION ALL SELECT 'PROPERTIES',    COUNT(*) FROM properties
UNION ALL SELECT 'BOOKINGS',      COUNT(*) FROM bookings
UNION ALL SELECT 'PAYMENTS',      COUNT(*) FROM payments
UNION ALL SELECT 'NOTIFICATIONS', COUNT(*) FROM notifications;

-- ============================================================
-- READ  (retrieve / consult information)
-- ============================================================

-- R1. The 10 guests
SELECT guest_id, full_name, email, phone_number, address
FROM guests
ORDER BY guest_id;

-- R2. The 10 hosts and how many properties each one owns
SELECT h.host_id, h.full_name, h.email, COUNT(p.property_id) AS properties_owned
FROM hosts h
LEFT JOIN properties p ON p.host_id = h.host_id
GROUP BY h.host_id, h.full_name, h.email
ORDER BY h.full_name;

-- R3. Property search: location + budget + free for 20-24 Dec 2026
SELECT p.property_id, p.title, p.location, p.price_per_night
FROM properties p
WHERE p.is_available = 'Y'
  AND p.price_per_night BETWEEN 40 AND 250
  AND NOT EXISTS (SELECT 1 FROM bookings b
                  WHERE b.property_id = p.property_id
                    AND b.status = 'CONFIRMED'
                    AND b.check_in_date  < DATE '2026-12-24'
                    AND b.check_out_date > DATE '2026-12-20')
ORDER BY p.price_per_night;

-- R4. Calendar availability check for ONE property and ONE date range
SELECT p.property_id, p.title,
       CASE WHEN p.is_available = 'N' THEN 'NOT AVAILABLE (host blocked)'
            WHEN COUNT(b.booking_id) > 0 THEN 'NOT AVAILABLE (dates taken)'
            ELSE 'AVAILABLE' END AS availability
FROM properties p
LEFT JOIN bookings b ON b.property_id = p.property_id
                    AND b.status = 'CONFIRMED'
                    AND b.check_in_date  < DATE '2026-12-20'
                    AND b.check_out_date > DATE '2026-12-18'
WHERE p.property_id = (SELECT property_id FROM bookings WHERE booking_id = 4)
GROUP BY p.property_id, p.title, p.is_available;

-- R5. Reservation status review: every booking with guest, property and payment
SELECT b.booking_id, g.full_name AS guest, p.title AS property, b.check_in_date, b.check_out_date,
       b.total_price, b.status AS booking_status, NVL(pay.payment_status, 'NO PAYMENT') AS payment_status
FROM bookings b
JOIN guests g      ON g.guest_id = b.guest_id
JOIN properties p  ON p.property_id = b.property_id
LEFT JOIN payments pay ON pay.booking_id = b.booking_id
ORDER BY b.booking_id;

-- R6. Host reviews pending requests
SELECT h.full_name AS host, b.booking_id, g.full_name AS guest, p.title,
       b.check_in_date, b.check_out_date, b.total_price
FROM bookings b
JOIN properties p ON p.property_id = b.property_id
JOIN hosts h      ON h.host_id = p.host_id
JOIN guests g     ON g.guest_id = b.guest_id
WHERE b.status = 'PENDING'
ORDER BY b.check_in_date;

-- R7. History monitoring (administrator): bookings and money per status
SELECT status, COUNT(*) AS bookings, SUM(total_price) AS total_value
FROM bookings
GROUP BY status
ORDER BY bookings DESC;

-- R8. Payments waiting for verification or failed
SELECT pay.payment_id, pay.booking_id, pay.amount, pay.payment_method,
       pay.transaction_ref, pay.payment_status, pay.payment_date
FROM payments pay
WHERE pay.payment_status IN ('PENDING','FAILED');

-- R9. Revenue per host (verified payments only)
SELECT h.full_name AS host, COUNT(*) AS paid_bookings, SUM(pay.amount) AS revenue_eur
FROM payments pay
JOIN bookings b   ON b.booking_id = pay.booking_id
JOIN properties p ON p.property_id = b.property_id
JOIN hosts h      ON h.host_id = p.host_id
WHERE pay.payment_status = 'VERIFIED'
GROUP BY h.full_name
ORDER BY revenue_eur DESC;

-- R10. Double-booking audit: two CONFIRMED bookings overlapping on one property (expected: no rows)
SELECT a.booking_id AS booking_a, b.booking_id AS booking_b, a.property_id
FROM bookings a
JOIN bookings b ON a.property_id = b.property_id
               AND a.booking_id < b.booking_id
               AND a.check_in_date < b.check_out_date
               AND b.check_in_date < a.check_out_date
WHERE a.status = 'CONFIRMED' AND b.status = 'CONFIRMED';

-- R11. Unread notifications per guest
SELECT g.full_name, COUNT(*) AS unread
FROM notifications n
JOIN guests g ON g.guest_id = n.recipient_id
WHERE n.recipient_type = 'GUEST' AND n.is_read = 'N'
GROUP BY g.full_name
ORDER BY unread DESC;

-- ============================================================
-- CREATE  (new records)  - one full booking lifecycle, booking #1001
-- ============================================================

-- C1. Guest registration
INSERT INTO guests (guest_id, full_name, email, phone_number, address)
VALUES (11, 'Demo Guest', 'demo.guest@mail-demo.com', '+250788000111', 'KN 5 Rd, Kigali, Rwanda');

-- C2. Booking request submission
INSERT INTO bookings (booking_id, guest_id, property_id, check_in_date, check_out_date, total_price, status)
SELECT 1001, 11, p.property_id, DATE '2027-06-10', DATE '2027-06-14', p.price_per_night * 4, 'PENDING'
FROM properties p
WHERE p.property_id = 912070346204926147
  AND p.is_available = 'Y'
  AND NOT EXISTS (SELECT 1 FROM bookings b
                  WHERE b.property_id = p.property_id
                    AND b.status = 'CONFIRMED'
                    AND b.check_in_date  < DATE '2027-06-14'
                    AND b.check_out_date > DATE '2027-06-10');

-- C3. Notification generation: the host is told about the request
INSERT INTO notifications (notification_id, recipient_id, recipient_type, notification_type, message)
SELECT seq_notification.NEXTVAL, p.host_id, 'HOST', 'BOOKING_REQUEST', 'New booking request #1001 for ' || p.title
FROM properties p WHERE p.property_id = 912070346204926147;

-- ============================================================
-- UPDATE  (modify existing records)
-- ============================================================

-- U1. Booking approval by the host
UPDATE bookings SET status = 'APPROVED' WHERE booking_id = 1001 AND status = 'PENDING';

INSERT INTO notifications (notification_id, recipient_id, recipient_type, notification_type, message)
VALUES (seq_notification.NEXTVAL, 11, 'GUEST', 'BOOKING_APPROVED', 'Booking #1001 was approved. Please complete the payment.');

-- C4. Payment record creation (guest pays)
INSERT INTO payments (payment_id, booking_id, amount, payment_method, transaction_ref, payment_status)
SELECT 1001, b.booking_id, b.total_price, 'BANK_TRANSFER', 'TXN-DEMO-1001', 'PENDING'
FROM bookings b WHERE b.booking_id = 1001;

-- U2. Payment status verification by the administrator
UPDATE payments SET payment_status = 'VERIFIED', admin_id = 3 WHERE payment_id = 1001;

-- U3. Reservation confirmation
UPDATE bookings SET status = 'CONFIRMED', admin_id = 3 WHERE booking_id = 1001;

INSERT INTO notifications (notification_id, recipient_id, recipient_type, notification_type, message)
VALUES (seq_notification.NEXTVAL, 11, 'GUEST', 'BOOKING_CONFIRMED', 'Booking #1001 is confirmed.');

-- Check: the dates of booking #1001 are now unavailable
SELECT booking_id, status, check_in_date, check_out_date FROM bookings WHERE booking_id = 1001;

COMMIT;

-- U4. Host rejects a pending request (undone with ROLLBACK)
UPDATE bookings SET status = 'REJECTED'
WHERE booking_id = (SELECT MIN(booking_id) FROM bookings
                    WHERE status = 'PENDING' AND check_in_date > DATE '2026-11-13');
SELECT booking_id, status FROM bookings WHERE status = 'REJECTED' ORDER BY booking_id;
ROLLBACK;

-- U5. Cancellation status update
UPDATE bookings SET status = 'CANCELLED', admin_id = 2 WHERE booking_id = 1001;

INSERT INTO notifications (notification_id, recipient_id, recipient_type, notification_type, message)
VALUES (seq_notification.NEXTVAL, 11, 'GUEST', 'BOOKING_CANCELLED', 'Booking #1001 was cancelled.');

-- U6. Host blocks and unblocks a property in the calendar
UPDATE properties SET is_available = 'N' WHERE property_id = 912070346204926147;
UPDATE properties SET is_available = 'Y' WHERE property_id = 912070346204926147;

COMMIT;

-- ============================================================
-- DELETE / ARCHIVE
-- ============================================================

-- Safely drop archive table if it exists to allow re-running this script
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE bookings_archive CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- D1. Archive completed or cancelled reservations
CREATE TABLE bookings_archive AS
  SELECT b.*, SYSDATE AS archived_on FROM bookings b WHERE 1 = 0;

INSERT INTO bookings_archive
SELECT b.*, SYSDATE FROM bookings b
WHERE b.status IN ('CONFIRMED','CANCELLED')
  AND b.check_out_date < DATE '2026-11-13';

SELECT booking_id, status, check_out_date, archived_on FROM bookings_archive ORDER BY booking_id;

-- D2. Purge expired temporary requests
DELETE FROM bookings
WHERE status = 'PENDING' AND check_in_date < DATE '2026-11-13';

-- D3. Remove the demo data (children first, then parents)
DELETE FROM notifications WHERE message LIKE '%#1001%' OR (recipient_id = 11 AND recipient_type = 'GUEST');
DELETE FROM payments WHERE booking_id = 1001;
DELETE FROM bookings WHERE booking_id = 1001;
DELETE FROM guests   WHERE guest_id = 11;

COMMIT;

-- Final check
SELECT status, COUNT(*) AS bookings FROM bookings GROUP BY status ORDER BY status;