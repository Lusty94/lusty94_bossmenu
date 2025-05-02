![bossmenu](https://github.com/user-attachments/assets/64f1da96-42a5-47dc-97c8-10d9985a4b75)


## Script Support

- Script support is via Discord tickets for ``PAID`` resources ONLY: https://discord.gg/BJGFrThmA8
- Any tickets created for ``free`` scripts will be ``immediately closed``
- For ``free`` script support please use the ``gated channels``



## Features

- 🧑‍💼 Employee Management System with support for hiring, promoting/demoting, and firing employees using clean menus and proper distance checks.
- 📡 Works with both online and offline players using server callbacks and offline job record updates.
- 🧠 Dynamic context menus for selecting nearby players, setting ranks, and confirming job actions.
- 🏷️ Automatically displays employee job labels and rank names across all menus and confirmations.
- 📨 Integrated Messaging System allowing employees to send direct messages to their boss with optional boss replies.

``🛠️ Full Boss Menu with modular access control``
- View all employees with online status and job rank
- Hire new employees from nearby players
- Promote or demote existing employees with rank selection (online or offline)
- Fire employees (online or offline)
- Read and reply to incoming employee messages
- Deposit funds into the job bank account
- Access job stash storage if enabled (stashes are configurable with weight and slot limits per job)

``👨‍🔧 Employee Utilities (non boss grade employees)``
- Send messages to their boss
- View replies to their own messages
- Toggle duty on/off
- Change into job-specific clothing



## DEPENDENCIES

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [ox_lib](https://github.com/overextended/ox_lib/releases/)
- [oxmysql](https://github.com/overextended/oxmysql/releases)
- [qb-banking](https://github.com/qbcore-framework/qb-banking) or supported scripts
- [qb-target](https://github.com/qbcore-framework/qb-target) or [ox_target](https://github.com/overextended/ox_target/releases/)
- [qb-inventory](https://github.com/qbcore-framework/qb-inventory) or [ox_inventory](https://github.com/overextended/ox_inventory/releases/)




## INSTALLATION

- Ensure all dependencies are started before this script
- Import or run the provided sql file in [SQL] folder to your database for the messaging system
- Add / Remove jobs required in Config.Locations
- Configure locations for each management menu zone
- Define custom image urls for each job
- Configure the blips for each job
- Configure the job boss stash information
