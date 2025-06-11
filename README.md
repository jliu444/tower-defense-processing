**Intro**

Period: 6  
Name: Jake Liu  
Project Title: Tower Defense

**Description**

This is my rendition of a tower defense game. Players will use cash earned from killing slimes in order to buy towers and build a strategy to defend the base against an onslaught of slimes. As the game progresses, the number of slimes and level of difficulty will increase as stronger slimes spawn. Try your best to survive for as many waves as you can\!

**Functionalities:**

* Random Map Initialization  
  * Random enemy spawn at the top or left of the map; base located at the opposite side  
  * A random path is generated between the enemy spawn and base  
* Currency System  
  * Cash can be used to buy towers or upgrade tower stats  
  * Players earns cash by killing slimes  
* Tower Shop  
  * An arsenal of towers that players can buy with cash  
    * Towers with better stats require more cash  
  * Window style \- use buttons to navigate the shop  
* Tower Placement  
  * Use the mouse to choose a location (snapped to an invisible grid) to place the tower after pressing the buy button  
  * A hologram shows the possible location for the tower  
    * Is tinted red if placing on an invalid location or insufficient cash  
* Waves  
  * A countdown tells the player when the next wave will come in  
  * Wave number is also displayed  
  * Increasing wave numbers lead to more difficulty (stronger slimes)  
* Health  
  * Base health and enemy health are visually displayed  
* Enemy Spawning  
* Enemy Movement  
  * Enemies will follow the path (colored brown)  
* Enemy Attacks \-Enemies do damage to the base  
* Tower Attacks \- Towers do damage to enemies  
* Display Tower Stats \-When the player clicks on a placed tower, an info box will display its stats  
* Upgrade Tower Stats \- Players can use cash to upgrade tower stats  
* Game Over Screen \- Once the player base reaches 0 health, the game is over and game stats will be displayed  
  


**UML Diagram**  
**![UML Diagram](UML.png)**  
**How does it work?**

When you press play, it will start you on wave 0, which does not have any mobs, allowing the player time to understand game mechanics and develop a winning strategy. Basic mobs will begin spawning at wave 1\. As the wave number increases, the difficulty level and variety of mobs will increase. Killing mobs will give the player currency, which the player can use to make upgrades or buy power ups. The goal is to keep the base safe for as long as possible and have fun\!  
The user interface is meant to be easy to understand and self-navigable. The action of the game itself takes place on the main interface. On the top left, the user can find the pause button; a timer is located on the top middle; the restart button is on the top right. The majority of helpful information and tools that the user can use to progress through the game can be found on the sidebar (on the right side). The sidebar shows base health. cash, wave number, and time until the next wave. The shop—consisting of a tower name, tower image, tower stats, and shop-navigating buttons—can be found under. After buying a tower, the user can use the cursor to place the tower on any grid of the map. The user can also click on existing towers to check the stats of that tower and upgrade it if desired.  
Each in-game function that can be applied by a button can also be applied by keyboard presses. The table below shows this key designation.

| Key | Function |
| :---- | :---- |
| P | Pause game |
| R | Restart game |
| Z | Upgrade tower |
| Left Arrow | See previous tower in shop |
| Right Arrow | See next tower in shop |
| Space | Buy tower |

**Functionalities**

* **Current Functionalities**  
  * Random Map Initialization  
  * Currency System  
  * Tower Shop  
  * Tower Placement  
  * Wave Countdown  
  * Health  
  * Enemy Spawning  
  * Enemy Movement  
  * Enemy Attacks  
  * Progression of Game Through Waves  
  * Tower Attacks  
  * Game Over Screen  
  * Display Tower Stats  
  * Upgrade Tower Stats  
  * Timer