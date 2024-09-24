# Updated TACACSGUI
Updated TACACSGUI  
For replacing instances that running on EOL Ubuntu 18.04 and nearly EOL Ubuntu 20.04.  
There is no update on the original repo since 2020.  
I really hope this will help you as well.

# DONATION
This work made me consume copious amount of coffee. If you want to help me then get me some more.  
[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buymeacoffee.com/vlab)

# DISCLAIMER
- I am _**NOT**_ a web developer.
- Ubuntu 18.04 is EOL and 20.04 is not far away. I needed this to work on a newer version so I tried my best.
- SUPPORT: Pretty much none, zip, nada, etc. No support is available private or otherwise.
- If you create an github issue, I _**MAY**_ look at this and attempt to fix it whenever I have free time.
- I will not accept any pull request that not actually for fixing broken functions. 

# Tested on

OS                                | PHP       | Python        | MySQL        | tac_plus
---                               | ---       | ---           | ---          | ---
Ubuntu Server 22.04 LTS STANDARD  | PHP8.3.11 | Python3.10.12 | MySQL 8.0.39 | tac_plus latest dl 2024-09
Ubuntu Server 24.04 LTS STANDARD  | PHP8.3.6  | Python3.12.3  | MySQL 8.0.39 | tac_plus latest dl 2024-09

:heavy_exclamation_mark::warning::heavy_exclamation_mark: NOT TESTED but will probably work on Debian 10 and 12 (very similar software repos)

# What does work (for me)
## tac_plus
PCRE2/CRYPTO/CURL/SSL

## WEB GUI - tac_plus:
- :white_check_mark: TACACS Global settings: OK
- :white_check_mark: TACACS Users: Create/Edit
- :white_check_mark: TACACS User Groups: Create/Edit
- :white_check_mark: TACACS Devices: Create/Edit
- :white_check_mark: TACACS Device Groups: Create/Edit
- :white_check_mark: TACACS Services: Create/Edit
- :white_check_mark: TACACS ACL: Create/Edit
- :white_check_mark: TACACS Objects: Addresses
- :white_check_mark: TACACS Objects: Command Sets
 

## WEB GUI - Admin:  
- :white_check_mark: TACACS GUI Users: Create/Edit
- :white_check_mark: DB Backup: Create/Delete/Download
- :white_check_mark: MAVIS: Local DB works, OTP works
- :white_check_mark: Settings: Time (with NTPSEC or NTP)
- :white_check_mark: Network: View (**I RECOMMEND YOU SET NETWORK VIA UBUNTU NETPLAN DIRECTLY**)
- :white_check_mark: Logging: seems ok
- :white_check_mark: Update: DISABLE

## WEG GUI - Configuration Manager:
:white_check_mark: Work OK but not sure if anyone uses it. Not too sure you should use it as well

:heavy_exclamation_mark::warning::heavy_exclamation_mark: THE REST WERE NOT TESTED!

## Added function
Added parser filter to keep the logs clean. The filters below happen _**BEFORE**_ logs ingestion.  
Various system has default auto system cmd that generate a lot of logs when a user is logged in.  
These filters give you ability to filter them out.

- You can edit the filters at 
```bash
# Accounting filter
/opt/tgui_data/parser/acc-filter.txt
# Authorisation filter
/opt/tgui_data/parser/autho-filter.txt
# Authentication filter
/opt/tgui_data/parser/authe-filter.txt
```

- Support format: simple regular expression. Example below
```bash
# Comment line starting with # is ok

# ^ Empty line like above will be ignored
# Simple regex to filter out automation host
robotuser.*192.168.1.10
robotuser.*control-node.lan
_ses_open$
bin.[a-z]{2,5}.*exit=.$
# DO NOT USE SELECTOR OR FORMAT
# >> THIS WILL NOT WORK: bin.[a-z]{2,5}\sexit=(0|1)$
# >> THIS WILL NOT WORK: bin.[a-z]{2,5}\sexit=\(0\|1\)$
```

# Installation
See my installer repo [tacacsgui-installation](https://github.com/ichantio/tacacsgui-installation/)  
I wrote a new one from scratch. Tested on both Ubuntu 22.04 and 24.04.

# Code status
- Released as 1.0.0
- See [CHANGELOGS](CHANGELOGS.md)

# License 
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)  
:heavy_exclamation_mark: Matching the original project.

# Author
:computer: [@me](https://github.com/ichantio)

# Original Author
- tac_plus: tacacs daemon by Marc Huber:  
https://projects.pro-bono-publico.de/event-driven-servers/doc/tac_plus.html
- TACACSGUI: Aleksey Mochalin  
https://tacacsgui.com/  
Original TACACS GUI Repo:  
https://github.com/tacacsgui/tacacsgui
