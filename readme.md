<!-- vim: set textwidth=78: -->
Ever installed plugins using mason and thought "hmm. I wish I could just use
my system package manager for this too" Well say no more my dear cause
metapack.nvim is here!

### What metapack.nvim is:
metapack.nvim isn't a plugin manager. It's a meta plugin manager. It doesn't
install the plugins directly. Instead, it first tries to use your system
package manager, if it can, then it tries to install it from that. And if it
doesn't, it tries to use mason as fallback

### usage:
<details>
    <summary>Using <a href="https://github.com/folke/lazy.nvim">lazy.nvim</a>:</summary>

```lua
{
    "ingenarel/metapack.nvim",
    dependencies = {
        {
            "williamboman/mason.nvim",
            config = true,
        },
    },
    config = function()
        require("metapack").ensure_installed {
            --lsp
            "pyright",
            "clangd",
            "lua-language-server",
            "bash-language-server",
            "termux-language-server",
            "ltex-ls",
            "yaml-language-server",
            --lsp
            --dap
            "codelldb",
            "debugpy",
            --dap
            --formatter
            "black",
            "stylua",
            "clang-format",
            "beautysh",
            --formatter
        }
    end,
}
```
</details>

### current package manager support:
- [  portage](https://wiki.gentoo.org/wiki/Portage)
- [  mason](https://github.com/williamboman/mason.nvim)

### GOALS:
<details>
    <summary> implement these package managers:</summary>

- [ ] apt
- [ ] building from source
- [ ] cargo
- [ ] dnf
- [ ] luarocks
- [ ] npm
- [ ] pacman
- [ ] paru
- [ ] pip
- [ ] scoop
- [ ] yay

</details>

<details>
    <summary> implement these features </summary>

- specifying:
    - [ ] package manager
    - [ ] version
    - [ ] commit hash
    - [ ] operating system / Linux distro

- features:
    - [ ] work with gentoo USE flags
        some stuff in gentoo, like codelldb and clang-format, are not seperate
        packages, but instead they are USE flags in the clang package

</details>
