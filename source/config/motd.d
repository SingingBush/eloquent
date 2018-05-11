module eloquent.config.motd;

import std.stdio;
import ColourfulMoon;

void displayBanner() {
	auto cyan = Colour(80, 238, 238);
`
 ___________.__                                      __
 \_   _____/|  |   ____   ________ __   ____   _____/  |_
  |    __)_ |  |  /  _ \ / ____/  |  \_/ __ \ /    \   __\
  |        \|  |_(  <_> < <_|  |  |  /\  ___/|   |  \  |
 /_______  /|____/\____/ \__   |____/  \___  >___|  /__|
         \/                 |__|           \/     \/
`.Foreground(cyan).Reset.write;
}
