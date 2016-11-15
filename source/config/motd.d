module eloquent.config.motd;

import consoled : writec, Fg;

void displayBanner() {
	writec(Fg.cyan, `
 ___________.__                                      __
 \_   _____/|  |   ____   ________ __   ____   _____/  |_
  |    __)_ |  |  /  _ \ / ____/  |  \_/ __ \ /    \   __\
  |        \|  |_(  <_> < <_|  |  |  /\  ___/|   |  \  |
 /_______  /|____/\____/ \__   |____/  \___  >___|  /__|
         \/                 |__|           \/     \/
`, Fg.initial, "\n");
}
