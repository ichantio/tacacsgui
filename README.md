# TACACSGUI
TACACSGUI - Updated for Newer OS

# DONATION
This work made me consume copious amount of coffee. If you want to help me then get me some more.  
[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buymeacoffee.com/vlab)

# DISCLAIMER
- I am NOT a web developer.
- I fumble through the code and fix what I can so it works on Ubuntu 22.04 with newer software packages.
- SUPPORT: None, zip, nada. No support is available private or otherwise.
- If you create an github issue, I **MAY** look at this and attempt to fix it whenever I have free time.

# Tested on
- Ubuntu Server 22.04 LTS Standard Installation
- PHP8.3
- Python3.10.12
- MySQL 8.0.39

# What does work (for me)
- tac_plus daemon with spawnd (LWRES has been deprecated by all platforms)
- WEB GUI - tac_plus:
  - TACACS User: Create/Edit
  - TACACS Devices: Create/Edit
  - TACACS Groups: Create/Edit
  - TACACS ACL: Create/Edit
  - TACACS Objects: Addresses

- WEB GUI Admin:  
  - TACACS GUI Users: Create/Edit
  - DB Backup: Create/Delete/Download
  - MAVIS: Local DB works
  - Settings: Time (with NTP)
  - Network: View (**I RECOMMEND YOU SET NETWORK VIA UBUNTU DIRECTLY**)
  - Logging: seems ok
  - Update: DISABLE

- THE REST WERE NOT TESTED!

# Installation
See repo tacacsgui installation https://github.com/ichantio/tacacsgui-installation/

# What did you change?
- Mostly so I can update the OS from Ubuntu 18 -> 22
- Fix stuffs that I use and were broken in the process
- Changed some codes so more references are local
- You can find all the original code before I made any modification in the  
[original_src](original_src/)  
folder. Diff to your heart's content.

# License 
GPL-3.0 license based on the original project.

# Original Author
- tac_plus: tacacs daemon by Marc Huber: https://projects.pro-bono-publico.de/event-driven-servers/doc/tac_plus.html
- TACACSGUI: Aleksey Mochalin https://tacacsgui.com/
- Original Repo: https://github.com/tacacsgui/tacacsgui
