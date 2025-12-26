# Secure MariaDB Infrastructure with High Availability (Master-Slave Replication)

![Platform](https://img.shields.io/badge/Platform-CentOS_Stream-blue)
![Database](https://img.shields.io/badge/MariaDB-10.5-orange)
![Security](https://img.shields.io/badge/Security-Hardened-red)
![Project Status](https://img.shields.io/badge/Status-Completed-success)

## 📌 Project Overview
This project demonstrates the design, deployment, and security hardening of a Linux-based MariaDB database environment. Designed to simulate a healthcare data scenario, the infrastructure prioritizes **Data Confidentiality, Integrity, and Availability (CIA)**.

Key achievements include implementing **Column-Level Encryption** for PII (Personally Identifiable Information), enforcing **Role-Based Access Control (RBAC)**, and establishing **Master-Slave Replication** for disaster recovery.

##

### 🎯 Key Objectives
* **Database Hardening:** Mitigating threats via OS and SQL configuration tuning.
* **Data Protection:** Implementation of AES-256 encryption for sensitive health records.
* **High Availability:** configuring asynchronous replication to ensure business continuity.
* **Network Security:** Implementing custom ports, firewall rich rules, and DMZ simulation.

---

## 🏗️ System Architecture
The environment consists of three Virtual Machines (VMs) simulating a segmented enterprise network.

| Machine Role | Hostname/IP | OS | Function |
| :--- | :--- | :--- | :--- |
| **Master Node** | `DB-Master` (192.168.120.128) | CentOS | Primary Write Server, Encrypted Data Store |
| **Slave Node** | `DB-Slave` (192.168.120.129) | CentOS | Read-Only Replica, Failover Target |
| **Web Client** | `Web-App` (192.168.120.130) | CentOS | Application Layer (Simulated DMZ) |

**Topology Diagram:**
> *[ 📂 Click here to view the System Architecture Diagram ](./images/architecture_diagram.png)*

---

## 🔒 Security Implementation (CIA Triad)

### 1. Confidentiality (Encryption & Access)
* **Data at Rest:** Critical columns (`patient_name`, `diagnosis`) are encrypted using `AES_ENCRYPT` with a private key.
* **Network:** Traffic restricted via **Firewalld Rich Rules**.
* **Access:** Least Privilege enforced. The Web App cannot decrypt data; only specific Analysts can.

### 2. Integrity (RBAC & Hardening)
* **Role-Based Access Control (RBAC):**
    * `db_admin`: Full Root Access (Local Only).
    * `app_analyst`: SELECT/INSERT privileges.
    * `slave_user`: Replication rights only.
* [cite_start]**Hardening:** Default port changed to `3307`, Version hidden, Root remote login disabled[cite: 54].

### 3. Availability (Redundancy)
* **Replication:** Asynchronous Master-Slave replication configured.
* **Backups:** Automated bash scripts for daily logical backups (`mysqldump`).

---

## ⚙️ Configuration Guide

### 🖥️ Master Server (192.168.120.144)
**File:** `/etc/my.cnf.d/server.cnf`

```ini
[mysqld]
# Network & Hardening
user = mysql
port = 3307                 # Custom Port (Security by Obscurity)
bind-address = 192.168.120.144
symbolic-links = 0
local-infile = 0            # Prevent local file injection

# Replication Settings
server-id = 1
log_bin = mysql-bin
binlog_format = ROW
expire_logs_days = 7
