---
-- InfoHandler.client.lua - Handling for blackboard GUI
--

local blackboard = workspace.Blackboard

blackboard.Board.SurfaceGui.VersionInfo.Info.Text = [[
(I) - Internal (i.e. you probably don't care)
(B) - Bug / Unintended behavior
(F) - Feature
(P) - Performance

<b>ATB 2022/10/05</b>
- Happy anniversary!
- (B) Fixed all known broken meshes
- (B) Fixed playlists
    - 10 songs from the original playlists have been reintroduced.
    - The rest are Roblox toolbox music.
- (B) Fixed unanchored cans in the noodle bar

<b>ATB 2021/11/27</b>
- NOTICE: This is (most likely) the final update for Fumofas on Roblox. Thank you for playing and making a wonderful community.
- Fumofas. Made w/ ♥ voided_etc & co. 2021
- A community project. Please read the credits.

* No works from the original game are being put in this game going forward. This means that existing characters are not being ported anymore.

- Added the Shinmyoumaru Noodle Bar (by Dthae)

<b>ATB 2021/11/18</b>
- (B) Fixed jittery door movement by moving all movement handling to the client
- (F) HeadNipah and headFX are now hidden from parts menus and should be attached automatically when choosing their respective dialogues.
- (I) Refactored item pickup to use CollectionService
- Seija and Kogasa's faces have been split into components.
    * Seija uses the same mouth style as Kogasa now, since her original smile is not unique enough to have its own style.
- Added a working piano

<b>ATB 2021/11/12</b>
- Added a new "Doll" model size which is 50% the size of the full size
- Added Shanghai. Her hair is by PoliticalCirno (see credits).
- (B) Fixed part selector viewports sinking input (causing them to not work on mobile)
- For mobile accessibility and clutter reasons, the character menu has been separated from the editor. Selecting characters from the new menu will open the editor automatically.
- (F) Custom characters are now split from the preset ones, using the tabs at the top of the character selector.
- (I) Various code quality and convention changes
- Separated Marisa's face into components
    * The colors are slightly off, but the new eye style introduced is recolorable.
- (F) The door is now rigid and can be opened/closed by clicking it (3s cooldown).

<b>ATB 2021/11/9</b>
- (F) Seats now adjust based on character size, and the chairs in the cafe are now less difficult to get into
- Straight Gradient and Curved Gradient eye styles have been replaced with remade versions

<b>ATB 2021/11/8</b>
- (IP) EyeShinePart has been removed. Decal.ZIndex is used in its place (-2 Instances/Player, incl. 1 joint, + performance benefits from no transparent parts with decals, see RDC 2018)
- Added Medicine
- The following shoe styles have been removed: Yukari, Yuuka, Rumia, Reimu, Elly, Nitori, Charlotte, Medicine, Tsukasa, Sakuya, Koishi, Mokou, Cirno, Aya.
    * They have been replaced with the "Base" style which is recolorable and resizable (but the sizing option cannot be changed).
- Re-unioned the path
- (I) Cleaned up sounds from base characters
- (F) Allow placing mugs on coasters
- (F) Sounds when placing mugs on things
- (F) Mugs face random directions when placed on things

<b>ATB 2021/11/7</b>
- (B) Fix selection for ears, etc. sticking when switching to a character without parts in that scope
- (I) Removed the AccessoryRootPart ObjectValue in favor of Model.PrimaryPart. Reduces Instance count.
- (B) Fixed HeadNipah not accepting empty face decal values & Rika failing schema check
- (B) Fixed Dropdown firing error with empty string on AllowNone (error when selecting Reimu in editor)
- Resnapped the entire front wall of the cafe to remove seams
- Windows changed to SmoothPlastic to prevent clipping of nametags and eye shine
- Various optimizations
    - Part optimization in blackboard (-1)
    - Removed textures from below floor pieces
    - Removed all unnecessary textures from trees (Loss of 8-16 textures per tree)
    - Left and right textures have been removed from small benches (Loss of 16 textures per small bench)
    - Parts optimization in benches (Loss of ~12 parts per bench)
    - Cheese changed from SpecialMesh to MeshPart (Loss of 6 instances)
    - Set collision fidelity of all shelf items to Box.
    - Removed random welds from macrons (-4 instances)
    - Removed all joints from Remilia doll (-many instances)
    - Adjusted collision fidelity of the cash register
    - Removed extra textures from the menus box (Loss of 12 textures)
    - Adjusted collision fidelity of the menus box
    - Removed extra textures from the exterior poster stand (Loss of 18 textures)
    - Set collision fidelity of spilled bottles to Box
- The character grid ("obby") has been removed.
- (I) Removed invisible region parts
- (I) Remove the SelectorFrame button functions
- Added Madotsuki

<b>ATB 2021/11/6</b>
- Split up Parsee's face into new eyes, eyebrows, and mouth styles
- (F) Changed part selectors to use viewports instead of text
- Fixed Marisa's pant legs being part of her shoes
- Fixed one of Rika's shoes having a leg attached to it for some reason
- Added Nue, Clownpiece
- Fixed the ladder sticking out
- (F) Moved the "Spawn As" and "Save" buttons to below the viewport and made them far less ugly
- Split Saki's tail from the rest of her outfit
- (F) Altered viewport's default scale and positioned the focal point at the center of the model vertically
- Tweaked positioning of the cafe interior posters
- (F) Restyled the slider component and use it in the music controller
- Fix formatting of the clock to be consistent (e.g. 13:00 PM -> 1:00 PM)
- Coffee cups are now welded to the machine based on attachments (so the bottom will always be on the surface instead of floating or inside)
- (B) Fixed liquid overflowing when changing size
- (I) Server now verifies options with set accepted values

<b>ATB 2021/11/5</b>
- (B) Fixed the dropdown menus being deleted on resetting character
- (F) Dropdown menus now close when clicking anything outside
- (F) Overhauled face editor to use paginated layout with icons instead of text
- Added Saki
- (B) Fixed non-FileMesh SpecialMeshes being scaled twice as much (i.e. Doremy's shoes)
- (F) Added zoom and rotate to the character preview in the editor (scroll to zoom, mouse 1 to rotate)

<b>ATB 2021/11/4</b>
- (F) The "Voice" and "Size" tab have been merged into "Misc," and the UI has been switched to dropdowns.
    * Other UI tweaks are currently in progress or pending. If the parts I haven't touched look worse, welcome to alpha!

<b>ATB 2021/11/3</b>
- (F) The tab UI has been switched to icons, and many icons have been unified under the same style.
- (B) SpecialMesh scaling has been added, so things like Koishi's buttons and Rika's tail now scale properly.
- Added Aya
- (F) Beginnings of the editor rework

<b>ATB 2021/11/2</b>
- (B) Fix Marisa's hair color
- (B) Fix issues with sideways script when switching model scale
- (B) Fixed the ladder
- (B) Fixed scaling of Shinmyoumaru's parts
- (I) Added more characters to queue and added Yuuma dialogue (not currently usable)
- (F) Add editor GUI for scripts on characters
- (F) Split per-part options into a different tab
- Added Rika + her dialogue (which has a customizable face)
- Added new style of Neco Arc face

<b>ATB 2021/11/1</b>
- (B) Fix error with mug on resetting character
- (B) Fix players getting assigned to default collision group on join
- (I) Refactored head dialogue. Please report any remaining issues with it.
- (I) Base scaling on ground truth instead of relative scale
- (I) Migrated many scripts to Rojo
- (B) Fixed behavior of region change prompt
- Added Miko, Youmu, Sideways Youmu
- (I) Added framework for per-part options
- (F) Added the ability to recolor hair
- Added outdoor paths, dumpster, shelf design, roof access - by RANDOMPOTATO & PoliticalCirno (see credits)
- (IB) Use WaitForChild more in mug handling code

<b>ATB 2021/10/31</b>
- (B) Fix daytime sync between clients and the server
- (B) Fixed issues with welding items on different size fumo
- (F) Mug item, working coffee maker
- Creamer carafe model (not functional yet)
- (B) Fix potential error with region changed text
- (B) Alter physical properties of large fumo
- (B) Fixed responsiveness of window UI when closing and opening windows quickly
- (B) Fixed the behavior of the music controller when entering and exiting regions repeatedly
- (B) Fix touch inputs not working in certain UI areas

<b>ATB 2021/10/27</b>
- (IB) Use attachment to create weld instead of storing weld in tool
- (B) Fix animation priorities of Walk and Idle
- (B) Fire animations for the menu item on the client instead of the server
- Further remove code from the Animate script
- More map stuff from RANDOMPOTATO (cafe door, coffee maker, hill design, blackboard)
- Removed click function of the version label and split changelog and credits
- (B) Made the version label a fixed size
- (F) Added a day/night cycle which can be controlled from the top right GUI. Supports stopping/changing time.

<b>ATB 2021/10/26</b>
- (IB) Fix dual propagation of appearance updates
- (B) Fix registering multiple CharacterAppearance and CustomPhysicalProperties errors
    - Falling into the void and changing character size no longer breaks
- (F) The backpack has been reenabled until a proper replacement is made
- (F) Menu has been made into an item, which opens a gui of the image when clicked
- (B) Remove collision of "head" head
- Added Shion, Futo, Nitori
- (B) Fix improperly scaled textures on large/small model sizes
- (B) Fix scripts cloning multiple times
- (IB) Avoid setting character multiple times

<b>ATB 2021/10/25</b>
- Enable sanity checks server-side to help ensure presets and models are proper
- Add aggressive logging to help diagnose errors
- Fixed CharacterAdded unbinding too early
- Properly teleport to spawn when clicking "Spawn As" while sitting
- Made poster frame lights more dim
- Music fades when changing
- Added region specific playlist for cafe
- Added popup when switching regions

<b>ATB 2021/10/24.2</b>
- Disable collision on Yuyuko hair
- Cash register moved into cafe folder
- Create folder structure cleanup
- Removed contributor notes - moved elsewhere (please inquire)
- Restructured info page
- Added sonanoka animation (/e sonanoka)
- Editor refactor
- Allow customization of dialogue and voice pitch (includes "head" !!!)
   - hint: select headFX under Torso Accessories
- (hopefully) Fixed chat bubbles sometimes not getting added to character
- Fixed edge cases with nametag height
- Clicking "Spawn As" no longer recreates the entire character, only the parts necessary. It still teleports you back to spawn.
- Added Elly, Sekibanki, Sakuya, Cirno, Tenshi, Suwako, Seija, Aunn, SBF Okuu (⑨)
- Removed exclusivity attributes on all parts
- Editor now has a color picker for changing eye color
- New face style: Toutetsu
- New decals + mug in cafe

<b>ATB 2021/10/24.1</b>
- Removed RumiaEX (upon request)
- Removed list of pending characters - moved elsewhere (please inquire)

<b>ATB 2021/10/23</b>
- Fixed anchoring in cafe walls
- Added Rumia, RumiaEX, Yuyuko, SBF Yuyuko
- Pressing the 0 key now toggles the entire gui
- Added an option to disable collision
- Fixed nametag and chat bubble height on big/small/tall characters
- Alphabetized the character list
- New map design from RANDOMPOTATO
- Rotated spawn
- Added a music player and basic overworld music. If you would like to see a song added or removed from the playlist (if it doesn't fit the theme) please tell me.
- Made the size of the side buttons fixed
- Added cash register model (you can open it)

<b>ATB 2021/10/22</b>
- Removed coloring support on some faces/eyes which should not be recolored (e.g. Kogasa face)
- Added Scatter and Neco Arc faces
- Moved into alpha, and switched version name to <b>A</b>lpha <b>T</b>est <b>B</b>uild. Place is no longer friend-only.
- Appearance checking is now <b>very</b> strict. You can no longer:
    - Remove your clothes or hair
    - Define any invalid keys in appearance data
    - Spawn with an exclusive dialogue or voicepitch
    - Define any random value for face data other than empty string.
    * The server will refuse to save or apply appearance data if it is invalid.
- Switched baseplate for a fumo styled one
- Added Chen, Satori, Alice
- Rearranged the grid of characters
- Delete dev assets on server start
- Added size customization
- Added a sit button and removed abbreviations for sidebar

<b>DEV 2021/10/21</b>
- Fixed ghost characters spawning whenever the player rejoins just after resetting
- It is no longer possible to set random decals for the face, assets are all listed explicitly now
- You explode on death (better)
- Added face customization

<b>DEV 2021/10/20</b>
- Fix error when pressing target button without any appearance loaded
- Added extra part to Reimu's torso clothing
- Reduced part count in cafe walls
- Removed the testing "Fallback" character
- Server now deletes appearances when the player leaves
- Updated all popup GUIs. Feedback needed.
- Added Mokou, BenBen, Parsee
- Soku & AY YO CATGIRL dialogue for Mokou
- Removed some lower priority characters from the workspace

<b>DEV 2021/10/19</b>
- Fixed height of couch model
- Updated all furniture
- Added bricks to the base of the cafe
- Changed the spawn location
- Set the default character to Reimu
- You explode on death
- Added a scuffed walking animation
- Moved character select to the edit menu
- Began restructuring editor code
- Added Yukari

<b>DEV 2021/10/18</b>
- Added sitting animation
- Added working new wooden chair design outside the cafe

<b>DEV 2021/10/17</b>
- Updated version scheme
- Added this info page
- Added the cafe prototype

<b>Day 8 / 20211016</b>
- Removed the AppearanceUpdated remote
- Remove AdjustHeightDynamicallyToLayout from legacy Roblox code
- Split editor button into a ModuleScript
- Make EditorHandler rely on appearance instead of character parts folder to determine active buttons
- Remove option to copy appearance in CharacterAppearance
- Avoid recreating all parts when changing appearance
- Avoid recreating the viewport character when updating appearance
- Create the parts lists for the editor only once
- Add name field to widget
- Add voice pitch and dialogue
- Remove graphemes limit on text boxes
- Added Miyoi, Charlotte, Yuuka, Kogasa, Reimu, Rei'sen, Marisa, Marisa (Old Hair), Nazrin
- UI color and layout tweaks

<b>Day 7 / 20211015</b>
- Moved the splitting of parts to the widget

<b>Day 6 / 20211013</b>
- Create a plugin widget for better management of plugin tools
- Moved the fix character option to the widget

<b>Day 5 / 20211012</b>
- Add a Cel Shading test script
- Bind server-side events to allow for uploading and spawning as certain appearances

<b>Day 4 / 20211009</b>
- Created the changelog
- Added idle animation
- Convert WeldTarget and Exclusivity to Attributes
- Split AppearanceStore from CreateModule
- Move save function to be per appearance and not per character
- Move findModelInfo function to ModelData
- Remove garbage from the Animation script
- Remove the StarterCharacter, pending replacement function

<b>The following versions have no changelog:</b>
Day 3 / 20211008
Day 2 / 20211007
Day 1 / 20211006
]]
