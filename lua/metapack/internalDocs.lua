---@meta
---@diagnostic disable: duplicate-doc-field

---@class (exact) PackageData
---@field os string? The operating system to install the package for, so if it doesn't match the current os, it doesn't
---install the package
---@field execName string? optional executable name of the package
---@field portage boolean? if true, install using portage
---@field mason boolean? if true, install using mason
---@field pacman boolean? if true, install using pacman
---@field aur boolean? if true, install using an aur helper
---@field apt boolean? if true, install using apt
---@field nix boolean? if true, install using nix
---@field force boolean? if true, force install the package every time (useful for debugging)

---@class initModule the main init module
---@field _catagorizePackages function
---@field ensure_installed function
---@field _osData string
---@field _portagePackages string[]
---@field _masonPackages string[]
---@field _pacmanPackages string[]
---@field _aurPackages string[]
---@field _aurHelper string
---@field _aptPackages string[]

---@class UIOpts
---@field height integer?
---@field width integer?
