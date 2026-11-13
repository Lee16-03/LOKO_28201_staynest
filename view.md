# LOKO_28201_staynest
# StayNest - Accommodation Booking and Reservation Management System

> StayNest is a modern web platform for advertising and booking rental properties such as houses, apartments, and short-term accommodations. The system automates the complete reservation lifecycle, from guest search to payment confirmation, while providing centralized management tools for hosts and administrators.


## About the Project

### Problem & Solution
* Problem: Manual and uncoordinated property rental processes lead to high risks of double bookings, delayed host-guest communication, inaccurate payment tracking, and a lack of reliable availability data.
* Solution: StayNest automates and secures reservations by incorporating real-time availability checks, a host approval workflow, and a streamlined payment and administrative verification pipeline.

### Key Innovations
* Pre-Payment Temporary Lock: Automatic date hold upon host approval during the payment window to prevent double bookings.
* Hybrid Payment Pipeline: Seamless handling of automated payment gateway webhooks alongside administrative manual verification.
* Dynamic Expiration Canceling: Automated timeout triggers that cancel stale pending requests if a host does not respond within a specified window.


## Actors and Responsibilities

| Actor | Primary Responsibilities |
| :--- | :--- |
| Guest | Searches properties, checks availability, submits booking requests, completes payments, and checks reservation status. |
| Host | Manages property listings, approves or rejects booking requests, and monitors availability calendars. |
| Administrator | Supervises platform activities, verifies manual payments, handles authorized cancellations, and generates reports. |
| Payment System | Processes secure financial transactions and returns payment status. |
| Notification System | Sends automated alerts (booking requests, approvals, rejections, payments, confirmations) to users. |
| Booking| see confirmation of booking; which property they book. |
| Property | how many properties someone has |


## Business Process Modeling (BPM)

The system architecture is grounded in a UML Activity Diagram with Swimlanes modeled using diagrams.net.

### Key Process Flow:
1. Search & Selection: The guest searches for accommodation and selects check-in and check-out dates.
2. Availability Check: The system checks real-time calendar availability and blocked dates.
3. Host Approval: The host receives a notification to approve or reject the request.
4. Payment Processing: The guest completes the payment (via automated gateway or payment proof submission).
5. Confirmation & Calendar Update: The system updates the booking to confirmed, blocks calendar dates, and issues notifications to all parties.


## Database Operations (CRUD Summary)

| Operation | Activities |
| :--- | :--- |
| CREATE | Guest registration, booking request submission, payment record creation, notification generation. |
| READ | Property search, calendar availability check, reservation status review, history monitoring. |
| UPDATE | Booking approval/rejection, payment status verification, availability calendar lock, cancellation status update. |
| DELETE / ARCHIVE | Archiving completed or canceled reservations, purging expired temporary requests. |


## Technical Modeling and Tools

* Modeling Tool: diagrams.net (StarUML)
* Modeling Technique: UML Activity Diagram with Swimlanes
* Process Documentation: Detailed specification files located under `docs/business_process/`


## Repository Structure

```text
.
├── docs/
│   └── business_process/
│       ├── business_process_explanation.pdf
│       └── staynest_activity_diagram.drawio
├── README.md
└── src/  # Application Source Code
