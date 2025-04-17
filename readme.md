Ever installed plugins using mason and thought "hmm. I wish I could just use
my system package manager for this too" Well say no more my dear cause
metapack.nvim is here!

[![YouTube Video](https://img.youtube.com/vi/3dRy8ad6oHM/0.jpg)](https://www.youtube.com/watch?v=3dRy8ad6oHM)

### What metapack.nvim is:
metapack.nvim isn't a plugin manager. It's a meta plugin manager. It doesn't
install the plugins directly. Instead, it first tries to use your system
package manager, if it can, then it tries to install it from that. And if it
doesn't, it tries to use mason as fallback

### Usage:
<details>
    <summary>Using <a href="https://github.com/folke/lazy.nvim">lazy.nvim</a>:</summary>

```lua
    {
        "ingenarel/metapack.nvim",
        dependencies = {
            {
                "williamboman/mason.nvim", -- will try to make this optional in future
                config = true,
            },
            {
                "ingenarel/smart-floatterm.nvim", -- terminal plugin that i made to use with my other plugins
                config = true,
            }
        },
        config = function()
            require("metapack").setup{
                ensure_installed = {
                    --lsp
                    "pyright", -- package could be string for simple use
                    "clangd",
                    {
                        "lua-language-server",
                        portage = true,
                        os = "gentoo"
                    }, -- or it could be a table specifying stuff,
                    {
                        "lua-language-server-git",
                        aur = true,
                        os = "arch",
                        exec = "lua-language-server"
                    }, -- you can use execName if the package name isn't the same as the executable name
                    "bash-language-server",
                    "termux-language-server",
                    "ltex-ls",
                    "yaml-language-server",
                    --lsp
                    --dap
                    { "codelldb", mason = true}, -- if you use table, it's not idiotproof, so if you name a plugin wrong, that's on you.
                    "debugpy",
                    --dap
                    --formatter
                    "black",
                    "stylua",
                    "clang-format",
                    "beautysh",
                    --formatter
                }
            }
        end,
    }
```
</details>

### Tips:

<details>
    <summary> Using doas </summary>

Metapack works with sudo when trying to interact with your package
manager. But it can also use doas.

```lua
    require("metapack").setup{
        ensure_installed =(
            {
                --packages
            },
            doas = true
        }
```

</details>

### UI:

![Main Menu](images/main-menu.png)
![Packages](images/package-menu.png)

NOTE: The images might not be the accurate representation of the current UI,
since it's heavily in development

There is currently a work in progress UI, you can call it in two different
ways:


Use the command:
```vim
    :Metapack
```
Or call the Lua function

```lua
    require("metapack.utils.ui.draw").showUI()
```

### Current package manager support:
- [ portage](https://wiki.gentoo.org/wiki/Portage)
- [ mason](https://github.com/williamboman/mason.nvim)
- [󰣇 pacman](https://wiki.archlinux.org/title/Pacman)
- [󰣇 paru](https://github.com/Morganamilo/paru)
- [󰣚 apt](https://en.wikipedia.org/wiki/APT_(software))

### GOALS:
<details>
    <summary> Implement these package managers:</summary>

- [ ] building from source
- [ ] cargo
- [ ] dnf
- [ ] luarocks
- [ ] npm
- [ ] pip
- [ ] scoop
- [x] apt
- [x] yay
- [x] pacman
- [x] paru

</details>

<details>
    <summary> Implement these features </summary>

- Specifying:
    - [ ] version
    - [ ] commit hash
    - [x] ~operating system / Linux distro~
    - [x] ~package manager~

- Features:
    - [ ] A logger for managing, cleaning, deleting and updating packages.
    - [ ] Work with gentoo USE flags
        some stuff in gentoo, like codelldb and clang-format, are not separate
        packages, but instead they are USE flags in the clang package

</details>

### TODOS:
- [ ] add cleanup functions
<!-- vim: set textwidth=78: -->
