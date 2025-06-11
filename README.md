# frudy-pets 🐾

A modular and extensible pet companion system for FiveM servers — built in Lua with a gameplay-first focus and clean, organized logic.

This system lets players own, manage, and interact with pets, with features like shops, animations, renaming, and a vet system. Designed to be lightweight, expandable, and easy to integrate.

> ⚠️ Originally developed for MC9 Gaming. This system was designed and built by me and has been adapted for independent use. No proprietary MC9 assets or systems are included.

---

## 🚀 Features

- 🐶 **Pet Ownership** — Players can buy, summon, and send pets home
- 📝 **Rename System** — Rename pets via UI
- 🧠 **Pet Behavior** — Pets follow, idle, and perform tricks
- 🎭 **Animation Support** — Custom pet-specific tricks and emotes
- 🧸 **Toy Shop** — Purchase pet toys (customizable)
- 🏥 **Vet System** — Revive and heal injured pets
- 🧩 **Modular Design** — Easily expand pet types, colors, and behavior
- 📱 **Future-Ready** — Can be adapted into a phone app or UI extension

---

## 🧱 Tech Stack

- **Lua** — Object-oriented structure for pet logic
- **QBCore** — Framework used for player handling
- **ox_lib** — UI (context menus, inputs)
- **mc9-core** — Organization library used for interaction system and callback helpers (private)
- **PolyZone** — Zone definitions (shop, vet, etc.)
- **oxmysql** — Server-side data storage

---

## 🧩 Dependencies

| Resource   | Purpose                                  |
|------------|------------------------------------------|
| `ox_lib`   | Context/input menus                      |
| `mc9-core` | Interaction system and utility wrappers  |
| `PolyZone` | Zone detection for interactions          |
| `oxmysql`  | SQL integration                          |

---

## 📦 Installation

1. Download or clone this repository into your `resources` folder.
2. Rename folder to `frudy-pets` (optional, but recommended).
3. Add `ensure frudy-pets` to your `server.cfg`.
4. Make sure the following dependencies are started before it:
   - `ox_lib`
   - `oxmysql`
   - `PolyZone`

---

## ⚙️ Configuration

Pet data and shop prices can be customized in the following files:

- `shared/petdata.lua` – Breeds, species, colors, animations
- `shared/prices.lua` – Token and cash prices per pet
- `shared/config.lua` – General configuration (health, thresholds, etc.)

---

## 🧠 Developer Notes

- The pet system uses a class-based `Pet` module on the client.
- Shops and renaming use `ox_lib` context menus for a clean UI.
- Animations are data-driven and can be added per pet in `petdata.lua`.
- All pet interactions are tied to the player's `citizenid`.

---

## 📸 Preview

_(Add a few GIFs or images of pets being spawned, renamed, or doing tricks here if desired)_

---

## 🔐 License

Feel free to fork or use with credit. Do not resell or redistribute as your own.

---

## 📄 Credits & Disclaimer

This system was originally created while working with **MC9 Gaming**. All logic, structure, and UI implementation in this repository were written by me (frudy), and this version has been adapted for open demonstration and personal development use.

No proprietary assets, private resources, or protected logic from **mc9-core** are distributed here. If you use this system, you will need to replace or recreate any internal MC9 dependencies.

