# VERSION: 1.0.0 - 2024-09-13 (Friday the 13th :sweat_smile:)
## Changes
- Release as 1.0.0 so you know it's clearly different on the GUI
- Fix/add various PHP codes logics and variables
- Fix/add various compatibilities for Ubuntu 22/24 and PHP 8.3
- Fix/add various bash scripts and python scripts
- Update with latest tac_plus package
- Update to use ntpsec (ntp basically got replaced with ntpsec from Ubuntu 24.04 or Debian 12)
- Update refereces from tacacsgui.com to local including disable update check for tacacsGUI from `tacacsgui.com` just in case something strange occurs.
- You can find all the original files before I made any modification in the [original_src](original_src/) folder. Diff until your heart's content.
## TODO:
- Replace adldap2 with something newer which will let the rest of the PHP packages upgrade as well
- Upgrade tac_plus to tac_plus-ng. The problem with this is major rework of the PHP code. I am _**NOT**_ a web developer. Will see...