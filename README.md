<p align="center">
    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Bash_Logo_Colored.svg/2560px-Bash_Logo_Colored.svg.png" align="center" width="150px">  <!-- Bash logo -->
</p>
<p align="center"><h1 align="center">DBMS-BASH: A Simple Bash Database Management System</h1></p>
<p align="center">
	<em>A basic database implemented in Bash for educational purposes.</em>
</p>
<p align="center">
	<img src="https://img.shields.io/github/license/philopateermansour/DBMS-Bash?style=default&logo=opensourceinitiative&logoColor=white&color=00ff00" alt="license">
	<img src="https://img.shields.io/github/last-commit/philopateermansour/DBMS-Bash?style=default&logo=git&logoColor=white&color=00ff00" alt="last-commit">
	<img src="https://img.shields.io/github/languages/top/philopateermansour/DBMS-Bash?style=default&color=00ff00" alt="repo-top-language">
	<img src="https://img.shields.io/github/languages/count/philopateermansour/DBMS-Bash?style=default&color=00ff00" alt="repo-language-count">
</p>


<br>

## 🔗 Table of Contents

- [📍 Overview](#-overview)
- [👾 Features](#-features)
- [🚀 Getting Started](#-getting-started)
  - [☑️ Prerequisites](#-prerequisites)
  - [⚙️ Installation](#-installation)
  - [🤖 Usage](#-usage)
- [⌨️ Commands](#-commands)
- [📂 Project Structure (for developers)](#-project-structure-for-developers)
- [📌 Project Roadmap](#-project-roadmap)
- [🔰 Contributing](#-contributing)
- [🎗 License](#-license)
- [🙌 Acknowledgments](#-acknowledgments)

---

## 📍 Overview

DBMS-Bash is a simplified database management system implemented entirely in Bash script. It's designed as a learning tool to illustrate basic database principles and operations.  While not suitable for production environments, it provides a practical way to explore database internals and Bash scripting.

---

## 👾 Features

- **Data Persistence:** Data is stored in text files for easy inspection and portability.
- **Core Operations:** Create, use, and delete databases and tables.
- **Data Manipulation:** Insert, select (with basic `WHERE` clauses), update, and delete records.
- **Command-Line Interface:**  Interact with the DBMS through a simple command-line interface.
- **Basic GUI:**  Provides a menu-driven interface for easier navigation and use. (Implemented using `dialog` or similar.)
- **Educational Focus:**  Clear implementation of core database concepts.

---

## 🚀 Getting Started


### ☑️ Prerequisites

- Bash (usually pre-installed on Linux/macOS)
- `dialog` (for the GUI - install with `sudo apt-get install dialog` on Debian/Ubuntu systems, or the equivalent for your distribution)


### ⚙️ Installation

1. Clone the repository: `git clone https://github.com/philopateermansour/DBMS-Bash`
2. Navigate to the directory: `cd DBMS-Bash`
3. Make the script executable: `chmod +x dbms.sh`

### 🤖 Usage

Run the DBMS: `./dbms.sh`



## 📂 Project Structure (for developers)
<pre>
DBMS-Bash/
├── bin/
│   └── dbms.sh                  (Main script - entry point for the DBMS)
├── databases/                     (Directory where database files are stored)
└── src/                           (Source code for various DBMS functions)
    ├── config.sh                 (Configuration settings)
    ├── database.gui.sh           (Functions for the GUI elements related to databases)
    ├── database.sh              (Functions for database operations)
    ├── table.gui.sh              (Functions for the GUI elements related to tables)
    ├── table.sh                 (Functions for table operations)
    └── validation.sh             (Input validation functions)
</pre>

---

## 📌 Project Roadmap

* Improve error handling and input validation.
* Add more complex query capabilities (e.g., joins).
* Support more data types.
* Enhance the GUI.


---

## 🔰 Contributing

Contributions are welcome! Please open an issue or submit a pull request.


---

## 🎗 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.  You should create a LICENSE file in the root of your project containing the MIT license text.


---

## 🙌 Acknowledgments

* Special thanks to Mahmoud Helmi ([@Ma7moudHelmi](https://github.com/Ma7moudHelmi))
