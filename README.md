# Explorer

![](https://i.imgur.com/WdrFY8N.png)
(red zone for illustration)

#### A map discovery system

Hides blips from the map until you've discovered the area.
Based on how the Singleplayer map hides blips.

## Configurations
Options can be changed in the `config.lua` file, they're commented there.
You should probably edit the config before using this.

## How does this work?
The map is divided into cells. The cells near the player get revealed.
The configured blips will be hidden or shown based on the state of the cell they're within.
Client KVPs are used to store revealed cells, so they're revealed when you re-join. (If enabled)

## Exports (client)
`exports.explorer:progress()`, returns a list containing {`Discovery Progress Percentage`, `Discovered Cells`, `Total Cells`}

## Contribution
You're welcome to contribute. 
Feedback and test results are also very much appreciated.

## Credits
Script by @glitchdetector
