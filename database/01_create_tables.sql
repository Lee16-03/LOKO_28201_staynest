-- Drop tables in reverse order of dependencies safely
BEGIN EXECUTE IMMEDIATE 'DROP TABLE notifications CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE payments CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE bookings CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE properties CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE guests CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE hosts CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE administrators CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Drop sequences safely using dynamic SQL
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_admin'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_guest'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_booking'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_payment'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_notification'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Create Sequences for Auto-Incrementing IDs
CREATE SEQUENCE seq_admin START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE seq_guest START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE seq_booking START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE seq_payment START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE seq_notification START WITH 100 INCREMENT BY 1;

-- Class: Admin
CREATE TABLE administrators (
  admin_id      NUMBER(10) PRIMARY KEY,
  full_name     VARCHAR2(100 CHAR) NOT NULL,
  email         VARCHAR2(120 CHAR) NOT NULL,
  CONSTRAINT uq_admin_email UNIQUE (email)
);

-- Class: Host
CREATE TABLE hosts (
  host_id       NUMBER(20) PRIMARY KEY,
  full_name     VARCHAR2(100 CHAR) NOT NULL,
  email         VARCHAR2(120 CHAR) NOT NULL,
  phone_number  VARCHAR2(20 CHAR),
  CONSTRAINT uq_host_email UNIQUE (email)
);

-- Class: Guest
CREATE TABLE guests (
  guest_id      NUMBER(10) PRIMARY KEY,
  full_name     VARCHAR2(100 CHAR) NOT NULL,
  email         VARCHAR2(120 CHAR) NOT NULL,
  phone_number  VARCHAR2(20 CHAR),
  address       VARCHAR2(200 CHAR),
  CONSTRAINT uq_guest_email UNIQUE (email)
);

-- Class: Property  (Host 1 --- 1..* Property)
CREATE TABLE properties (
  property_id      NUMBER(20) PRIMARY KEY,
  host_id          NUMBER(20) NOT NULL,
  title            VARCHAR2(150 CHAR) NOT NULL,
  description      VARCHAR2(500 CHAR),
  location         VARCHAR2(100 CHAR) NOT NULL,
  price_per_night  NUMBER(10,2) NOT NULL,
  is_available     CHAR(1) DEFAULT 'Y' NOT NULL,
  CONSTRAINT fk_prop_host  FOREIGN KEY (host_id) REFERENCES hosts (host_id),
  CONSTRAINT ck_prop_price CHECK (price_per_night > 0),
  CONSTRAINT ck_prop_avail CHECK (is_available IN ('Y','N'))
);

-- Class: Booking
CREATE TABLE bookings (
  booking_id      NUMBER(10) PRIMARY KEY,
  guest_id        NUMBER(10) NOT NULL,
  property_id     NUMBER(20) NOT NULL,
  check_in_date   DATE NOT NULL,
  check_out_date  DATE NOT NULL,
  total_price     NUMBER(12,2) NOT NULL,
  status          VARCHAR2(12) DEFAULT 'PENDING' NOT NULL,
  admin_id        NUMBER(10),
  CONSTRAINT fk_book_guest FOREIGN KEY (guest_id)    REFERENCES guests (guest_id),
  CONSTRAINT fk_book_prop  FOREIGN KEY (property_id) REFERENCES properties (property_id),
  CONSTRAINT fk_book_admin FOREIGN KEY (admin_id)    REFERENCES administrators (admin_id),
  CONSTRAINT ck_book_dates CHECK (check_out_date > check_in_date),
  CONSTRAINT ck_book_total CHECK (total_price >= 0),
  CONSTRAINT ck_book_stat  CHECK (status IN ('PENDING','APPROVED','REJECTED','CONFIRMED','CANCELLED'))
);

-- Class: Payment
CREATE TABLE payments (
  payment_id       NUMBER(10) PRIMARY KEY,
  booking_id       NUMBER(10) NOT NULL,
  amount           NUMBER(12,2) NOT NULL,
  payment_method   VARCHAR2(20) NOT NULL,
  transaction_ref  VARCHAR2(30) NOT NULL,
  payment_status   VARCHAR2(10) DEFAULT 'PENDING' NOT NULL,
  payment_date     TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  admin_id         NUMBER(10),
  CONSTRAINT fk_pay_book   FOREIGN KEY (booking_id) REFERENCES bookings (booking_id),
  CONSTRAINT fk_pay_admin  FOREIGN KEY (admin_id)   REFERENCES administrators (admin_id),
  CONSTRAINT uq_pay_book   UNIQUE (booking_id),
  CONSTRAINT uq_pay_ref    UNIQUE (transaction_ref),
  CONSTRAINT ck_pay_amount CHECK (amount > 0),
  CONSTRAINT ck_pay_method CHECK (payment_method IN ('CARD','MOBILE_MONEY','BANK_TRANSFER')),
  CONSTRAINT ck_pay_status CHECK (payment_status IN ('PENDING','VERIFIED','FAILED'))
);

-- Class: Notification
CREATE TABLE notifications (
  notification_id    NUMBER(10) PRIMARY KEY,
  recipient_id       NUMBER(20) NOT NULL,
  recipient_type     VARCHAR2(10) NOT NULL,
  notification_type  VARCHAR2(20) NOT NULL,
  message            VARCHAR2(300 CHAR) NOT NULL,
  is_read            CHAR(1) DEFAULT 'N' NOT NULL,
  created_at         TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  CONSTRAINT ck_note_rtype CHECK (recipient_type IN ('GUEST','HOST','ADMIN')),
  CONSTRAINT ck_note_read  CHECK (is_read IN ('Y','N')),
  CONSTRAINT ck_note_type  CHECK (notification_type IN
    ('BOOKING_REQUEST','BOOKING_APPROVED','BOOKING_REJECTED','PAYMENT_PENDING',
     'PAYMENT_VERIFIED','PAYMENT_FAILED','BOOKING_CONFIRMED','BOOKING_CANCELLED'))
);

-- Indexes on foreign keys and frequent filters
CREATE INDEX ix_prop_host   ON properties (host_id);
CREATE INDEX ix_book_guest  ON bookings (guest_id);
CREATE INDEX ix_book_prop   ON bookings (property_id, check_in_date, check_out_date);
CREATE INDEX ix_book_status ON bookings (status);
CREATE INDEX ix_note_recip  ON notifications (recipient_type, recipient_id);

PROMPT All tables and sequences created successfully!