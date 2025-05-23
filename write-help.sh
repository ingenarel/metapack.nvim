#!/usr/bin/env bash

paraBreak="$(for ((i = 0; i < 78; i++)); do echo -n "="; done)"

#@formatter:off
echo "$(
        echo -e "*metapack.nvim.txt*\t\t\t     A Meta Package Manager For Neovim"
        echo -e "$paraBreak\n"
        sed -E "
            /<!--.+/d;
            s/### Usage.+/$paraBreak\nUsage\t\t\t\t\t\t\t   *metapack.nvim-usage*\n/I;
            s/### UI.+/$paraBreak\nUI\t\t\t\t\t\t\t      *metapack.nvim-ui*\n/I;
            s/### (.+)/$paraBreak\n\1\n/;
            /<\/?details>/d;
            s/.*<summary>\s*(.+)<\/summary>/\1 ~/;
            s/<a href=\".+\">(.+)<\/a>:/\1/;
            s/\`\`\`(.+)/>\1/;
            s/\`\`\`\s*/</
        " readme.md
        echo "vim:tw=78:ts=8:noet:ft=help:norl:"
    )"\
    > ./doc/metapack.nvim.txt

